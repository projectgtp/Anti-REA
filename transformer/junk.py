#!/usr/bin/env python3
"""Anti-REA v1.0 — L15 anti-decompile junk (invalid-UTF traps).

EXPERIMENTAL, OPT-IN ONLY. Off by default; see docs/L15-JUNK-TRAPS.md
before enabling it on anything. A bad trap can break the app itself,
and this pass has NEVER been device-tested.

What it does
------------
Plants strings containing byte sequences that are *invalid UTF-8*
(lone surrogates, overlong encodings) into a COPY of dex string data
or into smali text, in the hope that a naive decompiler — one that
decodes every string in the file with a strict UTF-8 decoder instead
of DEX Modified UTF-8 — throws or crashes while reading them, while
ART (which reads Modified UTF-8 and tolerates / never touches these
particular strings) keeps running.

What it deliberately does NOT do
---------------------------------
* It NEVER rewrites a live string. Both plant functions only APPEND
  new, decoy entries to the end of the input: new const-string lines
  inside a brand-new decoy class (smali), or new string_data_item
  entries appended to a copy of a string-data blob (dex). Every byte
  of the input is a prefix of the output, byte for byte. A live
  string the app itself reads must never contain a trap, because ART
  behaviour on invalid Modified UTF-8 in a *used* string is exactly
  the untested risk this layer carries.
* It does NOT rebuild a real .dex file. ``plant_traps_in_dex_bytes``
  works on a COPY of string data (a blob of string_data_item
  entries). Splicing new entries into a real dex means rebuilding
  string_ids / string_data offsets, which this module does not do.
  That integration step is unbuilt — one more reason L15 stays
  experimental.
* It is NOT wired into ``anti-rea.py protect``. The only wiring is
  the two ``apply_*`` gate wrappers below: they return the input
  unchanged unless the config explicitly enables the flag. A caller
  that wants L15 must call them deliberately.

Trap kinds (raw Modified-UTF-8 bytes as stored in a dex string)
---------------------------------------------------------------
* lone-high-surrogate — U+D800, MUTF-8 ``ED A0 80``. A lone high
  surrogate is illegal in UTF-8, so a strict UTF-8 decoder rejects
  it. Expressible in smali as ``\\uD800``.
* lone-low-surrogate — U+DC00, MUTF-8 ``ED B0 80``. Same idea, low
  half. Smali: ``\\uDC00``.
* overlong-slash — U+002F encoded as the overlong 2-byte sequence
  ``C0 AF`` instead of ``2F``. Valid MUTF-8 never uses overlong
  forms (except ``C0 80`` for NUL); strict UTF-8 decoders reject
  them. NOT expressible as a smali ``\\u`` escape — dex bytes only.
* overlong-nul-3byte — U+0000 as the overlong 3-byte ``E0 80 80``.
  The legal MUTF-8 NUL is ``C0 80``; this 3-byte form is invalid.
  Dex bytes only.
* overlong-del — U+007F as overlong 2-byte ``C1 BF``. Dex bytes only.

Each trap string is ``antirea-junk:<kind>:<trap bytes>:end`` — an
ASCII marker around the trap bytes, so a trap is identifiable in a
hex dump and so ``verify_planted`` can prove a trap exists ONLY
where the report claims it does.

Config gate
-----------
``experimental: {junk_traps: true}`` in the config file (see
``transformer/config.py::junk_traps_enabled``). Default OFF: absent,
false, or any falsy value means OFF. This flag is deliberately
SEPARATE from ``layers.enable`` — ``L15`` in ``layers.enable`` still
raises ConfigError because L15 is PLANNED in layers/REGISTRY.md
until the parent merges it. The flag only arms this module's own
``apply_*`` wrappers; it changes nothing in the CLI by itself.

Stdlib only.
"""
import re

# ---------------------------------------------------------------- traps

# kind -> {mutf8: raw trap bytes, smali_escape: \\uXXXX or None,
#           utf16_units: UTF-16 code units the trap sequence counts as,
#           description: plain words}
TRAP_KINDS = {
    "lone-high-surrogate": {
        "mutf8": b"\xed\xa0\x80",
        "smali_escape": "\\uD800",
        "utf16_units": 1,
        "description": "lone high surrogate U+D800 (MUTF-8 ED A0 80)",
    },
    "lone-low-surrogate": {
        "mutf8": b"\xed\xb0\x80",
        "smali_escape": "\\uDC00",
        "utf16_units": 1,
        "description": "lone low surrogate U+DC00 (MUTF-8 ED B0 80)",
    },
    "overlong-slash": {
        "mutf8": b"\xc0\xaf",
        "smali_escape": None,
        "utf16_units": 1,
        "description": "overlong 2-byte encoding of U+002F (C0 AF)",
    },
    "overlong-nul-3byte": {
        "mutf8": b"\xe0\x80\x80",
        "smali_escape": None,
        "utf16_units": 1,
        "description": "overlong 3-byte encoding of U+0000 (E0 80 80)",
    },
    "overlong-del": {
        "mutf8": b"\xc1\xbf",
        "smali_escape": None,
        "utf16_units": 1,
        "description": "overlong 2-byte encoding of U+007F (C1 BF)",
    },
}

# Kinds that can be written as a smali const-string (have a \u escape).
SMALI_KINDS = [k for k, v in TRAP_KINDS.items()
               if v["smali_escape"] is not None]

MARKER_PREFIX = b"antirea-junk:"
MARKER_SUFFIX = b":end"
DECOY_CLASS = "com/antirea/junk/JunkTraps"
DECOY_CLASS_MARKER = ".class public L%s;" % DECOY_CLASS


def trap_kinds():
    """All trap kind names, in deterministic definition order."""
    return list(TRAP_KINDS)


def smali_kinds():
    """Trap kinds expressible in smali (lone surrogates only)."""
    return list(SMALI_KINDS)


def trap_mutf8_bytes(kind):
    """Raw trap bytes for a kind. Raises ValueError for unknown kinds."""
    try:
        return TRAP_KINDS[kind]["mutf8"]
    except KeyError:
        raise ValueError(
            "Anti-REA L15: unknown trap kind %r (want one of %s)"
            % (kind, ", ".join(TRAP_KINDS)))


def _uleb128(n):
    """Encode a non-negative int as unsigned LEB128 bytes."""
    if n < 0:
        raise ValueError("uleb128 of negative %r" % (n,))
    out = bytearray()
    while True:
        b = n & 0x7F
        n >>= 7
        if n:
            out.append(b | 0x80)
        else:
            out.append(b)
            return bytes(out)


def make_trap_string_data(kind):
    """Build one complete dex string_data_item body for a trap kind.

    Layout: uleb128(utf16_size) + MUTF-8 bytes + 0x00 terminator.
    The MUTF-8 bytes are MARKER_PREFIX + kind + b":" + trap bytes +
    MARKER_SUFFIX. utf16_size counts the ASCII marker as its own
    length plus the trap sequence as ``utf16_units`` code units (a
    lone surrogate is one UTF-16 unit; an overlong sequence decodes
    leniently to one unit). Strict readers reject the bytes before
    trusting the size — that is the point of the trap.
    Returns bytes. Raises ValueError for an unknown kind.
    """
    spec = TRAP_KINDS.get(kind)
    if spec is None:
        raise ValueError(
            "Anti-REA L15: unknown trap kind %r (want one of %s)"
            % (kind, ", ".join(TRAP_KINDS)))
    prefix = MARKER_PREFIX + kind.encode("ascii") + b":"
    body = prefix + spec["mutf8"] + MARKER_SUFFIX
    utf16_size = len(prefix) + spec["utf16_units"] + len(MARKER_SUFFIX)
    return _uleb128(utf16_size) + body + b"\x00"


# ---------------------------------------------------------------- gate

def is_enabled(cfg):
    """True only if cfg has experimental.junk_traps set truthy.

    cfg is a parsed config dict (see transformer/config.py). Absent
    ``experimental`` section, absent key, False, 0, None, "" all mean
    OFF. This mirrors config.junk_traps_enabled; both read the same
    key so they cannot disagree.
    """
    if not isinstance(cfg, dict):
        return False
    exp = cfg.get("experimental") or {}
    if not isinstance(exp, dict):
        return False
    return bool(exp.get("junk_traps", False))


# ---------------------------------------------------------------- smali

_SMALI_DECOY_TEMPLATE = (
    "\n"
    "# Anti-REA L15 EXPERIMENTAL decoy — invalid-UTF trap strings.\n"
    "# NEVER enable on a shipping build without device proof: a bad\n"
    "# trap can break the app itself (see docs/L15-JUNK-TRAPS.md).\n"
    "# These strings are decoys only: no live code ever reads them.\n"
    ".class public L%s;\n"
    ".super Ljava/lang/Object;\n"
    "\n"
    ".method public constructor <init>()V\n"
    "    .locals 1\n"
    "    invoke-direct {p0}, Ljava/lang/Object;-><init>()V\n"
    "    return-void\n"
    ".end method\n"
    "\n"
    ".method public static junkTraps()V\n"
    "    .locals 1\n"
    "%s"
    "    return-void\n"
    ".end method\n"
)

_CONST_STRING_LINE = '    const-string v0, "antirea-junk:%s:%s:end"\n'


def plant_traps_in_smali(text, kinds=None, count=None):
    """Append L15 trap const-strings to smali text. Returns
    (new_text, report).

    A new decoy class ``com/antirea/junk/JunkTraps`` with one
    ``const-string`` per trap is appended at the end. NO existing
    line is touched: ``new_text`` starts with ``text`` verbatim, so
    every live const-string keeps its exact value. Only kinds with a
    smali ``\\u`` escape can be planted here (lone surrogates);
    overlong kinds raise ValueError — use the dex-bytes pass for
    those. Raises ValueError if the decoy class is already present
    (never plant twice) or if ``kinds`` names an unknown kind.
    ``count`` caps how many traps are planted (default: one per
    requested kind, cycling kinds in order if count exceeds them).
    Each report entry: {"surface": "smali", "kind", "line_no"
    (1-based line of the const-string in new_text), "line" (the
    exact line text), "smali_escape"}.
    """
    if kinds is None:
        kinds = SMALI_KINDS
    kinds = list(kinds)
    for kind in kinds:
        if kind not in TRAP_KINDS:
            raise ValueError(
                "Anti-REA L15: unknown trap kind %r (want one of %s)"
                % (kind, ", ".join(TRAP_KINDS)))
        if TRAP_KINDS[kind]["smali_escape"] is None:
            raise ValueError(
                "Anti-REA L15: trap kind %r has no smali escape "
                "(overlong sequences exist only at raw dex-byte level); "
                "use plant_traps_in_dex_bytes for it" % kind)
    if DECOY_CLASS_MARKER in text:
        raise ValueError(
            "Anti-REA L15: decoy class %s already present — refusing "
            "to plant twice" % DECOY_CLASS)
    if count is None:
        count = len(kinds)
    if count < 0:
        raise ValueError("Anti-REA L15: count must be >= 0")
    chosen = [kinds[i % len(kinds)] for i in range(count)] if kinds else []
    lines = []
    for kind in chosen:
        lines.append(_CONST_STRING_LINE % (
            kind, TRAP_KINDS[kind]["smali_escape"]))
    base = text if text.endswith("\n") or text == "" else text + "\n"
    decoy = _SMALI_DECOY_TEMPLATE % (DECOY_CLASS, "".join(lines))
    new_text = base + decoy
    new_lines = new_text.splitlines()
    report = []
    for i, line in enumerate(new_lines):
        m = re.match(
            r'^\s*const-string v0, "antirea-junk:([^:]+):(\\u[0-9A-Fa-f]{4}):end"$',
            line)
        if m and m.group(1) in chosen:
            report.append({"surface": "smali",
                           "kind": m.group(1),
                           "line_no": i + 1,
                           "line": line,
                           "smali_escape": m.group(2)})
    if len(report) != len(chosen):
        raise RuntimeError(
            "Anti-REA L15: internal error — planted %d traps but "
            "found %d in output" % (len(chosen), len(report)))
    return new_text, report


# ---------------------------------------------------------------- dex bytes

def plant_traps_in_dex_bytes(data, kinds=None, count=None):
    """Append L15 trap string_data_item entries to a COPY of dex
    string data. Returns (new_bytes, report).

    ``data`` is a bytes blob of string_data_item entries (a copy of
    a dex string pool, NOT a whole .dex file). New entries are
    appended at the end; ``new_bytes`` starts with ``data`` verbatim,
    so every existing string is untouched. Each report entry:
    {"surface": "dex", "kind", "offset" (byte offset of the entry in
    new_bytes), "length" (entry byte length), "hex" (entry hex)}.
    ``count`` caps how many traps are planted (default: one per
    requested kind, cycling if count exceeds them). Raises
    ValueError for unknown kinds or negative count, TypeError if
    ``data`` is not bytes.
    """
    if not isinstance(data, (bytes, bytearray)):
        raise TypeError("Anti-REA L15: dex string data must be bytes")
    data = bytes(data)
    if kinds is None:
        kinds = list(TRAP_KINDS)
    kinds = list(kinds)
    for kind in kinds:
        if kind not in TRAP_KINDS:
            raise ValueError(
                "Anti-REA L15: unknown trap kind %r (want one of %s)"
                % (kind, ", ".join(TRAP_KINDS)))
    if count is None:
        count = len(kinds)
    if count < 0:
        raise ValueError("Anti-REA L15: count must be >= 0")
    chosen = [kinds[i % len(kinds)] for i in range(count)] if kinds else []
    out = bytearray(data)
    report = []
    for kind in chosen:
        entry = make_trap_string_data(kind)
        offset = len(out)
        out += entry
        report.append({"surface": "dex",
                       "kind": kind,
                       "offset": offset,
                       "length": len(entry),
                       "hex": entry.hex()})
    return bytes(out), report


# ---------------------------------------------------------------- verify

def verify_planted(output, report, surface):
    """Prove traps exist ONLY where ``report`` claims.

    For "smali": ``output`` is text; every report entry's exact
    ``line`` must sit at its 1-based ``line_no``, and the total count
    of each trap's smali escape in the whole text must equal the
    number of report entries for that kind (no trap anywhere else).
    For "dex": ``output`` is bytes; the bytes at each entry's
    ``offset`` must equal its ``hex``, and the total count of each
    trap's raw MUTF-8 bytes in the whole blob must equal the number
    of report entries for that kind.
    Returns True on success; raises ValueError with a precise reason
    on any mismatch. An empty report verifies only if the output
    contains no trap bytes/escapes at all.
    """
    if surface == "smali":
        lines = output.splitlines()
        for entry in report:
            if entry.get("surface") != "smali":
                raise ValueError(
                    "Anti-REA L15: report entry surface %r is not smali"
                    % (entry.get("surface"),))
            ln = entry["line_no"]
            if ln < 1 or ln > len(lines) or lines[ln - 1] != entry["line"]:
                raise ValueError(
                    "Anti-REA L15: smali trap %r not at claimed line %d"
                    % (entry.get("kind"), ln))
        for kind in TRAP_KINDS:
            esc = TRAP_KINDS[kind]["smali_escape"]
            if esc is None:
                continue
            want = sum(1 for e in report if e.get("kind") == kind)
            got = output.count(esc)
            if got != want:
                raise ValueError(
                    "Anti-REA L15: smali escape %s appears %d times, "
                    "report claims %d" % (esc, got, want))
        return True
    if surface == "dex":
        for entry in report:
            if entry.get("surface") != "dex":
                raise ValueError(
                    "Anti-REA L15: report entry surface %r is not dex"
                    % (entry.get("surface"),))
            off, want = entry["offset"], bytes.fromhex(entry["hex"])
            if output[off:off + len(want)] != want:
                raise ValueError(
                    "Anti-REA L15: dex trap %r not at claimed offset %d"
                    % (entry.get("kind"), off))
        for kind, spec in TRAP_KINDS.items():
            want = sum(1 for e in report if e.get("kind") == kind)
            got = output.count(spec["mutf8"])
            if got != want:
                raise ValueError(
                    "Anti-REA L15: dex trap bytes %s appear %d times, "
                    "report claims %d"
                    % (spec["mutf8"].hex(), got, want))
        return True
    raise ValueError("Anti-REA L15: unknown surface %r" % (surface,))


# ---------------------------------------------------------------- gated wrappers

def apply_junk_traps_to_smali(text, cfg, kinds=None, count=None):
    """Flag-gated smali pass. Flag OFF (default) returns
    (text, []) — input byte-identical, nothing planted. Flag ON
    (experimental.junk_traps: true) plants via
    plant_traps_in_smali. This is the ONLY entry point a caller
    should use; it never plants unless the config enables it."""
    if not is_enabled(cfg):
        return text, []
    return plant_traps_in_smali(text, kinds=kinds, count=count)


def apply_junk_traps_to_dex_bytes(data, cfg, kinds=None, count=None):
    """Flag-gated dex-bytes pass. Flag OFF (default) returns
    (data, []) — input byte-identical, nothing planted. Flag ON
    plants via plant_traps_in_dex_bytes."""
    if not is_enabled(cfg):
        return data, []
    return plant_traps_in_dex_bytes(data, kinds=kinds, count=count)

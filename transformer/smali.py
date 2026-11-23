#!/usr/bin/env python3
"""Anti-REA v1.0 — smali-level transforms (stdlib only).

L01 smali-string-encrypt: every `const-string` whose value equals a
configured exact needle (or matches a configured regex pattern) is
replaced by an encrypted blob + a ReaRuntime.decrypt() call. The plain
value never appears in the rebuilt APK.

Smali replacement, for original `const-string vN, "needle"`:
    const-string vT0, "<blob_b64>"
    const-string vT1, "<key_part1_b64>"
    const-string vT2, "<key_part2_b64>"
    sget-object vT3, Lcom/appcore/runtime/ReaRuntime;->INSTANCE:Lcom/appcore/runtime/ReaRuntime;
    invoke-virtual {vT3, vT0, vT1, vT2}, Lcom/appcore/runtime/ReaRuntime;->decrypt(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object vN
vT0..vT3 are fresh registers obtained by bumping `.locals` by 4. The
INSTANCE form is used deliberately so the call works whether or not
decrypt() is @JvmStatic. If a method has no `.locals` directive
(it uses `.registers`), it is SKIPPED and recorded — never silently
rewritten with a wrong register layout.

L14 strip-debug-lines: `.line` directives are removed from protected
smali files (they only help a decompiler map code to source lines).

HIGH-REGISTER FIXUP (the `.locals` bump problem): bumping `.locals`
shifts every `p` register up (pN == v(locals + N)). Original code in
the same method that references a parameter in a NIBBLE-limited
instruction — plain `invoke-*` (35c), `move*` / `/2addr` / unary
(12x), iget/iput field ops / instance-of / new-array (22c),
`*-lit16` (22s), two-register branches (22t), and `const/4` (11n)
only encode v0–v15 — then breaks the build (e.g. p1 became v20 in
BridgeConfig$Companion.serverUrlError, and `iput p1` broke
ArrayDeque.retainAll after L55 chunking bumped .locals 11->15).
Static field ops are NOT in that list: sget/sput are format 21c
(ONE 8-bit register + 16-bit field ref), so v0–v255 is legal and
they need no fixup — an earlier version of this file wrongly
treated them as 22c, which pointlessly rewrote valid
`sget-object p3` (testapp EncodeOutputStream) and aborted the
Bridge 2.14.0 protect on the perfectly legal `sget-object v18`
(SessionActivity.refresh(), .locals 25).
`_fixup_high_regs` runs after every transform and rewrites EVERY
nibble-limited form: invokes become `/range` with arguments copied
into temp registers via `move/16` / `move-object/16` / `move-wide/16`
(typed from the callee descriptor), `move*` becomes `move*/16`,
`/2addr` becomes its 23x form, and 22c/22s/22t/12x instructions are
rewritten by copying each high parameter through a temp (type from
the opcode, the field, or the method descriptor) and copying results
back afterwards. (22s `*-lit16` ops were wrongly listed as 8-bit
until 2026-11-23 — smali rejects `and-int/lit16` above v15 — and
the Bridge rebuild died on one in AdminAttentionItem.copy$default.) When the transform's own bump leaves too little
temp room (e.g. a 5-register invoke with only 4 bump slots), the
fixup GROWS .locals for that method and re-scans, because growing
shifts p-registers up again — capped at 255 locals. It raises
loudly only when a method genuinely cannot be fixed (locals would
exceed 255, a parameter the descriptor cannot account for, a high
v-register, or an unknown nibble-limited form) instead of shipping
a broken APK.

Decoys / maze (L03, L52, L53): generated smali classes under
com/appcore/cache/ with plausible names and fake secret-looking
strings. They are TRAPS in the honest sense: the strings are fake
(honeypot values from the config), using them triggers a server-side
tripwire (see docs/TRAPS.md), and the classes do nothing useful.
"""
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from config import derive_needles  # noqa: E402
from crypto import encrypt_payload  # noqa: E402

CONST_RE = re.compile(
    r'^(\s*)const-string(?:/jumbo)?\s+([vp]\d+),\s*"((?:[^"\\]|\\.)*)"\s*$')
LOCALS_RE = re.compile(r"^(\s*)\.locals\s+(\d+)\s*$")
LINE_RE = re.compile(r"^\s*\.line\s+\d+\s*$")
METHOD_RE = re.compile(r"^\s*\.method\s+")
END_METHOD_RE = re.compile(r"^\s*\.end method\s*$")

RUNTIME_CLASS = "Lcom/appcore/runtime/ReaRuntime;"


def unescape_smali(s):
    out, i = [], 0
    while i < len(s):
        c = s[i]
        if c == "\\" and i + 1 < len(s):
            n = s[i + 1]
            if n == "n":
                out.append("\n")
                i += 2
            elif n == "t":
                out.append("\t")
                i += 2
            elif n == "r":
                out.append("\r")
                i += 2
            elif n == '"':
                out.append('"')
                i += 2
            elif n == "\\":
                out.append("\\")
                i += 2
            elif n == "u" and i + 5 < len(s):
                try:
                    out.append(chr(int(s[i + 2:i + 6], 16)))
                except ValueError:
                    out.append(s[i:i + 6])
                i += 6
            else:
                out.append(n)
                i += 2
        else:
            out.append(c)
            i += 1
    return "".join(out)


def escape_smali(s):
    return (s.replace("\\", "\\\\").replace('"', '\\"')
             .replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r"))


# --- needle matching: derivation + host case-insensitivity -----------
#
# Two slip-throughs of the same kind as the Bridge bare-domain leak
# lived in the MATCHING, not just in the config list:
#
#   (a) Case. Hostnames are case-insensitive (RFC 1035), but every
#       match above was byte-exact, so "HTTPS://MBBRIDGE.ONRENDER.COM"
#       in smali survived a config that listed the lowercase URL.
#       _ci_matchable() marks the needles this applies to — a URL
#       (scheme://...) or a bare host (optionally :port and /path).
#       Paths stay case-sensitive in DERIVATION (config.py never
#       lowercases them); matching a whole URL case-insensitively is
#       still safe because the payload encrypts the ACTUAL literal
#       found, so the runtime value is byte-identical — over-matching
#       a path's case only hides one more literal, it never changes
#       behaviour. Non-URL needles (secrets, labels) stay exact.
#   (b) Derivation. find_needles_in_text() and transform_smali_file()
#       expand `exact` through config.derive_needles() themselves,
#       so a caller that passes raw config strings still hides every
#       derived spelling (bare host, www., scheme/port/trailing-slash/
#       encoded forms). transform_static_fields() does the same from
#       its payload keys when the caller passes no explicit list.

_URL_LIKE_RE = re.compile(r"^[A-Za-z][A-Za-z0-9+.\-]*://")
_BARE_HOST_NEEDLE_RE = re.compile(
    r"([A-Za-z0-9.\-]+)(?::\d+)?(?:/.*)?")


def _ci_matchable(needle):
    """True when `needle` is a URL or a bare host, i.e. its host part
    is case-insensitive and it may be matched case-insensitively."""
    if not needle or any(c.isspace() for c in needle):
        return False
    if _URL_LIKE_RE.match(needle):
        return True
    m = _BARE_HOST_NEEDLE_RE.fullmatch(needle)
    return bool(m and "." in m.group(1))


def find_needles_in_text(text, exact, patterns):
    """Return the list of configured needles found in text (exact match
    wins; regex patterns match whole literals). `exact` is expanded
    through derive_needles() first, so derived spellings (bare host,
    www., scheme/port/trailing-slash/encoded forms) are found even
    when the caller passed only raw config strings; URL/host needles
    also match case-insensitively (hosts are case-insensitive)."""
    exact = derive_needles(list(exact or []))
    found = []
    low_text = text.lower()
    for needle in exact:
        if needle and needle in text:
            found.append(needle)
        elif (needle and _ci_matchable(needle)
                and needle.lower() in low_text):
            found.append(needle)
    for pat in patterns:
        try:
            rx = re.compile(pat)
        except re.error:
            continue
        for m in rx.finditer(text):
            if m.group(0) and m.group(0) not in found:
                found.append(m.group(0))
    return found


def _split_segments(value, exact, patterns):
    """Split a string literal into ("lit", text) / ("needle", text)
    segments, where every needle occurrence (exact literal or regex
    match) becomes its own segment. Returns None when the value
    contains no needle — e.g. "Enter a domain, for example
    https://mbbridge.onrender.com" splits into a literal prefix plus
    the URL needle. Longest exact needle wins at each position."""
    compiled = []
    for pat in patterns:
        try:
            compiled.append(re.compile(pat))
        except re.error:
            pass
    exact_sorted = sorted(exact, key=len, reverse=True)
    # Case-insensitive candidates (URL / bare-host needles only —
    # hosts are case-insensitive; see _ci_matchable). Longest first,
    # like the exact list. The hit text is the ACTUAL substring from
    # the value, so the payload encrypts the literal as written.
    ci = sorted(((n, n.lower()) for n in exact if _ci_matchable(n)),
                key=lambda t: len(t[0]), reverse=True)
    low_value = value.lower()
    segs, buf, i, found = [], "", 0, False
    n = len(value)
    while i < n:
        hit = None
        for needle in exact_sorted:
            if needle and value.startswith(needle, i):
                hit = needle
                break
        if hit is None:
            for needle, low in ci:
                if low_value.startswith(low, i):
                    hit = value[i:i + len(needle)]
                    break
        if hit is None:
            for rx in compiled:
                m = rx.match(value, i)
                if m and m.group(0):
                    hit = m.group(0)
                    break
        if hit is not None:
            if buf:
                segs.append(("lit", buf))
                buf = ""
            segs.append(("needle", hit))
            found = True
            i += len(hit)
        else:
            buf += value[i]
            i += 1
    if buf:
        segs.append(("lit", buf))
    return segs if found else None


def _emit_concat(indent, temps, segs, payloads, orig_reg):
    """Build a string with embedded needles via StringBuilder: literal
    segments as const-strings, needle segments decrypted. temps is 6
    CONTIGUOUS registers: [instance, blob, part1, part2, builder,
    scratch] — builder < scratch so the append invoke can use the
    /range form {builder .. scratch} in argument order. All invokes
    use /range (see _decrypt_block)."""
    this, blob, p1, p2, builder, scratch = temps
    lines = [
        "%snew-instance %s, Ljava/lang/StringBuilder;" % (indent, builder),
        "%sinvoke-direct/range {%s .. %s}, Ljava/lang/StringBuilder;"
        "-><init>()V" % (indent, builder, builder),
    ]
    for kind, text in segs:
        if kind == "lit":
            lines.append('%sconst-string %s, "%s"'
                         % (indent, scratch, escape_smali(text)))
        else:
            # Decrypt straight into `scratch` (just above builder) so
            # the append invoke can use /range {builder .. scratch}
            # in ascending order. (An earlier version copied blob ->
            # scratch with move-object; move-object is 12x, v0–v15
            # only, and broke the build at v17/v21.)
            lines.extend(_decrypt_block(indent, [this, blob, p1, p2],
                                        payloads[text], result_reg=scratch))
        lines.append(
            "%sinvoke-virtual/range {%s .. %s}, Ljava/lang/StringBuilder;"
            "->append(Ljava/lang/String;)Ljava/lang/StringBuilder;"
            % (indent, builder, scratch))
        lines.append("%smove-result-object %s" % (indent, builder))
    lines.append(
        "%sinvoke-virtual/range {%s .. %s}, Ljava/lang/StringBuilder;"
        "->toString()Ljava/lang/String;" % (indent, builder, builder))
    lines.append("%smove-result-object %s" % (indent, orig_reg))
    return lines


def transform_smali_file(path, exact, patterns, payloads, stats):
    """Rewrite one .smali file in place. payloads: dict needle -> crypto
    dict (from encrypt_payload). stats: dict updated with counts.
    Returns True if the file changed. `exact` is expanded through
    derive_needles() first, so derived spellings are hidden even when
    the caller passed only raw config strings."""
    exact = derive_needles(list(exact or []))
    exact_set = set(exact)
    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    out, changed = [], False
    in_method = False
    locals_idx = None  # index in `out` of the .locals line, if any
    locals_n = None
    bump_needed = 0  # extra locals this method needs (4 simple, 6 concat)
    method_start = None
    method_desc = None
    bumped = []  # methods whose .locals grew — need the high-reg fixup
    for line in lines:
        if METHOD_RE.match(line):
            in_method = True
            locals_idx = None
            locals_n = None
            bump_needed = 0
            method_start = len(out)
            method_desc = line
            out.append(line)
            continue
        if END_METHOD_RE.match(line):
            if bump_needed and locals_idx is not None:
                indent, n = out[locals_idx][0], out[locals_idx][1]
                out[locals_idx] = "%s.locals %d" % (indent, n + bump_needed)
                bumped.append({
                    "start": method_start, "end": len(out),
                    "locals_new": locals_n + bump_needed,
                    "bump": bump_needed, "desc": method_desc})
            in_method = False
            out.append(line)
            continue
        m = LOCALS_RE.match(line) if in_method else None
        if m:
            locals_idx = len(out)
            locals_n = int(m.group(2))
            out.append([m.group(1), locals_n])  # placeholder, fixed at .end
            continue
        if LINE_RE.match(line):
            stats["lines_stripped"] = stats.get("lines_stripped", 0) + 1
            changed = True
            continue
        cm = CONST_RE.match(line) if in_method else None
        if cm:
            indent, reg, raw = cm.group(1), cm.group(2), cm.group(3)
            value = unescape_smali(raw)
            hit = None
            if value in payloads:
                hit = value
            elif value in exact_set:
                # Whole literal is a configured (or derived) needle
                # the sweep never saw — encrypt it on demand instead
                # of leaving it because payloads lacks the key.
                hit = value
            else:
                # Whole literal is a case variant of a URL/host
                # needle (hosts are case-insensitive) — the payload
                # encrypts the literal as written.
                low = value.lower()
                for needle in exact_set:
                    if (_ci_matchable(needle)
                            and needle.lower() == low):
                        hit = value
                        break
                if hit is None:
                    for pat in patterns:
                        try:
                            if re.fullmatch(pat, value):
                                hit = value
                                break
                        except re.error:
                            pass
            if hit is not None and hit not in payloads:
                payloads[hit] = encrypt_payload(hit)
            segs = None
            if hit is None:
                segs = _split_segments(value, exact, patterns)
                if segs:
                    for kind, text in segs:
                        if kind == "needle" and text not in payloads:
                            payloads[text] = encrypt_payload(text)
            if hit is not None or segs:
                if locals_idx is None or locals_n + 6 > 255:
                    import hashlib
                    stats.setdefault("skipped_no_locals", []).append(
                        "%s: sha256=%s" % (
                            path, hashlib.sha256(
                                value.encode("utf-8")).hexdigest()[:16]))
                    out.append(line)
                    continue
                base = locals_n
                # temps: [instance, blob, part1, part2, builder, scratch]
                temps = ["v%d" % (base + i) for i in range(6)]
                if hit is not None:
                    p = payloads[hit]
                    out.extend(_decrypt_block(indent, temps[:4], p,
                                              result_reg=reg))
                    bump_needed = max(bump_needed, 4)
                else:
                    out.extend(_emit_concat(indent, temps, segs, payloads, reg))
                    bump_needed = max(bump_needed, 6)
                    stats["strings_embedded"] = stats.get("strings_embedded", 0) + 1
                stats["strings_encrypted"] = stats.get("strings_encrypted", 0) + 1
                changed = True
                continue
        out.append(line)
    if changed:
        rendered = []
        for item in out:
            if isinstance(item, list):
                rendered.append("%s.locals %d" % (item[0], item[1]))
            else:
                rendered.append(item)
        if bumped:
            rendered = _fixup_high_regs(rendered, bumped, path, stats)
        path.write_text("\n".join(rendered) + "\n", encoding="utf-8")
    return changed


def encrypt_needles(needles):
    """needle -> encrypt_payload dict. One fresh key per needle per run."""
    return {n: encrypt_payload(n) for n in needles}


# --- high-register fixup -----------------------------------------------

INVOKE_RE = re.compile(
    r"^(\s*)(invoke-\w+?)(/range)?\s+\{([^}]*)\},\s*(.+)$")
MOVE_RE = re.compile(
    r"^(\s*)(move-object|move-wide|move)\s+([vp]\d+),\s*([vp]\d+)\s*$")
FILLED_RE = re.compile(
    r"^(\s*)filled-new-array\s+\{([^}]*)\},\s*(.+)$")
REG_TOKEN_RE = re.compile(r"\b([vp])(\d+)\b")

# Instructions that encode registers in 8 bits (or more) and therefore
# stay valid when a p-register lands above v15 after the .locals bump.
# VERIFIED empirically against smali 2.5.2 (assemble + baksmali
# round-trip, 2026-11-23): every op listed here assembled with v16.
# The Dalvik format is the decider, not the name:
#   8-bit: 11x (move-result*, return*, monitor-*, throw, move-exception),
#     21c (const-string, const-class, check-cast, new-instance,
#     sget/sput — ONE 8-bit register + 16-bit field ref),
#     21s (const/16, const-wide/16), 21h (const/high16, const-wide/high16),
#     21t (if-*z), 22b (*-lit8, registers are 8-bit despite the name),
#     22x (move*/from16), 23x (3-reg arithmetic,
#     aget/aput, cmp-*), 31i (const, const-wide/32), 31t (packed/
#     sparse-switch, fill-array-data), 31c (const-string/jumbo), 51l.
#   4-bit (NOT here — the fixup rewrites them, see _plan_fix):
#     12x (move, array-length, neg-*, conversions, */2addr),
#     22c (iget/iput ONLY — two 4-bit registers; instance-of,
#     new-array), 22s (*-lit16, including BARE "rsub-int" — the two
#     registers are 4-bit because the 16-bit literal occupies the
#     rest of the code unit), 22t (if-eq/ne/lt/ge/gt/le), 35c
#     (plain invoke-*). NOTE the 22b/22s trap: *-lit8 ops ARE 8-bit
#     (literal is 8 bits, registers get 8 bits each) while *-lit16
#     ops are 4-bit (literal is 16 bits). An earlier version of
#     this set listed the whole 22s family as 8-bit; smali PROVES
#     otherwise (assembling `and-int/lit16 p14, p13, 0x80` with
#     .locals 3 fails: "Invalid register: v17"), and the Bridge
#     2.14.0 protect died on exactly that line in the rebuild
#     (AdminAttentionItem.copy$default, .locals 3 -> p14 is v17).
#     sget/sput are 21c, NOT 22c, despite the similar names: the
#     "22" in 22c means two 4-bit registers (value + object), while
#     a static field op has only ONE register, encoded in 8 bits.
#     An earlier version of this set listed sget/sput under 22c and
#     the fixup rewrote them through temps (pointless churn) and
#     raised "unfixable high v-register" on a legal `sget-object
#     v18` (Bridge SessionActivity.refresh(), .locals 25), aborting
#     the protect. They belong here, untouched.
#     version of this set wrongly listed the 22c/22t ops as safe;
#     that shipped broken builds for methods whose p0 landed above
#     v15 (e.g. ParameterizedTypeImpl.getTypeName with .locals 12
#     -> 16: `iget-object v1, p0` failed to assemble). A later
#     version knew they were unsafe but only RAISED on them, which
#     aborted whole protects (ArrayDeque.retainAll/removeAll after
#     L55 chunking: `iput p1, p0, ...->size:I` with p1 at v16).
SAFE_8BIT_OPS = {
    "check-cast", "const-string", "const-string/jumbo", "const-class",
    "const", "const/16", "const/high16", "const-wide", "const-wide/16",
    "const-wide/32", "const-wide/high16",
    # 21c static field ops: ONE 8-bit register, NOT 22c (see comment
    # above). Every suffix variant is 21c. const-method-handle/type
    # are 21c too (dexlib2 Opcode enum) — no occurrence in Bridge or
    # the testapp yet, but a high-register one would otherwise trip
    # the safety net the same way rsub-int/lit8 did.
    "sget", "sget-wide", "sget-object", "sget-boolean", "sget-byte",
    "sget-char", "sget-short",
    "sput", "sput-wide", "sput-object", "sput-boolean", "sput-byte",
    "sput-char", "sput-short",
    "const-method-handle", "const-method-type",
    "if-eqz", "if-nez", "if-ltz", "if-gez", "if-gtz", "if-lez",
    "goto", "goto/16", "goto/32",
    "return", "return-void", "return-wide", "return-object",
    "move-result", "move-result-wide", "move-result-object",
    "move-exception",
    "new-instance", "monitor-enter", "monitor-exit",
    "throw", "fill-array-data",
    "packed-switch", "sparse-switch",
    # 23x three-register arithmetic / array / compare (all 8-bit).
    "add-int", "sub-int", "mul-int", "div-int", "rem-int",
    "and-int", "or-int", "xor-int", "shl-int", "shr-int", "ushr-int",
    "add-long", "sub-long", "mul-long", "div-long", "rem-long",
    "and-long", "or-long", "xor-long", "shl-long", "shr-long",
    "ushr-long",
    "add-float", "sub-float", "mul-float", "div-float", "rem-float",
    "add-double", "sub-double", "mul-double", "div-double",
    "rem-double",
    "aget", "aget-wide", "aget-object", "aget-boolean", "aget-byte",
    "aget-char", "aget-short",
    "aput", "aput-wide", "aput-object", "aput-boolean", "aput-byte",
    "aput-char", "aput-short",
    "cmp-long", "cmpg-float", "cmpl-float", "cmpg-double",
    "cmpl-double",
    # 22b literal-byte ops: registers 8-bit (literal is 8 bits).
    # 22s literal-short ops are 4-bit, NOT 8-bit — see the comment
    # above — so they are NOT listed here; _plan_fix rewrites them.
    # NAMING TRAP (dexlib2 Opcode enum, the actual assembler): the
    # 22s rsub is BARE "rsub-int" (two regs + 16-bit literal, as
    # baksmali emits it: `rsub-int v5, v4, 0x2000`), while the 22b
    # form is "rsub-int/lit8" — there is NO "rsub-int/lit16", and
    # NO shl/shr/ushr-int/lit16 (shifts exist only as /lit8).
    # An earlier version of this set listed "rsub-int/lit16" (dead:
    # never matches real input) and MISSED "rsub-int/lit8", so the
    # Bridge protect aborted on the legal `rsub-int/lit8 p3, p3,
    # 0x1a` (wireguard Curve25519.eval) with "unfixable high
    # parameter register in 'rsub-int/lit8'".
    "add-int/lit8", "rsub-int/lit8", "mul-int/lit8",
    "div-int/lit8",
    "rem-int/lit8", "and-int/lit8", "or-int/lit8", "xor-int/lit8",
    "shl-int/lit8", "shr-int/lit8", "ushr-int/lit8",
    # 22x "from16" moves: destination 8-bit, source 16-bit.
    "move/from16", "move-wide/from16", "move-object/from16",
}


# 12x two-address arithmetic (add-int/2addr etc.): 4-bit registers,
# so a parameter above v15 cannot stay — but the equivalent
# three-register 23x form (add-int vA, vA, vB) is 8-bit-safe and
# semantics-identical, so the fixup rewrites it instead of failing.
_TWOADDR_RE = re.compile(
    r"^(\s*)([\w-]+)/2addr\s+([vp]\d+),\s*([vp]\d+)\s*$")
_TWOADDR_OPS = {
    "add-int", "sub-int", "mul-int", "div-int", "rem-int",
    "and-int", "or-int", "xor-int", "shl-int", "shr-int", "ushr-int",
    "add-long", "sub-long", "mul-long", "div-long", "rem-long",
    "and-long", "or-long", "xor-long", "shl-long", "shr-long",
    "ushr-long",
    "add-float", "sub-float", "mul-float", "div-float", "rem-float",
    "add-double", "sub-double", "mul-double", "div-double",
    "rem-double",
}


# 22s literal-short ops (add-int/lit16, BARE rsub-int, mul/div/rem/
# and/or/xor-int/lit16): TWO 4-bit registers + a 16-bit literal, so
# a parameter above v15 cannot stay — but the operands are plain
# 32-bit ints, so the fixup copies each high operand through a temp
# (move/16) and copies the destination back afterwards, exactly like
# the 22c/22t handling. The literal is preserved verbatim. (22b
# *-lit8 ops are 8-bit and need no fixup — see SAFE_8BIT_OPS.)
_LIT16_RE = re.compile(
    r"^(\s*)(add-int/lit16|rsub-int|mul-int/lit16|div-int/lit16|"
    r"rem-int/lit16|and-int/lit16|or-int/lit16|xor-int/lit16)"
    r"\s+([vp]\d+)\s*,\s*([vp]\d+)\s*,\s*(.+?)\s*$")


def _parse_descriptor_params(desc):
    """Parse a method descriptor's parameter list into
    [(kind, width), ...]; kind is 'object' | 'wide' | 'prim'."""
    out, i = [], 0
    while i < len(desc):
        c = desc[i]
        if c == "L":
            j = desc.index(";", i)
            out.append(("object", 1))
            i = j + 1
        elif c == "[":
            j = i
            while desc[j] == "[":
                j += 1
            if desc[j] == "L":
                j = desc.index(";", j) + 1
            else:
                j += 1
            out.append(("object", 1))
            i = j
        elif c in "JD":
            out.append(("wide", 2))
            i += 1
        else:
            out.append(("prim", 1))
            i += 1
    return out


def _reg_abs(token, locals_new):
    """Absolute v-index of a register token in the bumped method."""
    kind, num = token[0], int(token[1:])
    return locals_new + num if kind == "p" else num


def _move_op(kind):
    return {"object": "move-object/16",
            "wide": "move-wide/16",
            "prim": "move/16"}[kind]


def _copy_args_to_temps(indent, regs, typed, temps_base):
    """Emit /16 moves copying each argument register into contiguous
    temp slots starting at temps_base. Returns (lines, end_slot).
    typed is [(kind, width), ...] aligned with regs; a width-0 entry
    is the high half of a wide (J/D) value and emits no move — it
    travels with the move-wide/16 of its low half."""
    lines, cursor = [], temps_base
    for reg, (kind, width) in zip(regs, typed):
        if width == 0:
            continue
        lines.append("%s%s v%d, %s"
                     % (indent, _move_op(kind), cursor, reg))
        cursor += width
    return lines, cursor - 1


def _expand_params_to_regs(param_types):
    """_parse_descriptor_params output -> one (kind, width) entry per
    REGISTER: a wide (J/D) parameter occupies two registers, so it
    contributes ("wide", 2) for its low half and (None, 0) for its
    high half. Without this, an invoke like
    `ULong.constructor-impl(J)J` (2 regs, 1 param) fails the
    register/type count check."""
    out = []
    for kind, width in param_types:
        if width == 2:
            out.append(("wide", 2))
            out.append((None, 0))
        else:
            out.append((kind, width))
    return out


# 11n const/4: the destination register is 4-bit, so a parameter
# pushed above v15 cannot stay — but const/16 (21s, 8-bit) takes
# the same literal text (a const/4 literal is -8..7, always inside
# const/16's 16-bit range), so the rewrite is a straight rename.
_CONST4_RE = re.compile(
    r"^(\s*)const/4\s+([vp]\d+)\s*,\s*(.+?)\s*$")


def _method_param_kinds(desc):
    """`.method` line -> {register index: kind} for the method's
    parameters. kind is "object" | "wide-low" | "wide-high" | "prim".
    Non-static methods: p0 is `this` (object). Wide (J/D) parameters
    occupy two registers: the low half is "wide-low", the high half
    "wide-high". The fixup needs this map because the COPY instruction
    for a spilled parameter must match the value's type (move/16 for
    ints, move-object/16 for references, move-wide/16 for longs and
    doubles) — and the type of a 22t branch operand (int vs reference)
    is only visible in the descriptor."""
    head = desc.split("(", 1)[0]
    is_static = re.search(r"\bstatic\b", head) is not None
    m = re.search(r"\(([^)]*)\)", desc)
    params = _parse_descriptor_params(m.group(1)) if m else []
    kinds = {}
    cur = 0
    if not is_static:
        kinds[0] = "object"  # `this`
        cur = 1
    for kind, width in params:
        if width == 2:
            kinds[cur] = "wide-low"
            kinds[cur + 1] = "wide-high"
            cur += 2
        else:
            kinds[cur] = kind
            cur += 1
    return kinds


def _param_reg_root(param_kinds, token, path, lineno, line):
    """p-register token -> (kind, root_reg). kind is "object" | "wide"
    | "prim"; root_reg is the register that starts the value (a wide
    high-half maps to its low half). Raises RuntimeError for a
    p-register the descriptor cannot account for — that is invalid
    dex, and guessing its type could ship a build that fails ART
    verification, so it fails loudly instead."""
    n = int(token[1:])
    k = param_kinds.get(n)
    if k is None:
        raise RuntimeError(
            "%s: parameter register %s is not in the method descriptor "
            "(line %d): %s" % (path, token, lineno, line.strip()))
    if k == "wide-high":
        return ("wide", n - 1)
    if k == "wide-low":
        return ("wide", n)
    return (k, n)


def _branch_operand_kind(token, param_kinds, path, lineno, line):
    """Copy kind for a 22t branch operand: two-register branches
    compare 32-bit values (ints or references), never wide values, so
    a wide parameter contributes only the referenced 32-bit half."""
    if token[0] == "v":
        return "prim"
    kind, _root = _param_reg_root(param_kinds, token, path, lineno, line)
    return "object" if kind == "object" else "prim"


# Extra patterns for the general fixup (22c field ops, 22t branches,
# remaining 12x unary ops). Field ops are matched as op + rest and
# split on commas. ONLY iget/iput are 22c (two 4-bit registers:
# value + object). sget/sput are 21c (one 8-bit register) and are
# deliberately NOT matched here — they are in SAFE_8BIT_OPS and pass
# through untouched; matching them here was the Bridge 2.14.0
# protect failure (`sget-object v18` raised "unfixable").
_FIELD_RE = re.compile(
    r"^(\s*)((?:iget|iput)(?:-wide|-object|-boolean|-byte|-char|-short)?)\s+(.+)$")
_INSTANCEOF_RE = re.compile(
    r"^(\s*)instance-of\s+([vp]\d+)\s*,\s*([vp]\d+)\s*,\s*(\S+)\s*$")
_NEWARRAY_RE = re.compile(
    r"^(\s*)new-array\s+([vp]\d+)\s*,\s*([vp]\d+)\s*,\s*(\S+)\s*$")
_IF2_RE = re.compile(
    r"^(\s*)(if-(?:eq|ne|lt|ge|gt|le))\s+([vp]\d+)\s*,\s*([vp]\d+)\s*,\s*(:\w+)\s*$")
_UNARY12X_RE = re.compile(
    r"^(\s*)(array-length|neg-int|neg-long|neg-float|neg-double|not-int|not-long|"
    r"int-to-long|int-to-float|int-to-double|long-to-int|long-to-float|long-to-double|"
    r"float-to-int|float-to-long|float-to-double|double-to-int|double-to-long|double-to-float|"
    r"int-to-byte|int-to-char|int-to-short)\s+([vp]\d+)\s*,\s*([vp]\d+)\s*$")

# Field-op suffix -> kind of the VALUE operand. The object operand of
# iget/iput is always a reference.
_FIELD_SUFFIX_KIND = {
    "": "prim", "-wide": "wide", "-object": "object",
    "-boolean": "prim", "-byte": "prim", "-char": "prim", "-short": "prim",
}

# 12x unary op -> (destination kind, source kind). The opcode is
# authoritative for the types: e.g. int-to-long writes a wide pair
# from a 32-bit source, long-to-int the reverse.
_UNARY12X_KINDS = {
    "array-length": ("prim", "object"),
    "neg-int": ("prim", "prim"), "neg-long": ("wide", "wide"),
    "neg-float": ("prim", "prim"), "neg-double": ("wide", "wide"),
    "not-int": ("prim", "prim"), "not-long": ("wide", "wide"),
    "int-to-long": ("wide", "prim"), "int-to-float": ("prim", "prim"),
    "int-to-double": ("wide", "prim"),
    "long-to-int": ("prim", "wide"), "long-to-float": ("prim", "wide"),
    "long-to-double": ("wide", "wide"),
    "float-to-int": ("prim", "prim"), "float-to-long": ("wide", "prim"),
    "float-to-double": ("wide", "prim"),
    "double-to-int": ("prim", "wide"), "double-to-long": ("wide", "wide"),
    "double-to-float": ("prim", "wide"),
    "int-to-byte": ("prim", "prim"), "int-to-char": ("prim", "prim"),
    "int-to-short": ("prim", "prim"),
}


def _plan_operands(operands, locals_cur, param_kinds, path, lineno, line):
    """Plan temp copies for one instruction's operands.

    operands: [(token, role, kind)] with role "src" (copy the value
    into a temp BEFORE the instruction) or "dst" (copy the temp back
    AFTER it), and kind "prim" | "wide" | "object" — the type the
    copy instruction must use, taken from the opcode, NOT the param
    map (the opcode is authoritative for the value being moved).
    Returns (planned, slots): planned is a list of dicts with
    "token" (original), "role", "kind", "temp_off" (temp-slot offset
    from temps_base, or None when the operand needs no copy),
    "repl_off" (offset of the replacement register in the rewritten
    instruction, or None), "copy" (register the copy reads/writes:
    the pair root for wide values, the token itself otherwise).
    slots is the number of temp slots the fix needs. Operands that
    share a wide pair share one temp. A v-register above v15 in a
    4-bit op means the input was already invalid before any transform
    — that raises loudly: only p-registers can be pushed over v15 by
    a .locals bump, because v-registers never move."""
    planned, alloc, cursor = [], {}, 0
    for token, role, kind in operands:
        if token[0] == "v":
            if int(token[1:]) > 15:
                raise RuntimeError(
                    "%s: unfixable high v-register in a 4-bit op "
                    "(line %d): %s" % (path, lineno, line.strip()))
            planned.append({"token": token, "role": role, "kind": kind,
                            "temp_off": None, "repl_off": None,
                            "copy": token})
            continue
        # Validate the parameter against the descriptor (loud on
        # unknown) — _param_reg_root raises.
        _param_reg_root(param_kinds, token, path, lineno, line)
        n = int(token[1:])
        if kind == "wide":
            is_high_half = param_kinds.get(n) == "wide-high"
            root = n - 1 if is_high_half else n
            key = ("wide", root)
            width = 2
            copy_token = "p%d" % root
        else:
            is_high_half = False
            root = n
            key = ("reg", n)
            width = 1
            copy_token = token
        if locals_cur + n > 15:
            if key not in alloc:
                alloc[key] = cursor
                cursor += width
            temp_off = alloc[key]
            repl_off = temp_off + 1 if is_high_half else temp_off
            planned.append({"token": token, "role": role, "kind": kind,
                            "temp_off": temp_off, "repl_off": repl_off,
                            "copy": copy_token})
        else:
            planned.append({"token": token, "role": role, "kind": kind,
                            "temp_off": None, "repl_off": None,
                            "copy": copy_token})
    return planned, cursor


def _emit_with_operands(indent, planned, temps_base, rebuilt):
    """Copy-in lines (src operands, in order, deduped by copy
    register), the rebuilt instruction, copy-out lines (dst
    operands). Temps are addressed as temps_base + offset. The temp
    registers are the transform's own scratch (builder/scratch,
    decrypt temps, opaque guard temps) or the fixup's grown spares:
    they are dead at every original-code instruction site — the
    transform's temps are live only inside its own emitted sequences,
    and the L11 state register is write-only between dispatcher
    reads (every block rewrites it before jumping to the dispatcher),
    so clobbering one mid-block is safe. This is the same discipline
    the invoke fixup already relied on."""
    lines = []
    done_in, done_out = set(), set()
    for entry in planned:
        if entry["role"] != "src" or entry["temp_off"] is None:
            continue
        if entry["copy"] in done_in:
            continue
        done_in.add(entry["copy"])
        lines.append("%s%s v%d, %s"
                     % (indent, _move_op(entry["kind"]),
                        temps_base + entry["temp_off"], entry["copy"]))
    lines.append(rebuilt)
    for entry in planned:
        if entry["role"] != "dst" or entry["temp_off"] is None:
            continue
        if entry["copy"] in done_out:
            continue
        done_out.add(entry["copy"])
        lines.append("%s%s %s, v%d"
                     % (indent, _move_op(entry["kind"]), entry["copy"],
                        temps_base + entry["temp_off"]))
    return lines


def _repl_token(entry, temps_base):
    """The register token to use for a planned operand in the
    rewritten instruction."""
    if entry["temp_off"] is None:
        return entry["token"]
    return "v%d" % (temps_base + entry["repl_off"])


def _plan_fix(line, locals_cur, param_kinds, path, lineno):
    """Plan the fix for ONE line, or return None when the line needs
    no fix. Returns (slots, stat_key, emit) where slots is the number
    of temp slots the rewrite needs (counted from temps_base upward)
    and emit(temps_base) -> [replacement lines]. locals_cur is the
    method's CURRENT .locals count (after any fixup growth); a
    p-register is high iff locals_cur + N > 15. Raises RuntimeError
    (fail loudly) for a line that cannot be fixed: an invoke whose
    registers do not match its descriptor, a malformed field op, a
    parameter the descriptor cannot account for, or a nibble-limited
    instruction in a form none of the branches below knows."""
    op_m = re.match(r"^\s*([a-z][\w/-]*)", line)
    if not op_m:
        return None
    op = op_m.group(1)
    if "/16" in op or "/range" in op or "/jumbo" in op:
        return None
    if op in SAFE_8BIT_OPS:
        return None
    m = INVOKE_RE.match(line)
    if m:
        indent, op, is_range, reglist, callee = m.groups()
        if is_range:
            return None
        regs = [r.strip() for r in reglist.split(",") if r.strip()]
        if not regs:
            return None
        if max(_reg_abs(r, locals_cur) for r in regs) <= 15:
            return None
        dm = re.search(r"\(([^)]*)\)", callee)
        if dm is None:
            raise RuntimeError(
                "%s: cannot fix invoke without descriptor: %s"
                % (path, line.strip()))
        typed = []
        if op != "invoke-static":
            typed.append(("object", 1))  # `this`
        typed.extend(_expand_params_to_regs(
            _parse_descriptor_params(dm.group(1))))
        if len(regs) != len(typed):
            raise RuntimeError(
                "%s: invoke register/type mismatch (%d regs, "
                "%d types): %s" % (path, len(regs), len(typed),
                                   line.strip()))
        slots = len(typed)

        def emit(temps_base, _indent=indent, _op=op, _regs=regs,
                 _typed=typed, _callee=callee):
            moves, end_slot = _copy_args_to_temps(
                _indent, _regs, _typed, temps_base)
            return moves + ["%s%s/range {v%d .. v%d}, %s"
                            % (_indent, _op, temps_base, end_slot, _callee)]

        return (slots, "invokes_fixed", emit)
    m = MOVE_RE.match(line)
    if m:
        indent, op, dest, src = m.groups()
        if (_reg_abs(dest, locals_cur) <= 15
                and _reg_abs(src, locals_cur) <= 15):
            return None

        def emit(temps_base, _indent=indent, _op=op, _dest=dest,
                 _src=src):
            return ["%s%s/16 %s, %s" % (_indent, _op, _dest, _src)]

        return (0, "moves_fixed", emit)
    m = FILLED_RE.match(line)
    if m:
        indent, reglist, typ = m.groups()
        regs = [r.strip() for r in reglist.split(",") if r.strip()]
        if not regs:
            return None
        if max(_reg_abs(r, locals_cur) for r in regs) <= 15:
            return None
        t = typ.strip()
        kind = ("wide" if t in ("[J", "[D") else
                "object" if t.startswith("[L") or t.startswith("[[")
                else "prim")
        if kind == "wide":
            copy_regs = regs[0::2]
            typed = [("wide", 2)] * len(copy_regs)
        else:
            copy_regs = regs
            typed = [(kind, 1)] * len(regs)
        slots = sum(w for _k, w in typed)

        def emit(temps_base, _indent=indent, _copy_regs=copy_regs,
                 _typed=typed, _typ=typ):
            moves, end_slot = _copy_args_to_temps(
                _indent, _copy_regs, _typed, temps_base)
            return moves + [
                "%sfilled-new-array/range {v%d .. v%d}, %s"
                % (_indent, temps_base, end_slot, _typ)]

        return (slots, "filled_fixed", emit)
    m = _TWOADDR_RE.match(line)
    if m:
        indent, op, dest, src = m.groups()
        if op not in _TWOADDR_OPS:
            return None
        if (_reg_abs(dest, locals_cur) <= 15
                and _reg_abs(src, locals_cur) <= 15):
            return None

        def emit(temps_base, _indent=indent, _op=op, _dest=dest,
                 _src=src):
            return ["%s%s %s, %s, %s"
                    % (_indent, _op, _dest, _dest, _src)]

        return (0, "twoaddr_fixed", emit)
    m = _LIT16_RE.match(line)
    if m:
        indent, op, dest, src, lit = m.groups()
        operands = [(dest, "dst", "prim"), (src, "src", "prim")]
        planned, slots = _plan_operands(
            operands, locals_cur, param_kinds, path, lineno, line)
        if slots == 0:
            return None

        def emit(temps_base, _indent=indent, _op=op, _planned=planned,
                 _lit=lit):
            rebuilt = "%s%s %s, %s, %s" % (
                _indent, _op, _repl_token(_planned[0], temps_base),
                _repl_token(_planned[1], temps_base), _lit)
            return _emit_with_operands(_indent, _planned, temps_base,
                                       rebuilt)

        return (slots, "lit16_fixed", emit)
    m = _FIELD_RE.match(line)
    if m:
        indent, fullop, rest = m.groups()
        bm = re.fullmatch(
            r"(iget|iput)(-wide|-object|-boolean|-byte|-char|-short)?",
            fullop)
        if bm is None:
            raise RuntimeError(
                "%s: unknown field op '%s' (line %d): %s"
                % (path, fullop, lineno, line.strip()))
        base, suffix = bm.group(1), bm.group(2) or ""
        vkind = _FIELD_SUFFIX_KIND[suffix]
        parts = [p.strip() for p in rest.split(",")]
        if len(parts) != 3:
            raise RuntimeError(
                "%s: malformed field op (line %d): %s"
                % (path, lineno, line.strip()))
        r1, r2, field = parts
        if base == "iget":
            operands = [(r1, "dst", vkind), (r2, "src", "object")]
        else:
            operands = [(r1, "src", vkind), (r2, "src", "object")]
        nregs = 2
        planned, slots = _plan_operands(
            operands, locals_cur, param_kinds, path, lineno, line)
        if slots == 0:
            return None

        def emit(temps_base, _indent=indent, _fullop=fullop,
                 _planned=planned, _field=field, _nregs=nregs):
            repls = [_repl_token(e, temps_base) for e in _planned]
            if _nregs == 2:
                rebuilt = "%s%s %s, %s, %s" % (
                    _indent, _fullop, repls[0], repls[1], _field)
            else:
                rebuilt = "%s%s %s, %s" % (
                    _indent, _fullop, repls[0], _field)
            return _emit_with_operands(_indent, _planned, temps_base,
                                       rebuilt)

        return (slots, "field_fixed", emit)
    m = _INSTANCEOF_RE.match(line)
    if m:
        indent, dst, src, typ = m.groups()
        operands = [(dst, "dst", "prim"), (src, "src", "object")]
        planned, slots = _plan_operands(
            operands, locals_cur, param_kinds, path, lineno, line)
        if slots == 0:
            return None

        def emit(temps_base, _indent=indent, _planned=planned,
                 _typ=typ):
            rebuilt = "%sinstance-of %s, %s, %s" % (
                _indent, _repl_token(_planned[0], temps_base),
                _repl_token(_planned[1], temps_base), _typ)
            return _emit_with_operands(_indent, _planned, temps_base,
                                       rebuilt)

        return (slots, "instanceof_fixed", emit)
    m = _NEWARRAY_RE.match(line)
    if m:
        indent, dst, src, typ = m.groups()
        operands = [(dst, "dst", "object"), (src, "src", "prim")]
        planned, slots = _plan_operands(
            operands, locals_cur, param_kinds, path, lineno, line)
        if slots == 0:
            return None

        def emit(temps_base, _indent=indent, _planned=planned,
                 _typ=typ):
            rebuilt = "%snew-array %s, %s, %s" % (
                _indent, _repl_token(_planned[0], temps_base),
                _repl_token(_planned[1], temps_base), _typ)
            return _emit_with_operands(_indent, _planned, temps_base,
                                       rebuilt)

        return (slots, "newarray_fixed", emit)
    m = _IF2_RE.match(line)
    if m:
        indent, op, r1, r2, label = m.groups()
        k1 = _branch_operand_kind(r1, param_kinds, path, lineno, line)
        k2 = _branch_operand_kind(r2, param_kinds, path, lineno, line)
        operands = [(r1, "src", k1), (r2, "src", k2)]
        planned, slots = _plan_operands(
            operands, locals_cur, param_kinds, path, lineno, line)
        if slots == 0:
            return None

        def emit(temps_base, _indent=indent, _op=op, _planned=planned,
                 _label=label):
            rebuilt = "%s%s %s, %s, %s" % (
                _indent, _op, _repl_token(_planned[0], temps_base),
                _repl_token(_planned[1], temps_base), _label)
            return _emit_with_operands(_indent, _planned, temps_base,
                                       rebuilt)

        return (slots, "branch_fixed", emit)
    m = _UNARY12X_RE.match(line)
    if m:
        indent, op, r1, r2 = m.groups()
        dk, sk = _UNARY12X_KINDS[op]
        operands = [(r1, "dst", dk), (r2, "src", sk)]
        planned, slots = _plan_operands(
            operands, locals_cur, param_kinds, path, lineno, line)
        if slots == 0:
            return None

        def emit(temps_base, _indent=indent, _op=op, _planned=planned):
            rebuilt = "%s%s %s, %s" % (
                _indent, _op, _repl_token(_planned[0], temps_base),
                _repl_token(_planned[1], temps_base))
            return _emit_with_operands(_indent, _planned, temps_base,
                                       rebuilt)

        return (slots, "unary_fixed", emit)
    m = _CONST4_RE.match(line)
    if m:
        indent, reg, lit = m.groups()
        if _reg_abs(reg, locals_cur) <= 15:
            return None

        def emit(temps_base, _indent=indent, _reg=reg, _lit=lit):
            return ["%sconst/16 %s, %s" % (_indent, _reg, _lit)]

        return (0, "const4_fixed", emit)
    # Safety net: any other line referencing a p-register above v15
    # must be an 8-bit (or wider) instruction or the build will fail
    # — raise instead of shipping broken.
    op_m2 = re.match(r"^\s*([a-z][\w/-]*)", line)
    if op_m2:
        for kind, num in REG_TOKEN_RE.findall(line):
            if kind == "p" and locals_cur + int(num) > 15:
                raise RuntimeError(
                    "%s: unfixable high parameter register in "
                    "'%s' (line %d): %s"
                    % (path, op_m2.group(1), lineno, line.strip()))
    return None


def _fixup_high_regs(lines, bumped, path, stats):
    """Repair nibble-limited instructions that reference a parameter
    register now above v15 in methods whose .locals grew. Every
    4-bit format is rewritten, never skipped: plain invokes become
    `/range` (arguments copied into temp registers), `move*` becomes
    `move*/16`, `filled-new-array` becomes `/range`, `/2addr`
    arithmetic becomes its 23x form, `const/4` becomes `const/16`,
    and 22c field ops (iget/iput ONLY — sget/sput are 21c, 8-bit,
    and pass through untouched; see SAFE_8BIT_OPS), instance-of
    and new-array, 22s `*-lit16` ops, 22t two-register branches,
    and the remaining 12x unary ops (array-length, neg-*/ not-*,
    conversions) are rewritten by copying each high parameter
    through a temp register (`move/16` for ints, `move-object/16`
    for references, `move-wide/16` for longs/doubles — the type comes
    from the opcode, the field, the callee descriptor, or the method
    descriptor) and copying results back afterwards.

    Temp budget: the rewrite needs at most as many temp slots as the
    widest instruction in the method (an invoke copies all its
    arguments contiguously; a field op at most a wide value plus its
    object). When the transform's own bump does not leave enough
    room, the fixup GROWS .locals for that method — and re-scans,
    because growing shifts every p-register up and can push further
    instructions over v15. The growth is capped at 255 locals.
    Raises RuntimeError (fail loudly) only when a method genuinely
    cannot be fixed: locals would exceed 255, a parameter the
    descriptor cannot account for, a high v-register (already invalid
    before any transform), or an unknown nibble-limited form. A
    broken APK must never be shipped silently.
    Methods are processed in reverse order so insertions keep earlier
    indices valid."""
    for info in sorted(bumped, key=lambda b: b["start"], reverse=True):
        start, end = info["start"], info["end"]
        locals_new = info["locals_new"]
        bump = info["bump"]
        temps_base = locals_new - bump
        desc = info["desc"]
        param_kinds = _method_param_kinds(desc)
        # Phase 1: fixpoint — grow .locals until the temp area covers
        # the widest fix this method needs. Each growth shifts
        # p-registers up, so the requirement is recomputed after
        # every growth until it is stable.
        locals_cur = locals_new
        while True:
            need = 0
            for idx in range(start, end):
                plan = _plan_fix(lines[idx], locals_cur, param_kinds,
                                 path, idx + 1)
                if plan is not None:
                    need = max(need, plan[0])
            avail = locals_cur - temps_base
            if need <= avail:
                break
            grow = need - avail
            if locals_cur + grow > 255:
                raise RuntimeError(
                    "%s: unfixable high parameter register: method %s "
                    "would need %d locals (>255)"
                    % (path, desc.strip(), locals_cur + grow))
            locals_cur += grow
        if locals_cur != locals_new:
            for idx in range(start, end):
                m = LOCALS_RE.match(lines[idx])
                if m:
                    lines[idx] = "%s.locals %d" % (m.group(1), locals_cur)
                    break
            stats["locals_grown"] = stats.get("locals_grown", 0) + 1
            stats["locals_grown_by"] = stats.get(
                "locals_grown_by", 0) + (locals_cur - locals_new)
        # Phase 2: rewrite pass, in reverse so insertions before a
        # line leave all earlier indices untouched.
        for idx in range(end - 1, start - 1, -1):
            plan = _plan_fix(lines[idx], locals_cur, param_kinds,
                             path, idx + 1)
            if plan is None:
                continue
            slots, stat_key, emit = plan
            lines[idx:idx + 1] = emit(temps_base)
            stats[stat_key] = stats.get(stat_key, 0) + 1
    return lines


FIELD_RE = re.compile(
    r'^(\s*)\.field\s+((?:(?:public|private|protected|static|final|'
    r'synthetic|volatile|transient)\s+)*)(\w+):Ljava/lang/String;'
    r'\s*=\s*"((?:[^"\\]|\\.)*)"\s*$')
CLASS_RE = re.compile(r"^\s*\.class\s+.*\s+(L[\w/$]+;)\s*$")
CLINIT_RE = re.compile(
    r"^\s*\.method\s+static\s+constructor\s+<clinit>\(\)V\s*$")


def _decrypt_block(indent, temps, payload, result_reg=None):
    """Smali lines that decrypt a blob. temps is 4 CONTIGUOUS
    registers in invoke order: [instance, blob, part1, part2]. The
    invoke uses the /range form deliberately: the plain invoke form
    only encodes v0–v15, and protected methods can have .locals well
    above that (a v20 register broke the first Bridge build).
    The result goes into `result_reg` (default: the blob register)
    via move-result-object, which encodes an 8-bit register — so it
    works above v15. Never use move-object here: move-object is a
    12x instruction limited to v0–v15, and it broke the build at
    v17/v21."""
    this, blob, p1, p2 = temps
    result = result_reg or blob
    return [
        '%sconst-string %s, "%s"' % (indent, blob, payload["blob_b64"]),
        '%sconst-string %s, "%s"' % (indent, p1, payload["key_part1_b64"]),
        '%sconst-string %s, "%s"' % (indent, p2, payload["key_part2_b64"]),
        "%ssget-object %s, %s->INSTANCE:%s"
        % (indent, this, RUNTIME_CLASS, RUNTIME_CLASS),
        "%sinvoke-virtual/range {%s .. %s}, %s->decrypt"
        "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)"
        "Ljava/lang/String;" % (indent, this, p2, RUNTIME_CLASS),
        "%smove-result-object %s" % (indent, result),
    ]


def _field_value_sensitive(value, needles, patterns, payloads):
    """True when a static field's string value must be hidden: it is
    itself a known needle, it CONTAINS one (exact, derived, or a
    case variant of a URL/host needle), or it matches a pattern.
    (The old code only hid a field whose value EQUALLED a needle —
    a field holding "Enter a domain, for example
    mbbridge.onrender.com" or a bare host therefore survived.)"""
    if not value:
        return False
    if value in payloads:
        return True
    low = value.lower()
    for n in needles:
        if n and n in value:
            return True
        if n and _ci_matchable(n) and n.lower() in low:
            return True
    for pat in patterns:
        try:
            if re.search(pat, value):
                return True
        except re.error:
            continue
    return False


def transform_static_fields(path, payloads, stats, exact=None,
                            patterns=None):
    """Rewrite static String field initializers (L01b).

    Kotlin `const val` / Java `static final String X = "..."` compiles
    to a field with a constant value (`.field ... = "literal"`), NOT
    to a `const-string` instruction — so the const-string pass misses
    it. This pass strips the initializer and assigns the decrypted
    value in `<clinit>` instead (creating `<clinit>` if the class has
    none). Returns True if the file changed.

    The WHOLE field value is encrypted whenever it needs hiding (a
    needle it contains, a pattern it matches, or a case variant of a
    URL/host needle) — whole-value encryption needs no concatenation
    in <clinit> and hides the surrounding prose too, while the
    runtime value is byte-identical. `exact`/`patterns` are optional:
    when omitted, needles are derived from the payload keys already
    collected (which, since find_needles_in_text() derives, already
    include derived spellings found anywhere in the APK) — but a
    field value that matches ONLY a pattern is then missed, so
    callers with patterns should pass them explicitly.
    """
    if exact is not None or patterns is not None:
        needles = derive_needles(list(exact or []))
        pats = list(patterns or [])
    else:
        needles = derive_needles(list(payloads))
        pats = []
    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    class_desc = None
    for ln in lines:
        m = CLASS_RE.match(ln)
        if m:
            class_desc = m.group(1)
            break
    if class_desc is None:
        return False
    fields = []  # (name, payload)
    out = []
    for ln in lines:
        m = FIELD_RE.match(ln)
        if m:
            value = unescape_smali(m.group(4))
            if _field_value_sensitive(value, needles, pats, payloads):
                if value not in payloads:
                    payloads[value] = encrypt_payload(value)
                fields.append((m.group(3), payloads[value]))
                out.append("%s.field %s%s:Ljava/lang/String;"
                           % (m.group(1), m.group(2), m.group(3)))
                stats["fields_encrypted"] = stats.get("fields_encrypted", 0) + 1
                continue
        out.append(ln)
    if not fields:
        return False
    # Find <clinit> and its .locals line.
    clinit_idx = locals_idx = locals_n = None
    for i, ln in enumerate(out):
        if CLINIT_RE.match(ln):
            clinit_idx = i
            for j in range(i, len(out)):
                lm = LOCALS_RE.match(out[j])
                if lm:
                    locals_idx, locals_n = j, int(lm.group(2))
                    break
                if END_METHOD_RE.match(out[j]):
                    break
            break
    if clinit_idx is not None and locals_idx is not None:
        indent = "    "
        # temps in invoke order: [instance, blob, part1, part2] —
        # instance MUST be the lowest register or the /range invoke
        # is rejected ("lower register listed first").
        temps = ["v%d" % (locals_n + k) for k in range(4)]
        block = []
        for name, p in fields:
            block.extend(_decrypt_block(indent, temps, p))
            block.append("%ssput-object %s, %s->%s:Ljava/lang/String;"
                         % (indent, temps[1], class_desc, name))
        out[locals_idx] = "%s.locals %d" % (
            LOCALS_RE.match(out[locals_idx]).group(1), locals_n + 4)
        out[locals_idx + 1:locals_idx + 1] = block
    elif clinit_idx is None:
        indent = "    "
        block = [".method static constructor <clinit>()V",
                 "    .locals 4"]
        for name, p in fields:
            block.extend(_decrypt_block(indent, ["v0", "v1", "v2", "v3"], p))
            block.append("%ssput-object v1, %s->%s:Ljava/lang/String;"
                         % (indent, class_desc, name))
        block.extend(["    return-void", ".end method", ""])
        out.extend(block)
    else:
        stats.setdefault("skipped_no_locals", []).append(
            "%s: <clinit> without .locals" % path)
        return False
    path.write_text("\n".join(out) + "\n", encoding="utf-8")
    return True


DECOY_CLASS_TMPL = """# Cache helper — internal use only.
# The strings below are HONEYPOT values from the config: they look like
# real secrets/endpoints but are fake. Using one triggers a server-side
# tripwire (see docs/TRAPS.md). The methods do nothing useful.
.class public L{cls};
.super Ljava/lang/Object;

.method public constructor <init>()V
    .locals 1
    invoke-direct {{p0}}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public static {mname}()Ljava/lang/String;
    .locals 1
    const-string v0, "{value}"
    return-object v0
.end method

.method public static {mname2}()I
    .locals 3
    const/4 v0, 0x7
    const/4 v1, 0x3
    mul-int v0, v0, v1
    add-int/lit8 v0, v0, 0x5
    const/16 v2, 0x2a
    rem-int/2addr v0, v2
    return v0
.end method
"""


def write_decoy_smali(out_dir, index, fake_value, method_name):
    """Write one decoy smali class. Returns its path."""
    cls = "com/appcore/cache/Cache%02d" % index
    text = DECOY_CLASS_TMPL.format(
        cls=cls, mname=method_name, mname2=method_name + "Code",
        value=escape_smali(fake_value))
    d = Path(out_dir) / "smali" / "com" / "appcore" / "cache"
    d.mkdir(parents=True, exist_ok=True)
    p = d / ("Cache%02d.smali" % index)
    p.write_text(text, encoding="utf-8")
    return p


MAZE_CLASS_TMPL = """# dead-code maze — analysis-time sink, no behaviour.
# A chain of plausible-looking branches that always resolves to 0.
.class public L{cls};
.super Ljava/lang/Object;

.method public constructor <init>()V
    .locals 1
    invoke-direct {{p0}}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public static compute(I)I
    .locals 4
    const/4 v0, 0x0
    const/16 v1, 0x64
    :loop_{tag}
    add-int/lit8 v0, v0, 0x1
    rem-int/lit8 v2, v0, 0x7
    if-eqz v2, :even_{tag}
    add-int/lit8 v1, v1, -1
    goto :check_{tag}
    :even_{tag}
    add-int/lit8 v1, v1, 0x2
    :check_{tag}
    if-lt v0, p0, :loop_{tag}
    const/4 v3, 0x0
    return v3
.end method
"""


def write_maze_smali(out_dir, index):
    cls = "com/appcore/cache/Maze%02d" % index
    text = MAZE_CLASS_TMPL.format(cls=cls, tag="%02d" % index)
    d = Path(out_dir) / "smali" / "com" / "appcore" / "cache"
    d.mkdir(parents=True, exist_ok=True)
    p = d / ("Maze%02d.smali" % index)
    p.write_text(text, encoding="utf-8")
    return p


# ----------------------------------------------------------------------
# Batch A transforms (L55 / L58 / L59 / L11).
#
# All four are semantics-preserving smali rewrites: they change HOW a
# value is produced or control flows, never WHAT the method computes.
# Each runs as its own file pass (read the file, rewrite, bump
# .locals, run _fixup_high_regs) so passes compose in any order —
# but flattening (L11) must run LAST, because it restructures the
# whole method body and must see the final instruction stream.
#
# Register discipline, shared by all four: new temporaries are
# allocated at the TOP of the method's locals (v(locals_n) ...),
# .locals grows by the number used, and _fixup_high_regs repairs the
# nibble-limited instructions whose p-registers shifted — growing
# .locals further when the temp area is too small for a repair (see
# _fixup_high_regs). Emitted code uses only 8-bit-safe instructions
# (const/16, rem-int, if-eqz, packed-switch, invoke-*/range,
# move-result-*) — never const/4 or plain invoke/move on a temp that
# could sit above v15.
# ----------------------------------------------------------------------

_LABEL_RE = re.compile(r"^(\s*)(:\w+)\s*$")
# Branch targets are labels (":cond_0") at the end of an instruction.
# The negative lookbehind is load-bearing: without it the pattern
# also matches the TYPE SUFFIX of a field reference
# ("iput v0, p0, Lx;->size:I" ends in ":I"), and flatten then
# wrongly skipped every method with a primitive-typed field access
# as "branch to undefined label :I". A real label's colon is
# preceded by whitespace/a comma; a field ref's colon is preceded
# by the field name (a word char) after "->".
_BRANCH_TARGET_RE = re.compile(r"(?<![\w/>]):\w+\s*$")


def _rewrite_smali_methods(path, on_start, on_line, stats):
    """Shared engine for line-local method transforms.

    on_start(ctx) -> (extra_lines, bump): called once per method,
    right after its .locals line; extra_lines are inserted there.
    on_line(ctx, line) -> (replacement_lines, bump) | None: called
    for every body line; None keeps the line. ctx has "desc" and
    (after .locals) "locals_n". bump is the number of EXTRA locals
    the transform needs in this method (temps are v(locals_n)...).
    Methods without .locals (`.registers`) are left untouched.
    Returns True if the file changed.
    """
    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    out, changed = [], False
    in_method = False
    locals_idx = None
    locals_n = None
    bump_needed = 0
    method_start = None
    method_desc = None
    bumped = []
    ctx = {}
    for line in lines:
        if METHOD_RE.match(line):
            in_method = True
            locals_idx = None
            locals_n = None
            bump_needed = 0
            method_start = len(out)
            method_desc = line
            ctx = {"desc": line}
            out.append(line)
            continue
        if END_METHOD_RE.match(line):
            if bump_needed and locals_idx is not None:
                indent, n = out[locals_idx][0], out[locals_idx][1]
                out[locals_idx] = "%s.locals %d" % (indent, n + bump_needed)
                bumped.append({
                    "start": method_start, "end": len(out),
                    "locals_new": locals_n + bump_needed,
                    "bump": bump_needed, "desc": method_desc})
            in_method = False
            out.append(line)
            continue
        m = LOCALS_RE.match(line) if in_method else None
        if m:
            locals_idx = len(out)
            locals_n = int(m.group(2))
            ctx["locals_n"] = locals_n
            out.append([m.group(1), locals_n])
            if on_start is not None:
                extra, bump = on_start(ctx)
                if extra:
                    out.extend(extra)
                    changed = True
                if bump:
                    bump_needed = max(bump_needed, bump)
            continue
        if in_method and on_line is not None and locals_n is not None:
            repl = on_line(ctx, line)
            if repl is not None:
                rlines, rbump = repl
                out.extend(rlines)
                changed = True
                bump_needed = max(bump_needed, rbump)
                continue
        out.append(line)
    if changed:
        rendered = []
        for item in out:
            if isinstance(item, list):
                rendered.append("%s.locals %d" % (item[0], item[1]))
            else:
                rendered.append(item)
        if bumped:
            rendered = _fixup_high_regs(rendered, bumped, path, stats)
        path.write_text("\n".join(rendered) + "\n", encoding="utf-8")
    return changed


def _split_chunks(value, nparts):
    """Split a string into nparts non-empty chunks, roughly equal."""
    n = len(value)
    nparts = max(2, min(nparts, n))
    base, rem = divmod(n, nparts)
    chunks, pos = [], 0
    for i in range(nparts):
        size = base + (1 if i < rem else 0)
        chunks.append(value[pos:pos + size])
        pos += size
    return [c for c in chunks if c]


# --- L55 string chunking ----------------------------------------------

def chunk_string_literals(path, min_len=8, exclude=None, stats=None):
    """Split const-string literals into 2-3 chunks joined with a
    StringBuilder (L55), so the full literal never appears in the dex
    string table. Semantics-preserving: the rebuilt value is identical.

    Only literals with len >= min_len are chunked; `exclude` (a set of
    values, e.g. the L01 blob/key const-strings) is skipped. Literals
    containing control characters other than \\n/\\t/\\r, or lone
    surrogates (which cannot round-trip through smali escaping), are
    skipped and recorded — never rewritten unsafely. Needs 4 extra
    locals per transformed method: builder + scratch, plus 2 spare
    registers the high-register fixup uses as scratch when it rewrites
    wide invokes (a 3-argument invoke needs 3 temp slots).
    """
    stats = stats if stats is not None else {}
    exclude = set(exclude or [])

    def on_line(ctx, line):
        cm = CONST_RE.match(line)
        if not cm:
            return None
        indent, reg, raw = cm.group(1), cm.group(2), cm.group(3)
        value = unescape_smali(raw)
        if len(value) < min_len or value in exclude:
            return None
        if ctx["locals_n"] + 4 > 255:
            stats.setdefault("chunk_skipped_regs", []).append(
                "%s: %s" % (path, ctx["desc"].strip()))
            return None
        if any(ord(c) < 0x20 and c not in "\n\t\r" for c in value):
            stats.setdefault("chunk_skipped_control", []).append(
                "%s: len=%d" % (path, len(value)))
            return None
        if any(0xD800 <= ord(c) <= 0xDFFF for c in value):
            stats.setdefault("chunk_skipped_surrogate", []).append(
                "%s: len=%d" % (path, len(value)))
            return None
        chunks = _split_chunks(value, 3)
        if len(chunks) < 2:
            return None
        base = ctx["locals_n"]
        builder, scratch = "v%d" % base, "v%d" % (base + 1)
        lines = [
            "%snew-instance %s, Ljava/lang/StringBuilder;"
            % (indent, builder),
            "%sinvoke-direct/range {%s .. %s}, Ljava/lang/StringBuilder;"
            "-><init>()V" % (indent, builder, builder),
        ]
        for ch in chunks:
            lines.append('%sconst-string %s, "%s"'
                         % (indent, scratch, escape_smali(ch)))
            lines.append(
                "%sinvoke-virtual/range {%s .. %s}, "
                "Ljava/lang/StringBuilder;->append(Ljava/lang/String;)"
                "Ljava/lang/StringBuilder;"
                % (indent, builder, scratch))
            lines.append("%smove-result-object %s" % (indent, builder))
        lines.append(
            "%sinvoke-virtual/range {%s .. %s}, "
            "Ljava/lang/StringBuilder;->toString()Ljava/lang/String;"
            % (indent, builder, builder))
        lines.append("%smove-result-object %s" % (indent, reg))
        stats["strings_chunked"] = stats.get("strings_chunked", 0) + 1
        return (lines, 4)

    return _rewrite_smali_methods(path, None, on_line, stats)


# --- L58 opaque predicates --------------------------------------------

def insert_opaque_predicates(path, seed=0, stats=None):
    """Insert always-true / always-false branch guards (L58) at the
    start of every method with .locals. The guard computes
    (C % 2) from a per-build odd constant C (seed | 1, so the value
    differs every build) with 8-bit-safe instructions, then branches
    on the known result (1): one shape takes the always-true branch,
    the other the always-false branch, alternating per method. The
    dead arm holds a single harmless const/16 that never executes.
    Needs 2 extra locals. `seed` also namespaces the labels so two
    runs over the same file cannot collide.
    """
    stats = stats if stats is not None else {}
    const_c = (int(seed) | 1) & 0xFFFFFFFF
    if const_c == 1:
        const_c = 0x5A3C11
    tag_base = "%04x" % (int(seed) & 0xFFFF)
    counter = [0]

    def on_start(ctx):
        base = ctx["locals_n"]
        if base + 2 > 255:
            stats.setdefault("opaque_skipped_regs", []).append(
                "%s: %s" % (path, ctx["desc"].strip()))
            return ([], 0)
        tag = "%s_%d" % (tag_base, counter[0])
        counter[0] += 1
        t, u = "v%d" % base, "v%d" % (base + 1)
        indent = "    "
        head = [
            "%sconst %s, 0x%x" % (indent, t, const_c),
            "%sconst %s, 0x2" % (indent, u),
            "%srem-int %s, %s, %s" % (indent, t, t, u),
        ]
        if counter[0] % 2 == 1:
            # Shape A: vT == 1, so if-eqz is never taken.
            lines = head + [
                "%sif-eqz %s, :rea_dead_%s" % (indent, t, tag),
                "%sgoto :rea_live_%s" % (indent, tag),
                ":rea_dead_%s" % tag,
                "%sconst/16 %s, 0x0" % (indent, t),
                ":rea_live_%s" % tag,
            ]
        else:
            # Shape B: vT == 1, so if-nez is always taken.
            lines = head + [
                "%sif-nez %s, :rea_live_%s" % (indent, t, tag),
                "%sconst/16 %s, 0x0" % (indent, t),
                ":rea_live_%s" % tag,
            ]
        stats["opaque_predicates"] = stats.get("opaque_predicates", 0) + 1
        return (lines, 2)

    return _rewrite_smali_methods(path, on_start, None, stats)


# --- L59 method-call indirection --------------------------------------

INDIRECT_CLASS = "Lcom/appcore/runtime/ReaIndirect;"
_INVOKE_RE = re.compile(
    r"^(\s*)(invoke-\w+)(/range)?\s+\{([^}]*)\},\s*"
    r"(L[\w/$]+;)->(\w+)\(([^)]*)\)(\S+)\s*$")
# Opcodes that may be indirected. invoke-direct is EXCLUDED on
# purpose: a static stub in another class cannot call a private
# method (access check), and constructors must stay in place.
# invoke-super is excluded: super resolution belongs to the class
# that declares the call.
_INDIRECTABLE = {"invoke-virtual", "invoke-static", "invoke-interface"}


def _absolute_regs(regs, locals_n):
    """Register tokens -> absolute v-indices (pN == v(locals_n + N))."""
    out = []
    for r in regs:
        kind, num = r[0], int(r[1:])
        out.append(locals_n + num if kind == "p" else num)
    return out


def _is_contiguous(abs_regs):
    return all(b == a + 1 for a, b in zip(abs_regs, abs_regs[1:]))


def indirect_method_calls(path, targets, stubs, stats=None):
    """Route chosen method calls through a static indirection stub
    (L59). targets: list of (callee_class, method_name) — every
    matching invoke-virtual/static/interface call site in this file is
    rewritten to invoke-static/range on
    Lcom/appcore/runtime/ReaIndirect;->rea_indirect_N(...), and the
    stub's signature is recorded in `stubs` (a dict shared across
    files, keyed by full callee signature) for write_indirect_stub().
    No extra locals are needed: the replacement reuses the call's own
    registers. A call site is skipped (recorded) when its registers
    are non-contiguous and above v15 — /range cannot express it and a
    plain invoke cannot encode it.
    """
    stats = stats if stats is not None else {}
    target_set = set(targets)

    def on_line(ctx, line):
        m = _INVOKE_RE.match(line)
        if not m:
            return None
        indent, op, _rng, reglist, callee, name, params, ret = m.groups()
        if op not in _INDIRECTABLE:
            return None
        if name == "<init>":
            return None
        if (callee, name) not in target_set:
            return None
        regs = [r.strip() for r in reglist.split(",") if r.strip()]
        if not regs:
            return None
        abs_regs = _absolute_regs(regs, ctx["locals_n"])
        if not _is_contiguous(abs_regs):
            if max(abs_regs) > 15:
                stats.setdefault("indirect_skipped_regs", []).append(
                    "%s: %s" % (path, line.strip()))
                return None
            range_form = False
        else:
            range_form = True
        is_static = (op == "invoke-static")
        param_types = _parse_descriptor_params(params)
        # Stub params: `this` (callee type) first for instance calls.
        stub_params = ([callee] if not is_static else []) + [
            _param_type_string(params, i)
            for i in range(len(param_types))]
        key = (callee, name, tuple(stub_params), ret, op)
        stub = stubs.get(key)
        if stub is None:
            stub = {
                "name": "rea_indirect_%d" % len(stubs),
                "callee": callee, "method": name,
                "params": list(stub_params), "ret": ret,
                "orig_params": params, "is_static": is_static,
                "op": op,
            }
            stubs[key] = stub
        if range_form:
            first, last = regs[0], regs[-1]
            inv = ("%sinvoke-static/range {%s .. %s}, %s->%s(%s)%s"
                   % (indent, first, last, INDIRECT_CLASS, stub["name"],
                      "".join(stub_params), ret))
        else:
            inv = ("%sinvoke-static {%s}, %s->%s(%s)%s"
                   % (indent, ", ".join(regs), INDIRECT_CLASS,
                      stub["name"], "".join(stub_params), ret))
        stats["calls_indirected"] = stats.get("calls_indirected", 0) + 1
        return ([inv], 0)

    return _rewrite_smali_methods(path, None, on_line, stats)


def _param_type_string(params_desc, index):
    """The type string of the index-th parameter in a descriptor."""
    i, idx = 0, 0
    while i < len(params_desc):
        c = params_desc[i]
        if c == "L":
            j = params_desc.index(";", i)
            typ = params_desc[i:j + 1]
            i = j + 1
        elif c == "[":
            j = i
            while params_desc[j] == "[":
                j += 1
            if params_desc[j] == "L":
                j = params_desc.index(";", j) + 1
            else:
                j += 1
            typ = params_desc[i:j]
            i = j
        else:
            typ = c
            i += 1
        if idx == index:
            return typ
        idx += 1
    raise ValueError("parameter index %d out of range in (%s)"
                     % (index, params_desc))


def write_indirect_stub_class(smali_root, stubs):
    """Write smali/com/appcore/runtime/ReaIndirect.smali (L59) with
    one public static forwarding method per recorded stub. Each stub
    just re-issues the original invoke with the same arguments and
    returns the same value. `stubs` is the dict filled by
    indirect_method_calls(); pass .values() in insertion order.
    Returns the path written, or None when there are no stubs.
    """
    stub_list = list(stubs.values()) if isinstance(stubs, dict) \
        else list(stubs)
    if not stub_list:
        return None
    lines = [
        "# indirection stubs (L59) — generated, no behaviour.",
        "# Each method forwards one call to its original target.",
        ".class public Lcom/appcore/runtime/ReaIndirect;",
        ".super Ljava/lang/Object;",
        "",
        ".method public constructor <init>()V",
        "    .locals 0",
        "    invoke-direct {p0}, Ljava/lang/Object;-><init>()V",
        "    return-void",
        ".end method",
        "",
    ]
    for stub in stub_list:
        params = "".join(stub["params"])
        ret = stub["ret"]
        # Register mapping for the stub's own params (p0..), wide
        # params (J/D) occupy two registers.
        regs, cur = [], 0
        for p in stub["params"]:
            regs.append("p%d" % cur)
            cur += 2 if p in ("J", "D") else 1
        ret_local = 2 if ret in ("J", "D") else 1
        lines.append(".method public static %s(%s)%s"
                     % (stub["name"], params, ret))
        lines.append("    .locals %d" % (ret_local if ret != "V" else 0))
        op = ("invoke-static" if stub["is_static"]
              else stub["op"])  # virtual / interface as originally
        lines.append("    %s {%s}, %s->%s(%s)%s"
                     % (op, ", ".join(regs), stub["callee"],
                        stub["method"], stub["orig_params"], ret))
        if ret == "V":
            lines.append("    return-void")
        elif ret in ("J", "D"):
            lines.append("    move-result-wide v0")
            lines.append("    return-wide v0")
        elif ret.startswith("L") or ret.startswith("["):
            lines.append("    move-result-object v0")
            lines.append("    return-object v0")
        else:
            lines.append("    move-result v0")
            lines.append("    return v0")
        lines.append(".end method")
        lines.append("")
    d = Path(smali_root) / "com" / "appcore" / "runtime"
    d.mkdir(parents=True, exist_ok=True)
    p = d / "ReaIndirect.smali"
    p.write_text("\n".join(lines), encoding="utf-8")
    return p


# --- L11 control-flow flattening --------------------------------------

_FLATTEN_SKIP_RES = [
    re.compile(r"^\s*\.catch\b"),
    re.compile(r"^\s*\.catchall\b"),
    re.compile(r"^\s*\.param\b"),
    re.compile(r"^\s*\.local\b"),
    re.compile(r"^\s*\.annotation\b"),
    re.compile(r"^\s*packed-switch\b"),
    re.compile(r"^\s*sparse-switch\b"),
    re.compile(r"^\s*\.packed-switch\b"),
    re.compile(r"^\s*\.sparse-switch\b"),
    re.compile(r"^\s*fill-array-data\b"),
    re.compile(r"^\s*monitor-enter\b"),
    re.compile(r"^\s*monitor-exit\b"),
    re.compile(r"^\s*move-exception\b"),
    re.compile(r"^\s*:try_start"),
    re.compile(r"^\s*:try_end"),
]
_GOTO_RE = re.compile(
    r"^(\s*)(goto(?:/16|/32)?)\s+(:\w+)\s*$")
_IF_RE = re.compile(
    r"^(\s*)(if-(?:eq|ne|lt|ge|gt|le|eqz|nez|ltz|gez|gtz|lez))\s+"
    r"([vp]\d+(?:\s*,\s*[vp]\d+)?)\s*,\s*(:\w+)\s*$")
_RETURN_RE = re.compile(r"^\s*(return(?:-void|-wide|-object)?)\b")
_THROW_RE = re.compile(r"^\s*throw\b")
_INVOKE_LINE_RE = re.compile(r"^\s*invoke-\w+")
_MOVERESULT_RE = re.compile(r"^\s*move-result")


def _flatten_method_lines(method_lines, method_substrings, tag, stats):
    """Flatten ONE method's body into a state-variable dispatcher.

    Returns (new_lines, bump) or (None, 0) when the method is not
    eligible. new_lines include the .method line, a [indent, n]
    placeholder for the bumped .locals line, and .end method.
    Eligibility (checked, never guessed): has .locals; matches
    method_substrings when given; no try/catch, switches, array-data
    payloads, monitors, move-exception, .param/.local/annotation in
    the body; every branch target is a label defined in the body;
    every block ends in a terminator or a fall-through to a next
    block; no invoke is split from its move-result by a label; at
    most 128 blocks.
    """
    desc = method_lines[0]
    if method_substrings:
        if not any(s in desc for s in method_substrings):
            return None, 0
    locals_idx = None
    locals_n = None
    for i, ln in enumerate(method_lines):
        m = LOCALS_RE.match(ln)
        if m:
            locals_idx, locals_n = i, int(m.group(2))
            break
    if locals_idx is None:
        stats.setdefault("flatten_skipped", []).append(
            "no .locals: %s" % desc.strip())
        return None, 0
    if locals_n + 1 > 255:
        stats.setdefault("flatten_skipped", []).append(
            "locals would exceed 255: %s" % desc.strip())
        return None, 0
    # Prologue lines (annotations etc. before .locals) are copied
    # verbatim; the body is everything after .locals up to .end method.
    prologue = method_lines[:locals_idx + 1]
    body = method_lines[locals_idx + 1:-1]
    for ln in body:
        if any(rx.match(ln) for rx in _FLATTEN_SKIP_RES):
            stats.setdefault("flatten_skipped", []).append(
                "unsupported construct %r: %s"
                % (ln.strip()[:40], desc.strip()))
            return None, 0
    # Split into basic blocks: a new block starts at every label AND
    # after every terminator (goto / if-* / return / throw). A branch
    # in the middle of a straight-line run ends its block — splitting
    # only at labels would leave branches mid-block and the dispatcher
    # could never rewrite them.
    blocks = []  # (label_or_None, [instructions])
    cur_label, cur = None, []
    for ln in body:
        if LINE_RE.match(ln):
            stats["lines_stripped"] = stats.get("lines_stripped", 0) + 1
            continue
        if re.match(r"^\s*\.(prologue|epilogue)\b", ln):
            continue
        lm = _LABEL_RE.match(ln)
        if lm:
            blocks.append((cur_label, cur))
            cur_label, cur = lm.group(2), []
            continue
        cur.append(ln)
        if (_GOTO_RE.match(ln) or _IF_RE.match(ln)
                or _RETURN_RE.match(ln) or _THROW_RE.match(ln)):
            blocks.append((cur_label, cur))
            cur_label, cur = None, []
    blocks.append((cur_label, cur))
    # Drop the empty leading/trailing blocks the splitter creates when
    # the body starts with a label or ends with a terminator.
    while blocks and blocks[0][0] is None and not blocks[0][1]:
        blocks.pop(0)
    while blocks and blocks[-1][0] is None and not blocks[-1][1]:
        blocks.pop()
    if not blocks:
        stats.setdefault("flatten_skipped", []).append(
            "empty body: %s" % desc.strip())
        return None, 0
    if len(blocks) > 128:
        stats.setdefault("flatten_skipped", []).append(
            "too many blocks (%d): %s" % (len(blocks), desc.strip()))
        return None, 0
    label_to_block = {}
    for i, (label, _) in enumerate(blocks):
        if label is not None:
            label_to_block[label] = i
    # Every branch target must be a defined label.
    for _, instrs in blocks:
        for ln in instrs:
            for tm in _BRANCH_TARGET_RE.finditer(ln):
                if tm.group(0) not in label_to_block:
                    stats.setdefault("flatten_skipped", []).append(
                        "branch to undefined label %s: %s"
                        % (tm.group(0), desc.strip()))
                    return None, 0
    # No invoke may be split from its move-result by a label: a block
    # must not end with an invoke when the next block starts with a
    # move-result, and no block may start with a move-result.
    for i, (_, instrs) in enumerate(blocks):
        if instrs and _MOVERESULT_RE.match(instrs[0]):
            stats.setdefault("flatten_skipped", []).append(
                "block starts with move-result: %s" % desc.strip())
            return None, 0
        if (instrs and _INVOKE_LINE_RE.match(instrs[-1])
                and i + 1 < len(blocks) and blocks[i + 1][1]
                and _MOVERESULT_RE.match(blocks[i + 1][1][0])):
            stats.setdefault("flatten_skipped", []).append(
                "invoke split from move-result: %s" % desc.strip())
            return None, 0
    # Last block must have a terminator, and a trailing conditional
    # branch is not one: its fall-through would run off the end.
    last_label, last_instrs = blocks[-1]
    if last_instrs:
        last = last_instrs[-1]
        if _IF_RE.match(last):
            stats.setdefault("flatten_skipped", []).append(
                "last block ends with a conditional branch: %s"
                % desc.strip())
            return None, 0
        if not (_GOTO_RE.match(last)
                or _RETURN_RE.match(last) or _THROW_RE.match(last)):
            stats.setdefault("flatten_skipped", []).append(
                "last block has no terminator: %s" % desc.strip())
            return None, 0
    elif last_label is not None:
        stats.setdefault("flatten_skipped", []).append(
            "trailing empty block: %s" % desc.strip())
        return None, 0
    state = "v%d" % locals_n
    indent = "    "
    out = list(prologue[:-1])
    out.append([prologue[-1][0] if isinstance(prologue[-1], list)
                else LOCALS_RE.match(prologue[-1]).group(1),
                locals_n + 1])
    out.append("%sconst/16 %s, 0x0" % (indent, state))
    out.append(":rea_dispatch_%s" % tag)
    out.append("%spacked-switch %s, :rea_pswitch_data_%s"
               % (indent, state, tag))
    out.append(":rea_pswitch_data_%s" % tag)
    out.append(".packed-switch 0x0")
    for i in range(len(blocks)):
        out.append("    :rea_case_%s_%d" % (tag, i))
    out.append(".end packed-switch")
    for i, (_, instrs) in enumerate(blocks):
        out.append(":rea_case_%s_%d" % (tag, i))
        if not instrs:
            # Empty block: fall through to the next one.
            out.append("%sconst/16 %s, 0x%x" % (indent, state, i + 1))
            out.append("%sgoto :rea_dispatch_%s" % (indent, tag))
            continue
        term = instrs[-1]
        gm = _GOTO_RE.match(term)
        im = _IF_RE.match(term)
        if gm:
            target = label_to_block[gm.group(3)]
            out.extend(instrs[:-1])
            out.append("%sconst/16 %s, 0x%x" % (indent, state, target))
            out.append("%sgoto :rea_dispatch_%s" % (indent, tag))
        elif im:
            target = label_to_block[im.group(4)]
            fall = i + 1
            out.extend(instrs[:-1])
            out.append("%s%s %s, :rea_br_%s_%d_true"
                       % (indent, im.group(2), im.group(3), tag, i))
            out.append("%sconst/16 %s, 0x%x" % (indent, state, fall))
            out.append("%sgoto :rea_dispatch_%s" % (indent, tag))
            out.append(":rea_br_%s_%d_true" % (tag, i))
            out.append("%sconst/16 %s, 0x%x" % (indent, state, target))
            out.append("%sgoto :rea_dispatch_%s" % (indent, tag))
        elif _RETURN_RE.match(term) or _THROW_RE.match(term):
            out.extend(instrs)
        else:
            out.extend(instrs)
            out.append("%sconst/16 %s, 0x%x" % (indent, state, i + 1))
            out.append("%sgoto :rea_dispatch_%s" % (indent, tag))
    out.append(method_lines[-1])  # .end method
    stats["methods_flattened"] = stats.get("methods_flattened", 0) + 1
    stats.setdefault("flattened_methods", []).append(desc.strip())
    return out, 1


def flatten_smali_file(path, method_substrings=None, seed=0, stats=None):
    """Control-flow flatten (L11) for eligible methods in one smali
    file. Each eligible method body is split into blocks at its labels
    and rebuilt behind a packed-switch dispatcher driven by a new
    state local (1 extra local). Branch instructions become
    state-assignments + jumps back to the dispatcher; returns and
    throws stay terminal. Ineligible methods are left untouched and
    recorded in stats['flatten_skipped'] — never force-flattened.
    `seed` namespaces the generated labels so two runs cannot
    collide. MUST run after the other smali passes (it restructures
    the final instruction stream).
    Returns True if the file changed.
    """
    stats = stats if stats is not None else {}
    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    out, changed = [], False
    bumped = []
    tag_base = "%04x" % (int(seed) & 0xFFFF)
    counter = [0]
    i, n = 0, len(lines)
    while i < n:
        line = lines[i]
        if not METHOD_RE.match(line):
            out.append(line)
            i += 1
            continue
        j = i
        while j < n and not END_METHOD_RE.match(lines[j]):
            j += 1
        if j >= n:
            out.extend(lines[i:])
            break
        method_lines = lines[i:j + 1]
        tag = "%s_%d" % (tag_base, counter[0])
        counter[0] += 1
        flat, bump = _flatten_method_lines(
            method_lines, method_substrings, tag, stats)
        if flat is not None:
            method_start = len(out)
            out.extend(flat)
            # Locate the .locals placeholder to record the fixup.
            locals_new = None
            for k in range(method_start, len(out)):
                if isinstance(out[k], list):
                    locals_new = out[k][1]
                    break
            bumped.append({
                "start": method_start, "end": len(out) - 1,
                "locals_new": locals_new, "bump": bump,
                "desc": method_lines[0]})
            changed = True
        else:
            out.extend(method_lines)
        i = j + 1
    if changed:
        rendered = []
        for item in out:
            if isinstance(item, list):
                rendered.append("%s.locals %d" % (item[0], item[1]))
            else:
                rendered.append(item)
        if bumped:
            rendered = _fixup_high_regs(rendered, bumped, path, stats)
        path.write_text("\n".join(rendered) + "\n", encoding="utf-8")
    return changed

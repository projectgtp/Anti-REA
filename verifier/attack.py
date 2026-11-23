#!/usr/bin/env python3
"""Anti-REA v1.0 — attack verifier (generic, no Bridge code).

Compares a control APK against a protected APK with three independent
static tools and counts LITERAL (not regex) occurrences of each needle:

  1. jadx decompiled sources
  2. apktool decode (smali + resources)
  3. `strings` on the EXTRACTED classes.dex (never on the raw APK:
     zip entries are DEFLATED, so raw-APK strings reads ~0 by
     construction — v0.1 methodology bug #2)

Verdict (v1.0 rule — see notes below):
  PASS  iff (a) every tool ran without error, (b) protected == 0 for
        every needle in every tool, (c) every GIVEN needle has
        control > 0 in AT LEAST ONE tool, and (d) every tool finds
        control > 0 for at least one GIVEN needle (tool sanity: a
        tool that sees nothing at all is broken, not clean).
  Given needles are the ones passed on the command line; DERIVED
  needles (bare host, scheme/www/port/encoded variants expanded
  from them via transformer/config.py derive_needles) must also be
  0 in protected, but may be 0 in control — most derived spellings
  never occur in the control, and demanding control > 0 for them
  would fail every run. They are recorded as derived_vacuous.
  FAIL  otherwise. A needle that is vacuous in ONE tool but
        non-vacuous in another is recorded in `vacuous_in_tool`,
        not a failure — some needles are invisible to some tools
        by construction (see below).

Methodology notes (from v0.1 / v0.2, do not regress):
  - jadx needs JAVA_HOME set (~/workspace/tools/jdk17); without it
    jadx exits 1 with "JAVA_HOME is not set" and counts are 0/0.
  - jadx exits 1 on stdlib decompile errors even on a good run
    (v0.1: 16 errors, all in kotlin-stdlib, none in app classes).
    A non-zero jadx exit is therefore tolerated IF the sources
    directory was still produced; if no sources exist, the tool
    result is an ERROR, not a 0, and the verdict is FAIL.
  - All counting is literal: Python str.count on lines / `grep -F`
    semantics. Never regex — v0.2 caught `tunnel.key.` matching
    ordinary prose ("Seller tunnel key registered...") under regex.
  - v1.0 jadx counting is QUOTE-AWARE: only occurrences inside a
    `"..."` string literal count. Raw substring counting produced
    false positives from Java identifiers — e.g. the real secret
    label ".private" also matches `this.privateKeyBase64`, which
    is a field name, not a leaked secret. A leaked secret in
    decompiled Java always appears as a string literal.
  - v1.0 tree counting SKIPS binary files (anything that does not
    decode as UTF-8) and anything under `lib/`. The Bridge APK
    ships the untouched WireGuard native library libwg-go.so,
    whose Go symbol data contains the byte sequences ".private"
    and ".public" — v1.0 does not rewrite native libraries (L49
    is PARTIAL for exactly this reason), so counting .so bytes
    would fail every run for a reason unrelated to protection.
  - v1.0 verdict rule change: the old rule demanded control > 0
    for EVERY needle in EVERY tool. That is unachievable for
    honest reasons — jadx does not render every string (e.g. the
    sentence "Enter a full domain (for example
    bridge-marketplace.onrender.com)..." lives in smali and in
    the dex string table but jadx drops that method, so jadx
    control is 0 for that needle while strings_dex and apktool
    prove it present and protected). The new rule keeps the
    anti-vacuity guarantee at the needle level (control > 0
    somewhere) and at the tool level (each tool sees something),
    and records per-tool vacuity instead of failing on it.

Usage:
  python3 verifier/attack.py --control <apk> --protected <apk> \
      --needles NEEDLE1,NEEDLE2
  python3 verifier/attack.py --control <apk> --protected <apk> \
      --needles-file needles.txt [--out attack-report.json] [--workdir DIR]

Python stdlib only. If jadx or apktool is missing, exits non-zero
with a clear message — it never fakes a PASS.
"""
import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

HOME = Path.home()
JDK = HOME / "workspace/tools/jdk17"
BIN = HOME / "workspace/tools/bin"
JADX = BIN / "jadx"
APKTOOL = BIN / "apktool"

# --- Needle auto-derivation (same contract as transformer/config.py) ---
# The needles given on the command line are EXPANDED through
# config.derive_needles() before counting, so a run that only lists
# the full URL also checks its bare host, scheme/www/port/trailing-
# slash/encoded variants (the Bridge bare-domain slip class).
# The verdict treats the two sets differently, on purpose:
#   * GIVEN needles: protected must be 0 AND control must be > 0 in
#     at least one tool (the anti-vacuity guarantee — unchanged).
#   * DERIVED needles: protected must be 0, but control may be 0.
#     Most derived variants (ws://, :443, URL-encoded spellings)
#     never occur in the control at all; demanding control > 0 for
#     them would fail every run for a reason unrelated to
#     protection. A derived needle that DOES occur in control and is
#     0 in protected is the proof the derivation mattered (e.g. the
#     bare host); a derived needle that occurs in protected is a
#     FAIL, same as a given one. Derived needles with control == 0
#     are recorded in the report as derived_vacuous, not failures.
# transformer/config.py is the authority when importable; the local
# fallback below is the same minimal contract (see anti-rea.py).
_SCHEME_HOST_RE = re.compile(r"[A-Za-z][A-Za-z0-9+.-]*://([^/?#\s\"']+)")


def _derive_needles_fallback(strings):
    out, seen = [], set()

    def add(v):
        if v and v not in seen:
            seen.add(v)
            out.append(v)

    for s in strings or []:
        if not s:
            continue
        add(s)
        add(s.rstrip("/"))
        for m in _SCHEME_HOST_RE.finditer(s):
            netloc = m.group(1)
            hostport = netloc.rsplit("@", 1)[-1]
            if not hostport:
                continue
            add(hostport)
            if hostport.startswith("["):
                host = hostport.split("]", 1)[0] + "]"
            else:
                host = hostport.split(":")[0]
            # Bare host only — never the www-stripped form, so this
            # stays a subset of config.derive_needles() (which adds
            # www. but never strips it).
            add(host)
    return out


try:
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent
                           / "transformer"))
    from config import derive_needles as _cfg_derive  # noqa: E402
    derive_needles = _cfg_derive
    NEEDLE_DERIVATION_SOURCE = "transformer/config.py"
except Exception:  # noqa: BLE001 - config import must never break attack
    derive_needles = _derive_needles_fallback
    NEEDLE_DERIVATION_SOURCE = ("attack.py fallback (transformer/config.py "
                                "unavailable)")


def die(msg):
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(2)


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def count_literal_lines(text, needle):
    """Literal line count, i.e. `grep -F -c` semantics."""
    return sum(1 for line in text.splitlines() if needle in line)


def _read_text_file(path):
    """Read a file as UTF-8 text, or return None for binary files
    (anything that does not decode as UTF-8) and for anything under
    a `lib/` directory (native libraries — v1.0 does not rewrite
    them, L49 PARTIAL, so their bytes must not count)."""
    if "lib" in path.parts:
        return None
    try:
        return path.read_bytes().decode("utf-8")
    except (OSError, UnicodeDecodeError):
        return None


_QUOTED_SPAN_RE = re.compile(r'"((?:[^"\\]|\\.)*)"')


def count_all_in_tree(root, needles, quoted):
    """Single-pass literal count for EVERY needle across every TEXT
    file under root (binary files skipped — see _read_text_file).

    One walk, not one walk per needle: derivation can expand a
    2-needle config into ~150 needles, and a per-needle walk would
    re-read a big decompiled tree 150 times. Returns (counts dict,
    files read). Quoted mode counts only occurrences inside a
    `"..."` string literal (jadx); plain mode counts any line
    containing the needle (apktool). A line counts at most once per
    needle, matching the old per-needle `grep -F -c` semantics.
    """
    counts = {n: 0 for n in needles}
    files = 0
    for p in Path(root).rglob("*"):
        if not p.is_file():
            continue
        text = _read_text_file(p)
        if text is None:
            continue
        files += 1
        for line in text.splitlines():
            if quoted:
                spans = [m.group(1) for m in _QUOTED_SPAN_RE.finditer(line)]
                if not spans:
                    continue
                for n in needles:
                    if any(n in s for s in spans):
                        counts[n] += 1
            else:
                for n in needles:
                    if n in line:
                        counts[n] += 1
    return counts, files


def count_literal_in_tree(root, needle):
    """Literal line count across every TEXT file under root
    (binary files skipped — see _read_text_file)."""
    total, files = count_all_in_tree(root, [needle], quoted=False)
    return total[needle], files


def count_quoted_lines(text, needle):
    """Lines where the needle occurs inside a `"..."` string
    literal. Used for jadx output: a leaked secret in decompiled
    Java is always a string literal, while a raw substring match
    also hits identifiers (`this.privateKeyBase64` contains
    ".private" but is a field name, not a secret)."""
    n = 0
    for line in text.splitlines():
        for m in _QUOTED_SPAN_RE.finditer(line):
            if needle in m.group(1):
                n += 1
                break
    return n


def count_quoted_in_tree(root, needle):
    """Quote-aware literal count across every text file under root."""
    total, files = count_all_in_tree(root, [needle], quoted=True)
    return total[needle], files


def extract_all_dex(apk_path, work, label):
    """Extract EVERY classes*.dex from an APK into work/.

    Returns a list of paths (sorted, classes.dex first). Raises
    FileNotFoundError when the APK has no dex at all. The old code
    extracted only classes.dex (or the first classes*.dex), so a
    needle living in classes2.dex was invisible to strings_dex —
    a false PASS on multi-dex APKs.
    """
    out_paths = []
    with zipfile.ZipFile(apk_path) as z:
        names = sorted(n for n in z.namelist()
                       if re.fullmatch(r"classes\d*\.dex", n))
        if not names:
            raise FileNotFoundError("no classes*.dex in APK")
        for i, name in enumerate(names):
            out = work / f"{label}-classes{i + 1}.dex"
            out.write_bytes(z.read(name))
            out_paths.append(out)
    return out_paths


def strings_counts(dex_paths, needles):
    """Run `strings` once per dex file and count every needle in
    the output (single pass per file). Returns {needle: count}."""
    counts = {n: 0 for n in needles}
    for dex_path in dex_paths:
        proc = subprocess.run(["strings", str(dex_path)],
                              capture_output=True, text=True, timeout=120)
        for line in proc.stdout.splitlines():
            for n in needles:
                if n in line:
                    counts[n] += 1
    return counts


def run(cmd, env, timeout=600):
    return subprocess.run(cmd, capture_output=True, text=True,
                          env=env, timeout=timeout)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--control", required=True, help="control (unprotected) APK")
    ap.add_argument("--protected", required=True, help="protected APK")
    ap.add_argument("--needles", default="",
                    help="comma-separated literal needles")
    ap.add_argument("--needles-file", default="",
                    help="file with one literal needle per line")
    ap.add_argument("--out", default="attack-report.json",
                    help="JSON report output path (default: attack-report.json)")
    ap.add_argument("--workdir", default="",
                    help="work dir for jadx/apktool/dex output "
                         "(default: fresh dir under $JOBDIR or /home/hatch/tmp)")
    args = ap.parse_args()

    needles = []
    if args.needles:
        needles += [n for n in args.needles.split(",") if n.strip()]
    if args.needles_file:
        try:
            needles += [l.strip() for l in Path(args.needles_file).read_text().splitlines()
                        if l.strip() and not l.strip().startswith("#")]
        except OSError as e:
            die(f"cannot read needles file {args.needles_file}: {e}")
    # Deduplicate, keep order.
    needles_given = list(dict.fromkeys(needles))
    if not needles_given:
        die("no needles given (--needles or --needles-file required)")
    # Expand through derivation (bare host etc.). The verdict holds
    # GIVEN needles to the full anti-vacuity rule and DERIVED needles
    # to protected==0 only (see the module note above).
    needles = derive_needles(needles_given)
    derived = [n for n in needles if n not in set(needles_given)]
    print(f"needles: {len(needles_given)} given, {len(derived)} derived "
          f"({NEEDLE_DERIVATION_SOURCE})")

    control = Path(args.control)
    protected = Path(args.protected)
    for label, p in (("control", control), ("protected", protected)):
        if not p.is_file():
            die(f"{label} APK not found: {p}")

    # Tool availability: missing tool = hard error, never a faked PASS.
    missing = []
    if not JADX.is_file():
        missing.append(f"jadx not found at {JADX}")
    if not APKTOOL.is_file():
        missing.append(f"apktool not found at {APKTOOL}")
    if not shutil.which("strings"):
        missing.append("`strings` not found on PATH")
    if missing:
        die("required tool(s) missing, cannot run attack test:\n  - " +
            "\n  - ".join(missing))

    if args.workdir:
        work = Path(args.workdir)
        work.mkdir(parents=True, exist_ok=True)
    else:
        base = os.environ.get("JOBDIR") or os.environ.get("TMPDIR") or "/home/hatch/tmp"
        work = Path(tempfile.mkdtemp(prefix="antirea-attack-", dir=base))
    print(f"workdir: {work}")

    env = dict(os.environ, JAVA_HOME=str(JDK),
               PATH=f"{JDK}/bin:{BIN}:{os.environ.get('PATH', '')}")

    report = {
        "control_apk": str(control),
        "protected_apk": str(protected),
        "control_sha256": sha256(control),
        "protected_sha256": sha256(protected),
        "control_bytes": control.stat().st_size,
        "protected_bytes": protected.stat().st_size,
        "needles": needles,
        "needles_given": needles_given,
        "derived_needles": derived,
        "needle_derivation_source": NEEDLE_DERIVATION_SOURCE,
        "tools": {},
        "control": {},
        "protected": {},
        "errors": [],
        "verdict": "FAIL",
        "reason": "",
    }

    def record_tool(name, control_counts, protected_counts, error=None):
        report["tools"][name] = {"error": error}
        report["control"][name] = control_counts
        report["protected"][name] = protected_counts

    # --- 1. Extract ALL classes*.dex from both APKs (zipfile, not
    # raw strings) — a needle in classes2.dex must count too. ---
    dex = {}
    for label, apk in (("control", control), ("protected", protected)):
        try:
            dex[label] = extract_all_dex(apk, work, label)
            print(f"{label} dex: {len(dex[label])} file(s) "
                  f"({sum(p.stat().st_size for p in dex[label])} bytes)")
        except Exception as e:  # noqa: BLE001 - report as tool error
            record_tool("strings_dex", {}, {}, error=f"dex extract failed ({label}): {e}")
            report["errors"].append(f"strings_dex dex extract failed ({label}): {e}")

    # --- 2. strings on the extracted dex files (one run per file) ---
    if "control" in dex and "protected" in dex:
        try:
            c_counts = strings_counts(dex["control"], needles)
            p_counts = strings_counts(dex["protected"], needles)
            record_tool("strings_dex", c_counts, p_counts)
        except Exception as e:  # noqa: BLE001 - report, never traceback
            record_tool("strings_dex", {}, {}, error=f"strings failed: {e}")
            report["errors"].append(f"strings_dex: {e}")

    # --- 3. jadx (non-zero exit tolerated if sources exist) ---
    jadx_dirs = {}
    for label, apk in (("control", control), ("protected", protected)):
        outdir = work / f"jadx-{label}"
        try:
            r = run(["jadx", "-q", "-d", str(outdir), str(apk)], env)
        except subprocess.TimeoutExpired:
            print(f"jadx {label}: TIMEOUT after 600s (tool failure, not a 0)")
            jadx_dirs[label] = None
            continue
        src = outdir / "sources"
        produced = src.is_dir() and any(src.rglob("*.java"))
        print(f"jadx {label}: exit={r.returncode} sources_produced={produced}")
        if r.returncode != 0 and r.stderr:
            print(f"  jadx {label} stderr tail: {r.stderr.strip()[-300:]}")
        jadx_dirs[label] = src if produced else None
    if jadx_dirs["control"] is not None and jadx_dirs["protected"] is not None:
        # Quote-aware: only string literals count (see docstring).
        # Single pass per tree — see count_all_in_tree.
        c_counts, _ = count_all_in_tree(jadx_dirs["control"], needles, quoted=True)
        p_counts, _ = count_all_in_tree(jadx_dirs["protected"], needles, quoted=True)
        record_tool("jadx", c_counts, p_counts)
    else:
        missing_side = [l for l in ("control", "protected") if jadx_dirs[l] is None]
        err = (f"jadx produced no sources for: {', '.join(missing_side)} "
               "(non-zero exit with no output is a tool failure, not a 0)")
        record_tool("jadx", {}, {}, error=err)
        report["errors"].append(err)

    # --- 4. apktool decode ---
    apktool_dirs = {}
    for label, apk in (("control", control), ("protected", protected)):
        outdir = work / f"apktool-{label}"
        try:
            r = run(["apktool", "d", "-q", "-o", str(outdir), str(apk)], env)
        except subprocess.TimeoutExpired:
            print(f"apktool {label}: TIMEOUT after 600s (tool failure, not a 0)")
            apktool_dirs[label] = None
            continue
        produced = outdir.is_dir() and any(outdir.rglob("*"))
        print(f"apktool {label}: exit={r.returncode} output_produced={produced}")
        if r.returncode != 0 and (r.stdout or r.stderr):
            tail = (r.stdout + r.stderr).strip()[-300:]
            print(f"  apktool {label} output tail: {tail}")
        apktool_dirs[label] = outdir if produced else None
    if apktool_dirs["control"] is not None and apktool_dirs["protected"] is not None:
        c_counts, _ = count_all_in_tree(apktool_dirs["control"], needles, quoted=False)
        p_counts, _ = count_all_in_tree(apktool_dirs["protected"], needles, quoted=False)
        record_tool("apktool", c_counts, p_counts)
    else:
        missing_side = [l for l in ("control", "protected") if apktool_dirs[l] is None]
        err = f"apktool produced no output for: {', '.join(missing_side)}"
        record_tool("apktool", {}, {}, error=err)
        report["errors"].append(err)

    # --- Verdict (v1.0 rule, derivation-aware): every tool ran;
    # protected == 0 for every needle (given AND derived); every
    # GIVEN needle has control > 0 in at least one tool; every tool
    # sees control > 0 for at least one GIVEN needle. A DERIVED
    # needle with control == 0 is recorded in derived_vacuous, not
    # a failure — most derived spellings never occur in the control
    # (see the module note). Per-tool vacuity for a single needle is
    # recorded, not a failure (see docstring).
    reasons = []
    vacuous = {}
    derived_vacuous = []
    if report["errors"]:
        reasons.append("tool error(s): " + "; ".join(report["errors"]))
    tools = ("strings_dex", "jadx", "apktool")
    for tool in tools:
        c_counts = report["control"].get(tool) or {}
        p_counts = report["protected"].get(tool) or {}
        if c_counts and not any(c_counts.get(n, 0) > 0 for n in needles_given):
            reasons.append(
                f"{tool}: control=0 for every GIVEN needle (tool saw "
                "nothing — broken run, not a clean result)")
        for needle in needles:
            if needle not in c_counts or needle not in p_counts:
                reasons.append(f"{tool} [{needle}]: missing count (tool did not run)")
                continue
            if p_counts[needle] != 0:
                reasons.append(
                    f"{tool} [{needle}]: protected={p_counts[needle]} (must be 0)")
    for needle in needles_given:
        if not any((report["control"].get(t) or {}).get(needle, 0) > 0
                   for t in tools):
            reasons.append(
                f"[{needle}]: control=0 in every tool (vacuous test — "
                "needle not found in control, cannot PASS)")
    for needle in derived:
        if not any((report["control"].get(t) or {}).get(needle, 0) > 0
                   for t in tools):
            derived_vacuous.append(needle)
    for tool in tools:
        for needle in needles:
            c = (report["control"].get(tool) or {}).get(needle)
            p = (report["protected"].get(tool) or {}).get(needle)
            if c == 0 and p == 0:
                vacuous.setdefault(tool, []).append(needle)
    report["vacuous_in_tool"] = vacuous
    report["derived_vacuous"] = derived_vacuous

    if reasons:
        report["verdict"] = "FAIL"
        report["reason"] = "; ".join(reasons)
    else:
        report["verdict"] = "PASS"
        report["reason"] = ("protected is 0 for every needle (given + "
                            "derived) in every tool; every GIVEN needle "
                            "found in control (>0) in at least one tool; "
                            "every tool saw at least one GIVEN needle. "
                            + (f"{len(derived_vacuous)} derived needle(s) "
                               "vacuous in control (checked protected==0 "
                               "only, not a failure): "
                               + json.dumps(derived_vacuous)
                               if derived_vacuous else
                               "No derived needles were vacuous.")
                            + (" Per-tool vacuous needles (needle invisible "
                               "to that tool by construction, not a failure): "
                               + json.dumps(vacuous) if vacuous else
                               " No per-tool vacuous needles."))

    print()
    for tool in ("strings_dex", "jadx", "apktool"):
        for needle in needles:
            c = (report["control"].get(tool) or {}).get(needle, "?")
            p = (report["protected"].get(tool) or {}).get(needle, "?")
            tag = " [derived]" if needle in set(derived) else ""
            print(f"  {tool} [{needle}]{tag}: control={c} protected={p}")
    print(f"VERDICT: {report['verdict']}")
    print(f"REASON: {report['reason']}")

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(report, indent=2))
    print(f"report written: {out_path}")
    print(json.dumps(report, indent=2))
    sys.exit(0 if report["verdict"] == "PASS" else 1)


if __name__ == "__main__":
    main()

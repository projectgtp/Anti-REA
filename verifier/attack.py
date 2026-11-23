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
        every needle in every tool, (c) every needle has control > 0
        in AT LEAST ONE tool, and (d) every tool finds control > 0
        for at least one needle (tool sanity: a tool that sees
        nothing at all is broken, not clean).
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


def count_literal_in_tree(root, needle):
    """Literal line count across every TEXT file under root
    (binary files skipped — see _read_text_file)."""
    total = 0
    files = 0
    for p in Path(root).rglob("*"):
        if not p.is_file():
            continue
        text = _read_text_file(p)
        if text is None:
            continue
        files += 1
        total += count_literal_lines(text, needle)
    return total, files


_QUOTED_SPAN_RE = re.compile(r'"((?:[^"\\]|\\.)*)"')


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
    total = 0
    files = 0
    for p in Path(root).rglob("*"):
        if not p.is_file():
            continue
        text = _read_text_file(p)
        if text is None:
            continue
        files += 1
        total += count_quoted_lines(text, needle)
    return total, files


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
        needles += [l.strip() for l in Path(args.needles_file).read_text().splitlines()
                    if l.strip() and not l.strip().startswith("#")]
    # Deduplicate, keep order.
    needles = list(dict.fromkeys(needles))
    if not needles:
        die("no needles given (--needles or --needles-file required)")

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

    # --- 1. Extract classes.dex from both APKs (zipfile, not raw strings) ---
    dex = {}
    for label, apk in (("control", control), ("protected", protected)):
        try:
            with zipfile.ZipFile(apk) as z:
                names = z.namelist()
                dex_name = "classes.dex" if "classes.dex" in names else None
                if dex_name is None:
                    dex_name = next((n for n in names if n.startswith("classes") and n.endswith(".dex")), None)
                if dex_name is None:
                    raise FileNotFoundError("no classes*.dex in APK")
                out = work / f"{label}-classes.dex"
                out.write_bytes(z.read(dex_name))
                dex[label] = out
                print(f"{label} dex: {dex_name} ({out.stat().st_size} bytes)")
        except Exception as e:  # noqa: BLE001 - report as tool error
            record_tool("strings_dex", {}, {}, error=f"dex extract failed ({label}): {e}")
            report["errors"].append(f"strings_dex dex extract failed ({label}): {e}")

    # --- 2. strings on extracted classes.dex ---
    if "control" in dex and "protected" in dex:
        c_counts, p_counts, err = {}, {}, None
        for needle in needles:
            try:
                c_out = subprocess.run(["strings", str(dex["control"])],
                                       capture_output=True, text=True, timeout=120)
                p_out = subprocess.run(["strings", str(dex["protected"])],
                                       capture_output=True, text=True, timeout=120)
                c_counts[needle] = count_literal_lines(c_out.stdout, needle)
                p_counts[needle] = count_literal_lines(p_out.stdout, needle)
            except Exception as e:  # noqa: BLE001
                err = str(e)
                break
        record_tool("strings_dex", c_counts, p_counts, error=err)
        if err:
            report["errors"].append(f"strings_dex: {err}")

    # --- 3. jadx (non-zero exit tolerated if sources exist) ---
    jadx_dirs = {}
    for label, apk in (("control", control), ("protected", protected)):
        outdir = work / f"jadx-{label}"
        r = run(["jadx", "-q", "-d", str(outdir), str(apk)], env)
        src = outdir / "sources"
        produced = src.is_dir() and any(src.rglob("*.java"))
        print(f"jadx {label}: exit={r.returncode} sources_produced={produced}")
        if r.returncode != 0 and r.stderr:
            print(f"  jadx {label} stderr tail: {r.stderr.strip()[-300:]}")
        jadx_dirs[label] = src if produced else None
    if jadx_dirs["control"] is not None and jadx_dirs["protected"] is not None:
        # Quote-aware: only string literals count (see docstring).
        c_counts = {n: count_quoted_in_tree(jadx_dirs["control"], n)[0] for n in needles}
        p_counts = {n: count_quoted_in_tree(jadx_dirs["protected"], n)[0] for n in needles}
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
        r = run(["apktool", "d", "-q", "-o", str(outdir), str(apk)], env)
        produced = outdir.is_dir() and any(outdir.rglob("*"))
        print(f"apktool {label}: exit={r.returncode} output_produced={produced}")
        if r.returncode != 0 and (r.stdout or r.stderr):
            tail = (r.stdout + r.stderr).strip()[-300:]
            print(f"  apktool {label} output tail: {tail}")
        apktool_dirs[label] = outdir if produced else None
    if apktool_dirs["control"] is not None and apktool_dirs["protected"] is not None:
        c_counts = {n: count_literal_in_tree(apktool_dirs["control"], n)[0] for n in needles}
        p_counts = {n: count_literal_in_tree(apktool_dirs["protected"], n)[0] for n in needles}
        record_tool("apktool", c_counts, p_counts)
    else:
        missing_side = [l for l in ("control", "protected") if apktool_dirs[l] is None]
        err = f"apktool produced no output for: {', '.join(missing_side)}"
        record_tool("apktool", {}, {}, error=err)
        report["errors"].append(err)

    # --- Verdict (v1.0 rule): every tool ran; protected == 0 for
    # every needle in every tool; every needle has control > 0 in at
    # least one tool; every tool sees control > 0 for at least one
    # needle. Per-tool vacuity for a single needle is recorded, not
    # a failure (see docstring).
    reasons = []
    vacuous = {}
    if report["errors"]:
        reasons.append("tool error(s): " + "; ".join(report["errors"]))
    tools = ("strings_dex", "jadx", "apktool")
    for tool in tools:
        c_counts = report["control"].get(tool) or {}
        p_counts = report["protected"].get(tool) or {}
        if c_counts and not any(v > 0 for v in c_counts.values()):
            reasons.append(
                f"{tool}: control=0 for every needle (tool saw nothing — "
                "broken run, not a clean result)")
        for needle in needles:
            if needle not in c_counts or needle not in p_counts:
                reasons.append(f"{tool} [{needle}]: missing count (tool did not run)")
                continue
            if p_counts[needle] != 0:
                reasons.append(
                    f"{tool} [{needle}]: protected={p_counts[needle]} (must be 0)")
    for needle in needles:
        if not any((report["control"].get(t) or {}).get(needle, 0) > 0
                   for t in tools):
            reasons.append(
                f"[{needle}]: control=0 in every tool (vacuous test — "
                "needle not found in control, cannot PASS)")
    for tool in tools:
        for needle in needles:
            c = (report["control"].get(tool) or {}).get(needle)
            p = (report["protected"].get(tool) or {}).get(needle)
            if c == 0 and p == 0:
                vacuous.setdefault(tool, []).append(needle)
    report["vacuous_in_tool"] = vacuous

    if reasons:
        report["verdict"] = "FAIL"
        report["reason"] = "; ".join(reasons)
    else:
        report["verdict"] = "PASS"
        report["reason"] = ("protected is 0 for every needle in every tool; "
                            "every needle found in control (>0) in at least "
                            "one tool; every tool saw at least one needle. "
                            + ("Per-tool vacuous needles (needle invisible "
                               "to that tool by construction, not a failure): "
                               + json.dumps(vacuous) if vacuous else
                               "No per-tool vacuous needles."))

    print()
    for tool in ("strings_dex", "jadx", "apktool"):
        for needle in needles:
            c = (report["control"].get(tool) or {}).get(needle, "?")
            p = (report["protected"].get(tool) or {}).get(needle, "?")
            print(f"  {tool} [{needle}]: control={c} protected={p}")
    print(f"VERDICT: {report['verdict']}")
    print(f"REASON: {report['reason']}")

    out_path = Path(args.out)
    out_path.write_text(json.dumps(report, indent=2))
    print(f"report written: {out_path}")
    print(json.dumps(report, indent=2))
    sys.exit(0 if report["verdict"] == "PASS" else 1)


if __name__ == "__main__":
    main()

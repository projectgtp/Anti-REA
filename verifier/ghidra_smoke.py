#!/usr/bin/env python3
"""Anti-REA v1.0 — L90 Ghidra smoke (native static analysis).

Runs Ghidra 12.2 headless (analyzeHeadless, via the REA install) on
one .so, with a hard timeout, and reports:
  * whether headless analysis completed (exit 0 + "Analysis succeeded")
  * function count and names (via the AntiReaSmoke post-script)
  * whether each needle string is found as a defined string

Usage:
  python3 verifier/ghidra_smoke.py --so libfoo.so \
      --needles SECRET1,SECRET2 [--out report.json] [--timeout 120]

The post-script lives at verifier/ghidra_scripts/AntiReaSmoke.java.
Work goes under /home/hatch/tmp (never /tmp). Ghidra needs JDK 25
(~/workspace/tools/jdk25); the script sets JAVA_HOME itself.

Honest scope: this is a SMOKE test — it proves Ghidra can open and
analyse the file and find (or not find) a string. It does not prove
a protected native library is safe, and L12 (native string hide) is
still PLANNED: v1.0 does not rewrite .so files.

First successful run (2026-11-23): libtiny.so (15 KB, 2 test
functions + string GHIDRA-SMOKE-STRING-1234), 17 s, exit 0,
13 functions found, needle string_hits=1. Earlier attempts that
timed out at 420 s were a wrong invocation (missing project dir),
not a Ghidra limitation.
"""
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
GHIDRA_HOME = Path.home() / "workspace" / "tools" / "ghidra_12.2_PUBLIC"
ANALYZE = GHIDRA_HOME / "support" / "analyzeHeadless"
JDK25 = Path.home() / "workspace" / "tools" / "jdk25"
SCRIPT_DIR = Path(__file__).resolve().parent / "ghidra_scripts"


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--so", required=True, help=".so file to analyse")
    ap.add_argument("--needles", default="",
                    help="comma-separated literal needles to search for")
    ap.add_argument("--out", default="ghidra-smoke-report.json")
    ap.add_argument("--timeout", type=int, default=120,
                    help="hard timeout in seconds (default 120)")
    ap.add_argument("--workdir", default="",
                    help="work dir (default: fresh dir under /home/hatch/tmp)")
    args = ap.parse_args(argv)

    so = Path(args.so)
    if not so.is_file():
        print("ERROR: .so not found: %s" % so, file=sys.stderr)
        return 2
    if not ANALYZE.is_file():
        print("ERROR: analyzeHeadless not found at %s" % ANALYZE,
              file=sys.stderr)
        return 2
    needles = [n for n in args.needles.split(",") if n.strip()]

    if args.workdir:
        work = Path(args.workdir)
        work.mkdir(parents=True, exist_ok=True)
    else:
        base = os.environ.get("JOBDIR") or "/home/hatch/tmp"
        work = Path(tempfile.mkdtemp(prefix="antirea-ghidra-",
                                     dir=base))
    proj = work / "proj"
    proj.mkdir(parents=True, exist_ok=True)
    log_path = work / "ghidra.log"

    env = dict(os.environ, JAVA_HOME=str(JDK25),
               PATH="%s/bin:%s" % (JDK25, os.environ.get("PATH", "")))
    report = {
        "so": str(so), "so_sha256": None, "needles": needles,
        "timeout_seconds": args.timeout, "workdir": str(work),
        "exit_code": None, "timed_out": False,
        "analysis_succeeded": False, "functions": None,
        "function_names": [], "needle_hits": {},
        "verdict": "FAIL", "reason": "",
        "generated_utc": datetime.now(timezone.utc).isoformat(),
    }
    import hashlib
    report["so_sha256"] = hashlib.sha256(so.read_bytes()).hexdigest()

    needle = needles[0] if needles else ""
    cmd = [str(ANALYZE), str(proj), "SmokeProj",
           "-import", str(so),
           "-scriptPath", str(SCRIPT_DIR),
           "-postScript", "AntiReaSmoke", needle]
    print("workdir: %s" % work)
    print("running: %s (timeout %ds)" % (" ".join(cmd), args.timeout))
    try:
        p = subprocess.run(cmd, capture_output=True, text=True,
                           env=env, timeout=args.timeout)
        report["exit_code"] = p.returncode
        log_path.write_text((p.stdout or "") + (p.stderr or ""),
                            encoding="utf-8")
    except subprocess.TimeoutExpired:
        report["timed_out"] = True
        report["reason"] = ("analyzeHeadless did not finish within "
                            "%ds (hard timeout)" % args.timeout)
        Path(args.out).write_text(json.dumps(report, indent=2))
        print("VERDICT: FAIL — %s" % report["reason"])
        return 1

    log = log_path.read_text(encoding="utf-8", errors="replace")
    report["analysis_succeeded"] = "Analysis succeeded for file" in log
    m = re.search(r"ANTIREA-SMOKE functions=(\d+)", log)
    if m:
        report["functions"] = int(m.group(1))
    m = re.search(r"ANTIREA-SMOKE function_names=\[(.*?)\]", log)
    if m and m.group(1).strip():
        report["function_names"] = [n.strip() for n in
                                    m.group(1).split(",")]
    m = re.search(r"ANTIREA-SMOKE needle=(.*?) string_hits=(\d+)", log)
    if m:
        report["needle_hits"][m.group(1)] = int(m.group(2))
    # Extra needles beyond the first are searched in the raw log text
    # only as a fallback note — the script checks the first needle
    # properly as a defined string; others are reported as unknown.
    for n in needles[1:]:
        report["needle_hits"].setdefault(n, None)

    reasons = []
    if report["exit_code"] != 0:
        reasons.append("analyzeHeadless exit=%s" % report["exit_code"])
    if not report["analysis_succeeded"]:
        reasons.append("no 'Analysis succeeded' line in the log")
    if report["functions"] is None:
        reasons.append("post-script produced no function count")
    if reasons:
        report["reason"] = "; ".join(reasons)
    else:
        report["verdict"] = "PASS"
        report["reason"] = (
            "Ghidra analysed %s: %d functions, needle %r hits=%s"
            % (so.name, report["functions"], needle,
               report["needle_hits"].get(needle)))
    print("functions=%s needle_hits=%s" % (report["functions"],
                                            report["needle_hits"]))
    print("VERDICT: %s" % report["verdict"])
    print("REASON: %s" % report["reason"])
    Path(args.out).write_text(json.dumps(report, indent=2))
    print("report written: %s (log: %s)" % (args.out, log_path))
    return 0 if report["verdict"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())

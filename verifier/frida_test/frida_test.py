#!/usr/bin/env python3
"""Anti-REA v1.0 — L89 Frida runtime test harness.

Runs FIVE live Frida checks against a protected APK on a real phone
and classifies each one as PASS (protection held), BREAK (protection
defeated — report it), INCONCLUSIVE (no decisive evidence) or ERROR
(the harness/tooling failed, not the app).

The five checks
  F1 attach      — Frida agent attaches to the running app process.
  F2 gadget      — frida-gadget injected (repacked APK, libfrida-gadget.so).
  F3 hook        — hook ReaRuntime.decrypt / verifyIntegrity at runtime.
  F4 memread     — read an obfuscated value / the test secret from RAM.
  F5 ssl-unpin   — hook the TLS trust path (SSL unpinning attempt).

Every check has its expected results defined in CHECKS below:
what PASS looks like, what BREAK looks like, and what counts as
INCONCLUSIVE. A BREAK verdict always wins over a PASS verdict for the
same check: if a hook fired AND the app later noticed Frida, the hook
still worked, so it is a BREAK.

Modes
  --dry-run            No device needed. Runs all five checks against
                       canned fake Frida output (two scenarios: the
                       protected behaviour and the attacker-wins
                       behaviour) and proves the classifier sorts them
                       correctly. This is the mode that runs in this VM.
  --from-file FILE     Classify a real Frida transcript the tester
                       saved on their PC (see README.md). No device
                       needed at classify time.
  (live) --package PKG
                       Attach Frida to the app on a connected phone
                       and run frida_script.js for real. Needs adb +
                       frida-tools + frida-server on the phone.
                       Exit 2 with a plain message if any of those
                       is missing — never pretend a live run happened.
  --list-checks        Print the five checks and their expectations.

Python stdlib only. No network. Temp files (live mode only) go under
/home/hatch/tmp, never /tmp (512 MB tmpfs).

Usage:
  python3 frida_test.py --dry-run [--out report.json]
  python3 frida_test.py --from-file transcript.txt [--check F3] [--out report.json]
  python3 frida_test.py --package com.antirea.testapp [--timeout 120] [--out report.json]
  python3 frida_test.py --list-checks
"""
import argparse
import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
AGENT = HERE / "frida_script.js"

LAYER = "L89"
DEFAULT_PACKAGE = "com.antirea.testapp"  # tester-pack test app
BRIDGE_PACKAGE = "com.bridge.mvp"       # tester-pack Bridge 2.14.0
# Fake test value from the tester brief — NOT a real secret. The live
# memory-scan check looks for this string in RAM; finding it plain
# means the obfuscation (L102) failed at runtime.
TESTAPP_SECRET = "TEST-SECRET-7f3a9-generic"
BRIDGE_NEEDLE = "mbbridge.onrender.com"  # public URL, tester-brief target

# ---------------------------------------------------------------- checks
# Each check: what the Frida agent tries, what PASS looks like (the
# protection held), what BREAK looks like (the protection was beaten),
# and the agent message tags that prove each outcome. Tags are the
# "[ANTIREA] TAG ..." lines frida_script.js sends; the classifier
# matches them, never free-form prose.

CHECKS = [
    {
        "id": "F1",
        "name": "attach",
        "title": "Frida agent attach to the running app",
        "target": "com.appcore.runtime.ReaEnv (fridaMapsDetected, "
                  "fridaPortsDetected, checkAll)",
        "method": "frida -U -f <package> -l frida_script.js --no-pause; "
                  "agent sends ATTACHED, then reads ReaEnv.checkAll()",
        "pass_when": "App detects Frida (ENV_DETECTED frida-maps and/or "
                     "frida-ports) and refuses the sensitive action, or "
                     "the process exits/detaches before the agent can "
                     "do anything (APP_REFUSED / APP_EXITED with no "
                     "agent work done).",
        "break_when": "Agent stays ATTACHED, app keeps running normally, "
                      "and ReaEnv.checkAll() reports no frida finding "
                      "(ENV_CLEAN) — Frida is present and undetected.",
        "inconclusive_when": "Agent never attaches (ATTACH_FAILED, no "
                             "device, wrong frida-server arch) or the app "
                             "crashes for an unrelated reason before any "
                             "check runs.",
        "pass_tags": ["ENV_DETECTED", "APP_REFUSED", "APP_EXITED"],
        # Compound break rule: ATTACHED alone is NOT a break — the
        # agent must attach in order to read ReaEnv at all, so a
        # protected app also shows ATTACHED. BREAK needs ATTACHED
        # AND ENV_CLEAN together (attached, app saw nothing).
        "break_tags": [],
        "break_needs_all": ["ATTACHED", "ENV_CLEAN"],
    },
    {
        "id": "F2",
        "name": "gadget",
        "title": "frida-gadget injection (repacked APK)",
        "target": "APK signature + integrity gate (L16/L103) vs a "
                  "repacked APK carrying libfrida-gadget.so",
        "method": "Repack the protected APK with frida-gadget "
                  "(frida-gadget + a patched lib entry), re-sign with a "
                  "test key, install, launch, watch for GADGET_LOADED "
                  "vs the app refusing.",
        "pass_when": "App refuses to run the sensitive action or exits "
                     "on the repacked build (GADGET_BLOCKED / "
                     "APP_REFUSED), because the signature/integrity "
                     "check (L16/L103) caught the re-sign.",
        "break_when": "Gadget loads (GADGET_LOADED) and the app runs "
                      "normally on the repacked APK — the re-sign was "
                      "not caught.",
        "inconclusive_when": "Repack itself fails (bad gadget arch, "
                             "install blocked by the phone, not by the "
                             "app) before the app ever launches.",
        "pass_tags": ["GADGET_BLOCKED", "APP_REFUSED"],
        "break_tags": ["GADGET_LOADED"],
    },
    {
        "id": "F3",
        "name": "hook",
        "title": "Hook ReaRuntime.decrypt / verifyIntegrity",
        "target": "com.appcore.runtime.ReaRuntime.decrypt, "
                  ".verifyIntegrity, .reconstructKey",
        "method": "Java.use('com.appcore.runtime.ReaRuntime'); hook "
                  "decrypt() to log its return value (first 8 chars "
                  "only, never the full plaintext) and hook "
                  "verifyIntegrity() to force it to return true; then "
                  "trigger a decrypt-gated action in the app.",
        "pass_when": "Hook never fires (HOOK_MISSED — method not "
                     "reachable / already gone) or the anti-hook "
                     "re-check (L54) refuses the decrypt anyway "
                     "(DECRYPT_REFUSED) even though the hook was "
                     "installed.",
        "break_when": "Hook fires (HOOK_FIRED decrypt) and returns a "
                      "plaintext the app accepts (DECRYPT_PLAINTEXT), "
                      "or a forced verifyIntegrity()==true lets a "
                      "tampered blob through (VERIFY_FORCED).",
        "inconclusive_when": "Agent attaches but the app never calls "
                             "decrypt during the run, so the hook had "
                             "nothing to catch (HOOK_IDLE).",
        "pass_tags": ["HOOK_MISSED", "DECRYPT_REFUSED"],
        "break_tags": ["HOOK_FIRED", "DECRYPT_PLAINTEXT", "VERIFY_FORCED"],
    },
    {
        "id": "F4",
        "name": "memread",
        "title": "Read an obfuscated value / test secret from RAM",
        "target": "com.appcore.runtime.ReaMemory$ObfuscatedLong / "
                  "ObfuscatedInt, and the test-app secret "
                  "TEST-SECRET-7f3a9-generic (fake test value)",
        "method": "Memory.scan() every readable range for the UTF-8 "
                  "bytes of the test secret (test app) or the public "
                  "Bridge URL (Bridge); also read an ObfuscatedLong "
                  "field and check whether its plain value is in RAM.",
        "pass_when": "Memory scan finds nothing (MEMSCAN_CLEAN): the "
                     "value is stored obfuscated with a checksum "
                     "(L102) and never sits plain in RAM.",
        "break_when": "Scan finds the plaintext bytes "
                      "(MEMSCAN_FOUND / PLAINTEXT_FOUND) — the value "
                      "was readable from live memory.",
        "inconclusive_when": "Scan could not run (MEMSCAN_ERROR — "
                             "no readable ranges, app exited first) or "
                             "the app never held the value during the run.",
        "pass_tags": ["MEMSCAN_CLEAN"],
        "break_tags": ["MEMSCAN_FOUND", "PLAINTEXT_FOUND"],
    },
    {
        "id": "F5",
        "name": "ssl-unpin",
        "title": "SSL unpinning attempt (TLS trust-path hook)",
        "target": "javax.net.ssl.SSLContext / X509TrustManager / "
                  "okhttp3.CertificatePinner.check (whichever the app "
                  "uses — the agent tries each and reports which)",
        "method": "Hook the trust manager / certificate pinner to "
                  "accept any certificate, then route the phone "
                  "through a MITM proxy with a custom CA and watch "
                  "whether app traffic flows.",
        "pass_when": "Pinning holds (SSL_PIN_OK) or the connection is "
                     "refused despite the hook (SSL_FAILED) — no app "
                     "traffic passes through the proxy.",
        "break_when": "TLS interception succeeds "
                      "(SSL_INTERCEPT_OK): app traffic flows through "
                      "the proxy with the custom CA accepted.",
        "inconclusive_when": "The app made no network call during the "
                             "run, so there was nothing to intercept "
                             "(SSL_IDLE), or the proxy itself was "
                             "misconfigured.",
        "pass_tags": ["SSL_PIN_OK", "SSL_FAILED"],
        "break_tags": ["SSL_INTERCEPT_OK"],
    },
]

BY_ID = {c["id"]: c for c in CHECKS}

# ---------------------------------------------------------------- canned
# Fake Frida transcripts for --dry-run. Scenario A is what a protected
# app SHOULD do; scenario B is what an attacker winning looks like.
# Both are canned strings — no device, no Frida, no app involved.

FAKE_CLEAN = {
    "F1": "[ANTIREA] ATTACHED pid=12345\n"
          "[ANTIREA] ENV_DETECTED frida-maps\n"
          "[ANTIREA] ENV_DETECTED frida-ports\n"
          "[ANTIREA] APP_REFUSED sensitive action refused",
    "F2": "[ANTIREA] GADGET_BLOCKED signature check refused repacked APK\n"
          "[ANTIREA] APP_REFUSED sensitive action refused",
    "F3": "[ANTIREA] HOOK_INSTALLED decrypt\n"
          "[ANTIREA] DECRYPT_REFUSED anti-hook re-check refused decrypt",
    "F4": "[ANTIREA] MEMSCAN_CLEAN no plaintext bytes found in 42 ranges",
    "F5": "[ANTIREA] SSL_PIN_OK pinning held, proxy got no traffic",
}

FAKE_BREAK = {
    "F1": "[ANTIREA] ATTACHED pid=12345\n"
          "[ANTIREA] ENV_CLEAN no frida finding in checkAll()",
    "F2": "[ANTIREA] GADGET_LOADED frida-gadget active\n"
          "[ANTIREA] ATTACHED pid=12345",
    "F3": "[ANTIREA] HOOK_FIRED decrypt\n"
          "[ANTIREA] DECRYPT_PLAINTEXT prefix=TEST-SEC len=24",
    "F4": "[ANTIREA] MEMSCAN_FOUND TEST-SECRET bytes at 0x7abc0000\n"
          "[ANTIREA] PLAINTEXT_FOUND test secret in RAM",
    "F5": "[ANTIREA] SSL_INTERCEPT_OK app traffic flowing via proxy",
}

# Extra canned case used by the unit tests: a hook fired AND the app
# noticed Frida afterwards. BREAK must still win — the hook worked.
FAKE_HOOK_THEN_DETECTED = (
    "[ANTIREA] ATTACHED pid=12345\n"
    "[ANTIREA] HOOK_FIRED decrypt\n"
    "[ANTIREA] DECRYPT_PLAINTEXT prefix=TEST-SEC len=24\n"
    "[ANTIREA] ENV_DETECTED frida-maps\n"
)

TAG_RE = re.compile(r"\[ANTIREA\]\s+([A-Z_]+)(?:\s+(.*))?")


def parse_tags(text):
    """Return the ordered list of (tag, rest) from [ANTIREA] lines."""
    return [(m.group(1), (m.group(2) or "").strip())
            for m in TAG_RE.finditer(text or "")]


def classify(check_id, text):
    """Classify one check's Frida output.

    Returns (verdict, evidence): verdict is PASS, BREAK,
    INCONCLUSIVE or ERROR; evidence is the decisive tag line.
    BREAK evidence is checked first and always wins over PASS
    evidence for the same check.
    """
    check = BY_ID[check_id]
    tags = parse_tags(text)
    if not tags:
        return ("INCONCLUSIVE",
                "no [ANTIREA] lines in output — agent never ran or "
                "output was not captured")
    if any(t == "ERROR" for t, _ in tags):
        err = next(r for t, r in tags if t == "ERROR")
        return ("ERROR", f"agent error: {err}")
    tag_names = [t for t, _ in tags]
    # Compound break rule (F1): BREAK only when ALL listed tags are
    # present together. Checked before single-tag rules, and BREAK
    # always wins over PASS.
    needs_all = check.get("break_needs_all") or []
    if needs_all and all(t in tag_names for t in needs_all):
        found = [f"{t} {r}".strip() for t, r in tags if t in needs_all]
        return ("BREAK", " + ".join(found))
    for t, rest in tags:
        if t in check["break_tags"]:
            return ("BREAK", f"{t} {rest}".strip())
    for t, rest in tags:
        if t in check["pass_tags"]:
            return ("PASS", f"{t} {rest}".strip())
    # Tags exist but none is decisive for this check.
    if "ATTACHED" in tag_names or "HOOK_INSTALLED" in tag_names:
        return ("INCONCLUSIVE",
                f"agent ran ({', '.join(tag_names)}) but produced no "
                f"decisive evidence for {check_id}")
    return ("INCONCLUSIVE",
            f"unrecognised tags only: {', '.join(tag_names)}")


def run_dry_run():
    """Both canned scenarios; returns (results, ok).

    ok is True only if scenario A classifies all PASS and scenario B
    classifies all BREAK — i.e. the classifier sorts protected
    behaviour from attacker-wins behaviour correctly.
    """
    results = []
    ok = True
    for scenario, canned, want in (("protected-behaviour", FAKE_CLEAN, "PASS"),
                                   ("attacker-wins", FAKE_BREAK, "BREAK")):
        for check in CHECKS:
            verdict, evidence = classify(check["id"], canned[check["id"]])
            good = verdict == want
            ok = ok and good
            results.append({
                "check": check["id"], "name": check["name"],
                "scenario": scenario, "verdict": verdict,
                "expected": want, "match": good, "evidence": evidence,
            })
    return results, ok


def check_prereqs():
    """Live-mode prerequisites. Returns a list of missing items."""
    missing = []
    if shutil.which("adb") is None:
        missing.append("adb not found on PATH")
    if shutil.which("frida") is None:
        missing.append("frida CLI not found (pip install frida-tools)")
    if not AGENT.is_file():
        missing.append(f"agent script missing: {AGENT}")
    return missing


def run_live(package, timeout):
    """Attach Frida to the app on a connected phone. Returns raw output.

    Raises RuntimeError with a plain message when the live run cannot
    happen (no device, no frida-server, attach failed). Never returns
    fake output as if it were live.
    """
    missing = check_prereqs()
    if missing:
        raise RuntimeError("live run not possible: " + "; ".join(missing))
    r = subprocess.run(["adb", "devices"], capture_output=True,
                       text=True, timeout=30)
    lines = [ln for ln in r.stdout.splitlines()[1:] if ln.strip()]
    if not any(ln.split()[-1] == "device" for ln in lines if ln.split()):
        raise RuntimeError("live run not possible: no adb device connected "
                           "(adb devices shows no 'device' entry)")
    tmpdir = Path(tempfile.mkdtemp(prefix="antirea-l89-",
                                   dir="/home/hatch/tmp"))
    out_file = tmpdir / "frida-output.txt"
    cmd = ["frida", "-U", "-f", package, "-l", str(AGENT),
           "--no-pause", "-o", str(out_file)]
    try:
        subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        pass  # frida runs until killed; timeout means "observed long enough"
    if not out_file.is_file():
        raise RuntimeError("live run produced no output file — frida "
                           "exited before the agent sent anything")
    return out_file.read_text(errors="replace")


def build_report(mode, package, per_check):
    counts = {v: 0 for v in ("PASS", "BREAK", "INCONCLUSIVE", "ERROR")}
    for c in per_check:
        counts[c["verdict"]] += 1
    return {
        "layer": LAYER,
        "mode": mode,
        "package": package,
        "agent": str(AGENT),
        "checks": per_check,
        "summary": counts,
        "claim": ("Dry-run / transcript classification only — no live "
                  "device run happened." if mode != "live" else
                  "Live Frida run on a connected phone."),
    }


def print_table(per_check):
    print(f"{'check':<6}{'verdict':<14}{'evidence'}")
    print("-" * 78)
    for c in per_check:
        print(f"{c['check']:<6}{c['verdict']:<14}{c['evidence']}")


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--dry-run", action="store_true",
                    help="classify canned fake Frida output (no device)")
    ap.add_argument("--from-file", default="",
                    help="classify a saved Frida transcript file")
    ap.add_argument("--check", default="",
                    help="only classify this check id (F1..F5) with --from-file")
    ap.add_argument("--package", default=DEFAULT_PACKAGE,
                    help=f"app package for a live run (default {DEFAULT_PACKAGE}; "
                         f"Bridge: {BRIDGE_PACKAGE})")
    ap.add_argument("--timeout", type=int, default=120,
                    help="seconds to observe the live run (default 120)")
    ap.add_argument("--out", default="", help="write JSON report here")
    ap.add_argument("--list-checks", action="store_true",
                    help="print the five checks and their expectations")
    args = ap.parse_args(argv)

    if args.list_checks:
        for c in CHECKS:
            print(f"{c['id']} {c['name']} — {c['title']}")
            print(f"  target: {c['target']}")
            print(f"  PASS:   {c['pass_when']}")
            print(f"  BREAK:  {c['break_when']}")
            print(f"  ?:      {c['inconclusive_when']}")
        return 0

    if args.dry_run:
        results, ok = run_dry_run()
        per_check = []
        print("L89 dry-run: canned fake Frida output (no device, no Frida)")
        for scenario in ("protected-behaviour", "attacker-wins"):
            rows = [r for r in results if r["scenario"] == scenario]
            print(f"\n-- scenario: {scenario} (expected: "
                  f"{rows[0]['expected']}) --")
            for r in rows:
                mark = "ok" if r["match"] else "MISMATCH"
                print(f"  {r['check']} {r['name']:<10} {r['verdict']:<14} "
                      f"[{mark}] {r['evidence']}")
                if scenario == "protected-behaviour":
                    per_check.append({
                        "check": r["check"], "name": r["name"],
                        "verdict": r["verdict"], "evidence": r["evidence"],
                    })
        print(f"\ndry-run classifier: {'OK' if ok else 'FAILED'} "
              f"(protected -> PASS, attacker-wins -> BREAK)")
        report = build_report("dry-run", args.package, per_check)
        report["dry_run_classifier_ok"] = ok
        report["dry_run_scenarios"] = results
        if args.out:
            Path(args.out).write_text(json.dumps(report, indent=2))
            print(f"report written: {args.out}")
        return 0 if ok else 1

    if args.from_file:
        text = Path(args.from_file).read_text(errors="replace")
        ids = [args.check] if args.check else [c["id"] for c in CHECKS]
        if args.check and args.check not in BY_ID:
            print(f"ERROR: unknown check {args.check} (use F1..F5)",
                  file=sys.stderr)
            return 2
        per_check = []
        for cid in ids:
            verdict, evidence = classify(cid, text)
            per_check.append({"check": cid, "name": BY_ID[cid]["name"],
                              "verdict": verdict, "evidence": evidence})
        print(f"L89 transcript classification: {args.from_file}")
        print_table(per_check)
        report = build_report("from-file", args.package, per_check)
        if args.out:
            Path(args.out).write_text(json.dumps(report, indent=2))
            print(f"report written: {args.out}")
        return 0

    # Live mode.
    try:
        text = run_live(args.package, args.timeout)
    except RuntimeError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        print("Live run needs: a phone with frida-server running, "
              "`adb devices` showing it, and `pip install frida-tools` "
              "on this PC. See README.md.", file=sys.stderr)
        return 2
    per_check = []
    for c in CHECKS:
        verdict, evidence = classify(c["id"], text)
        per_check.append({"check": c["id"], "name": c["name"],
                          "verdict": verdict, "evidence": evidence})
    print(f"L89 live run: package {args.package}")
    print_table(per_check)
    report = build_report("live", args.package, per_check)
    report["raw_transcript"] = text
    if args.out:
        Path(args.out).write_text(json.dumps(report, indent=2))
        print(f"report written: {args.out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""Anti-REA v1.0 — Frida / environment-check SMOKE test (generic).

STATIC presence check only. No device, no emulator, no Frida, no
runtime execution is involved.

It checks a protected APK for:
  (a) Frida-detection marker strings in the dex:
      "frida-agent", "frida-gadget", "27042" (default Frida port).
      These markers are expected to appear in the RUNTIME's own
      detection code (it has to name what it looks for); their
      presence means the detection strings survived into the dex,
      their absence means the strings were themselves hidden or
      the runtime has no such check. Either way this says nothing
      about whether Frida is actually stopped.
  (b) Which environment-check method names are present in the dex
      (via dexdump when available, else `strings` on the extracted
      classes.dex): isDebuggerConnected, isEmulator, isFridaPresent,
      fridaMapsDetected, detectFrida, isRooted, isDebuggable,
      checkFrida, detectDebugger, isRunningOnEmulator, etc.

  *** THIS IS A STATIC PRESENCE CHECK ONLY AND DOES NOT PROVE
      FRIDA IS STOPPED AT RUNTIME. ***
  Proving Frida is stopped needs a device/emulator with Frida
  attached while the protected app runs — which this VM does not
  have. Do not present this script's output as runtime proof.

Usage:
  python3 verifier/frida_smoke.py --apk <protected-apk> [--out report.json]
Python stdlib only. Exit 0 = the check ran and reported; it does
not pass/fail the APK (there is no runtime claim to pass).
"""
import argparse
import json
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

FRIDA_MARKERS = ["frida-agent", "frida-gadget", "27042"]

# Method names the v1.0 runtime is expected to expose (presence is
# informative only — a name can exist without being called, and a
# check can exist under a different name).
ENV_CHECK_METHODS = [
    "isDebuggerConnected",
    "isEmulator",
    "isFridaPresent",
    "fridaMapsDetected",
    "detectFrida",
    "checkFrida",
    "detectDebugger",
    "isRunningOnEmulator",
    "isRooted",
    "isDebuggable",
    "isDebuggerAttached",
    "detectEmulator",
    "checkRoot",
    "isFridaDetected",
]


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--apk", required=True, help="protected APK to inspect")
    ap.add_argument("--out", default="", help="optional JSON report path")
    args = ap.parse_args()

    apk = Path(args.apk)
    if not apk.is_file():
        print(f"ERROR: APK not found: {apk}", file=sys.stderr)
        sys.exit(2)

    with zipfile.ZipFile(apk) as z:
        names = z.namelist()
        dex_name = "classes.dex" if "classes.dex" in names else next(
            (n for n in names if n.startswith("classes") and n.endswith(".dex")), None)
        if dex_name is None:
            print("ERROR: APK has no classes*.dex", file=sys.stderr)
            sys.exit(2)
        dex = z.read(dex_name)
    print(f"dex: {dex_name} ({len(dex)} bytes)")

    # (a) Frida markers — literal byte search in the dex, plus strings count.
    markers = {}
    for m in FRIDA_MARKERS:
        b = m.encode()
        markers[m] = {
            "present_in_dex_bytes": b in dex,
            "byte_occurrences": dex.count(b),
        }
        print(f"  marker [{m}]: present={markers[m]['present_in_dex_bytes']} "
              f"occurrences={markers[m]['byte_occurrences']}")

    # (b) Env-check method names — dexdump if available, else strings.
    dexdump = shutil.which("dexdump") or str(
        Path.home() / "workspace/tools/android-sdk/build-tools/36.0.0/dexdump")
    tmpdir = Path(tempfile.mkdtemp(prefix="antirea-frida-",
                                   dir="/home/hatch/tmp"))
    tmpdex = tmpdir / "classes.dex"
    tmpdex.write_bytes(dex)
    if Path(dexdump).is_file():
        try:
            r = subprocess.run([str(dexdump), str(tmpdex)],
                               capture_output=True, text=True, timeout=120)
            method_text = r.stdout
            method_source = "dexdump"
        except Exception as e:  # noqa: BLE001
            print(f"  dexdump failed ({e}); falling back to strings")
    if not method_text:
        r = subprocess.run(["strings", str(tmpdex)],
                           capture_output=True, text=True, timeout=120)
        method_text = r.stdout
        method_source = "strings"

    methods = {}
    for name in ENV_CHECK_METHODS:
        found = name in method_text
        methods[name] = found
        print(f"  method [{name}]: present={found} (via {method_source})")

    print()
    print("STATIC PRESENCE CHECK ONLY — this does NOT prove Frida is")
    print("stopped at runtime. Runtime proof needs a device/emulator")
    print("with Frida attached while the protected app runs; this VM")
    print("has no device/emulator, so that test was NOT run.")
    print("What this check DOES show: whether the Frida-detection")
    print("marker strings and env-check method names survived into")
    print("the protected dex (presence) or not (absence).")

    report = {
        "apk": str(apk),
        "dex": dex_name,
        "dex_bytes": len(dex),
        "frida_markers": markers,
        "env_check_methods": methods,
        "method_source": method_source,
        "claim": ("STATIC presence check only. Does NOT prove Frida is "
                  "stopped at runtime. No device/emulator test was run."),
    }
    if args.out:
        Path(args.out).write_text(json.dumps(report, indent=2))
        print(f"report written: {args.out}")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()

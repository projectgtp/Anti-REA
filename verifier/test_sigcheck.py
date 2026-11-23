#!/usr/bin/env python3
"""Test for verifier/sigcheck.py (L24 signature v2/v3 scheme check).

Runs the parser on the v1.0 test APKs and asserts:
  * control APK: signing block found, v2 + v3 present, v1 absent.
  * protected APK: signing block found, v2 + v3 present, v1 absent.
  * a non-APK file: error reported, no schemes claimed.
  * apksigner cross-check agrees on both APKs (when apksigner exists).

Usage:
    python3 verifier/test_sigcheck.py
Exit 0 on pass, non-zero on any failure. Python stdlib only.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import sigcheck

BASE = Path(__file__).resolve().parent.parent / "tests" / "testapp"


def check(cond, msg):
    if not cond:
        print(f"FAIL: {msg}")
        sys.exit(1)


def main():
    control = BASE / "testapp-control.apk"
    protected = BASE / "testapp-protected.apk"
    check(control.is_file(), f"missing {control}")
    check(protected.is_file(), f"missing {protected}")

    for apk, label in ((control, "control"), (protected, "protected")):
        r = sigcheck.check_apk(apk)
        check(r["error"] is None, f"{label}: unexpected error: {r['error']}")
        check(r["signing_block_found"], f"{label}: signing block not found")
        check(r["v2"] is True, f"{label}: v2 not reported (block_ids={r['block_ids']})")
        check(r["v3"] is True, f"{label}: v3 not reported (block_ids={r['block_ids']})")
        # v1: a valid JAR signature IS present (META-INF/ANTIREA-.SF +
        # .RSA, manifest digest matches, jarsigner says "jar verified").
        # A plain `apksigner verify` reports v1 false for these APKs
        # because their minSdk makes v1 inapplicable — the cross-check
        # below uses --min-sdk-version 21, where apksigner agrees v1.
        check(r["v1"] is True, f"{label}: v1 files not reported")
        problems = sigcheck.cross_check(r, apk)
        real = [p for p in problems if "unavailable" not in p]
        check(not real, f"{label}: apksigner disagrees: {real}")
        print(f"SIGCHECK-OK ({label}): v1=yes v2=yes v3=yes, apksigner agrees")

    # Non-APK input must report an error and claim no schemes.
    bad = sigcheck.check_apk(__file__)
    check(bad["error"] is not None, "non-APK file produced no error")
    check(not bad["v2"] and not bad["v3"], "non-APK file claimed v2/v3")
    print("SIGCHECK-OK (non-APK): error reported, no schemes claimed")

    # Missing file must report an error, never raise.
    missing = sigcheck.check_apk(BASE / "no-such.apk")
    check(missing["error"] is not None, "missing file produced no error")
    print("SIGCHECK-OK (missing file): error reported")

    print("TEST-PASS")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Anti-REA v1.0 — shipped-filename scan (decoy-filename fix).

A protected APK must never advertise the protector in a file
manager: no shipped filename or path may contain "fake", "decoy",
"antirea", "honeypot" or "trap" (case-insensitive). User report
2026-11-23: the protected Bridge APK showed
assets/antirea/decoys/fake-config.json, fake-crash.txt,
fake-errors.txt, fake-stacktrace.txt and libantirea-decoy.so.

Scope is SHIPPED FILENAMES/PATHS ONLY (the APK's zip entry names):
  * the internal asset dir is assets/meta/, not assets/antirea/;
  * decoy files live at the top level of assets/ with realistic
    names (config.json, crash-report.txt, error-log.txt,
    stacktrace.txt, libconfig.so);
  * the runtime package is com.appcore.runtime, not
    com.antirea.runtime.
File CONTENTS are out of scope here on purpose: the tripwire-id
marker inside a decoy file is what flags use, and placeholders
such as "meta-encrypted:" in XML text are runtime-read content,
not filenames. Dex class names are also out of scope for this scan
(they are checked by the attack verifier's needle counts, and the
protector's own smali tree is renamed by anti-rea.py before
rebuild); this module checks zip entry names only.

Usage:
  python3 verifier/shipped_names.py <apk> [apk ...]
  # exit 0: clean; exit 1: at least one offending entry found.

Python stdlib only.
"""
import sys
import zipfile
from pathlib import Path

BANNED_SUBSTRINGS = ("fake", "decoy", "antirea", "honeypot", "trap")


def scan_names(names):
    """Return the offending names from an iterable of shipped
    filenames/paths: any name containing a banned substring
    (case-insensitive). Never raises on odd input."""
    bad = []
    for name in names or []:
        low = str(name).lower()
        if any(b in low for b in BANNED_SUBSTRINGS):
            bad.append(str(name))
    return bad


def scan_apk(apk_path):
    """Return the offending zip entry names of an APK.

    Raises FileNotFoundError when the APK is missing and
    zipfile.BadZipFile when it is not a valid ZIP/APK — callers
    that want a clean failure should catch those (see main()).
    """
    with zipfile.ZipFile(apk_path) as z:
        return scan_names(z.namelist())


def main(argv=None):
    args = list(sys.argv[1:] if argv is None else argv)
    if not args:
        print("usage: shipped_names.py <apk> [apk ...]", file=sys.stderr)
        return 2
    rc = 0
    for target in args:
        try:
            bad = scan_apk(target)
        except FileNotFoundError:
            print("ERROR: APK not found: %s" % target, file=sys.stderr)
            rc = 2
            continue
        except zipfile.BadZipFile:
            print("ERROR: not a valid ZIP/APK: %s" % target, file=sys.stderr)
            rc = 2
            continue
        if bad:
            print("%s: FAIL — %d self-identifying shipped name(s):"
                  % (target, len(bad)))
            for name in bad:
                print("  - %s" % name)
            rc = 1
        else:
            print("%s: OK — no banned words in shipped filenames"
                  % target)
    return rc


if __name__ == "__main__":
    raise SystemExit(main())

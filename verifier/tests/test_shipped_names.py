#!/usr/bin/env python3
"""Unit tests for the shipped-filename scan (Agent B, decoy fix).

Proves, with no APK build:
  * The scan flags every banned word (fake, decoy, antirea,
    honeypot, trap — case-insensitive) in a shipped filename/path.
  * The OLD naming FAILS the scan: the committed
    tests/testapp/testapp-protected.apk (protected before the
    rename, assets/antirea/decoys/fake-*.txt) is flagged. That is
    the regression proof — the test fails on old naming by design.
  * The NEW naming PASSES: the realistic names protect now ships
    (assets/meta/*, assets/config.json, crash-report.txt,
    error-log.txt, stacktrace.txt, libconfig.so, res/values/
    update.xml, com/appcore/*) are all clean.
  * The CLI's shipped-name helper (anti-rea.py _decoy_dest) never
    overwrites an existing file.

Usage:
  python3 verifier/tests/test_shipped_names.py
Exit 0 on pass, non-zero on any failure. Python stdlib only.
"""
import importlib.util
import tempfile
import unittest
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
V10 = HERE.parent.parent
TMP_BASE = Path("/home/hatch/tmp")


def _load(name, path):
    spec = importlib.util.spec_from_file_location(name, str(path))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


SCAN = _load("antirea_shipped_names", V10 / "verifier" / "shipped_names.py")

OLD_NAMES = [
    "assets/antirea/decoys/fake-config.json",
    "assets/antirea/decoys/fake-crash.txt",
    "assets/antirea/decoys/fake-errors.txt",
    "assets/antirea/decoys/fake-stacktrace.txt",
    "assets/antirea/decoys/libantirea-decoy.so",
    "assets/antirea/manifest.json",
    "assets/antirea/res_strings.json",
    "assets/antirea/build.json",
    "res/values/antirea-decoy.xml",
    "smali/com/antirea/runtime/ReaRuntime.smali",
]

NEW_NAMES = [
    "assets/meta/manifest.json",
    "assets/meta/res_strings.json",
    "assets/meta/build.json",
    "assets/config.json",
    "assets/crash-report.txt",
    "assets/error-log.txt",
    "assets/stacktrace.txt",
    "assets/libconfig.so",
    "res/values/update.xml",
    "AndroidManifest.xml",
    "classes.dex",
    "META-INF/MANIFEST.MF",
]


class TestScanNames(unittest.TestCase):
    def test_each_banned_word_flagged(self):
        for word in ("fake", "decoy", "antirea", "honeypot", "trap"):
            flagged = SCAN.scan_names(["assets/%s-file.txt" % word])
            self.assertEqual(flagged, ["assets/%s-file.txt" % word],
                             "banned word not flagged: %s" % word)

    def test_case_insensitive(self):
        flagged = SCAN.scan_names(["assets/FAKE-Config.JSON",
                                   "assets/AntiRea-Decoy.so"])
        self.assertEqual(len(flagged), 2)

    def test_old_naming_fails(self):
        flagged = SCAN.scan_names(OLD_NAMES)
        self.assertEqual(len(flagged), len(OLD_NAMES),
                         "old naming not fully flagged: %s" % flagged)

    def test_new_naming_passes(self):
        self.assertEqual(SCAN.scan_names(NEW_NAMES), [])

    def test_empty_and_none_safe(self):
        self.assertEqual(SCAN.scan_names([]), [])
        self.assertEqual(SCAN.scan_names(None), [])


class TestScanApk(unittest.TestCase):
    def test_old_protected_apk_flagged(self):
        # The committed protected testapp predates the rename: it
        # MUST fail the scan (proves the test catches old naming).
        # Note: this APK was protected WITHOUT the trap layers, so
        # it has no fake-* decoys — what it proves is the old
        # assets/antirea/ dir AND the keystore-alias leak: the
        # test keystore alias "antirea-test" made apksigner write
        # META-INF/ANTIREA-.SF/.RSA (shipped paths!). The alias
        # default is now "appcore-test" (anti-rea.py).
        old = V10 / "tests" / "testapp" / "testapp-protected.apk"
        self.assertTrue(old.is_file(), "committed protected testapp missing")
        flagged = SCAN.scan_apk(old)
        self.assertTrue(any("antirea" in n.lower() for n in flagged),
                        "old protected APK not flagged: %s" % flagged)
        self.assertTrue(any(n.startswith("META-INF/ANTIREA-")
                            for n in flagged),
                        "old signature-block leak not flagged: %s" % flagged)

    def test_synthetic_new_apk_passes(self):
        tmp = Path(tempfile.mkdtemp(prefix="antirea-names-",
                                    dir=str(TMP_BASE)))
        apk = tmp / "new.apk"
        with zipfile.ZipFile(apk, "w") as z:
            for name in NEW_NAMES:
                z.writestr(name, b"x")
        try:
            self.assertEqual(SCAN.scan_apk(apk), [])
        finally:
            import shutil
            shutil.rmtree(tmp, ignore_errors=True)

    def test_missing_apk_raises(self):
        with self.assertRaises(FileNotFoundError):
            SCAN.scan_apk(V10 / "tests" / "no-such.apk")

    def test_non_zip_raises(self):
        tmp = Path(tempfile.mkdtemp(prefix="antirea-names-",
                                    dir=str(TMP_BASE)))
        bad = tmp / "plain.txt"
        bad.write_text("not a zip")
        try:
            with self.assertRaises(zipfile.BadZipFile):
                SCAN.scan_apk(bad)
        finally:
            import shutil
            shutil.rmtree(tmp, ignore_errors=True)


class TestDecoyDest(unittest.TestCase):
    def test_never_overwrites(self):
        cli = _load("antirea_cli", V10 / "anti-rea.py")
        tmp = Path(tempfile.mkdtemp(prefix="antirea-dest-",
                                    dir=str(TMP_BASE)))
        try:
            (tmp / "config.json").write_text("real app config")
            dest = cli._decoy_dest(tmp, "config.json")
            self.assertNotEqual(dest, tmp / "config.json")
            self.assertEqual(dest, tmp / "config-2.json")
            self.assertEqual((tmp / "config.json").read_text(),
                             "real app config")
            # Second collision keeps counting up.
            dest.parent.joinpath("config-2.json").write_text("x")
            self.assertEqual(cli._decoy_dest(tmp, "config.json"),
                             tmp / "config-3.json")
        finally:
            import shutil
            shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    unittest.main(verbosity=2)

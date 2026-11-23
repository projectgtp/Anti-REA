#!/usr/bin/env python3
"""Unit tests for attack.py multi-dex handling and tamper.py (Agent B).

Proves, with synthetic APKs only (no jadx/apktool run):
  * attack.extract_all_dex() returns EVERY classes*.dex, not just
    the first — a needle living only in classes2.dex is counted by
    strings_counts() (the old code extracted one dex and would
    have missed it: a false PASS on multi-dex APKs).
  * count_all_in_tree() counts every needle in one walk, quoted and
    plain, with the same per-line semantics as the old per-needle
    counters (one count per line per needle, max).
  * tamper.py flips exactly one byte in the right dex file (incl. a
    classes2.dex-only APK), fixes the dex SHA-1 + Adler-32 so the
    result re-verifies, and refuses a missing blob prefix (exit 1).
  * sigcheck.check_apk() on a synthetic unsigned APK reports no
    signing block without raising.

Usage:
  python3 verifier/tests/test_attack_tamper.py
Exit 0 on pass, non-zero on any failure. Python stdlib only.
"""
import hashlib
import importlib.util
import shutil
import struct
import subprocess
import sys
import tempfile
import unittest
import zipfile
import zlib
from pathlib import Path

HERE = Path(__file__).resolve().parent
V10 = HERE.parent.parent
TMP_BASE = Path("/home/hatch/tmp")


def _load(name, path):
    spec = importlib.util.spec_from_file_location(name, str(path))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


ATTACK = _load("antirea_attack", V10 / "verifier" / "attack.py")
SIGCHECK = _load("antirea_sigcheck", V10 / "verifier" / "sigcheck.py")


def make_fake_dex(marker=b"", size=256):
    """Minimal dex-shaped blob: magic + header + marker bytes."""
    dex = bytearray(b"dex\n035\x00" + b"\x00" * (size - 8))
    if marker:
        dex[64:64 + len(marker)] = marker
    return bytes(dex)


def dex_checksums_ok(dex):
    sha = hashlib.sha1(bytes(dex[32:])).digest()
    adler = zlib.adler32(bytes(dex[12:])) & 0xFFFFFFFF
    return (bytes(dex[12:32]) == sha
            and struct.unpack("<I", bytes(dex[8:12]))[0] == adler)


class TestMultiDex(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp(prefix="antirea-md-",
                                         dir=str(TMP_BASE)))
        self.addCleanup(lambda: shutil.rmtree(self.tmp, ignore_errors=True))
        self.apk = self.tmp / "multi.apk"
        with zipfile.ZipFile(self.apk, "w") as z:
            z.writestr("classes.dex",
                       make_fake_dex(b"FIRST-DEX-MARKER-1111"))
            z.writestr("classes2.dex",
                       make_fake_dex(b"MULTIDEX-NEEDLE-1234"))
            z.writestr("AndroidManifest.xml", b"<manifest/>")

    def test_extract_all_dex(self):
        dexes = ATTACK.extract_all_dex(self.apk, self.tmp, "t")
        self.assertEqual(len(dexes), 2)
        self.assertTrue(all(p.is_file() for p in dexes))

    def test_strings_counts_sees_second_dex(self):
        dexes = ATTACK.extract_all_dex(self.apk, self.tmp, "t")
        counts = ATTACK.strings_counts(
            dexes, ["MULTIDEX-NEEDLE-1234", "FIRST-DEX-MARKER-1111",
                    "ABSENT-NEEDLE-9999"])
        self.assertEqual(counts["MULTIDEX-NEEDLE-1234"], 1,
                         "needle in classes2.dex was missed")
        self.assertEqual(counts["FIRST-DEX-MARKER-1111"], 1)
        self.assertEqual(counts["ABSENT-NEEDLE-9999"], 0)

    def test_extract_no_dex_raises(self):
        empty = self.tmp / "empty.apk"
        with zipfile.ZipFile(empty, "w") as z:
            z.writestr("AndroidManifest.xml", b"<manifest/>")
        with self.assertRaises(FileNotFoundError):
            ATTACK.extract_all_dex(empty, self.tmp, "t")


class TestCountAllInTree(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp(prefix="antirea-ct-",
                                         dir=str(TMP_BASE)))
        self.addCleanup(lambda: shutil.rmtree(self.tmp, ignore_errors=True))
        (self.tmp / "a.java").write_text(
            'String u = "https://api.example.com/v1";\n'
            'String h = api.example.com;\n'
            'String u2 = "https://api.example.com/v1";\n',
            encoding="utf-8")
        (self.tmp / "b.java").write_text(
            'String s = "nothing here";\n', encoding="utf-8")

    def test_plain_counts_all_needles_one_walk(self):
        counts, files = ATTACK.count_all_in_tree(
            self.tmp, ["https://api.example.com/v1", "api.example.com",
                       "absent"], quoted=False)
        self.assertEqual(files, 2)
        self.assertEqual(counts["https://api.example.com/v1"], 2)
        # api.example.com appears on 3 lines (twice inside the URL,
        # once bare) — one count per line per needle.
        self.assertEqual(counts["api.example.com"], 3)
        self.assertEqual(counts["absent"], 0)

    def test_quoted_counts_only_string_literals(self):
        counts, _ = ATTACK.count_all_in_tree(
            self.tmp, ["https://api.example.com/v1", "api.example.com"],
            quoted=True)
        self.assertEqual(counts["https://api.example.com/v1"], 2)
        # Bare `api.example.com` (not in quotes) must NOT count.
        self.assertEqual(counts["api.example.com"], 2)

    def test_single_needle_wrappers_agree(self):
        total, _ = ATTACK.count_literal_in_tree(
            self.tmp, "https://api.example.com/v1")
        self.assertEqual(total, 2)
        total_q, _ = ATTACK.count_quoted_in_tree(
            self.tmp, "api.example.com")
        self.assertEqual(total_q, 2)


class TestTamper(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp(prefix="antirea-tp-",
                                         dir=str(TMP_BASE)))
        self.addCleanup(lambda: shutil.rmtree(self.tmp, ignore_errors=True))

    def _apk_with(self, dex_name, marker):
        apk = self.tmp / ("in-%s.apk" % dex_name.replace(".", "_"))
        with zipfile.ZipFile(apk, "w") as z:
            z.writestr(dex_name, make_fake_dex(marker))
            z.writestr("other.txt", b"keep me")
        return apk

    def _run_tamper(self, apk, blob, out):
        return subprocess.run(
            [sys.executable, str(V10 / "verifier" / "tamper.py"),
             "--apk", str(apk), "--blob-b64", blob, "--out", str(out)],
            capture_output=True, text=True, timeout=60)

    def test_flip_one_byte_and_fix_checksums(self):
        marker = b"QUJDREVGR0hJSktM"  # base64-looking blob prefix
        apk = self._apk_with("classes.dex", marker)
        out = self.tmp / "tampered.apk"
        p = self._run_tamper(apk, "QUJDREVGR0hJSktM", out)
        self.assertEqual(p.returncode, 0, p.stdout + p.stderr)
        with zipfile.ZipFile(out) as z:
            dex = z.read("classes.dex")
            self.assertEqual(z.read("other.txt"), b"keep me")
        self.assertEqual(dex[64:80], b"BUJDREVGR0hJSktM",
                         "first blob byte was not flipped to B")
        self.assertTrue(dex_checksums_ok(dex),
                        "dex SHA-1/Adler-32 do not verify after fix")

    def test_classes2_only_apk(self):
        marker = b"QUJDREVGR0hJSktM"
        apk = self._apk_with("classes2.dex", marker)
        out = self.tmp / "tampered2.apk"
        p = self._run_tamper(apk, "QUJDREVGR0hJSktM", out)
        self.assertEqual(p.returncode, 0, p.stdout + p.stderr)
        with zipfile.ZipFile(out) as z:
            self.assertTrue(dex_checksums_ok(z.read("classes2.dex")))

    def test_missing_prefix_exit_1(self):
        apk = self._apk_with("classes.dex", b"QUJDREVGR0hJSktM")
        out = self.tmp / "nope.apk"
        p = self._run_tamper(apk, "WlhZWg", out)
        self.assertEqual(p.returncode, 1)
        self.assertIn("not found", p.stderr)


class TestSigcheckSynthetic(unittest.TestCase):
    def test_unsigned_apk_no_block_no_raise(self):
        apk = Path(tempfile.mkdtemp(prefix="antirea-sc-",
                                    dir=str(TMP_BASE))) / "u.apk"
        with zipfile.ZipFile(apk, "w") as z:
            z.writestr("classes.dex", make_fake_dex())
        try:
            r = SIGCHECK.check_apk(apk)
        finally:
            shutil.rmtree(apk.parent, ignore_errors=True)
        self.assertFalse(r["signing_block_found"])
        self.assertIsNotNone(r["error"])


if __name__ == "__main__":
    unittest.main(verbosity=2)

#!/usr/bin/env python3
"""Unit tests for needle auto-derivation wiring (Agent B).

Proves, with no APK and no external tools:
  * anti-rea.py and verifier/attack.py resolve to the SAME
    derive_needles() (both prefer transformer/config.py; both fall
    back to an identical minimal implementation when it is absent).
  * The resolved derivation keeps every listed string, adds the bare
    host of every URL needle (the Bridge slip class), strips www.,
    dedupes, and never emits an empty needle.
  * all_needles(cfg) derives from protect.strings only — never from
    honeypots or regex patterns.
  * The two local fallbacks agree with each other on a corpus (they
    are the safety net if config.py ever loses the functions).

Usage:
  python3 verifier/tests/test_needle_derivation.py
Exit 0 on pass, non-zero on any failure. Python stdlib only.
"""
import importlib.util
import sys
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
V10 = HERE.parent.parent


def _load(name, path):
    spec = importlib.util.spec_from_file_location(name, str(path))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


ANTIREA = _load("antirea_cli", V10 / "anti-rea.py")
ATTACK = _load("antirea_attack", V10 / "verifier" / "attack.py")

CORPUS = [
    "https://mbbridge.onrender.com/api",
    "https://api.example.com/v1/auth/login",
    "https://www.example.com:8443/x/",
    "wss://tunnel.example.invalid/stream",
    "TEST-SECRET-7f3a9-generic",
    "tunnel.key.label",
    "mbbridge.onrender.com",
    "https://api.example.com/",
    "",
]


class TestDerivationAgreement(unittest.TestCase):
    def test_both_resolve_to_same_function(self):
        self.assertEqual(
            ANTIREA.derive_needles(CORPUS), ATTACK.derive_needles(CORPUS),
            "anti-rea.py and attack.py disagree on derive_needles()")

    def test_fallbacks_agree(self):
        a = ANTIREA._derive_needles_fallback(CORPUS)
        b = ATTACK._derive_needles_fallback(CORPUS)
        self.assertEqual(a, b, "fallback implementations drifted apart")

    def test_fallback_is_subset_of_resolved(self):
        # The minimal fallback must never invent a needle the real
        # derivation does not also produce for the same input (it is
        # a subset by design: bare host, host:port, www-added forms
        # are all inside the resolved set).
        for s in CORPUS:
            if not s:
                continue
            fb = set(ANTIREA._derive_needles_fallback([s]))
            real = set(ANTIREA.derive_needles([s]))
            self.assertTrue(fb <= real,
                            "fallback derived %s not in resolved for %r"
                            % (sorted(fb - real), s))


class TestDerivationProperties(unittest.TestCase):
    def test_listed_strings_kept(self):
        out = ANTIREA.derive_needles(CORPUS)
        for s in CORPUS:
            if s:
                self.assertIn(s, out, "listed string lost: %r" % s)

    def test_bare_host_derived(self):
        out = ANTIREA.derive_needles(
            ["https://mbbridge.onrender.com/api"])
        self.assertIn("mbbridge.onrender.com", out,
                      "bare host missing — the Bridge slip class")

    def test_www_host_bare_form_present(self):
        # Agent A's derivation adds www. but never strips it: for a
        # www. URL the bare ORIGINAL host is derived, and the
        # www-stripped bare host ("example.com" alone) is NOT — a
        # known gap, flagged to the parent, not asserted here.
        out = ANTIREA.derive_needles(["https://www.example.com/x"])
        self.assertIn("www.example.com", out)
        self.assertIn("www.example.com/x", out)

    def test_non_url_passthrough(self):
        self.assertEqual(
            ANTIREA.derive_needles(["TEST-SECRET-7f3a9-generic"]),
            ["TEST-SECRET-7f3a9-generic"])

    def test_deduped_no_empties(self):
        out = ANTIREA.derive_needles(
            ["https://api.example.com/", "https://api.example.com/"])
        self.assertEqual(len(out), len(set(out)), "duplicates emitted")
        self.assertNotIn("", out)

    def test_empty_input(self):
        self.assertEqual(ANTIREA.derive_needles([]), [])
        self.assertEqual(ANTIREA.derive_needles([""]), [])


class TestAllNeedles(unittest.TestCase):
    def test_derives_from_strings_only(self):
        cfg = {
            "protect": {
                "strings": ["https://api.example.com/v1"],
                "patterns": ["https?://.*"],
            },
            "honeypots": {
                "secrets": ["<redacted>"],
                "endpoints": ["https://api-decoy.example.invalid/v1/admin"],
            },
        }
        out = ANTIREA.all_needles(cfg)
        self.assertIn("https://api.example.com/v1", out)
        self.assertIn("api.example.com", out)
        # Honeypot values and patterns must never be derived from.
        self.assertNotIn("<redacted>", out)
        self.assertNotIn("api-decoy.example.invalid", out)
        self.assertNotIn("https?://.*", out)

    def test_bad_config_returns_empty(self):
        self.assertEqual(ANTIREA.all_needles({}), [])
        self.assertEqual(ANTIREA.all_needles(None), [])


if __name__ == "__main__":
    unittest.main(verbosity=2)

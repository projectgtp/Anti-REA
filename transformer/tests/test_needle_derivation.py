#!/usr/bin/env python3
"""Anti-REA v1.0 — needle auto-derivation tests
(transformer/config.py derive_needles / all_needles, plus the
smali/source matching fixes that go with them).

REGRESSION (2026-11-23, Bridge): the protected Bridge APK hid the
full URL "https://mbbridge.onrender.com" but the bare domain
"mbbridge.onrender.com" showed once — it was never on the hide list.
derive_needles() now enumerates every spelling of a configured URL
(bare host, www., http<->https, ws/wss, port, trailing slash,
URL-encoded forms) and the smali/source passes expand their needle
lists through it themselves, so a caller passing raw config strings
still hides all of them.

AUDIT SLIP-THROUGHS pinned here (each was a real leak before the fix):
  S1 bare host / www. / scheme / port / trailing-slash / encoded
     variants of a configured URL (the Bridge trigger).
  S2 host case: "HTTPS://MBBRIDGE.ONRENDER.COM" survived a lowercase
     config — hosts are case-insensitive, matching now is too.
  S3 static fields: transform_static_fields() only hid a field whose
     value EQUALLED a needle — a field holding a bare host, or a
     sentence embedding a URL, survived. Whole-value encryption now.
  S4 whole-value pattern hit with an empty payloads dict raised
     KeyError (payloads[hit] without creating it) instead of
     encrypting — the transform crashed instead of hiding.
  S5 source mode had the same exact-only hit as smali (S1/S2).

DOCUMENTED AS UNFIXABLE (tests assert the derivation does NOT claim
them — do not "fix" these by guessing):
  U1 subdomains other than www. ("internal.api.example.com") —
     unbounded; needs an explicit config string or a regex pattern.
  U2 an IP literal for a hostname URL (no DNS is done).
  U3 URLs assembled at runtime from pieces ("mbbridge" +
     ".onrender.com", char arrays, Base64, resources) — no static
     literal contains the endpoint, so no derivation can name it.
  U4 regex patterns are left alone (deriving from a pattern would
     mean guessing what it matches), and honeypot values are never
     derived from (they are fake by design).

Run from the v1.0 directory:
    python3 transformer/tests/test_needle_derivation.py
Stdlib only. Temp files go under /home/hatch/tmp and are removed
afterwards.
"""
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import smali as sm  # noqa: E402
from config import all_needles, derive_needles  # noqa: E402
from crypto import encrypt_payload  # noqa: E402
from source import transform_source_text  # noqa: E402

TMP_BASE = "/home/hatch/tmp"
BRIDGE_URL = "https://mbbridge.onrender.com"
BRIDGE_HOST = "mbbridge.onrender.com"

SMALI_TMPL = """.class public Lcom/example/Test;
.super Ljava/lang/Object;

.method public static get()Ljava/lang/String;
    .locals 1
    const-string v0, "%s"
    return-object v0
.end method
"""

FIELD_TMPL = """.class public Lcom/example/Cfg;
.super Ljava/lang/Object;

.field public static final BASE:Ljava/lang/String; = "%s"

.field public static final KEEP:Ljava/lang/String; = "hello world"
"""


class DerivationTest(unittest.TestCase):
    def test_bridge_exact_case(self):
        """The trigger, verbatim: every spelling the task names."""
        d = derive_needles([BRIDGE_URL])
        for want in (
            BRIDGE_URL,                       # original
            BRIDGE_HOST,                      # bare host
            "www." + BRIDGE_HOST,             # www.
            "http://" + BRIDGE_HOST,          # http <-> https
            "https://" + BRIDGE_HOST,
            "wss://" + BRIDGE_HOST,           # ws / wss forms
            "ws://" + BRIDGE_HOST,
            BRIDGE_URL + "/",                 # trailing slash
            "https://mbbridge.onrender.com:443",  # explicit default port
            "https%3A%2F%2Fmbbridge.onrender.com",      # encoded, upper hex
            "https%3a%2f%2fmbbridge.onrender.com",      # encoded, lower hex
            "https%3A%2F%2Fmbbridge.onrender.com%2F",   # encoded + slash
        ):
            self.assertIn(want, d, "missing derived needle %r" % want)

    def test_sorted_deduped_originals_included(self):
        d = derive_needles([BRIDGE_URL, BRIDGE_URL,
                            "https://api.example.com/v1"])
        self.assertEqual(d, sorted(d))
        self.assertEqual(len(d), len(set(d)))
        self.assertIn(BRIDGE_URL, d)
        self.assertIn("https://api.example.com/v1", d)
        self.assertEqual(derive_needles([]), [])
        self.assertEqual(derive_needles([""]), [])

    def test_non_url_passthrough(self):
        """Secrets and labels pass through unchanged — no junk
        variants are invented for strings that are not URLs."""
        for s in ("AKIAIOSFAKEEXAMPLE", "tunnel.key.", "plainword",
                  "example..com", "sk-fake-0000"):
            self.assertEqual(derive_needles([s]), [s], s)

    def test_path_case_preserved_host_lowercased(self):
        d = derive_needles(["https://API.Example.COM/V1/Auth"])
        self.assertIn("https://api.example.com/V1/Auth", d)
        self.assertIn("api.example.com", d)
        # Paths are case-sensitive: the lowercased path must NOT appear.
        self.assertNotIn("https://api.example.com/v1/auth", d)
        self.assertNotIn("api.example.com/v1/auth", d)

    def test_port_variants(self):
        d = derive_needles(["https://api.example.com:8443/v1"])
        for want in ("api.example.com:8443",
                     "https://api.example.com:8443/v1",
                     "https://api.example.com/v1",   # port-stripped
                     "api.example.com", "www.api.example.com"):
            self.assertIn(want, d, want)
        # Default-port spelling for a URL without an explicit port.
        self.assertIn("http://api.example.com:80/v1",
                      derive_needles(["http://api.example.com/v1"]))

    def test_url_encoded_forms(self):
        d = derive_needles(["https://api.example.com/v1/auth/login"])
        for want in (
            "https%3A%2F%2Fapi.example.com%2Fv1%2Fauth%2Flogin",
            "https%3a%2f%2fapi.example.com%2fv1%2fauth%2flogin",
            "https%3A%2F%2Fapi.example.com/v1/auth/login",
        ):
            self.assertIn(want, d, want)

    def test_ip_literal_no_www(self):
        d = derive_needles(["https://192.168.1.10:8080/api"])
        self.assertIn("192.168.1.10:8080", d)
        self.assertIn("https://192.168.1.10/api", d)  # port-stripped
        self.assertNotIn("www.192.168.1.10", d)
        self.assertNotIn("https://www.192.168.1.10:8080/api", d)

    def test_bare_host_input_derives_schemes(self):
        d = derive_needles([BRIDGE_HOST])
        for want in ("https://" + BRIDGE_HOST, "http://" + BRIDGE_HOST,
                     "wss://" + BRIDGE_HOST, "www." + BRIDGE_HOST):
            self.assertIn(want, d, want)

    def test_no_subdomain_enumeration_u1(self):
        """U1 (documented limit): subdomains other than www. are NOT
        derived — they are unbounded and need an explicit string or
        a regex pattern."""
        d = derive_needles(["https://api.example.com"])
        self.assertNotIn("https://internal.api.example.com", d)
        self.assertNotIn("internal.api.example.com", d)

    def test_no_dynamic_fragments_u3(self):
        """U3 (documented limit): runtime-assembled URLs have no
        static literal to derive — fragments are NOT produced."""
        d = derive_needles([BRIDGE_URL])
        self.assertNotIn("mbbridge", d)
        self.assertNotIn(".onrender.com", d)

    def test_all_needles_excludes_honeypots_and_patterns(self):
        cfg = {
            "protect": {
                "strings": [BRIDGE_URL],
                "patterns": ["https?://[A-Za-z0-9.-]+\\.example\\.com.*"],
            },
            "honeypots": {
                "secrets": ["AKIAIOSFAKEEXAMPLE"],
                "endpoints": ["https://api-decoy.example.invalid/v1/admin"],
            },
        }
        got = all_needles(cfg)
        self.assertIn(BRIDGE_HOST, got)
        # Honeypot host/endpoint must NOT be derived (fake by design).
        self.assertNotIn("api-decoy.example.invalid", got)
        self.assertNotIn("https://api-decoy.example.invalid/v1/admin", got)
        self.assertNotIn("AKIAIOSFAKEEXAMPLE", got)
        # Patterns are left alone, never derived from.
        self.assertNotIn("https?://[A-Za-z0-9.-]+\\.example\\.com.*", got)
        self.assertEqual(all_needles({}), [])
        self.assertEqual(all_needles(None), [])


class MatchingTest(unittest.TestCase):
    def setUp(self):
        self.dir = Path(tempfile.mkdtemp(prefix="antirea-needle-",
                                         dir=TMP_BASE))

    def tearDown(self):
        shutil.rmtree(self.dir, ignore_errors=True)

    def _smali_file(self, literal):
        p = self.dir / "T.smali"
        p.write_text(SMALI_TMPL % literal, encoding="utf-8")
        return p

    def _transform_smali(self, literal, exact=None, patterns=None):
        p = self._smali_file(literal)
        stats = {}
        changed = sm.transform_smali_file(
            p, exact if exact is not None else [BRIDGE_URL],
            patterns or [], {}, stats)
        return changed, p.read_text(), stats

    def test_find_needles_derives_bare_host(self):
        """S1 at the sweep level: a file containing ONLY the bare
        host is found when the config lists only the full URL."""
        found = sm.find_needles_in_text(
            'const-string v0, "mbbridge.onrender.com"',
            [BRIDGE_URL], [])
        self.assertIn(BRIDGE_HOST, found)

    def test_smali_bare_domain_encrypted(self):
        """S1, the Bridge case end to end: a bare-domain literal in
        smali is encrypted when the config lists only the full URL."""
        changed, txt, stats = self._transform_smali(BRIDGE_HOST)
        self.assertTrue(changed)
        self.assertNotIn(BRIDGE_HOST, txt)
        self.assertGreater(stats.get("strings_encrypted", 0), 0)

    def test_smali_scheme_port_slash_encoded_variants(self):
        """S1: every derived spelling is hidden, not just the host."""
        for literal in ("www." + BRIDGE_HOST,
                        "http://" + BRIDGE_HOST,
                        "wss://" + BRIDGE_HOST,
                        BRIDGE_URL + "/",
                        "https://" + BRIDGE_HOST + ":443",
                        "https%3A%2F%2Fmbbridge.onrender.com",
                        "https%3a%2f%2fmbbridge.onrender.com"):
            changed, txt, _ = self._transform_smali(literal)
            self.assertTrue(changed, literal)
            self.assertNotIn(literal, txt, literal)

    def test_smali_case_variant_encrypted(self):
        """S2: host case-insensitivity — uppercase scheme/host."""
        for literal in ("HTTPS://MBBRIDGE.ONRENDER.COM",
                        "Mbbridge.Onrender.Com",
                        "https://MBBRIDGE.onrender.com"):
            changed, txt, _ = self._transform_smali(literal)
            self.assertTrue(changed, literal)
            self.assertNotIn(literal, txt, literal)

    def test_smali_embedded_bare_host_sentence(self):
        """S1 embedded: the needle inside a longer literal is split
        out and encrypted; the harmless prefix stays in clear."""
        literal = "Enter a domain, for example mbbridge.onrender.com"
        changed, txt, stats = self._transform_smali(literal)
        self.assertTrue(changed)
        self.assertNotIn(BRIDGE_HOST, txt)
        self.assertIn("Enter a domain, for example ", txt)
        self.assertGreater(stats.get("strings_embedded", 0), 0)

    def test_smali_static_field_bare_host(self):
        """S3: a static field holding only the bare host is hidden
        even when payloads were built from the full URL alone (the
        Bridge shape: the sweep found the full URL, not the host)."""
        p = self.dir / "F.smali"
        p.write_text(FIELD_TMPL % BRIDGE_HOST, encoding="utf-8")
        payloads = {BRIDGE_URL: encrypt_payload(BRIDGE_URL)}
        stats = {}
        self.assertTrue(sm.transform_static_fields(p, payloads, stats))
        txt = p.read_text()
        self.assertNotIn(BRIDGE_HOST, txt)
        self.assertIn("hello world", txt)  # unrelated field untouched
        self.assertIn("<clinit>", txt)
        self.assertGreater(stats.get("fields_encrypted", 0), 0)

    def test_smali_static_field_embedded_sentence(self):
        """S3: a static field holding a sentence embedding the URL
        is hidden whole (no exact-equality requirement any more)."""
        p = self.dir / "F.smali"
        value = "Enter a domain, for example " + BRIDGE_URL
        p.write_text(FIELD_TMPL % value, encoding="utf-8")
        stats = {}
        self.assertTrue(sm.transform_static_fields(
            p, {}, stats, exact=[BRIDGE_URL], patterns=[]))
        self.assertNotIn(BRIDGE_URL, p.read_text())

    def test_smali_static_field_pattern_match(self):
        """S3: a static field matching only a pattern is hidden
        when the caller passes patterns explicitly."""
        p = self.dir / "F.smali"
        p.write_text(FIELD_TMPL % "https://new.example.com/x",
                     encoding="utf-8")
        stats = {}
        self.assertTrue(sm.transform_static_fields(
            p, {}, stats, exact=[],
            patterns=[r"https?://[A-Za-z0-9.\-]+\.example\.com.*"]))
        self.assertNotIn("https://new.example.com/x", p.read_text())

    def test_smali_pattern_whole_value_no_crash(self):
        """S4: a whole-value pattern hit with an empty payloads dict
        used to raise KeyError — it must encrypt instead."""
        changed, txt, _ = self._transform_smali(
            "https://new.example.com/x", exact=[],
            patterns=[r"https?://[A-Za-z0-9.\-]+\.example\.com.*"])
        self.assertTrue(changed)
        self.assertNotIn("https://new.example.com/x", txt)

    def test_source_bare_host_replaced(self):
        """S5: source mode hides the bare host from a full-URL config."""
        text = ('package com.example\n\n'
                'val host = "mbbridge.onrender.com"\n')
        new_text, replaced, _ = transform_source_text(
            text, [BRIDGE_URL], [], {})
        self.assertGreater(replaced, 0)
        self.assertNotIn(BRIDGE_HOST, new_text)
        self.assertIn("ReaRuntime.decrypt", new_text)

    def test_source_case_variant_replaced(self):
        """S5 + S2: source mode hides an uppercase-host literal."""
        text = 'val u = "HTTPS://MBBRIDGE.ONRENDER.COM"\n'
        new_text, replaced, _ = transform_source_text(
            text, [BRIDGE_URL], [], {})
        self.assertGreater(replaced, 0)
        self.assertNotIn("MBBRIDGE.ONRENDER.COM", new_text)

    def test_www_url_derives_www_stripped_bare_host(self):
        """Audit 2026-11-23: derivation added www. but never stripped
        it — a "www." URL left its bare host unhidden. The www-stripped
        bare host must be derived, and a bare-host smali literal must
        be encrypted from a www-URL-only config."""
        derived = derive_needles(["https://www.example.com/api"])
        self.assertIn("example.com", derived)
        self.assertIn("www.example.com", derived)
        self.assertIn("https://example.com/api", derived)
        changed, txt, _ = self._transform_smali(
            "example.com", exact=["https://www.example.com/api"])
        self.assertTrue(changed)
        self.assertNotIn("example.com", txt)


if __name__ == "__main__":
    unittest.main(verbosity=2)

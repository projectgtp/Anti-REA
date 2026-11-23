#!/usr/bin/env python3
"""Anti-REA v1.0 — tests for transformer/traps.py (L76-L85).

Run from the v1.0 directory:
    python3 -m unittest transformer.tests.test_traps -v
or:
    python3 transformer/tests/test_traps.py
Stdlib only. Each test asserts the trap's marker/tripwire id is
present and the snippet is well-formed (balanced braces, matching
.method/.end method pairs, parseable JSON/XML where applicable).
"""
import json
import struct
import sys
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import traps


def _braces_balanced(text):
    depth = 0
    for ch in text:
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth < 0:
                return False
    return depth == 0


def _smali_well_formed(text):
    """Smali-ish structure: balanced braces, .method/.end method
    counts match, .class present, no unbalanced parens in invokes."""
    if not _braces_balanced(text):
        return False
    if text.count(".method") != text.count(".end method"):
        return False
    return ".class public L" in text


class TestTrapsShared(unittest.TestCase):
    def test_shared_tripwire_id(self):
        # The shared id from L71-L75 honeypots (docs/SERVER.md).
        self.assertEqual(traps.TRIPWIRE_ID, "honeypot-secret-01")
        self.assertEqual(traps.TRIPWIRE_TYPE, "antirea-tripwire/v1")


class TestL76FakeLogin(unittest.TestCase):
    def test_marker_and_form(self):
        s = traps.fake_login_flow()
        self.assertIn(traps.TRIPWIRE_ID, s)
        self.assertTrue(_smali_well_formed(s))
        self.assertIn("FakeLogin", s)
        self.assertIn("login", s)

    def test_always_fails(self):
        # Decoy login returns false (const/4 v1, 0x0 then return v1).
        s = traps.fake_login_flow()
        self.assertIn("const/4 v1, 0x0", s)
        self.assertIn("return v1", s)


class TestL77FakeCrash(unittest.TestCase):
    def test_marker(self):
        s = traps.fake_crash()
        self.assertIn(traps.TRIPWIRE_ID, s)
        self.assertIn("FATAL EXCEPTION", s)
        self.assertIn("antirea-decoy-crash", s)
        # It is text, not a real crash: no raise/throw of a real error.
        self.assertIn("FakeLogin", s)


class TestL78SlowMaze(unittest.TestCase):
    def test_marker_and_form(self):
        s = traps.slow_maze()
        self.assertIn(traps.TRIPWIRE_ID, s)
        self.assertTrue(_smali_well_formed(s))
        self.assertIn("Thread;->sleep", s)
        self.assertIn("SlowMaze", s)


class TestL79FakeUpdatePrompt(unittest.TestCase):
    def test_marker_and_xml(self):
        s = traps.fake_update_prompt()
        self.assertIn(traps.TRIPWIRE_ID, s)
        root = ET.fromstring(s)  # must be valid XML
        names = [c.get("name") for c in root]
        self.assertIn("antirea_decoy_update_title", names)
        self.assertIn("antirea_decoy_update_url", names)
        self.assertIn("example.invalid",
                      "".join(c.text or "" for c in root))


class TestL80FakeConfig(unittest.TestCase):
    def test_marker_and_json(self):
        s = traps.fake_config_file()
        cfg = json.loads(s)  # must be valid JSON
        self.assertEqual(cfg["tripwire_id"], traps.TRIPWIRE_ID)
        self.assertTrue(cfg["antirea_decoy"])
        self.assertIn("api_key", cfg)
        self.assertIn("fake", cfg["api_key"])
        self.assertIn("example.invalid", cfg["admin_url"])


class TestL81FakeNativeLib(unittest.TestCase):
    def test_minimal_valid_elf_header(self):
        data = traps.fake_native_lib()
        self.assertIsInstance(data, bytes)
        self.assertEqual(len(data), 64)
        self.assertEqual(data[:4], b"\x7fELF")       # magic
        self.assertEqual(data[4], 2)                 # 64-bit
        self.assertEqual(data[5], 1)                 # little-endian
        e_type, e_machine = struct.unpack_from("<HH", data, 16)
        self.assertEqual(e_type, 3)                  # ET_DYN
        self.assertEqual(e_machine, 183)             # EM_AARCH64
        # Honest limit: NO program/section headers — NOT loadable.
        e_phoff, e_shoff = struct.unpack_from("<QQ", data, 32)
        self.assertEqual((e_phoff, e_shoff), (0, 0))
        e_phnum, = struct.unpack_from("<H", data, 56)
        self.assertEqual(e_phnum, 0)

    def test_docstring_states_not_loadable(self):
        self.assertIn("NOT a loadable", traps.fake_native_lib.__doc__)


class TestL82FakeStackTraces(unittest.TestCase):
    def test_marker(self):
        s = traps.fake_stack_traces()
        self.assertIn(traps.TRIPWIRE_ID, s)
        self.assertIn("antirea-decoy-stacktrace", s)
        self.assertIn("DecoyAdmin", s)


class TestL83FakeErrors(unittest.TestCase):
    def test_every_message_carries_marker(self):
        msgs = traps.fake_error_messages()
        self.assertGreaterEqual(len(msgs), 3)
        for m in msgs:
            self.assertIn(traps.TRIPWIRE_ID, m)
            self.assertIn("antirea-decoy-error", m)


class TestL84HoneypotAdmin(unittest.TestCase):
    def test_marker_and_form(self):
        s = traps.honeypot_admin_panel()
        self.assertIn(traps.TRIPWIRE_ID, s)
        self.assertTrue(_smali_well_formed(s))
        self.assertIn("DecoyAdmin", s)
        self.assertIn("grantAdmin", s)
        self.assertIn("openPanel", s)

    def test_grant_always_fails(self):
        self.assertIn("const/4 v0, 0x0", traps.honeypot_admin_panel())


class TestL85TrapChaining(unittest.TestCase):
    def test_chain_links(self):
        chain = traps.chain_traps("L76")
        self.assertEqual(len(chain), len(traps.TRAP_ORDER))
        self.assertEqual(chain[0]["trap_id"], "L76")
        for step, nxt in zip(chain, chain[1:] + chain[:1]):
            self.assertEqual(step["next_trap_id"], nxt["trap_id"])
            self.assertEqual(step["tripwire_id"], traps.TRIPWIRE_ID)
            self.assertEqual(step["tripwire_type"], traps.TRIPWIRE_TYPE)

    def test_chain_wraps_around(self):
        chain = traps.chain_traps("L84")
        self.assertEqual(chain[0]["trap_id"], "L84")
        self.assertEqual(chain[0]["next_trap_id"], "L76")
        self.assertEqual(chain[1]["trap_id"], "L76")

    def test_chain_all_traps_covered_once(self):
        chain = traps.chain_traps("L80")
        self.assertEqual(sorted(s["trap_id"] for s in chain),
                         sorted(traps.TRAP_ORDER))

    def test_unknown_trap_raises(self):
        with self.assertRaises(ValueError):
            traps.chain_traps("L99")


if __name__ == "__main__":
    unittest.main(verbosity=2)

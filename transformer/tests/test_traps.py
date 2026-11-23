#!/usr/bin/env python3
"""Anti-REA v1.0 — tests for transformer/traps.py (L76-L85).

Run from the v1.0 directory:
    python3 -m unittest transformer.tests.test_traps -v
or:
    python3 transformer/tests/test_traps.py
Stdlib only. Each test asserts the trap's marker/tripwire id is
present and the snippet is well-formed (balanced braces, matching
.method/.end method pairs, parseable JSON/XML where applicable).

CONTENT RULE (2026-11-23 cleanup): every planted decoy string must
read like a file a real app would ship — it must NOT contain the
protector's name ("antirea", case-insensitive) or the word "decoy"
(case-insensitive), while STILL containing the tripwire id
("honeypot-secret-01"). TestNoSelfIdentifyingContent enforces this
for every planted content generator. chain_traps() is NOT in that
list: it returns a Python data structure for the CLI/server, not a
planted file, and its "tripwire_type" is the server-protocol label
shared verbatim with server/reference.py and anti-rea.py
tripwire_format() — renaming it needs a coordinated change there.
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


def _planted_contents():
    """Every string/bytes blob that gets planted into a protected
    build, as (label, text). chain_traps() is deliberately excluded:
    it is CLI/server data, not planted content (see module docstring).
    """
    return [
        ("fake_login_flow", traps.fake_login_flow()),
        ("fake_crash", traps.fake_crash()),
        ("slow_maze", traps.slow_maze()),
        ("fake_update_prompt", traps.fake_update_prompt()),
        ("fake_config_file", traps.fake_config_file()),
        ("fake_native_lib", traps.fake_native_lib()),
        ("fake_stack_traces", traps.fake_stack_traces()),
        ("fake_error_messages", "\n".join(traps.fake_error_messages())),
        ("honeypot_admin_panel", traps.honeypot_admin_panel()),
    ]


class TestTrapsShared(unittest.TestCase):
    def test_shared_tripwire_id(self):
        # The shared id from L71-L75 honeypots (docs/SERVER.md).
        self.assertEqual(traps.TRIPWIRE_ID, "honeypot-secret-01")
        # Protocol label shared with server/reference.py and
        # anti-rea.py tripwire_format() — see module docstring.
        self.assertEqual(traps.TRIPWIRE_TYPE, "tripwire/v1")


class TestNoSelfIdentifyingContent(unittest.TestCase):
    def test_no_planted_content_names_protector_or_decoy(self):
        for label, content in _planted_contents():
            text = (content.decode("utf-8", "replace")
                    if isinstance(content, bytes) else content)
            lowered = text.lower()
            self.assertNotIn("antirea", lowered,
                             "%s contains 'antirea'" % label)
            self.assertNotIn("decoy", lowered,
                             "%s contains 'decoy'" % label)

    def test_every_planted_content_still_carries_tripwire_id(self):
        for label, content in _planted_contents():
            if label == "fake_native_lib":
                # Binary 64-byte ELF header: it cannot carry a text
                # marker without breaking the format, and it never
                # did — the id lives in the text decoys, not here.
                continue
            self.assertIn(traps.TRIPWIRE_ID, content,
                          "%s lost the tripwire id" % label)

    def test_every_error_message_carries_tripwire_id(self):
        for m in traps.fake_error_messages():
            self.assertIn(traps.TRIPWIRE_ID, m)

    def test_chain_still_carries_tripwire_id(self):
        for step in traps.chain_traps("L76"):
            self.assertEqual(step["tripwire_id"], traps.TRIPWIRE_ID)


class TestL76FakeLogin(unittest.TestCase):
    def test_marker_and_form(self):
        s = traps.fake_login_flow()
        self.assertIn(traps.TRIPWIRE_ID, s)
        self.assertTrue(_smali_well_formed(s))
        self.assertIn("LoginManager", s)
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
        self.assertIn("Session expired", s)
        # It is text, not a real crash: no raise/throw of a real error.
        self.assertIn("LoginManager", s)


class TestL78SlowMaze(unittest.TestCase):
    def test_marker_and_form(self):
        s = traps.slow_maze()
        self.assertIn(traps.TRIPWIRE_ID, s)
        self.assertTrue(_smali_well_formed(s))
        self.assertIn("Thread;->sleep", s)
        self.assertIn("RetryWorker", s)
        self.assertIn("backoff", s)


class TestL79FakeUpdatePrompt(unittest.TestCase):
    def test_marker_and_xml(self):
        s = traps.fake_update_prompt()
        self.assertIn(traps.TRIPWIRE_ID, s)
        root = ET.fromstring(s)  # must be valid XML
        names = [c.get("name") for c in root]
        self.assertIn("update_title", names)
        self.assertIn("update_url", names)
        self.assertIn("update_ref", names)
        self.assertIn("example.invalid",
                      "".join(c.text or "" for c in root))


class TestL80FakeConfig(unittest.TestCase):
    def test_marker_and_json(self):
        s = traps.fake_config_file()
        cfg = json.loads(s)  # must be valid JSON
        self.assertEqual(cfg["installation_id"], traps.TRIPWIRE_ID)
        self.assertNotIn("tripwire_id", cfg)
        self.assertNotIn("tripwire_type", cfg)
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
        self.assertIn("SecurityException", s)
        self.assertIn("Session token invalid", s)
        self.assertIn("AdminPanel", s)


class TestL83FakeErrors(unittest.TestCase):
    def test_every_message_carries_marker(self):
        msgs = traps.fake_error_messages()
        self.assertGreaterEqual(len(msgs), 3)
        for m in msgs:
            self.assertIn(traps.TRIPWIRE_ID, m)
            self.assertNotIn("antirea-decoy-error", m)
            self.assertIn("[ref: ", m)


class TestL84HoneypotAdmin(unittest.TestCase):
    def test_marker_and_form(self):
        s = traps.honeypot_admin_panel()
        self.assertIn(traps.TRIPWIRE_ID, s)
        self.assertTrue(_smali_well_formed(s))
        self.assertIn("AdminPanel", s)
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

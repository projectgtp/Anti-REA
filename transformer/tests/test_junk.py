#!/usr/bin/env python3
"""Anti-REA v1.0 — tests for transformer/junk.py (L15, EXPERIMENTAL).

Run from the v1.0 directory:
    python3 transformer/tests/test_junk.py
Stdlib only. No /tmp: temp config files go under /home/hatch/tmp
and are removed afterwards.

What is pinned here:
  (a) flag OFF leaves input byte-identical (smali text and dex bytes,
      including a config with no `experimental` section at all);
  (b) flag ON produces the trap bytes in the output;
  (c) a valid input with flag OFF is not corrupted (exact round-trip);
  (d) traps are only planted where the pass claims (verify_planted,
      plus prefix-preservation: the whole input is a verbatim prefix
      of the output, so no live string is ever rewritten).
Also pinned: the flag defaults OFF in the real config loader, L15 in
layers.enable still raises (the flag is separate from layer enable),
and planting twice / planting an overlong kind in smali raises.
"""
import os
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import junk
from config import ConfigError, enabled_layers, junk_traps_enabled, load_config

BIGTMP = Path("/home/hatch/tmp")

# A realistic smali file fragment: live const-strings the app uses.
SMALI_SAMPLE = (
    ".class public Lcom/example/app/ApiClient;\n"
    ".super Ljava/lang/Object;\n"
    "\n"
    ".method public static getBase()Ljava/lang/String;\n"
    "    .locals 1\n"
    '    const-string v0, "https://api.example.com/v1/"\n'
    "    return-object v0\n"
    ".end method\n"
    "\n"
    ".method public static getToken()Ljava/lang/String;\n"
    "    .locals 1\n"
    '    const-string v0, "hello-world-token"\n'
    "    return-object v0\n"
    ".end method\n"
)


def _uleb128(n):
    out = bytearray()
    while True:
        b = n & 0x7F
        n >>= 7
        if n:
            out.append(b | 0x80)
        else:
            out.append(b)
            return bytes(out)


def _string_data_item(text):
    """A valid dex string_data_item body for plain ASCII text."""
    body = text.encode("utf-8")
    return _uleb128(len(text)) + body + b"\x00"


# A realistic dex string-data blob: two valid string_data_items.
DEX_SAMPLE = (_string_data_item("https://api.example.com/v1/")
              + _string_data_item("hello-world-token"))

CFG_OFF = {"version": 1, "experimental": {"junk_traps": False}}
CFG_ON = {"version": 1, "experimental": {"junk_traps": True}}
CFG_NO_EXPERIMENTAL = {"version": 1}


class TestFlagDefaults(unittest.TestCase):
    def test_default_off_no_section(self):
        self.assertFalse(junk_traps_enabled(CFG_NO_EXPERIMENTAL))
        self.assertFalse(junk.is_enabled(CFG_NO_EXPERIMENTAL))

    def test_default_off_explicit_false(self):
        self.assertFalse(junk_traps_enabled(CFG_OFF))
        self.assertFalse(junk.is_enabled(CFG_OFF))

    def test_on_only_when_true(self):
        self.assertTrue(junk_traps_enabled(CFG_ON))
        self.assertTrue(junk.is_enabled(CFG_ON))

    def test_config_loader_round_trip(self):
        # The real YAML-subset loader must parse the flag, defaulting
        # OFF when the section is absent. Temp files live under
        # /home/hatch/tmp, never /tmp, and are removed afterwards.
        work = Path(tempfile.mkdtemp(prefix="antirea-l15-test-",
                                     dir=str(BIGTMP)))
        self.addCleanup(shutil.rmtree, work, True)
        off_path = work / "off.yaml"
        off_path.write_text("version: 1\napp:\n  name: \"T\"\n",
                            encoding="utf-8")
        self.assertFalse(junk_traps_enabled(load_config(str(off_path))))
        on_path = work / "on.yaml"
        on_path.write_text(
            "version: 1\nexperimental:\n  junk_traps: true\n",
            encoding="utf-8")
        self.assertTrue(junk_traps_enabled(load_config(str(on_path))))

    def test_l15_in_layers_enable_still_raises(self):
        # The experimental flag is NOT a layer enable: L15 stays
        # PLANNED in the registry, so enabling it as a layer must
        # still raise until the parent merges the registry.
        cfg = {"version": 1, "layers": {"enable": ["L01", "L15"]}}
        with self.assertRaises(ConfigError):
            enabled_layers(cfg, ["L01", "L03"])


class TestFlagOffLeavesInputIdentical(unittest.TestCase):
    """(a) + (c): flag OFF => byte-identical output, valid input intact."""

    def test_smali_off_explicit(self):
        out, report = junk.apply_junk_traps_to_smali(SMALI_SAMPLE, CFG_OFF)
        self.assertEqual(out, SMALI_SAMPLE)
        self.assertEqual(report, [])

    def test_smali_off_no_section(self):
        out, report = junk.apply_junk_traps_to_smali(
            SMALI_SAMPLE, CFG_NO_EXPERIMENTAL)
        self.assertEqual(out, SMALI_SAMPLE)
        self.assertEqual(report, [])

    def test_dex_off_explicit(self):
        out, report = junk.apply_junk_traps_to_dex_bytes(DEX_SAMPLE, CFG_OFF)
        self.assertEqual(out, DEX_SAMPLE)
        self.assertEqual(report, [])

    def test_dex_off_no_section(self):
        out, report = junk.apply_junk_traps_to_dex_bytes(
            DEX_SAMPLE, CFG_NO_EXPERIMENTAL)
        self.assertEqual(out, DEX_SAMPLE)
        self.assertEqual(report, [])

    def test_off_output_has_no_trap_bytes(self):
        # Round-trip check: the untouched output decodes cleanly as
        # UTF-8 and holds no trap sequence of any kind.
        out, _ = junk.apply_junk_traps_to_dex_bytes(DEX_SAMPLE, CFG_OFF)
        out.decode("utf-8")  # must not raise
        for spec in junk.TRAP_KINDS.values():
            self.assertNotIn(spec["mutf8"], out)


class TestFlagOnPlantsTraps(unittest.TestCase):
    """(b): flag ON produces the trap bytes in the output."""

    def test_smali_on_contains_lone_surrogate_escapes(self):
        out, report = junk.apply_junk_traps_to_smali(SMALI_SAMPLE, CFG_ON)
        self.assertIn("\\uD800", out)
        self.assertIn("\\uDC00", out)
        self.assertIn("com/appcore/junk/JunkTraps", out)
        self.assertEqual(len(report), 2)
        self.assertEqual([r["kind"] for r in report],
                         ["lone-high-surrogate", "lone-low-surrogate"])

    def test_dex_on_contains_all_trap_bytes(self):
        out, report = junk.apply_junk_traps_to_dex_bytes(DEX_SAMPLE, CFG_ON)
        self.assertEqual(len(report), len(junk.TRAP_KINDS))
        for kind, spec in junk.TRAP_KINDS.items():
            self.assertIn(spec["mutf8"], out, kind)
        # Every trap string carries its ASCII marker.
        self.assertEqual(out.count(b"appcore-junk:"), len(junk.TRAP_KINDS))

    def test_dex_trap_entry_layout(self):
        # One trap entry parses as a string_data_item: uleb128 size,
        # marker + kind + trap bytes + ":end", NUL terminator.
        entry = junk.make_trap_string_data("lone-high-surrogate")
        self.assertEqual(entry[-1], 0)
        # utf16_size = 13 ("appcore-junk:") + 19 (kind) + 1 (":")
        #              + 1 (lone surrogate) + 4 (":end") = 38 = 0x26.
        self.assertTrue(entry.startswith(b"\x26appcore-junk:"
                                         b"lone-high-surrogate:"))
        self.assertIn(b"\xed\xa0\x80", entry)
        self.assertTrue(entry.endswith(b":end\x00"))

    def test_smali_on_keeps_live_strings(self):
        # The app's own strings survive verbatim, values unchanged.
        out, _ = junk.apply_junk_traps_to_smali(SMALI_SAMPLE, CFG_ON)
        self.assertIn('"https://api.example.com/v1/"', out)
        self.assertIn('"hello-world-token"', out)


class TestTrapsOnlyWhereClaimed(unittest.TestCase):
    """(d): traps exist only at the reported locations."""

    def test_smali_input_is_verbatim_prefix(self):
        out, report = junk.apply_junk_traps_to_smali(SMALI_SAMPLE, CFG_ON)
        self.assertTrue(out.startswith(SMALI_SAMPLE))
        # No live line was rewritten: every original line is present
        # unchanged, in order, at the start of the output.
        self.assertEqual(out.splitlines()[:len(SMALI_SAMPLE.splitlines())],
                         SMALI_SAMPLE.splitlines())

    def test_dex_input_is_verbatim_prefix(self):
        out, report = junk.apply_junk_traps_to_dex_bytes(DEX_SAMPLE, CFG_ON)
        self.assertTrue(out.startswith(DEX_SAMPLE))
        self.assertEqual(out[:len(DEX_SAMPLE)], DEX_SAMPLE)

    def test_smali_verify_planted(self):
        out, report = junk.apply_junk_traps_to_smali(SMALI_SAMPLE, CFG_ON)
        self.assertTrue(junk.verify_planted(out, report, "smali"))

    def test_dex_verify_planted(self):
        out, report = junk.apply_junk_traps_to_dex_bytes(DEX_SAMPLE, CFG_ON)
        self.assertTrue(junk.verify_planted(out, report, "dex"))

    def test_smali_verify_catches_unreported_trap(self):
        out, report = junk.apply_junk_traps_to_smali(SMALI_SAMPLE, CFG_ON)
        with self.assertRaises(ValueError):
            junk.verify_planted(out, report[:-1], "smali")

    def test_dex_verify_catches_unreported_trap(self):
        out, report = junk.apply_junk_traps_to_dex_bytes(DEX_SAMPLE, CFG_ON)
        with self.assertRaises(ValueError):
            junk.verify_planted(out, report[:-1], "dex")

    def test_dex_verify_catches_wrong_offset(self):
        out, report = junk.apply_junk_traps_to_dex_bytes(DEX_SAMPLE, CFG_ON)
        tampered = [dict(report[0], offset=report[0]["offset"] + 1)]
        with self.assertRaises(ValueError):
            junk.verify_planted(out, tampered + report[1:], "dex")

    def test_empty_report_verifies_clean_output(self):
        self.assertTrue(junk.verify_planted(SMALI_SAMPLE, [], "smali"))
        self.assertTrue(junk.verify_planted(DEX_SAMPLE, [], "dex"))

    def test_report_offsets_point_at_entries(self):
        out, report = junk.apply_junk_traps_to_dex_bytes(DEX_SAMPLE, CFG_ON)
        for entry in report:
            blob = out[entry["offset"]:entry["offset"] + entry["length"]]
            self.assertEqual(blob.hex(), entry["hex"])
            self.assertEqual(blob, junk.make_trap_string_data(entry["kind"]))


class TestGuards(unittest.TestCase):
    def test_overlong_kind_rejected_in_smali(self):
        # Overlong sequences have no smali \u escape; they are
        # dex-bytes-only. The smali pass must refuse, not fake one.
        with self.assertRaises(ValueError):
            junk.plant_traps_in_smali(SMALI_SAMPLE,
                                      kinds=["overlong-slash"])

    def test_unknown_kind_raises(self):
        with self.assertRaises(ValueError):
            junk.plant_traps_in_smali(SMALI_SAMPLE, kinds=["nope"])
        with self.assertRaises(ValueError):
            junk.plant_traps_in_dex_bytes(DEX_SAMPLE, kinds=["nope"])
        with self.assertRaises(ValueError):
            junk.make_trap_string_data("nope")

    def test_double_plant_refused(self):
        out, _ = junk.plant_traps_in_smali(SMALI_SAMPLE)
        with self.assertRaises(ValueError):
            junk.plant_traps_in_smali(out)

    def test_plant_does_not_mutate_input(self):
        smali_before = SMALI_SAMPLE
        dex_before = bytes(DEX_SAMPLE)
        junk.plant_traps_in_smali(SMALI_SAMPLE)
        junk.plant_traps_in_dex_bytes(DEX_SAMPLE)
        self.assertEqual(SMALI_SAMPLE, smali_before)
        self.assertEqual(DEX_SAMPLE, dex_before)

    def test_count_zero_plants_nothing(self):
        out, report = junk.plant_traps_in_smali(SMALI_SAMPLE, count=0)
        # Zero traps still appends the (empty) decoy class shell; the
        # report is empty and verify_planted passes on it.
        self.assertEqual(report, [])
        self.assertTrue(junk.verify_planted(out, report, "smali"))
        out_b, report_b = junk.plant_traps_in_dex_bytes(DEX_SAMPLE, count=0)
        self.assertEqual(out_b, DEX_SAMPLE)
        self.assertEqual(report_b, [])


if __name__ == "__main__":
    unittest.main(verbosity=2)

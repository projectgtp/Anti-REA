#!/usr/bin/env python3
"""Anti-REA v1.0 — tests for the L60 flag in transformer/config.py.

Run from the v1.0 directory:
    python3 transformer/tests/test_self_changing_code.py
Stdlib only. No /tmp: temp config files go under /home/hatch/tmp
and are removed afterwards.

What is pinned here (per the user's explicit order 2026-11-23,
"Default is on man"):
  (a) DEFAULT ON: an empty config, a config with no `experimental`
      section, and a config with an `experimental` section that does
      not mention self_changing_code all mean ON.
  (b) EXPLICIT OFF: experimental.self_changing_code: false means
      OFF — the only way to turn it off.
  (c) EXPLICIT ON: experimental.self_changing_code: true means ON.
  (d) A non-dict config / non-dict experimental section means ON
      (the default), never a crash.
  (e) The L15 junk_traps flag is unaffected: it still defaults OFF.
  (f) The flag is separate from layers.enable: "L60" in
      layers.enable still raises ConfigError, because L60 stays
      PLANNED in layers/REGISTRY.md until the parent merges it.
"""
import os
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from config import (ConfigError, enabled_layers, junk_traps_enabled,
                    load_config, self_changing_code_enabled)

BIGTMP = Path("/home/hatch/tmp")


class TestSelfChangingCodeFlag(unittest.TestCase):
    def test_default_on_empty_config(self):
        self.assertTrue(self_changing_code_enabled({}))
        self.assertTrue(self_changing_code_enabled({"version": 1}))

    def test_default_on_no_experimental_section(self):
        cfg = {"version": 1, "layers": {"enable": None, "disable": []}}
        self.assertTrue(self_changing_code_enabled(cfg))

    def test_default_on_experimental_without_key(self):
        cfg = {"experimental": {"junk_traps": False}}
        self.assertTrue(self_changing_code_enabled(cfg))
        cfg = {"experimental": {"junk_traps": True}}
        self.assertTrue(self_changing_code_enabled(cfg))

    def test_explicit_false_turns_off(self):
        cfg = {"experimental": {"self_changing_code": False}}
        self.assertFalse(self_changing_code_enabled(cfg))

    def test_explicit_true_turns_on(self):
        cfg = {"experimental": {"self_changing_code": True}}
        self.assertTrue(self_changing_code_enabled(cfg))

    def test_non_dict_means_on(self):
        self.assertTrue(self_changing_code_enabled(None))
        self.assertTrue(self_changing_code_enabled("not-a-dict"))
        self.assertTrue(self_changing_code_enabled(
            {"experimental": "not-a-dict"}))
        self.assertTrue(self_changing_code_enabled({"experimental": None}))

    def test_junk_traps_still_defaults_off(self):
        # The L60 default-ON change must not leak into L15.
        self.assertFalse(junk_traps_enabled({}))
        self.assertFalse(junk_traps_enabled(
            {"experimental": {"self_changing_code": True}}))
        self.assertFalse(junk_traps_enabled(
            {"experimental": {"self_changing_code": False}}))
        self.assertTrue(junk_traps_enabled(
            {"experimental": {"junk_traps": True}}))

    def test_flag_reads_from_real_config_file(self):
        work = Path(tempfile.mkdtemp(prefix="antirea-l60-flag-",
                                     dir=str(BIGTMP)))
        try:
            off = work / "off.yaml"
            off.write_text("version: 1\nexperimental:\n"
                           "  self_changing_code: false\n",
                           encoding="utf-8")
            self.assertFalse(self_changing_code_enabled(
                load_config(str(off))))
            on = work / "on.yaml"
            on.write_text("version: 1\nexperimental:\n"
                          "  self_changing_code: true\n",
                          encoding="utf-8")
            self.assertTrue(self_changing_code_enabled(
                load_config(str(on))))
            default = work / "default.yaml"
            default.write_text("version: 1\n", encoding="utf-8")
            self.assertTrue(self_changing_code_enabled(
                load_config(str(default))))
        finally:
            shutil.rmtree(work, ignore_errors=True)

    def test_l60_in_layers_enable_still_raises(self):
        # The flag is separate from layer enabling: L60 stays
        # PLANNED in the registry, so naming it in layers.enable
        # must still raise until the parent merges it.
        cfg = {"layers": {"enable": ["L60"], "disable": []}}
        with self.assertRaises(ConfigError):
            enabled_layers(cfg, [])


if __name__ == "__main__":
    unittest.main(verbosity=2)

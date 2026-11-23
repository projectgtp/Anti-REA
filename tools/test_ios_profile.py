#!/usr/bin/env python3
"""Anti-REA v1.0 - L99 iOS profile tests.

Validates profiles/ios.yaml (the L99 definition) against
layers/REGISTRY.md. Python stdlib only, no PyYAML, no temp files.

What is checked:
  1. The YAML parses (with this file's own strict subset parser).
  2. It also loads through transformer/config.py load_config - the
     same REA-IR loader the Android configs use - and both parsers
     agree on profile, version, status and the mapping.
  3. Every mapped layer id exists in layers/REGISTRY.md.
  4. Every registry layer (L01-L103) is mapped exactly once - the
     mapping is complete, nothing is silently unaccounted for.
  5. Every verdict is one of APPLIES / ADAPTED / DOES-NOT-APPLY.
  6. Every category has at least one APPLIES entry.
  7. No APPLIES or ADAPTED entry has an empty mechanism.
  8. Every DOES-NOT-APPLY entry has a non-empty reason and claims
     no mechanism.
  9. The profile declares its honest status: defined, never built
     on iOS here, never device-tested, no iOS toolchain in this VM.
 10. The counts declared in the file match the mapping itself.

Run:
    python3 tools/test_ios_profile.py
"""
import re
import sys
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
PROFILE = ROOT / "profiles" / "ios.yaml"
REGISTRY = ROOT / "layers" / "REGISTRY.md"

sys.path.insert(0, str(ROOT / "transformer"))

VERDICTS = ("APPLIES", "ADAPTED", "DOES-NOT-APPLY")

# Categories the task requires the profile to cover.
REQUIRED_CATEGORIES = (
    "string_hiding",
    "integrity",
    "environment",
    "anti_debug",
    "anti_hook",
    "server",
    "traps",
)


def _scalar(text):
    """One YAML scalar from the supported subset (same rules as
    transformer/config.py: quoted, bool, int, null, plain)."""
    text = text.strip()
    if text in ("true", "True"):
        return True
    if text in ("false", "False"):
        return False
    if text in ("null", "~", ""):
        return None
    if re.fullmatch(r"-?\d+", text):
        return int(text)
    if len(text) >= 2 and text[0] == text[-1] and text[0] in ("'", '"'):
        inner = text[1:-1]
        if text[0] == '"':
            inner = inner.replace('\\"', '"').replace("\\\\", "\\")
        return inner
    return text


def parse_ios_yaml(path):
    """Strict parser for exactly the shape profiles/ios.yaml uses:
    top-level key: value scalars, then `categories:` holding one
    mapping per category, each a list of flat mappings. Anything
    else (tabs, unexpected indentation, a key without a value where
    a value is required) raises ValueError - the file must stay
    simple enough for stdlib parsing."""
    lines = Path(path).read_text(encoding="utf-8").splitlines()
    meta = {}
    categories = {}
    seen_categories = False
    current_category = None
    current_entry = None
    for lineno, raw in enumerate(lines, 1):
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        indent = len(raw) - len(raw.lstrip(" "))
        if "\t" in raw[:indent]:
            raise ValueError("line %d: tabs are not allowed" % lineno)
        text = raw.strip()
        if indent == 0:
            if ":" not in text:
                raise ValueError("line %d: expected 'key: value'" % lineno)
            key, _, value = text.partition(":")
            key, value = key.strip(), value.strip()
            if key == "categories":
                if value:
                    raise ValueError("line %d: 'categories' takes no "
                                     "inline value" % lineno)
                seen_categories = True
                current_category = None
                current_entry = None
                continue
            if not re.fullmatch(r"[A-Za-z0-9_.-]+", key):
                raise ValueError("line %d: bad key %r" % (lineno, key))
            meta[key] = _scalar(value)
            current_category = None
            current_entry = None
        elif indent == 2:
            if not seen_categories:
                raise ValueError("line %d: indented key before "
                                 "'categories:'" % lineno)
            if not text.endswith(":") or text[:-1].strip() == "":
                raise ValueError("line %d: expected 'category:'" % lineno)
            current_category = text[:-1].strip()
            if not re.fullmatch(r"[A-Za-z0-9_]+", current_category):
                raise ValueError("line %d: bad category %r"
                                 % (lineno, current_category))
            if current_category in categories:
                raise ValueError("line %d: duplicate category %r"
                                 % (lineno, current_category))
            categories[current_category] = []
            current_entry = None
        elif indent == 4 and text.startswith("- "):
            if current_category is None:
                raise ValueError("line %d: list item outside a category"
                                 % lineno)
            item = text[2:].strip()
            if ":" not in item:
                raise ValueError("line %d: list item needs 'key: value'"
                                 % lineno)
            key, _, value = item.partition(":")
            current_entry = {key.strip(): _scalar(value.strip())}
            categories[current_category].append(current_entry)
        elif indent == 6:
            if current_entry is None:
                raise ValueError("line %d: key outside an entry" % lineno)
            if ":" not in text:
                raise ValueError("line %d: expected 'key: value'" % lineno)
            key, _, value = text.partition(":")
            key = key.strip()
            if key in current_entry:
                raise ValueError("line %d: duplicate key %r in entry"
                                 % (lineno, key))
            current_entry[key] = _scalar(value.strip())
        else:
            raise ValueError("line %d: unexpected indentation (%d)"
                             % (lineno, indent))
    if not seen_categories:
        raise ValueError("no 'categories:' block found")
    return meta, categories


def parse_registry():
    """Same table parse as tools/profiles.py (REGISTRY.md is the
    source). Returns {layer_id: status}."""
    registry = {}
    text = REGISTRY.read_text(encoding="utf-8")
    for line in text.splitlines():
        line = line.strip()
        if not line.startswith("| L"):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) < 4 or not re.fullmatch(r"L\d+", cells[0]):
            continue
        registry[cells[0]] = cells[3]
    return registry


def all_entries(categories):
    for category, entries in categories.items():
        for entry in entries:
            yield category, entry


class TestIosProfile(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.meta, cls.categories = parse_ios_yaml(PROFILE)
        cls.registry = parse_registry()
        cls.entries = list(all_entries(cls.categories))
        cls.by_layer = {}
        for category, entry in cls.entries:
            cls.by_layer.setdefault(entry.get("layer"), []).append(category)

    def test_yaml_parses_and_has_103_entries(self):
        self.assertEqual(self.meta.get("profile"), "ios")
        self.assertEqual(self.meta.get("version"), 1)
        self.assertEqual(self.meta.get("layer"), "L99")
        self.assertEqual(len(self.entries), 103,
                         "mapping must cover all 103 REA-IR layers")
        self.assertEqual(len(self.categories), 9)

    def test_yaml_loads_via_rea_ir_loader(self):
        """Same loader the Android configs use must read this file,
        and both parsers must agree - it is a real REA-IR config."""
        from config import load_config
        cfg = load_config(str(PROFILE))
        self.assertEqual(cfg.get("profile"), "ios")
        self.assertEqual(cfg.get("version"), 1)
        self.assertEqual(cfg.get("status"), "defined")
        self.assertIs(cfg.get("built_on_ios"), False)
        self.assertEqual(
            sorted(cfg.get("categories", {})),
            sorted(self.categories))
        for name, entries in self.categories.items():
            loaded = cfg["categories"][name]
            self.assertEqual(len(loaded), len(entries),
                             "category %s: loader/entry count mismatch"
                             % name)
            for want, got in zip(entries, loaded):
                self.assertEqual(got.get("layer"), want.get("layer"))
                self.assertEqual(got.get("verdict"), want.get("verdict"))

    def test_every_mapped_layer_exists_in_registry(self):
        unknown = sorted(set(self.by_layer) - set(self.registry))
        self.assertEqual(unknown, [],
                         "mapped layer ids missing from REGISTRY.md: %s"
                         % unknown)

    def test_every_registry_layer_mapped_exactly_once(self):
        missing = sorted(set(self.registry) - set(self.by_layer))
        self.assertEqual(missing, [],
                         "registry layers with no iOS mapping: %s" % missing)
        duplicated = sorted(l for l, cats in self.by_layer.items()
                            if len(cats) > 1)
        self.assertEqual(duplicated, [],
                         "layers mapped more than once: %s" % duplicated)
        self.assertEqual(len(self.registry), 103)

    def test_verdicts_are_valid(self):
        for category, entry in self.entries:
            self.assertIn(entry.get("verdict"), VERDICTS,
                          "%s in %s: bad verdict %r"
                          % (entry.get("layer"), category,
                             entry.get("verdict")))

    def test_required_categories_present(self):
        for name in REQUIRED_CATEGORIES:
            self.assertIn(name, self.categories,
                          "required category %r missing" % name)

    def test_every_category_has_applies(self):
        for name, entries in self.categories.items():
            applies = [e for e in entries if e.get("verdict") == "APPLIES"]
            self.assertGreaterEqual(
                len(applies), 1,
                "category %r has no APPLIES entry" % name)

    def test_applies_and_adapted_have_mechanism(self):
        for category, entry in self.entries:
            if entry.get("verdict") in ("APPLIES", "ADAPTED"):
                mechanism = entry.get("mechanism")
                self.assertIsInstance(mechanism, str,
                                      "%s in %s: mechanism missing"
                                      % (entry.get("layer"), category))
                self.assertTrue(mechanism.strip(),
                                "%s in %s: mechanism is empty"
                                % (entry.get("layer"), category))

    def test_does_not_apply_has_reason_and_no_mechanism(self):
        for category, entry in self.entries:
            if entry.get("verdict") != "DOES-NOT-APPLY":
                continue
            reason = entry.get("reason")
            self.assertIsInstance(reason, str,
                                  "%s in %s: reason missing"
                                  % (entry.get("layer"), category))
            self.assertTrue(reason.strip(),
                            "%s in %s: reason is empty"
                            % (entry.get("layer"), category))
            self.assertNotIn("mechanism", entry,
                             "%s in %s: DOES-NOT-APPLY must not claim a "
                             "mechanism" % (entry.get("layer"), category))

    def test_every_entry_names_its_android_mechanism(self):
        for category, entry in self.entries:
            android = entry.get("android")
            self.assertIsInstance(android, str,
                                  "%s in %s: android field missing"
                                  % (entry.get("layer"), category))
            self.assertTrue(android.strip(),
                            "%s in %s: android field is empty"
                            % (entry.get("layer"), category))

    def test_honest_status_declared(self):
        self.assertEqual(self.meta.get("status"), "defined")
        self.assertIs(self.meta.get("built_on_ios"), False,
                      "profile must state built_on_ios: false")
        self.assertIs(self.meta.get("device_tested"), False,
                      "profile must state device_tested: false")
        self.assertEqual(self.meta.get("toolchain_in_vm"), "none")
        self.assertEqual(self.meta.get("platform"), "ios")

    def test_counts_match_metadata(self):
        counted = {v: 0 for v in VERDICTS}
        for _, entry in self.entries:
            counted[entry["verdict"]] += 1
        self.assertEqual(self.meta.get("applies_count"), counted["APPLIES"])
        self.assertEqual(self.meta.get("adapted_count"), counted["ADAPTED"])
        self.assertEqual(self.meta.get("does_not_apply_count"),
                         counted["DOES-NOT-APPLY"])
        self.assertEqual(self.meta.get("total_layers"), 103)
        self.assertEqual(sum(counted.values()), 103)


if __name__ == "__main__":
    unittest.main(verbosity=2)

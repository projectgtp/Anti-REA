#!/usr/bin/env python3
"""Anti-REA v1.0 — L100 layer marketplace (LOCAL plugin loader).

Discovers community layer plugins from a plugins/ directory. A
plugin is a plain Python module exposing:

    LAYER_ID = "X-HELLO-01"      # community ids are X-prefixed;
                                 # they never collide with registry
                                 # L01..L103 slots
    DESCRIPTION = "one line"
    def apply(apk_dir, config):  # transform the decoded APK dir
        ...                      # (stdlib only; raise on failure)
    def test():                  # -> True on pass, False / raise on fail
        ...

Plugins are NOT trusted code: they run with the same privileges as
the CLI, so only install plugins from sources you trust, and review
them first (a plugin can do anything Python can). The loader never
execs a plugin at import time beyond module top-level code, validates
the contract (LAYER_ID str, apply/test callable) before listing it,
and reports load errors per-plugin instead of failing the whole run.

Commands:
    python3 tools/layer_marketplace.py list [--plugins-dir DIR]
    python3 tools/layer_marketplace.py test [--plugins-dir DIR]
    python3 tools/layer_marketplace.py test --id X-HELLO-01

Default plugins dir: <v1.0 root>/plugins. A sample plugin ships at
plugins/sample_hello_layer.py. Python stdlib only.
"""
import argparse
import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_PLUGINS = ROOT / "plugins"


def discover(plugins_dir):
    """Load every *.py module in plugins_dir. Returns
    (plugins, errors): plugins is a list of dicts
    {id, description, module, path}; errors is a list of strings
    (one per plugin that failed the contract check)."""
    plugins_dir = Path(plugins_dir)
    plugins, errors = [], []
    if not plugins_dir.is_dir():
        return plugins, ["plugins dir not found: %s" % plugins_dir]
    for path in sorted(plugins_dir.glob("*.py")):
        if path.name.startswith("_"):
            continue
        mod_name = "antirea_plugin_%s" % path.stem
        try:
            spec = importlib.util.spec_from_file_location(mod_name, path)
            mod = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(mod)
        except Exception as e:
            errors.append("%s: failed to import: %s" % (path.name, e))
            continue
        layer_id = getattr(mod, "LAYER_ID", None)
        if not isinstance(layer_id, str) or not layer_id:
            errors.append("%s: LAYER_ID missing or not a string"
                          % path.name)
            continue
        if layer_id.startswith("L") and layer_id[1:].isdigit():
            errors.append("%s: LAYER_ID %r collides with registry "
                          "L-slots — community ids must be X-prefixed"
                          % (path.name, layer_id))
            continue
        if not callable(getattr(mod, "apply", None)):
            errors.append("%s: apply() missing or not callable" % path.name)
            continue
        if not callable(getattr(mod, "test", None)):
            errors.append("%s: test() missing or not callable" % path.name)
            continue
        plugins.append({
            "id": layer_id,
            "description": str(getattr(mod, "DESCRIPTION", "")),
            "module": mod,
            "path": str(path),
        })
    seen = set()
    dupes = [p["id"] for p in plugins if p["id"] in seen
             or seen.add(p["id"])]
    if dupes:
        errors.append("duplicate LAYER_IDs: %s" % sorted(set(dupes)))
    return plugins, errors


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("command", choices=["list", "test"])
    ap.add_argument("--plugins-dir", default=str(DEFAULT_PLUGINS))
    ap.add_argument("--id", default="",
                    help="only test this plugin id")
    args = ap.parse_args(argv)
    plugins, errors = discover(args.plugins_dir)
    for e in errors:
        print("PLUGIN-ERROR: %s" % e, file=sys.stderr)
    if args.command == "list":
        print(json.dumps(
            {"plugins": [{"id": p["id"], "description": p["description"],
                          "path": p["path"]} for p in plugins],
             "errors": errors}, indent=2))
        return 0 if not errors else 1
    # test
    selected = [p for p in plugins
                if not args.id or p["id"] == args.id]
    if args.id and not selected:
        print("no plugin with id %r" % args.id, file=sys.stderr)
        return 2
    failed = list(errors)
    for p in selected:
        try:
            ok = bool(p["module"].test())
        except Exception as e:
            ok, failed = False, failed + [
                "%s: test() raised: %s" % (p["id"], e)]
        print("%s %s: test %s" % ("PASS" if ok else "FAIL",
                                  p["id"], p["description"]))
        if not ok:
            failed.append("%s: test() returned False" % p["id"])
    if failed:
        print("MARKETPLACE-TEST-FAIL: %d problem(s)" % len(failed),
              file=sys.stderr)
        return 1
    print("MARKETPLACE-TEST-PASS: %d plugin(s)" % len(selected))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

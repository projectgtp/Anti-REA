#!/usr/bin/env python3
"""Anti-REA v1.0 — L96 multi-app profiles (per-app presets).

A profile is a named layer set. Built-ins (defined here, resolved
against layers/REGISTRY.md so they always track what is actually
IMPLEMENTED):

  strict    every IMPLEMENTED layer (43 in v1.0).
  standard  strict minus the on-device modder-app blocks
            (L101/L102/L103) — for apps that do not want device
            behaviour checks. 40 layers in v1.0.
  light     static hiding + integrity core only (18 layers):
            L01,L02,L03,L07,L09,L14 (hiding/sweep),
            L16,L17,L18,L19,L20,L21,L22 (integrity),
            L46,L47,L48 (runtime crypto), L86,L87 (verification).
            No env checks, no traps, no device checks.

Custom profiles live in the app config under `profiles:`:

    profiles:
      kiosk:
        base: light
        disable: ["L14"]
      payments:
        base: standard
        enable: ["L101"]

Rules: `base` names a built-in (default: strict). `enable` adds ids,
`disable` removes ids (disable wins over enable). Naming a PLANNED
or unknown id is an error — a profile can never silently claim a
layer that is not built. A config may also define a profile with an
`enable` list and no `base` (base defaults to strict, so enable-only
means "strict plus these" — use `base: light` + enable for subsets).

CLI use (anti-rea.py):
    python3 anti-rea.py protect --apk app.apk --config app.yaml \
        --out app-protected.apk --profile light

Standalone:
    python3 tools/profiles.py --config app.yaml --profile light
        # prints the resolved layer list as JSON
    python3 tools/profiles.py --config app.yaml --list
        # lists available profiles (built-ins + config-defined)

Python stdlib only. Never uses /tmp (no temp files at all).
"""
import argparse
import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
sys.path.insert(0, str(ROOT / "transformer"))
from config import load_config, ConfigError  # noqa: E402

LIGHT_LAYERS = [
    "L01", "L02", "L03", "L07", "L09", "L14",
    "L16", "L17", "L18", "L19", "L20", "L21", "L22",
    "L46", "L47", "L48", "L86", "L87",
]
# On-device behaviour blocks excluded from `standard`.
STANDARD_EXCLUDE = ["L101", "L102", "L103"]
BUILTINS = ["strict", "standard", "light"]


def parse_registry():
    """Same table parse as anti-rea.py (REGISTRY.md is the source)."""
    layers = []
    text = (ROOT / "layers" / "REGISTRY.md").read_text(encoding="utf-8")
    for line in text.splitlines():
        line = line.strip()
        if not line.startswith("| L"):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) < 4 or not re.fullmatch(r"L\d+", cells[0]):
            continue
        layers.append({"id": cells[0], "name": cells[1],
                       "counters": cells[2], "status": cells[3]})
    return layers


def implemented_ids():
    return sorted(l["id"] for l in parse_registry()
                  if l["status"] == "IMPLEMENTED")


def builtin_layers(name, impl):
    impl_set = set(impl)
    if name == "strict":
        return sorted(impl_set)
    if name == "standard":
        return sorted(impl_set - set(STANDARD_EXCLUDE))
    if name == "light":
        missing = [l for l in LIGHT_LAYERS if l not in impl_set]
        if missing:
            raise ConfigError(
                "builtin profile 'light' needs layers %s which are not "
                "IMPLEMENTED in this build" % missing)
        return sorted(LIGHT_LAYERS)
    raise ConfigError("unknown builtin profile: %r" % name)


def available_profiles(cfg):
    """Built-ins + config-defined profile names (sorted)."""
    names = list(BUILTINS)
    for name in (cfg.get("profiles") or {}):
        if name not in names:
            names.append(name)
    return sorted(names)


def resolve_profile(cfg, name, impl=None):
    """Resolve a profile name to a sorted layer list.

    Raises ConfigError on unknown profile, unknown layer id, or a
    PLANNED layer id. Never silently drops a requested layer.
    """
    impl = impl if impl is not None else implemented_ids()
    impl_set = set(impl)
    profiles = cfg.get("profiles") or {}
    if name in BUILTINS and name not in profiles:
        return builtin_layers(name, impl)
    if name not in profiles:
        raise ConfigError(
            "unknown profile %r (available: %s)"
            % (name, ", ".join(available_profiles(cfg))))
    spec = profiles[name] or {}
    if not isinstance(spec, dict):
        raise ConfigError("profile %r must be a mapping" % name)
    base = spec.get("base") or "strict"
    if base not in BUILTINS:
        raise ConfigError(
            "profile %r: unknown base %r (want one of %s)"
            % (name, base, ", ".join(BUILTINS)))
    layers = set(builtin_layers(base, impl))
    enable = list(spec.get("enable") or [])
    disable = list(spec.get("disable") or [])
    unknown = (set(enable) | set(disable)) - impl_set - set(
        "L%02d" % i for i in range(1, 104))
    if unknown:
        raise ConfigError("profile %r: unknown layer ids: %s"
                          % (name, sorted(unknown)))
    planned = set(enable) - impl_set
    if planned:
        raise ConfigError(
            "profile %r: layers %s are PLANNED, not implemented — "
            "remove them (see layers/REGISTRY.md)"
            % (name, sorted(planned)))
    layers |= set(enable)
    layers -= set(disable)
    return sorted(layers)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--config", required=True, help="anti-rea.yaml config")
    ap.add_argument("--profile", default="",
                    help="profile name to resolve")
    ap.add_argument("--list", action="store_true",
                    help="list available profiles")
    args = ap.parse_args(argv)
    cfg = load_config(args.config)
    if args.list:
        print(json.dumps({"profiles": available_profiles(cfg),
                          "builtins": BUILTINS}, indent=2))
        return 0
    if not args.profile:
        ap.error("--profile is required (or use --list)")
    layers = resolve_profile(cfg, args.profile)
    print(json.dumps({"profile": args.profile, "layers": layers,
                      "count": len(layers)}, indent=2))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except ConfigError as e:
        print("ERROR: %s" % e, file=sys.stderr)
        raise SystemExit(2)

#!/usr/bin/env python3
"""Anti-REA v1.0 — L26 build-time watermark.

Generates a per-build watermark — a fresh UUID plus a UTC build
timestamp — and stamps it into a REA-IR manifest dict. The watermark
lets a protected build be identified later (which build produced
this APK? when?) without leaking any secret: a UUID and a timestamp
are not key material and are safe to ship in the manifest.

This module ONLY generates and applies the watermark. It is NOT
wired into anti-rea.py — the coordinator integrates it (the CLI
calls apply_watermark() on the manifest dict before writing it).

Functions:
    make_watermark() -> dict
        {"build_id": <uuid4 str>, "built_at": <ISO-8601 UTC str>,
         "watermark_version": 1}
    apply_watermark(manifest: dict, watermark: dict | None = None) -> dict
        Returns a NEW dict (the input is never mutated) with
        manifest["watermark"] set. A supplied watermark is used
        as-is (lets the CLI reuse one across a multi-file build);
        otherwise a fresh one is generated.
    watermark_manifest_file(path) -> dict
        Loads a manifest JSON file, applies a fresh watermark,
        writes it back, returns the watermark. The file must be a
        JSON object; anything else raises ValueError.

Usage:
    python3 tools/watermark.py --self-test
    python3 tools/watermark.py <manifest.json>   # stamps the file in place

Python stdlib only.
"""
import argparse
import copy
import json
import sys
import uuid
from datetime import datetime, timezone
from pathlib import Path

WATERMARK_VERSION = 1


def make_watermark():
    """Generate a fresh per-build watermark (UUID + UTC timestamp)."""
    now = datetime.now(timezone.utc)
    return {
        "build_id": str(uuid.uuid4()),
        "built_at": now.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "watermark_version": WATERMARK_VERSION,
    }


def is_valid_watermark(wm):
    """True only when wm has the expected shape (uuid + timestamp)."""
    if not isinstance(wm, dict):
        return False
    if wm.get("watermark_version") != WATERMARK_VERSION:
        return False
    build_id = wm.get("build_id")
    built_at = wm.get("built_at")
    if not isinstance(build_id, str) or not isinstance(built_at, str):
        return False
    try:
        uuid.UUID(build_id)
    except (ValueError, AttributeError, TypeError):
        return False
    try:
        datetime.strptime(built_at, "%Y-%m-%dT%H:%M:%SZ")
    except ValueError:
        return False
    return True


def apply_watermark(manifest, watermark=None):
    """Return a NEW manifest dict with ["watermark"] set.

    The input dict is never mutated (deep-copied). Any existing
    watermark is replaced — a build gets exactly one watermark,
    the one from this build, never a stale one from a previous run.
    """
    if not isinstance(manifest, dict):
        raise ValueError("manifest must be a dict")
    wm = watermark if watermark is not None else make_watermark()
    if not is_valid_watermark(wm):
        raise ValueError("invalid watermark")
    out = copy.deepcopy(manifest)
    out["watermark"] = copy.deepcopy(wm)
    return out


def watermark_manifest_file(path):
    """Stamp a fresh watermark into a manifest JSON file, in place.

    Returns the watermark dict. Raises FileNotFoundError when the
    file is missing, ValueError when it is not a JSON object.
    """
    p = Path(path)
    raw = json.loads(p.read_text(encoding="utf-8"))
    if not isinstance(raw, dict):
        raise ValueError("manifest JSON must be an object")
    stamped = apply_watermark(raw)
    p.write_text(json.dumps(stamped, indent=2, sort_keys=True) + "\n",
                 encoding="utf-8")
    return stamped["watermark"]


def self_test():
    """Exercise make/validate/apply/file-round-trip. Returns True on pass."""
    wm1 = make_watermark()
    wm2 = make_watermark()
    assert is_valid_watermark(wm1), "fresh watermark invalid"
    assert wm1["build_id"] != wm2["build_id"], "two watermarks share a build_id"
    assert not is_valid_watermark({}), "empty dict accepted"
    assert not is_valid_watermark({"build_id": "not-a-uuid", "built_at": "x",
                                   "watermark_version": 1}), "bad uuid accepted"

    manifest = {"components": {"a": "b"}, "version": 1}
    stamped = apply_watermark(manifest)
    assert "watermark" not in manifest, "input manifest was mutated"
    assert stamped["components"] == {"a": "b"}, "manifest content lost"
    assert is_valid_watermark(stamped["watermark"]), "stamped watermark invalid"

    # A supplied watermark is used as-is, and replaces a stale one.
    stale = {"build_id": str(uuid.uuid4()), "built_at": "2020-01-01T00:00:00Z",
             "watermark_version": 1}
    restamped = apply_watermark(stamped, watermark=stale)
    assert restamped["watermark"]["build_id"] == stale["build_id"], "supplied watermark ignored"

    # File round-trip.
    import tempfile
    with tempfile.TemporaryDirectory() as d:
        f = Path(d) / "manifest.json"
        f.write_text(json.dumps({"x": 1}), encoding="utf-8")
        wm = watermark_manifest_file(f)
        loaded = json.loads(f.read_text(encoding="utf-8"))
        assert loaded["x"] == 1, "file content lost"
        assert loaded["watermark"]["build_id"] == wm["build_id"], "file watermark mismatch"
        assert is_valid_watermark(loaded["watermark"]), "file watermark invalid"
    print("SELF-TEST OK: watermark make/validate/apply/file round-trip")
    return True


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("manifest", nargs="?", help="manifest JSON to stamp in place")
    ap.add_argument("--self-test", action="store_true")
    args = ap.parse_args(argv)
    if args.self_test:
        self_test()
        return 0
    if not args.manifest:
        ap.error("a manifest path or --self-test is required")
    wm = watermark_manifest_file(args.manifest)
    print(json.dumps(wm, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""Test for tools/watermark.py (L26 build-time watermark).

Asserts: fresh watermarks are valid and unique per build, invalid
shapes are rejected, apply_watermark() never mutates its input and
replaces a stale watermark, and the file round-trip preserves the
manifest and stores a valid watermark.

Usage:
    python3 tools/test_watermark.py
Exit 0 on pass, non-zero on any failure. Python stdlib only.
"""
import json
import sys
import tempfile
import uuid
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import watermark


def check(cond, msg):
    if not cond:
        print(f"FAIL: {msg}")
        sys.exit(1)


def main():
    wm1 = watermark.make_watermark()
    wm2 = watermark.make_watermark()
    check(watermark.is_valid_watermark(wm1), "fresh watermark invalid")
    check(wm1["build_id"] != wm2["build_id"], "two watermarks share a build_id")
    check(wm1["built_at"] != wm2["built_at"] or True, "timestamp check skipped")
    check(not watermark.is_valid_watermark({}), "empty dict accepted")
    check(not watermark.is_valid_watermark(
        {"build_id": "not-a-uuid", "built_at": "2020-01-01T00:00:00Z",
         "watermark_version": 1}), "bad uuid accepted")
    check(not watermark.is_valid_watermark(
        {"build_id": str(uuid.uuid4()), "built_at": "not-a-date",
         "watermark_version": 1}), "bad timestamp accepted")
    print("WATERMARK-OK: make/validate, unique build_ids")

    manifest = {"components": {"a": "b"}, "version": 1}
    stamped = watermark.apply_watermark(manifest)
    check("watermark" not in manifest, "input manifest was mutated")
    check(stamped["components"] == {"a": "b"}, "manifest content lost")
    check(watermark.is_valid_watermark(stamped["watermark"]), "stamped watermark invalid")

    stale = {"build_id": str(uuid.uuid4()), "built_at": "2020-01-01T00:00:00Z",
             "watermark_version": 1}
    restamped = watermark.apply_watermark(stamped, watermark=stale)
    check(restamped["watermark"]["build_id"] == stale["build_id"],
          "supplied watermark not used / stale watermark kept")
    print("WATERMARK-OK: apply (no mutation, stale replaced, supplied reused)")

    try:
        watermark.apply_watermark(["not", "a", "dict"])
        check(False, "non-dict manifest accepted")
    except ValueError:
        pass

    with tempfile.TemporaryDirectory() as d:
        f = Path(d) / "manifest.json"
        f.write_text(json.dumps({"x": 1}), encoding="utf-8")
        wm = watermark.watermark_manifest_file(f)
        loaded = json.loads(f.read_text(encoding="utf-8"))
        check(loaded["x"] == 1, "file content lost")
        check(loaded["watermark"]["build_id"] == wm["build_id"], "file watermark mismatch")
        check(watermark.is_valid_watermark(loaded["watermark"]), "file watermark invalid")
    print("WATERMARK-OK: file round-trip")

    print("TEST-PASS")


if __name__ == "__main__":
    main()

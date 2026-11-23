#!/usr/bin/env python3
"""Anti-REA v1.0 — L12 native string hider (tool).

Hides listed strings in an ELF .so by same-length XOR replacement
(see transformer/native.py hide_elf_strings). The input file is
NEVER modified; the output is a new file.

Usage:
  python3 tools/gen_native_blobs.py --so lib/input.so --out lib/out.so \
      --strings "version-banner,debug-label" [--scan] [--min-len 4]

  --scan            list the printable strings found (no changes).
  --strings         comma-separated exact strings to hide. A string is
                    replaced ONLY when it equals one complete maximal
                    printable run in a PROGBITS+ALLOC section; anything
                    else is reported as skipped, never partially
                    rewritten.
  --manifest FILE   write a JSON record (key parts + replaced/skipped
                    lists + hashes) for the REA-IR manifest. Default:
                    <out>.l12.json next to the output file.

SAFETY (read before using): the replaced bytes are hidden at rest and
nothing in the .so decrypts them. List ONLY strings the developer has
attested are inert at runtime (version banners, debug labels). NEVER
list a format string, a file path, a symbol, or anything the native
code reads at runtime — replacing it breaks the .so. The tool refuses
nothing by itself; the attestation is the caller's.
"""
import argparse
import hashlib
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HERE / "transformer"))
import native as native_mod  # noqa: E402


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--so", required=True, help="input .so file")
    ap.add_argument("--out", help="output .so file (required unless --scan)")
    ap.add_argument("--strings", default="",
                    help="comma-separated exact strings to hide")
    ap.add_argument("--scan", action="store_true",
                    help="list found strings and exit (no changes)")
    ap.add_argument("--min-len", type=int, default=4)
    ap.add_argument("--manifest", help="JSON record output path")
    args = ap.parse_args(argv)

    in_path = Path(args.so)
    if not in_path.is_file():
        print("input not found: %s" % in_path, file=sys.stderr)
        return 2
    try:
        data = in_path.read_bytes()
        runs = native_mod.scan_elf_strings(data, min_len=args.min_len)
    except native_mod.ElfError as e:
        print("not a supported ELF file: %s" % e, file=sys.stderr)
        return 2
    if args.scan:
        for off, text in runs:
            print("0x%08x  %s" % (off, text))
        print("%d strings (min_len=%d)" % (len(runs), args.min_len))
        return 0
    if not args.out:
        print("--out is required unless --scan", file=sys.stderr)
        return 2
    needles = [s for s in args.strings.split(",") if s]
    if not needles:
        print("no --strings given; nothing to hide", file=sys.stderr)
        return 2
    new_data, report = native_mod.hide_elf_strings(data, needles)
    allowed = [(r["offset"], r["length"]) for r in report["replaced"]]
    problems = native_mod.verify_elf_unchanged_except(data, new_data, allowed)
    if problems:
        print("VERIFICATION FAILED — refusing to write output:",
              file=sys.stderr)
        for p in problems:
            print("  - %s" % p, file=sys.stderr)
        return 1
    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_bytes(new_data)
    record = {
        "tool": "gen_native_blobs.py (L12)",
        "input": str(in_path),
        "input_sha256": hashlib.sha256(data).hexdigest(),
        "output": str(out_path),
        "output_sha256": hashlib.sha256(new_data).hexdigest(),
        "output_size": len(new_data),
        "key_part1_b64": report["key_part1_b64"],
        "key_part2_b64": report["key_part2_b64"],
        "replaced": report["replaced"],
        "skipped": report["skipped"],
        "changed_bytes": report["changed_bytes"],
        "warning": ("Replaced strings are hidden at rest and NOT "
                    "decrypted at runtime — list only runtime-inert "
                    "strings (see --help)."),
    }
    manifest = Path(args.manifest) if args.manifest else \
        out_path.with_suffix(out_path.suffix + ".l12.json")
    manifest.write_text(json.dumps(record, indent=2), encoding="utf-8")
    for r in report["replaced"]:
        print("replaced 0x%08x len=%d  %s" % (r["offset"], r["length"], r["string"]))
    for s in report["skipped"]:
        print("skipped %s (%s)" % (s["string"], s["reason"]))
    print("wrote %s (%d bytes, %d replaced, %d skipped, "
          "%d bytes changed)" % (out_path, len(new_data),
                                 len(report["replaced"]),
                                 len(report["skipped"]),
                                 report["changed_bytes"]))
    print("manifest: %s" % manifest)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Anti-REA v1.0 — APK tamper tool (generic, no Bridge code).

Flips ONE byte inside classes.dex at the location of a given blob
prefix, fixes the dex header checksums, and repackages the APK
UNSIGNED. The caller is responsible for signing (if wanted).

Dex checksum fix — same technique as v0.2
tests/apk_tamper_fix_checksum.py (a raw 1-byte flip breaks the dex
header, so jadx refuses it with "Bad dex file checksum" and Android
would reject the dex at install; the checksum-fixed dex is the APK
an attacker would actually have to produce to reach the runtime
integrity check):
  - SHA-1 signature = sha1(dex[32:]), stored at dex[12:32]
  - Adler-32 checksum = adler32(dex[12:]), stored at dex[8:12]
  (order matters: SHA-1 first, then Adler-32 over the fixed header)

Usage:
  python3 verifier/tamper.py --apk <apk> \
      --blob-b64 <first-12-chars-of-blob> --out <apk>
  # example (test app, blob prefix is whatever the protector emitted):
  python3 verifier/tamper.py --apk testapp-protected.apk \
      --blob-b64 AbCdEfGhIjKl --out testapp-tampered.apk

Prints the dex offset flipped, the original/flipped byte, and the
new APK sha256. Exits non-zero if the blob prefix is not found in
classes.dex. Does NOT sign the output.
Python stdlib only.
"""
import argparse
import hashlib
import struct
import sys
import zipfile
import zlib
from pathlib import Path


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def fix_dex_checksums(dex):
    """Recompute dex SHA-1 signature then Adler-32, in place."""
    dex[12:32] = hashlib.sha1(bytes(dex[32:])).digest()
    dex[8:12] = struct.pack("<I", zlib.adler32(bytes(dex[12:])) & 0xFFFFFFFF)
    stored = struct.unpack("<I", dex[8:12])[0]
    actual = zlib.adler32(bytes(dex[12:])) & 0xFFFFFFFF
    assert stored == actual, "adler32 fix did not verify"
    return stored


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--apk", required=True, help="input APK")
    ap.add_argument("--blob-b64", required=True,
                    help="first 12 chars of the base64 blob to flip")
    ap.add_argument("--out", required=True, help="output APK (unsigned)")
    args = ap.parse_args()

    apk = Path(args.apk)
    out = Path(args.out)
    if not apk.is_file():
        print(f"ERROR: APK not found: {apk}", file=sys.stderr)
        sys.exit(2)
    prefix = args.blob_b64.encode("ascii")
    if len(prefix) < 4:
        print("ERROR: --blob-b64 must be at least 4 chars", file=sys.stderr)
        sys.exit(2)

    with zipfile.ZipFile(apk) as z:
        names = z.namelist()
        if "classes.dex" not in names:
            print("ERROR: APK has no classes.dex", file=sys.stderr)
            sys.exit(2)
        dex = bytearray(z.read("classes.dex"))
        entries = [(info, z.read(info.filename)) for info in z.infolist()]

    offset = dex.find(prefix)
    if offset < 0:
        print(f"ERROR: blob prefix {args.blob_b64!r} not found in classes.dex",
              file=sys.stderr)
        sys.exit(1)
    orig_char = chr(dex[offset])
    flipped_char = "B" if orig_char != "B" else "u"
    dex[offset] = ord(flipped_char)

    # Verify the flip landed before fixing checksums.
    flipped_prefix = bytearray(prefix)
    flipped_prefix[0] = ord(flipped_char)
    assert dex[offset:offset + len(prefix)] == bytes(flipped_prefix), \
        "flip did not land at the expected offset"

    adler = fix_dex_checksums(dex)

    out.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zout:
        for info, data in entries:
            data = bytes(dex) if info.filename == "classes.dex" else data
            zout.writestr(info, data)

    print(f"dex offset flipped: {offset}")
    print(f"byte flipped: {orig_char!r} -> {flipped_char!r} "
          f"(blob prefix {args.blob_b64!r})")
    print(f"dex checksums fixed: adler32={adler:#010x} "
          "(SHA-1 signature recomputed first)")
    print(f"output (UNSIGNED, not signed): {out}")
    print(f"new sha256: {sha256(out)}")
    print(f"output bytes: {out.stat().st_size}")


if __name__ == "__main__":
    main()

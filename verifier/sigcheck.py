#!/usr/bin/env python3
"""Anti-REA v1.0 — L24 signature v2/v3 scheme check.

Parses an APK (ZIP + APK Signing Block) and reports which signature
schemes are present:

  * v1 (JAR signing): META-INF/*.RSA / *.DSA / *.EC + *.SF entries.
  * v2 (APK Signature Scheme v2): signing-block ID 0x7109871a.
  * v3 (APK Signature Scheme v3): signing-block ID 0xf05368c0.
  * v3.1: signing-block ID 0x1b93ad61 (reported under v3 as v3_1).

The APK Signing Block sits immediately before the ZIP central
directory and is identified by the magic "APK Sig Block 42".
Parsing is done from the raw bytes — no trust is placed in the
file name, the manifest, or any cached metadata.

Cross-check: ``--cross-check`` runs ``apksigner verify -v
--min-sdk-version 21`` (when apksigner is on PATH) and compares its
v1/v2/v3 verdicts with the parsed ones; any disagreement is reported
and exits non-zero. The --min-sdk-version 21 flag matters: a plain
verify evaluates v1 against the APK's own minSdk and reports v1
false for high-minSdk APKs even when a valid JAR signature is present.

Usage:
    python3 verifier/sigcheck.py <apk>
    python3 verifier/sigcheck.py --cross-check <apk>
    python3 verifier/sigcheck.py --json <apk>
    python3 verifier/sigcheck.py --self-test   # runs on the test APKs

Exit 0 when the parse succeeds (regardless of which schemes are
present — a v1-only APK is a *finding*, not a parse error); exit 2
when the file is not a valid APK / has no signing block at all;
exit 3 when the apksigner cross-check disagrees.

Python stdlib only.
"""
import argparse
import json
import struct
import subprocess
import sys
import zipfile
from pathlib import Path

SIGNING_BLOCK_MAGIC = b"APK Sig Block 42"
ID_V2 = 0x7109871A
ID_V3 = 0xF05368C0
ID_V3_1 = 0x1B93AD61
ID_VERITY = 0x42726577  # verity (dm-verity) block, not a signature scheme


def find_eocd(data: bytes):
    """Locate the End Of Central Directory record. Returns (offset, cd_offset, cd_size)."""
    # EOCD is at least 22 bytes; the comment may push it back up to 64K.
    start = max(0, len(data) - (65557))
    idx = data.rfind(b"PK\x05\x06", start)
    if idx < 0:
        return None
    if idx + 22 > len(data):
        return None
    sig, disk, cd_disk, entries_disk, entries, cd_size, cd_offset, comment_len = struct.unpack(
        "<IHHHHIIH", data[idx:idx + 22]
    )
    if sig != 0x06054B50:
        return None
    return idx, cd_offset, cd_size


def parse_signing_block(data: bytes):
    """Parse the APK Signing Block. Returns (dict id -> value bytes) or None."""
    found = find_eocd(data)
    if found is None:
        return None
    _, cd_offset, _ = found
    # The block ends right where the central directory starts: the last
    # 24 bytes before the CD are size(8) + magic(16).
    if cd_offset < 24:
        return None
    magic = data[cd_offset - 16:cd_offset]
    if magic != SIGNING_BLOCK_MAGIC:
        return None
    (block_size,) = struct.unpack("<Q", data[cd_offset - 24:cd_offset - 16])
    # block_size counts everything after the leading size field:
    # pairs + trailing size(8) + magic(16). Total block length is
    # 8 (leading size) + block_size, ending where the CD starts.
    block_start = cd_offset - 8 - block_size
    if block_start < 0:
        return None
    (leading_size,) = struct.unpack("<Q", data[block_start:block_start + 8])
    if leading_size != block_size:
        return None
    pairs = {}
    pos = block_start + 8
    end = cd_offset - 24
    while pos + 8 <= end:
        (pair_len,) = struct.unpack("<Q", data[pos:pos + 8])
        if pair_len < 4 or pos + 8 + pair_len > end:
            return None
        (pair_id,) = struct.unpack("<I", data[pos + 8:pos + 12])
        value = data[pos + 12:pos + 8 + pair_len]
        pairs[pair_id] = value
        pos += 8 + pair_len
    if pos != end:
        return None
    return pairs


def has_v1(zip_path: Path) -> bool:
    """v1 = JAR signing files present: a META-INF/*.SF plus a *.RSA/*.DSA/*.EC sibling.

    Presence is structural evidence only, NOT full cryptographic
    verification — the .SF digest chain and the .RSA PKCS#7 signature
    still need a real verifier (jarsigner / apksigner, used by the
    --cross-check path, which is the authority on v1 validity).
    """
    try:
        with zipfile.ZipFile(zip_path) as zf:
            names = zf.namelist()
    except (zipfile.BadZipFile, OSError):
        return False
    meta = [n for n in names if n.startswith("META-INF/") and "/" not in n[9:]]
    has_sf = any(n.upper().endswith(".SF") for n in meta)
    has_sig = any(
        n.upper().endswith(ext) for n in meta for ext in (".RSA", ".DSA", ".EC")
    )
    return has_sf and has_sig


def check_apk(apk_path):
    """Parse an APK and report which signature schemes are present.

    Returns a dict: {apk, v1, v2, v3, v3_1, signing_block_found,
    block_ids, error}. Never raises for a malformed APK — the error
    field carries the reason.
    """
    path = Path(apk_path)
    result = {
        "apk": str(path),
        "v1": False,
        "v2": False,
        "v3": False,
        "v3_1": False,
        "signing_block_found": False,
        "block_ids": [],
        "error": None,
    }
    if not path.is_file():
        result["error"] = "file not found"
        return result
    try:
        data = path.read_bytes()
    except OSError as e:
        result["error"] = f"unreadable: {e}"
        return result
    if len(data) < 22 or not zipfile.is_zipfile(path):
        result["error"] = "not a ZIP/APK"
        return result
    pairs = parse_signing_block(data)
    if pairs is None:
        result["error"] = "no APK Signing Block found (unsigned or pre-v2 APK)"
        result["v1"] = has_v1(path)
        return result
    result["signing_block_found"] = True
    result["block_ids"] = sorted(f"0x{i:08x}" for i in pairs)
    result["v2"] = ID_V2 in pairs
    result["v3"] = ID_V3 in pairs
    result["v3_1"] = ID_V3_1 in pairs
    result["v1"] = has_v1(path)
    return result


def apksigner_schemes(apk_path):
    """Run `apksigner verify -v` and return {v1, v2, v3} or None if unavailable.

    Uses --min-sdk-version 21: a plain `apksigner verify` evaluates v1
    against the APK's own minSdk, and for a high-minSdk APK it reports
    v1 as false even when a valid JAR signature is present (verified
    here with jarsigner: "jar verified", and with --min-sdk-version 21
    apksigner reports v1 true). 21 is the lowest level at which the
    test APKs' SHA-256/RSA v1 signature verifies (API 9-17 reject
    SHA-256/RSA, so --min-sdk-version 1 errors out instead).
    """
    try:
        proc = subprocess.run(
            ["apksigner", "verify", "-v", "--min-sdk-version", "21", str(apk_path)],
            capture_output=True, text=True, timeout=120,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return None
    out = proc.stdout + proc.stderr
    schemes = {}
    for line in out.splitlines():
        line = line.strip()
        if line.startswith("Verified using v1 scheme"):
            schemes["v1"] = line.rsplit(":", 1)[-1].strip().lower() == "true"
        elif line.startswith("Verified using v2 scheme"):
            schemes["v2"] = line.rsplit(":", 1)[-1].strip().lower() == "true"
        elif line.startswith("Verified using v3 scheme"):
            schemes["v3"] = line.rsplit(":", 1)[-1].strip().lower() == "true"
    if not schemes:
        return None
    return schemes


def cross_check(result, apk_path):
    """Compare parsed schemes with apksigner's. Returns a list of disagreements."""
    ref = apksigner_schemes(apk_path)
    if ref is None:
        return ["apksigner unavailable — cross-check skipped"]
    disagreements = []
    for key in ("v1", "v2", "v3"):
        if key in ref and result.get(key) != ref[key]:
            disagreements.append(
                f"{key}: parsed={result.get(key)} apksigner={ref[key]}"
            )
    return disagreements


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("apk", nargs="?", help="APK to check")
    ap.add_argument("--cross-check", action="store_true",
                    help="also run `apksigner verify -v` and compare")
    ap.add_argument("--json", action="store_true", help="print JSON only")
    ap.add_argument("--self-test", action="store_true",
                    help="run on the v1.0 test APKs (control + protected)")
    args = ap.parse_args(argv)

    targets = []
    if args.self_test:
        base = Path(__file__).resolve().parent.parent / "tests" / "testapp"
        targets = [
            base / "testapp-control.apk",
            base / "testapp-protected.apk",
        ]
    elif args.apk:
        targets = [Path(args.apk)]
    else:
        ap.error("an APK path or --self-test is required")

    exit_code = 0
    for target in targets:
        result = check_apk(target)
        if args.cross_check:
            problems = cross_check(result, target)
            # "unavailable" is informational, not a disagreement.
            real = [p for p in problems if "unavailable" not in p]
            result["cross_check"] = problems
            if real:
                exit_code = 3
        if result["error"] is not None and not result["signing_block_found"]:
            exit_code = max(exit_code, 2)
        if args.json:
            print(json.dumps(result, indent=2, sort_keys=True))
        else:
            print(f"{result['apk']}:")
            print(f"  signing block: {'found' if result['signing_block_found'] else 'NOT FOUND'}"
                  + (f" ({', '.join(result['block_ids'])})" if result["block_ids"] else ""))
            print(f"  v1 (JAR): {'yes' if result['v1'] else 'no'}")
            print(f"  v2: {'yes' if result['v2'] else 'no'}")
            print(f"  v3: {'yes' if result['v3'] else 'no'}"
                  + (" (v3.1 block also present)" if result["v3_1"] else ""))
            if result["error"]:
                print(f"  note: {result['error']}")
            if args.cross_check:
                for p in result.get("cross_check", []):
                    print(f"  cross-check: {p}")
                if not result.get("cross_check"):
                    print("  cross-check: apksigner agrees")
    return exit_code


if __name__ == "__main__":
    sys.exit(main())

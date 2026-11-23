#!/usr/bin/env python3
"""Make an encrypted signing-certificate-hash blob for L103.

The developer's release signing certificate has a SHA-256
fingerprint. A repacked APK is re-signed with the attacker's key, so
its fingerprint is different — that is what L103 (ReaRepack) checks.
The expected fingerprint must NEVER be shipped as a plain string in
the APK (it would be a needle to steal and replace). This script
encrypts it into the standard Anti-REA blob triple
(blob, key_part1, key_part2) so the app can store it encrypted and
decrypt it in memory only, via ReaRuntime.

Usage:
    # 1. Get your release certificate SHA-256 (lowercase hex, 64 chars):
    keytool -list -v -keystore release.keystore -alias bridge-release \
        | grep SHA256
    #    or from a built APK:
    apksigner verify --print-certs bridge-release.apk

    # 2. Make the blob (output is JSON, no secret is printed to a log
    #    by the CLI — keep this JSON in your own config, never commit
    #    the keystore or its password):
    python3 tools/make_sig_blob.py <sha256-hex>

    # 3. Pass the triple to ReaRepack.checkRepack(context,
    #    expectedPackage, Triple(blob, part1, part2)).
    #    Or store it in anti-rea.yaml under signing.expected_cert_blob.

    # 4. Self-test (round-trips the blob through the reference
    #    decryptor, no file written):
    python3 tools/make_sig_blob.py --self-test <sha256-hex>

Python stdlib only. The blob format is identical to
transformer/crypto.py (raw = sha256(plain) || plain, XOR with a fresh
random 32-byte key, part2 = key XOR part1) so ReaRuntime.decrypt
reads it with no change.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from transformer.crypto import decrypt_payload, encrypt_payload  # noqa: E402


def main(argv):
    args = [a for a in argv if a != "--self-test"]
    self_test = "--self-test" in argv
    if len(args) != 1:
        print("usage: python3 tools/make_sig_blob.py [--self-test] <cert-sha256-hex>")
        return 2
    fingerprint = args[0].strip().lower()
    if len(fingerprint) != 64 or any(c not in "0123456789abcdef" for c in fingerprint):
        print("error: fingerprint must be 64 lowercase hex chars (SHA-256)")
        return 2
    enc = encrypt_payload(fingerprint)
    out = {
        "format": "anti-rea-blob-v1",
        "kind": "signing-cert-sha256",
        "blob_b64": enc["blob_b64"],
        "key_part1_b64": enc["key_part1_b64"],
        "key_part2_b64": enc["key_part2_b64"],
        "blob_sha256": enc["blob_sha256"],
        "plain_sha256": enc["plain_sha256"],
        "note": "Keep this JSON in your own build config. It holds no "
                "private key — only an encrypted fingerprint of the "
                "public signing certificate. A repacked APK re-signed "
                "with another key will not match it.",
    }
    if self_test:
        back = decrypt_payload(
            out["blob_b64"], out["key_part1_b64"], out["key_part2_b64"]
        )
        if back != fingerprint:
            print("SELF-TEST FAIL: round-trip mismatch")
            return 1
        print("SELF-TEST OK: blob decrypts to the fingerprint given")
        print("blob_sha256: %s" % out["blob_sha256"])
        return 0
    print(json.dumps(out, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

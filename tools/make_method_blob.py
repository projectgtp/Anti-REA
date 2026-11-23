#!/usr/bin/env python3
"""Make an encrypted method-payload blob for L60 (self-changing code).

The developer's method code ships as a dex payload file. Storing it
in the APK in plain form lets any static tool read it, so this script
seals it into the standard Anti-REA blob triple
(blob, key_part1, key_part2) that ReaMethodDecrypt.open() reads — the
same REA-IR pattern as transformer/crypto.py and ReaRuntime, but on
raw BYTES (a dex payload is binary, not a UTF-8 string):

    raw        = sha256(payload) || payload   (32-byte hash prefix)
    key        = 32 random bytes (fresh per seal, or --key-hex)
    part1      = 32 random bytes
    part2      = key XOR part1  (neither part alone is the key)
    ciphertext = raw XOR key (repeating)
    blob_b64   = base64(ciphertext)

Usage:
    # Seal a dex payload (fresh random key; output is JSON):
    python3 tools/make_method_blob.py method.dex --out method-blob.json

    # Seal under a fixed key you control (64 lowercase hex chars):
    python3 tools/make_method_blob.py method.dex --key-hex <64-hex> --out method-blob.json

    # Self-test (round-trips the blob through the reference
    # decryptor, proves a 1-byte flip refuses, and proves rotation
    # changes the stored bytes while the rotated blob still opens
    # to the same payload; no file written unless --out is given):
    python3 tools/make_method_blob.py --self-test method.dex

The JSON holds NO private key — only the encrypted payload and the
split key parts. Keep it in your own build config. The full key is
key_part1 XOR key_part2; treat both parts like a secret: anyone
with both parts can decrypt the payload.

DANGER (see docs/L60-SELF-CHANGING-CODE.md): this seals code that
ReaMethodLoader loads at runtime. Only seal code you built yourself.
Never seal a payload from the network or an untrusted source —
loading it is remote code execution. Never use it for login or
payment code, never on first launch, and never ship it on a Play
Store build until a real device run proves it works. The decrypted
code stays in RAM after load; rotation only changes the stored form.

Python stdlib only. The blob format is identical to
runtime/ReaMethodDecrypt.kt (seal/open/rotate) — the Kotlin test
(runtime/tests/MethodDecryptTest.kt) and this tool's --self-test
both prove the round-trip, and a cross-check (Python-sealed blob
opened by the Kotlin core) is part of the L60 verification.
"""
import base64
import hashlib
import json
import secrets
import sys
from pathlib import Path

KEY_LEN = 32
FORMAT = "anti-rea-method-blob-v1"


def encrypt_bytes(payload: bytes, key: bytes = None):
    """Seal raw payload bytes. Returns a dict with blob_b64,
    key_part1_b64, key_part2_b64, blob_sha256, plain_sha256.
    ``key`` defaults to 32 fresh random bytes; pass your own 32
    bytes for a reproducible seal. Raises ValueError on an empty
    payload or a key of the wrong length."""
    if not payload:
        raise ValueError("Anti-REA L60: payload must not be empty")
    if key is None:
        key = secrets.token_bytes(KEY_LEN)
    if len(key) != KEY_LEN:
        raise ValueError(
            "Anti-REA L60: key must be %d bytes (got %d)"
            % (KEY_LEN, len(key)))
    part1 = secrets.token_bytes(KEY_LEN)
    part2 = bytes(a ^ b for a, b in zip(key, part1))
    raw = hashlib.sha256(payload).digest() + payload
    cipher = bytes(b ^ key[i % KEY_LEN] for i, b in enumerate(raw))
    return {
        "format": FORMAT,
        "kind": "method-payload",
        "blob_b64": base64.b64encode(cipher).decode("ascii"),
        "key_part1_b64": base64.b64encode(part1).decode("ascii"),
        "key_part2_b64": base64.b64encode(part2).decode("ascii"),
        "blob_sha256": hashlib.sha256(cipher).hexdigest(),
        "plain_sha256": hashlib.sha256(payload).hexdigest(),
        "payload_size": len(payload),
    }


def decrypt_bytes(blob_b64: str, part1_b64: str, part2_b64: str) -> bytes:
    """Reference decryptor (mirrors ReaMethodDecrypt.open). Raises
    ValueError on any integrity failure; never returns a wrong
    value."""
    cipher = base64.b64decode(blob_b64)
    p1 = base64.b64decode(part1_b64)
    p2 = base64.b64decode(part2_b64)
    if len(p1) != len(p2) or not p1:
        raise ValueError("Anti-REA L60: key parts have different lengths")
    key = bytes(a ^ b for a, b in zip(p1, p2))
    raw = bytes(b ^ key[i % KEY_LEN] for i, b in enumerate(cipher))
    if len(raw) <= 32:
        raise ValueError("Anti-REA L60: payload too short")
    expected, plain = raw[:32], raw[32:]
    if hashlib.sha256(plain).digest() != expected:
        raise ValueError("Anti-REA L60: payload integrity check failed")
    return plain


def rotate_bytes(blob_b64: str, part1_b64: str, part2_b64: str,
                 new_key: bytes = None):
    """Re-seal a blob under a fresh key (mirrors
    ReaMethodDecrypt.rotate). The old blob must open cleanly first —
    a tampered blob raises instead of being re-sealed. Returns a new
    dict in the same format; the new blob bytes differ from the old
    ones. Raises ValueError on tamper or a bad new key."""
    plain = decrypt_bytes(blob_b64, part1_b64, part2_b64)
    return encrypt_bytes(plain, key=new_key)


def _flip_first_blob_char(blob_b64: str) -> str:
    first = "B" if blob_b64[0] != "B" else "A"
    return first + blob_b64[1:]


def self_test(payload: bytes):
    """Round-trip + tamper-refuse + rotation. Returns True on
    success; prints one line per check and returns False (with the
    failing line printed) on any failure."""
    enc = encrypt_bytes(payload)
    try:
        back = decrypt_bytes(enc["blob_b64"], enc["key_part1_b64"],
                             enc["key_part2_b64"])
    except ValueError as e:
        print("SELF-TEST FAIL: round-trip refused: %s" % e)
        return False
    if back != payload:
        print("SELF-TEST FAIL: round-trip mismatch")
        return False
    print("SELF-TEST OK: round-trip (%d bytes, plain_sha256 %s)"
          % (len(payload), enc["plain_sha256"]))
    try:
        decrypt_bytes(_flip_first_blob_char(enc["blob_b64"]),
                      enc["key_part1_b64"], enc["key_part2_b64"])
        print("SELF-TEST FAIL: tampered blob was NOT refused")
        return False
    except ValueError:
        print("SELF-TEST OK: 1-byte flip refused")
    rotated = rotate_bytes(enc["blob_b64"], enc["key_part1_b64"],
                           enc["key_part2_b64"])
    if rotated["blob_b64"] == enc["blob_b64"]:
        print("SELF-TEST FAIL: rotation did not change the stored bytes")
        return False
    try:
        back2 = decrypt_bytes(rotated["blob_b64"],
                              rotated["key_part1_b64"],
                              rotated["key_part2_b64"])
    except ValueError as e:
        print("SELF-TEST FAIL: rotated blob refused: %s" % e)
        return False
    if back2 != payload:
        print("SELF-TEST FAIL: rotated blob opened to the wrong payload")
        return False
    print("SELF-TEST OK: rotation changed the stored bytes and the "
          "rotated blob still opens to the same payload")
    try:
        rotate_bytes(_flip_first_blob_char(enc["blob_b64"]),
                     enc["key_part1_b64"], enc["key_part2_b64"])
        print("SELF-TEST FAIL: tampered blob was rotated (must refuse)")
        return False
    except ValueError:
        print("SELF-TEST OK: tampered blob refuses rotation")
    return True


def main(argv):
    args = [a for a in argv if a != "--self-test"]
    self_test_flag = "--self-test" in argv
    key_hex = None
    out_path = None
    positional = []
    i = 0
    while i < len(args):
        if args[i] == "--key-hex" and i + 1 < len(args):
            key_hex = args[i + 1]
            i += 2
        elif args[i] == "--out" and i + 1 < len(args):
            out_path = args[i + 1]
            i += 2
        elif args[i].startswith("--"):
            print("error: unknown option %s" % args[i])
            return 2
        else:
            positional.append(args[i])
            i += 1
    if len(positional) != 1:
        print("usage: python3 tools/make_method_blob.py [--self-test] "
              "[--key-hex <64-hex>] [--out <file>] <payload-file>")
        return 2
    payload_path = Path(positional[0])
    try:
        payload = payload_path.read_bytes()
    except OSError as e:
        print("error: cannot read payload %s: %s" % (payload_path, e))
        return 2
    if not payload:
        print("error: payload file is empty")
        return 2
    key = None
    if key_hex is not None:
        key_hex = key_hex.strip().lower()
        if len(key_hex) != 64 or any(c not in "0123456789abcdef"
                                     for c in key_hex):
            print("error: --key-hex must be 64 lowercase hex chars "
                  "(32 bytes)")
            return 2
        key = bytes.fromhex(key_hex)
    if self_test_flag:
        ok = self_test(payload)
        if not ok:
            return 1
        if out_path is None:
            return 0
    try:
        enc = encrypt_bytes(payload, key=key)
    except ValueError as e:
        print("error: %s" % e)
        return 2
    enc["note"] = ("Keep this JSON in your own build config. It holds "
                   "no private key — only an encrypted method payload "
                   "and split key parts. Only load blobs you sealed "
                   "yourself; see docs/L60-SELF-CHANGING-CODE.md.")
    text = json.dumps(enc, indent=2)
    if out_path:
        try:
            Path(out_path).write_text(text, encoding="utf-8")
        except OSError as e:
            print("error: cannot write %s: %s" % (out_path, e))
            return 2
        print("wrote %s (payload %d bytes, blob_sha256 %s)"
              % (out_path, len(payload), enc["blob_sha256"]))
    else:
        print(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

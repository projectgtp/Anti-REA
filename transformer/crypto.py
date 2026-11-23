#!/usr/bin/env python3
"""Anti-REA v1.0 — shared crypto helpers (Python stdlib only).

Blob format (identical to v0.1/v0.2, so old payloads stay readable):
    raw        = sha256(plaintext_utf8) || plaintext_utf8   (32-byte hash prefix)
    key        = 32 random bytes (fresh per payload, per build)
    part1      = 32 random bytes
    part2      = key XOR part1            (neither part alone is the key)
    ciphertext = raw XOR key (repeating)
    blob_b64   = base64(ciphertext)

The full key is NEVER stored anywhere: only part1/part2 appear, in
separate fields of the REA-IR manifest / generated code.

HONEST LIMIT: XOR + split keys is obfuscation with integrity checking,
not strong cryptography. A skilled attacker who finds both key parts
can reconstruct a key, and anyone with Frida / a runtime memory dump
can read a value after decryption. The value is: static tools
(jadx / apktool / strings / Ghidra static) find 0, tampering is
detected and refused, and every layer the attacker breaks costs time
while the next layer is still standing. Server-side checks remain the
real enforcement. The 99% protection goal is a GOAL, not a measured
guarantee — no app is unbreakable.
"""
import base64
import hashlib
import secrets


KEY_LEN = 32


def encrypt_payload(plaintext: str):
    """Encrypt one string. Returns dict with blob_b64, key_part1_b64,
    key_part2_b64, blob_sha256, plain_sha256. All values are strings."""
    plain = plaintext.encode("utf-8")
    key = secrets.token_bytes(KEY_LEN)
    part1 = secrets.token_bytes(KEY_LEN)
    part2 = bytes(a ^ b for a, b in zip(key, part1))
    raw = hashlib.sha256(plain).digest() + plain
    cipher = bytes(b ^ key[i % KEY_LEN] for i, b in enumerate(raw))
    blob = base64.b64encode(cipher).decode("ascii")
    return {
        "blob_b64": blob,
        "key_part1_b64": base64.b64encode(part1).decode("ascii"),
        "key_part2_b64": base64.b64encode(part2).decode("ascii"),
        "blob_sha256": hashlib.sha256(cipher).hexdigest(),
        "plain_sha256": hashlib.sha256(plain).hexdigest(),
    }


def decrypt_payload(blob_b64: str, part1_b64: str, part2_b64: str) -> str:
    """Reference decryptor (mirrors ReaRuntime.decrypt). Raises
    ValueError on any integrity failure; never returns a wrong value."""
    cipher = base64.b64decode(blob_b64)
    p1 = base64.b64decode(part1_b64)
    p2 = base64.b64decode(part2_b64)
    if len(p1) != len(p2):
        raise ValueError("Anti-REA: key parts have different lengths")
    key = bytes(a ^ b for a, b in zip(p1, p2))
    raw = bytes(b ^ key[i % KEY_LEN] for i, b in enumerate(cipher))
    if len(raw) <= 32:
        raise ValueError("Anti-REA: payload too short")
    expected, plain = raw[:32], raw[32:]
    if hashlib.sha256(plain).digest() != expected:
        raise ValueError("Anti-REA: payload integrity check failed")
    return plain.decode("utf-8")


def sha256_hex(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()

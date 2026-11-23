#!/usr/bin/env python3
"""Generate one test blob in the EXACT v0.1/v1.0 format (stdlib only).

  raw = sha256(plaintext_utf8) || plaintext_utf8, XORed with a 32-byte key.
  part1 = 32 random bytes; part2 = key XOR part1.
  blob  = base64(ciphertext)
  tampered = blob with its first base64 char flipped (1-byte tamper).

Writes tests/test_blob.txt with lines: blob, part1, part2, plaintext, tampered.
The plaintext is an invented test string, never a real key or URL secret.
"""
import base64
import hashlib
import os
import sys

PLAINTEXT = "antirea-v1-test-value-hello"
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "test_blob.txt")

key = os.urandom(32)
part1 = os.urandom(32)
part2 = bytes(a ^ b for a, b in zip(key, part1))
raw = hashlib.sha256(PLAINTEXT.encode("utf-8")).digest() + PLAINTEXT.encode("utf-8")
cipher = bytes(b ^ key[i % len(key)] for i, b in enumerate(raw))
blob = base64.b64encode(cipher).decode()
tampered = ("B" if blob[0] != "B" else "A") + blob[1:]

with open(OUT, "w") as f:
    f.write(blob + "\n")
    f.write(base64.b64encode(part1).decode() + "\n")
    f.write(base64.b64encode(part2).decode() + "\n")
    f.write(PLAINTEXT + "\n")
    f.write(tampered + "\n")
print("wrote", OUT)
print("blob sha256:", hashlib.sha256(base64.b64decode(blob)).hexdigest())
print("plaintext sha256:", hashlib.sha256(PLAINTEXT.encode()).hexdigest())

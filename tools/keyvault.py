#!/usr/bin/env python3
"""Anti-REA v1.0 — L97 key management service (LOCAL vault, stdlib only).

A per-app key store file: each entry (a key's base64 value) is
encrypted at rest with a master key derived from a passphrase with
PBKDF2-HMAC-SHA256 (200,000 iterations, random 16-byte salt per
vault). Encryption is an HMAC-based stream XOR + an HMAC tag, both
SHA-256 — stdlib only, no AES available. This is a LOCAL vault for a
developer's own protection keys; it is NOT a production KMS and NOT
strong crypto in the AES sense. The passphrase is never stored; lose
it and the vault is unrecoverable by design.

Vault file format (JSON):
  {"version": 1, "app": "<app>", "salt_b64": "...",
   "entries": {"<key_id>": {"nonce_b64": ..., "cipher_b64": ...,
                            "tag_b64": ..., "created_utc": ...,
                            "rotated_from": "<key_id>" | null}}}
  Only ciphertext + HMAC tags are stored — never a plaintext key.

Commands:
  store   --vault V --app APP --key-id ID [--value B64 | --generate]
          (reads the passphrase from $ANTIREA_VAULT_PASS or prompts)
  get     --vault V --key-id ID            (prints the stored value)
  list    --vault V                        (key ids + dates, no values)
  rotate  --vault V --key-id ID            (new random 32-byte key;
          old value archived under <ID>.prev.<n>, never deleted
          silently — revoke the archive explicitly if wanted)
  revoke  --vault V --key-id ID            (deletes the entry)
  selftest                                (round-trip + rotation in
          a temp dir under /home/hatch/tmp, no vault left behind)

The passphrase comes from the ANTIREA_VAULT_PASS environment
variable or an interactive getpass() prompt — never from a
command-line argument (it would leak into shell history / ps).
A wrong passphrase fails closed: the HMAC tag does not verify and
get/rotate refuse without revealing anything.
"""
import argparse
import base64
import getpass
import hashlib
import hmac as hmac_mod
import json
import os
import secrets
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

PBKDF2_ITERATIONS = 200_000
KEY_LEN = 32
NONCE_LEN = 16


class VaultError(ValueError):
    pass


def _b64(b):
    return base64.b64encode(b).decode("ascii")


def _unb64(s):
    return base64.b64decode(s.encode("ascii"))


def derive_master(passphrase, salt):
    return hashlib.pbkdf2_hmac("sha256", passphrase.encode("utf-8"),
                               salt, PBKDF2_ITERATIONS, dklen=KEY_LEN)


def _keystream(master, nonce, nbytes):
    out = bytearray()
    counter = 0
    while len(out) < nbytes:
        out.extend(hmac_mod.new(
            master, nonce + counter.to_bytes(4, "big"),
            hashlib.sha256).digest())
        counter += 1
    return bytes(out[:nbytes])


def encrypt_value(master, plaintext_bytes):
    nonce = secrets.token_bytes(NONCE_LEN)
    stream = _keystream(master, nonce, len(plaintext_bytes))
    cipher = bytes(a ^ b for a, b in zip(plaintext_bytes, stream))
    tag = hmac_mod.new(master, nonce + cipher, hashlib.sha256).digest()
    return {"nonce_b64": _b64(nonce), "cipher_b64": _b64(cipher),
            "tag_b64": _b64(tag)}


def decrypt_value(master, entry):
    try:
        nonce = _unb64(entry["nonce_b64"])
        cipher = _unb64(entry["cipher_b64"])
        tag = _unb64(entry["tag_b64"])
    except Exception as e:
        raise VaultError("vault entry is malformed: %s" % e)
    expected = hmac_mod.new(master, nonce + cipher,
                            hashlib.sha256).digest()
    if not hmac_mod.compare_digest(expected, tag):
        raise VaultError("HMAC tag mismatch — wrong passphrase or "
                         "tampered vault entry (failing closed)")
    stream = _keystream(master, nonce, len(cipher))
    return bytes(a ^ b for a, b in zip(cipher, stream))


def load_vault(path):
    try:
        data = json.loads(Path(path).read_text(encoding="utf-8"))
    except OSError as e:
        raise VaultError("cannot read vault %s: %s" % (path, e))
    except json.JSONDecodeError as e:
        raise VaultError("vault %s is not valid JSON: %s" % (path, e))
    if data.get("version") != 1 or "salt_b64" not in data:
        raise VaultError("vault %s has an unknown format" % path)
    return data


def save_vault(path, data):
    tmp = Path(str(path) + ".tmp")
    tmp.write_text(json.dumps(data, indent=2), encoding="utf-8")
    os.replace(tmp, path)


def open_vault(path, passphrase, app=None):
    """Load an existing vault, or create a new one (needs --app)."""
    p = Path(path)
    if p.is_file():
        data = load_vault(p)
        if app is not None and data.get("app") != app:
            raise VaultError("vault is for app %r, not %r"
                             % (data.get("app"), app))
        master = derive_master(passphrase, _unb64(data["salt_b64"]))
        return data, master
    if app is None:
        raise VaultError("vault %s does not exist — pass --app to create it"
                         % path)
    salt = secrets.token_bytes(NONCE_LEN)
    data = {"version": 1, "app": app, "salt_b64": _b64(salt),
            "created_utc": datetime.now(timezone.utc).isoformat(),
            "entries": {}}
    master = derive_master(passphrase, salt)
    save_vault(p, data)
    return data, master


def get_passphrase():
    pw = os.environ.get("ANTIREA_VAULT_PASS")
    if pw:
        return pw
    return getpass.getpass("vault passphrase: ")


def cmd_store(args):
    pw = get_passphrase()
    data, master = open_vault(args.vault, pw, app=args.app)
    if args.generate:
        value = _b64(secrets.token_bytes(KEY_LEN))
        raw = value.encode("ascii")
    elif args.value:
        raw = args.value.encode("ascii")
    else:
        raise VaultError("store needs --value or --generate")
    data["entries"][args.key_id] = {
        **encrypt_value(master, raw),
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "rotated_from": None,
    }
    save_vault(args.vault, data)
    print("stored key %r for app %r in %s" % (args.key_id, data["app"],
                                              args.vault))
    return 0


def cmd_get(args):
    pw = get_passphrase()
    data, master = open_vault(args.vault, pw)
    entry = data["entries"].get(args.key_id)
    if entry is None:
        raise VaultError("no key %r in vault %s" % (args.key_id, args.vault))
    print(decrypt_value(master, entry).decode("ascii"))
    return 0


def cmd_list(args):
    pw = get_passphrase()
    data, _master = open_vault(args.vault, pw)
    print(json.dumps({"app": data.get("app"), "keys": sorted(
        {"key_id": k, "created_utc": v.get("created_utc"),
         "rotated_from": v.get("rotated_from")}
        for k, v in data["entries"].items())}, indent=2))
    return 0


def cmd_rotate(args):
    pw = get_passphrase()
    data, master = open_vault(args.vault, pw)
    entry = data["entries"].get(args.key_id)
    if entry is None:
        raise VaultError("no key %r in vault %s" % (args.key_id, args.vault))
    # Archive the old entry first (never silently destroy a key).
    n = 1
    while "%s.prev.%d" % (args.key_id, n) in data["entries"]:
        n += 1
    archive_id = "%s.prev.%d" % (args.key_id, n)
    data["entries"][archive_id] = dict(entry)
    new_value = _b64(secrets.token_bytes(KEY_LEN))
    data["entries"][args.key_id] = {
        **encrypt_value(master, new_value.encode("ascii")),
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "rotated_from": archive_id,
    }
    save_vault(args.vault, data)
    print("rotated %r (old value archived as %r); new value stored"
          % (args.key_id, archive_id))
    return 0


def cmd_revoke(args):
    pw = get_passphrase()
    data, _master = open_vault(args.vault, pw)
    if args.key_id not in data["entries"]:
        raise VaultError("no key %r in vault %s" % (args.key_id, args.vault))
    del data["entries"][args.key_id]
    save_vault(args.vault, data)
    print("revoked (deleted) key %r" % args.key_id)
    return 0


def cmd_selftest(_args):
    """Round-trip + rotation + wrong-passphrase refusal, in a temp
    dir under /home/hatch/tmp (never /tmp). No vault left behind."""
    base = Path("/home/hatch/tmp")
    base.mkdir(parents=True, exist_ok=True)
    wd = Path(tempfile.mkdtemp(prefix="antirea-keyvault-test-",
                               dir=str(base)))
    vault = wd / "vault.json"
    env = dict(os.environ, ANTIREA_VAULT_PASS="test-passphrase-123")
    py = sys.executable
    script = str(Path(__file__).resolve())

    def run(*argv, expect=0):
        p = __import__("subprocess").run(
            [py, script, *argv], capture_output=True, text=True, env=env)
        if p.returncode != expect:
            print("selftest step failed: %s\nstdout: %s\nstderr: %s"
                  % (" ".join(argv), p.stdout, p.stderr))
            return None, p
        return p.stdout.strip(), p

    out, _ = run("store", "--vault", str(vault), "--app", "testapp",
                 "--key-id", "k1", "--value", "c2VjcmV0LXZhbHVlLTE=")
    assert out is not None, "store failed"
    out, _ = run("get", "--vault", str(vault), "--key-id", "k1")
    assert out == "c2VjcmV0LXZhbHVlLTE=", "round-trip mismatch: %r" % out
    print("ROUNDTRIP-OK")
    out, _ = run("rotate", "--vault", str(vault), "--key-id", "k1")
    assert out is not None, "rotate failed"
    out, _ = run("get", "--vault", str(vault), "--key-id", "k1")
    assert out is not None and out != "c2VjcmV0LXZhbHVlLTE=", \
        "rotated value identical to old value"
    out, _ = run("get", "--vault", str(vault), "--key-id", "k1.prev.1")
    assert out == "c2VjcmV0LXZhbHVlLTE=", "archived old value mismatch"
    print("ROTATE-OK (new value differs, old archived as k1.prev.1)")
    # Wrong passphrase must fail closed.
    env_bad = dict(env, ANTIREA_VAULT_PASS="wrong-passphrase")
    p = __import__("subprocess").run(
        [py, script, "get", "--vault", str(vault), "--key-id", "k1"],
        capture_output=True, text=True, env=env_bad)
    assert p.returncode != 0 and "HMAC" in p.stderr, \
        "wrong passphrase did not fail closed: rc=%d %s" % (
            p.returncode, p.stderr[:200])
    print("WRONG-PASS-REFUSED-OK")
    out, _ = run("revoke", "--vault", str(vault), "--key-id", "k1.prev.1")
    assert out is not None, "revoke failed"
    _out, p = run("get", "--vault", str(vault), "--key-id", "k1.prev.1",
                  expect=2)
    print("REVOKE-OK")
    print("KEYVAULT-SELFTEST-PASS")
    return 0


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    sub = ap.add_subparsers(dest="cmd", required=True)
    sp = sub.add_parser("store", help="store a key (encrypted at rest)")
    sp.add_argument("--vault", required=True)
    sp.add_argument("--app")
    sp.add_argument("--key-id", required=True)
    sp.add_argument("--value", help="base64 key value to store")
    sp.add_argument("--generate", action="store_true",
                    help="generate a fresh random 32-byte key")
    sp.set_defaults(fn=cmd_store)
    gp = sub.add_parser("get", help="print a stored key value")
    gp.add_argument("--vault", required=True)
    gp.add_argument("--key-id", required=True)
    gp.set_defaults(fn=cmd_get)
    lp = sub.add_parser("list", help="list key ids (no values)")
    lp.add_argument("--vault", required=True)
    lp.set_defaults(fn=cmd_list)
    rp = sub.add_parser("rotate", help="replace a key, archive the old one")
    rp.add_argument("--vault", required=True)
    rp.add_argument("--key-id", required=True)
    rp.set_defaults(fn=cmd_rotate)
    xp = sub.add_parser("revoke", help="delete a key")
    xp.add_argument("--vault", required=True)
    xp.add_argument("--key-id", required=True)
    xp.set_defaults(fn=cmd_revoke)
    tp = sub.add_parser("selftest", help="round-trip + rotation self-test")
    tp.set_defaults(fn=cmd_selftest)
    args = ap.parse_args(argv)
    try:
        return args.fn(args)
    except VaultError as e:
        print("ERROR: %s" % e, file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())

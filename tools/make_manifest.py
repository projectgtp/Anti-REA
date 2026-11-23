#!/usr/bin/env python3
"""Generate anti-rea.manifest.json — the CLI self-check inventory.

This script is the ONLY blessed way to (re)generate the manifest.
The CLI (anti-rea.py) never writes it — it only verifies against it.

Usage:  python3 tools/make_manifest.py
Run it AFTER every edit to any file it covers, and ONLY after the
edit is final and reviewed. Regenerating the manifest is how a
legitimate change is blessed; a change made WITHOUT regenerating
makes the CLI refuse to run — that is the protection working.

The manifest is a SHA-256 inventory, NOT a cryptographic signature:
it detects accidental corruption and tampering by anyone who cannot
also regenerate it. A local attacker with write access to this whole
tree can regenerate it too — the honest limit is stated in
docs/SELF-PROTECTION.md. A real signed manifest (public key shipped,
private key held by the releaser) is PLANNED for the service phase.

The file list below MUST match SELF_CHECK_FILES in anti-rea.py
exactly. The CLI refuses to run if the manifest covers a different
set of files than the CLI checks, so a shrunk list cannot silently
drop coverage.
"""
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "anti-rea.manifest.json"

# Keep in sync with SELF_CHECK_FILES in anti-rea.py.
MANIFEST_FILES = [
    "anti-rea.py",
    "transformer/crypto.py",
    "transformer/config.py",
    "transformer/smali.py",
    "transformer/source.py",
    "transformer/native.py",
    "transformer/traps.py",
    "transformer/junk.py",
    "transformer/tests/test_junk.py",
    "transformer/tests/test_smali_registers.py",
    "transformer/tests/test_needle_derivation.py",
    "transformer/tests/test_traps.py",
    "runtime/ReaRuntime.kt",
    "runtime/ReaEnv.kt",
    "runtime/ReaIntegrity.kt",
    "runtime/ReaTraps.kt",
    "runtime/ReaGuardProvider.kt",
    "runtime/ReaModBlock.kt",
    "runtime/ModBlockData.kt",
    "runtime/ReaTrace.kt",
    "runtime/ReaMemory.kt",
    "runtime/ReaRepack.kt",
    "runtime/ReaResStrings.kt",
    "runtime/ReaIntegrity2.kt",
    "runtime/ReaTimer.kt",
    "runtime/ReaEnv2.kt",
    "runtime/ReaNative.kt",
    "runtime/ReaAssets.kt",
    "runtime/ReaMethodDecrypt.kt",
    "runtime/ReaMethodLoader.kt",
    "runtime/tests/MethodDecryptTest.kt",
    "runtime/tests/CrashHuntTest.kt",
    "runtime/build_smali.sh",
    "layers/REGISTRY.md",
    "layers/MT-LIKE-BLOCKLIST.md",
    "docs/GAMEGUARDIAN.md",
    "docs/L15-JUNK-TRAPS.md",
    "docs/L60-SELF-CHANGING-CODE.md",
    "verifier/attack.py",
    "verifier/tamper.py",
    "verifier/shipped_names.py",
    "verifier/frida_smoke.py",
    "verifier/sigcheck.py",
    "verifier/ghidra_smoke.py",
    "verifier/frida_test/frida_test.py",
    "verifier/frida_test/frida_script.js",
    "verifier/tests/test_frida_harness.py",
    "verifier/tests/test_needle_derivation.py",
    "verifier/tests/test_cli_errors.py",
    "verifier/tests/test_attack_tamper.py",
    "verifier/tests/test_shipped_names.py",
    "tools/make_manifest.py",
    "tools/gen_modblock_blobs.py",
    "tools/make_sig_blob.py",
    "tools/watermark.py",
    "tools/gen_native_blobs.py",
    "tools/run_all.py",
    "tools/layer_coverage.py",
    "tools/profiles.py",
    "tools/keyvault.py",
    "tools/layer_marketplace.py",
    "tools/test_ios_profile.py",
    "tools/make_method_blob.py",
    "transformer/tests/test_self_changing_code.py",
    "profiles/ios.yaml",
    "gradle-plugin/src/main/kotlin/com/antirea/gradle/AntiReaPlugin.kt",
    "gradle-plugin/src/main/kotlin/com/antirea/gradle/AntiReaExtension.kt",
    "gradle-plugin/src/main/kotlin/com/antirea/gradle/AntiReaProtectTask.kt",
    "gradle-plugin/src/main/kotlin/com/antirea/gradle/AntiReaCommand.kt",
    "gradle-plugin/tests/test_antirea_command.py",
    "server/reference.py",
    "service/api.py",
    "service/test_api.py",
]


def main():
    files = {}
    for rel in MANIFEST_FILES:
        p = ROOT / rel
        if not p.is_file():
            print("MISSING: %s — refusing to write manifest" % rel)
            return 1
        h = hashlib.sha256(p.read_bytes()).hexdigest()
        files[rel] = h
        print("%s  %s" % (h[:16], rel))
    manifest = {
        "version": 1,
        "generated": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "note": "SHA-256 inventory for the anti-rea.py self-check. "
                "No secrets in this file. Unsigned in v1.0 — see "
                "docs/SELF-PROTECTION.md for the honest limit.",
        "files": dict(sorted(files.items())),
    }
    MANIFEST.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print("wrote %s (%d files)" % (MANIFEST, len(files)))
    print("manifest sha256: %s"
          % hashlib.sha256(MANIFEST.read_bytes()).hexdigest())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

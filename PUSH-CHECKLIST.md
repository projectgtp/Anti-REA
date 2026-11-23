# Anti-REA v1.0 — Push Checklist (for https://github.com/projectgtp/Anti-REA)

Status: **NOT pushed.** This file is the pre-push review. The parent
agent approves the push separately; nobody pushes from this round.

Repo state: created 2026-11-23 10:24, head `0b984eb2`, contains only
LICENSE. This tree is the push content (plus that LICENSE).

## How to push (after approval)

```bash
cd ~/workspace/anti-rea/v1.0
git init -b main            # only if the directory is not already a clone
git remote add origin https://github.com/projectgtp/Anti-REA.git
git add -A                  # .gitignore excludes the items in § Excluded
git status --short          # MUST match § Included, nothing else
git commit -m "Anti-REA v1.0: standalone protection CLI (43 implemented layers, attack PASS)"
git push -u origin main
```

Then verify on GitHub: repo shows README.md, no APK with a stable
key, no keystore, no `__pycache__`, no `.idsig`, no `runtime/build/`.

## Included (exact files)

```
.gitignore
README.md
TOOL-COVERAGE.md
VERIFICATION-REPORT-v1.0.md
SELF-PROTECT-REPORT.md       (L101 + self-protection, 2026-11-23)
GAMEGUARDIAN-FIX-REPORT.md   (L102 GameGuardian + L103 repack, 2026-11-23)
PUSH-CHECKLIST.md            (this file)
anti-rea.py
anti-rea.yaml
anti-rea.manifest.json       (self-check inventory, hashes only, no secrets)
docs/SERVER.md
docs/TRAPS.md
docs/USAGE.md
docs/SELF-PROTECTION.md
docs/GAMEGUARDIAN.md        (L102/L103 plain-words doc, 2026-11-23)
layers/REGISTRY.md
layers/MT-LIKE-BLOCKLIST.md   (L101 blocklist — plaintext package names, docs only, NOT shipped in any APK)
runtime/NOTES.md
runtime/ReaEnv.kt
runtime/ReaGuardProvider.kt
runtime/ReaIntegrity.kt
runtime/ReaRuntime.kt
runtime/ReaTraps.kt
runtime/ReaModBlock.kt
runtime/ModBlockData.kt      (generated encrypted blobs — no plaintext names)
runtime/ReaTrace.kt          (L102, 2026-11-23)
runtime/ReaMemory.kt         (L102, 2026-11-23)
runtime/ReaRepack.kt         (L103, 2026-11-23)
runtime/build_smali.sh
runtime/smali/com/antirea/runtime/*.smali   (26 files)
runtime/tests/Main.kt
runtime/tests/ModBlockTest.kt
runtime/tests/GameGuardianFixTest.kt   (L102/L103 JVM test, 2026-11-23)
runtime/tests/gen_test_blob.py
runtime/tests/test_blob.txt                  (invented test values only)
tools/make_manifest.py
tools/gen_modblock_blobs.py
tools/make_sig_blob.py       (L103, 2026-11-23)
tests/README.md
tests/attack-bridge-full-report.json
tests/attack-bridge-report.json
tests/attack-selftest-report.json
tests/attack-testapp-report.json
tests/attack-selfprotect-report.json   (L101 re-protect, 2026-11-23, PASS)
tests/bridge-2.14.0-v10-protected.apk       (TEST keystore — see below)
tests/bridge.yaml
tests/build_testapp.sh
tests/frida-smoke-control.json
tests/frida-smoke-testapp-report.json
tests/testapp-rea-ir/testapp-protected.antirea.json
tests/bridge-rea-ir/bridge-2.14.0-v10-protected.antirea.json
tests/testapp.yaml
tests/testapp/AndroidManifest.xml
tests/testapp/res/layout/activity_main.xml
tests/testapp/res/values/strings.xml
tests/testapp/src/main/java/com/antirea/testapp/MainActivity.kt
tests/testapp/testapp-control.apk           (generic test app, test key)
tests/testapp/testapp-protected.apk          (TEST keystore)
tests/testapp/testapp-protected-l101.apk     (TEST keystore, L101 runtime, 2026-11-23)
tests/testapp/testapp-protected-ggfix.apk    (TEST keystore, L102/L103 runtime, 2026-11-23, attack PASS)
tests/testapp/testapp-tampered.apk          (UNSIGNED tampered evidence)
transformer/config.py
transformer/crypto.py
transformer/smali.py
transformer/source.py
verifier/attack.py
verifier/frida_smoke.py
verifier/tamper.py
```

## Excluded (never push — `.gitignore` covers them)

- `transformer/__pycache__/`, `verifier/__pycache__/` — bytecode caches.
- `*.idsig` — apksigner sidecar files, not part of any APK.
- `runtime/build/` (`classes.dex`, `runtime.jar`) — regenerable via
  `runtime/build_smali.sh`.
- `runtime/tests/test.jar` — regenerable JVM test artifact.
- Any `*.keystore`, `*.jks`, `*.pem`, `*.key` — none exist in this
  tree; the CLI generates an ephemeral test keystore per run inside
  a temporary workdir, never in the tree.

## Secret / key audit (checked 2026-11-23)

- **No real secrets.** The only key-like values in the tree are:
  - `AKIAIOSFAKEEXAMPLE` in `anti-rea.yaml`, `tests/bridge.yaml`,
    `tests/testapp.yaml` — a documented FAKE honeypot value (AWS's
    own example key). It is meant to be found; using it trips a
    server-side tripwire. It is not a real credential.
  - `https://api-decoy.example.invalid/v1/admin` — a fake honeypot
    endpoint (`.invalid` TLD, cannot resolve).
  - Encrypted blobs + split key parts in `tests/*-rea-ir/*.json`
    and `runtime/tests/test_blob.txt` — ciphertext of invented
    test strings (`TEST-SECRET-7f3a9-generic`,
    `antirea-v1-test-value-hello`). No plaintext secret is stored
    anywhere in the tree.
  - `tests/testapp/testapp-control.apk` contains the invented test
    secret as plaintext (it is the CONTROL — that is its job).
  - L101 blocklist package names appear in plaintext ONLY in
    `layers/MT-LIKE-BLOCKLIST.md` (documentation) and
    `tools/gen_modblock_blobs.py` (build tool) — neither is shipped
    inside a protected APK. `runtime/*.kt` and `runtime/smali/`
    contain 0 plaintext blocklist names (verified by grep,
    2026-11-23; see SELF-PROTECT-REPORT.md). The names are public
    package identifiers, not secrets, but keeping them out of the
    shipped dex is the point of the blob design.
- **No stable-key APKs.** The Bridge protected APK is signed with
  an ephemeral test keystore and will NOT install over the
  stable-key Bridge 2.14.0. The test-app APKs use test keys. The
  Bridge 2.14.0 control APK is NOT in this tree (it lives in
  `~/workspace/bridge-marketplace/`).
- **No Bridge live source.** Nothing under
  `~/workspace/bridge-marketplace/` is copied here except the
  protected test APK built from it.
- **No user credentials, no keystore passwords, no API keys.**
  The `storepass`/`keypass` words appear only in code/docs
  describing the ephemeral test keystore flow.

## Pre-push verification (all done 2026-11-23)

- [x] `anti-rea.py layers --list` → 100 slots, 40 / 2 / 58.
- [x] Attack PASS, Bridge + test app (see VERIFICATION-REPORT-v1.0.md).
- [x] Tamper PASS (JVM level).
- [x] REA-IR contains zero plaintext needles (byte-searched).
- [x] `find . -type f` reviewed; excluded files are all in `.gitignore`.
- [x] No push made in this round.

## After the push (not this round)

- Tag the release (`v1.0.0`) once the push is verified on GitHub.
- The real red-team test (user's reverse-engineering contact)
  happens on v1.0 after the push, not before.
- Service layer (API / web upload / dashboard) comes after v1.0;
  it is NOT in this tree.

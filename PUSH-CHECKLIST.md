# Anti-REA v1.0 — Push Checklist (for https://github.com/projectgtp/Anti-REA)

Status: **PUSHED 2026-11-23 15:20.** Head `4f62f5f0`, 6 commits on `main`,
183 files / 7.0 MB. Verified live on the GitHub commits page by the
parent agent. Full details + full source code, per the user's order
("push full details + source code", 2026-11-23 15:16, superseding the
earlier tester-first hold).

Repo state: created 2026-11-23 10:24, head `0b984eb2` (LICENSE only)
before the push. The push went in 5 text-only batches (the first
single 7 MB attempt was refused with HTTP 413); each batch needed
one user approval.

## Current state (2026-11-23)

- Layers: **99 IMPLEMENTED / 4 PARTIAL / 0 PLANNED of 103.**
  The 4 partials (L15, L60, L91, L98) need a phone, the RE tester,
  or a working Gradle host to finish. See FINAL-6-REPORT.md.
- L60 self-changing code is ON by default per user order
  (2026-11-23 14:03), with an opt-out flag
  (`experimental.self_changing_code: false`) and a danger warning
  in docs/L60-SELF-CHANGING-CODE.md.
- End-to-end verification: `tools/run_all.py` 17/17 PASS; test-app
  and Bridge 2.14.0 full protects PASS; service API smoke PASS;
  self-check 64 files OK. See FULL-LAYERS-REPORT.md
  (sha256 `09b309b6…`).
- Public README has NO weakness reveal, per user order
  (2026-11-23 14:54). Honest limits live in the internal reports
  only, never in README.md.

## What was pushed (6 commits)

| Commit | Contents |
|---|---|
| `fec0c25e` | v1.0 tree, 179 files: CLI, transformer, runtime, verifier, tools, server, service, gradle-plugin, profiles, public README, docs, registry, all reports, tests, tester-pack brief |
| `384e5f59` | Bridge full-protect REA-IR manifest |
| `97e6dc4f` | Bridge final-6 REA-IR manifest |
| `f0d8f60c` | Test-app full-protect REA-IR manifest |
| `4f62f5f0` | Test-app final-6 REA-IR manifest |
| (this file) | PUSH-CHECKLIST.md updated to the pushed state |

## NOT on GitHub yet (binaries — the connector only takes text)

- All protected/test APKs (`tests/bridge-*.apk`,
  `tests/testapp/*.apk`) — test keystores only, no stable key.
- `tester-pack.zip` (3.5 MB) — 2 protected APKs + TESTER-BRIEF.md
  only, no source, no keys. Send it to the RE tester directly.
- `runtime/native/lib/arm64-v8a/libreagate.so` — rebuildable; its
  C source (`runtime/native/reagate.c`) IS pushed.
- `.jar` test artifacts and `.idsig` sidecars.

Getting them onto GitHub needs a normal git push or a GitHub
Release upload — a separate task, pending user decision
(2026-11-23 15:21, user asked why they are not on GitHub).

## Secret / key audit (checked 2026-11-23, before the push)

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
- **No stable-key APKs.** The Bridge protected APKs are signed with
  an ephemeral test keystore and will NOT install over the
  stable-key Bridge 2.14.0. The test-app APKs use test keys. The
  Bridge 2.14.0 control APK is NOT in this tree (it lives in
  `~/workspace/bridge-marketplace/`).
- **No Bridge live source.** Nothing under
  `~/workspace/bridge-marketplace/` is copied here. The pushed
  Bridge REA-IR manifests (`tests/bridge-*-rea-ir/*.json`) contain
  only hashes, layer names, counts, and fake honeypots — 0 Bridge
  URLs, 0 Bridge code, verified by grep 2026-11-23.
- **No user credentials, no keystore passwords, no API keys.**
  The `storepass`/`keypass` words appear only in code/docs
  describing the ephemeral test keystore flow.

## Excluded (never push — `.gitignore` covers them)

- `transformer/__pycache__/`, `verifier/__pycache__/` — bytecode caches.
- `*.idsig` — apksigner sidecar files, not part of any APK.
- `runtime/build/` (`classes.dex`, `runtime.jar`) — regenerable via
  `runtime/build_smali.sh`.
- `runtime/tests/test.jar` — regenerable JVM test artifact.
- Any `*.keystore`, `*.jks`, `*.pem`, `*.key` — none exist in this
  tree; the CLI generates an ephemeral test keystore per run inside
  a temporary workdir, never in the tree.

## After the push

- Tag the release (`v1.0.0`) once the push is verified on GitHub.
- The real red-team test (user's reverse-engineering contact)
  happens on v1.0 with the regenerated tester pack
  (`tester-pack.zip`, sha256 `85e9a9e3…`, 3.5 MB).
- Bridge protection with Anti-REA comes after the push, per user
  order — the 2.16.0 Bridge build is waiting for it.
- Service layer (API / web upload / dashboard) comes after v1.0.

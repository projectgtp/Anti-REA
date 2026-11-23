# Anti-REA v1.0 — Audit + Fix Report

Date: 2026-11-23. Trigger: the bare-domain slip in the Bridge protection
(full URL hidden, bare domain `mbbridge.onrender.com` still visible once)
plus two user reports the same day: self-identifying decoy filenames
(`assets/antirea/decoys/fake-*`) and the protected Bridge 2.16.0 APK
crashing on launch. User order 2026-11-23 16:22: "Fix it. And found all
possible weakness, possible error, bug. Fix it. Then push."

## Highlights (short version)

- **Bare-domain class of slip: FIXED permanently.** The CLI now derives
  bare-host / www / scheme / port / trailing-slash / URL-encoded needles
  from every listed URL automatically. A bare host can no longer slip
  through when its full URL is listed. Proven by a dedicated bare-host
  control APK: bare host 2/2/4 in control (strings/jadx/apktool) → 0/0/0
  protected, attack verdict PASS, 85 needles checked (2 listed + 83 derived).
- **Decoy filenames: FIXED.** `assets/antirea/decoys/fake-*` is gone.
  Decoys are now `assets/config.json`, `crash-report.txt`, `error-log.txt`,
  `stacktrace.txt`, `libconfig.so`; asset dir is `assets/meta/`; runtime
  package is `com.appcore.runtime`. A shipped-names test fails if any
  shipped filename/path contains "fake", "decoy", "antirea", "honeypot"
  or "trap". Scan is CLEAN on both fresh protected APKs.
- **Layer count corrected: 97 IMPLEMENTED / 6 PARTIAL of 103** (was 99/4).
  L16 and L17 were marked IMPLEMENTED but are not wired — corrected
  honestly, not faked. No layer count changed in the public README's
  weakness-free wording; the honest counts live here and in
  `layers/REGISTRY.md`.
- **Full suite: 22 passed, 0 failed** (`tools/run_all.py --skip-ghidra`;
  ghidra-smoke skipped, not passed). Self-check: 73 files OK.
- **Launch crash: cause NOT found by static analysis.** Every prime
  suspect was tested and eliminated or hardened (see Crash hunt). Two
  defence-in-depth fixes shipped (F11, F12). Do NOT install another
  protected build until a launch test passes — the device logcat
  checklist is in this report.
- **What is still NOT fixed here** is listed at the end, with reasons
  (needs a phone, the tester, or a Gradle host).

## Findings and fixes

### A. Needle / hide-list pipeline (transformer)

- **A1 — Bare-domain derivation (the trigger).** `transformer/config.py`
  gained `derive_needles()` + `all_needles()` (stdlib `urllib.parse`):
  one listed URL yields bare host, `www.` host, http/https/ws/wss
  variants, port forms, trailing-slash variants, URL-encoded forms
  (64 needles for the Bridge case). Hosts lowercased, paths never
  lowercased, honeypots/patterns never derived. CLI `protect`/`verify`
  now use `all_needles(cfg)`.
  Tests: 22/22 new needle-derivation tests; full transformer suite
  90/90 at the time; 95/95 after the coordinator's www-strip addition.
- **A2 — Four more slip-throughs of the same kind.** Host
  case-insensitivity; static fields holding a bare host or an embedded
  URL; a latent `KeyError` crash on pattern hits; the same gap in
  source mode. All fixed with tests (vacuity check proves the tests
  fail on old code).
- **A3 — www-strip gap (found in integration).** Derivation added
  `www.` but never stripped it. Fixed in `transformer/config.py`;
  regression test added to
  `transformer/tests/test_needle_derivation.py`.
- Honest limits (documented, not fixed): other subdomains,
  IP-for-hostname, runtime-assembled URLs, manifest deep-link hosts,
  native `.so` substring needles.

### B. CLI / verifier

- **B1 — Derivation wired in.** `protect` and `verify`/`attack` use
  derived needles end to end: bare-host control 2/2/4 → protected
  0/0/0, attack PASS; 2 listed strings → 85 needles checked, 83 derived.
- **B2 — Multi-dex bug.** Only `classes.dex` was extracted before;
  needles only in `classes2.dex` were invisible. Fixed.
- **B3 — Layer counts corrected (97/6).** L16 and L17 are PARTIAL, not
  IMPLEMENTED: no startup signature-check code exists in
  `ReaGuardProvider`/`ReaIntegrity.kt` (only SHA-256 helpers; the
  provider never inspects the signing certificate; real cert
  comparison lives in `ReaRepack.kt` L103, app-invoked, blob not
  auto-injected), and L17's provider reads `assets/antirea/dex.sha256`
  — now `assets/meta/dex.sha256` — which `protect` never writes (dex
  hash only in `build.json` + REA-IR), so `dexCheckPassed` is always
  null. Wiring also needs the provider to hash dex bytes via
  `verifyDexSha256` instead of the APK file hash (chicken-and-egg).
  L60 stays PARTIAL: flag exists, core tested, no APK wiring — no
  `ReaMethodDecrypt`/`Loader` smali in `runtime/smali/`, no config key
  names a payload dex, no protect step writes a method blob.
- **B4 — Error handling.** Bad config/APK/tools → clear message, exit 2,
  no traceback. `tamper.py`/`sigcheck.py`/`attack.py` crash paths fixed.
- **B5 — Decoy rename in CLI** (see Decoy rename below).

### C. Runtime audit + crash hunt — see separate section below.

### D. Server / service security audit

16 findings fixed. Service API (10): verified OOM on large uploads
(now streamed to disk, ~1 MiB peak RAM); no auth at all (now optional
`ANTIREA_API_TOKEN`, localhost-only by default, loud startup warning
when unset); non-loopback binds refused without token +
`--allow-network`; DNS-rebinding Host check; absolute paths leaked in
job JSON (stripped); crash on garbage Content-Length (now 400); no
disk-fill guard (new 507); no config-size cap (1 MB, 413); no APK
validation (must start with `PK`); keep-alive request smuggling
(close_connection). Server reference (6): L64 fail-open accept on
empty expected hashes (now rejects); L65 crash on corrupt binding;
L66 unbounded limiter state (max_devices 10000, first-seen eviction);
L68 NaN/inf weights scoring "clean" (now validated finite ≥ 0); L69
export relabelling; L70 raw exceptions.
Tests: server 36/36, service 20/21 (the 1 failure was the stale
manifest, fixed by the regen below).
Could NOT be fixed here: manifest regen (done by coordinator, see
below); zip-slip inside CLI APK extraction (not audited, flagged);
real production hardening (TLS, accounts, persistent storage, signed
manifest, salted device hashes — documented, not faked); L67 has no
un-revoke. Note: the VM transparent proxy 198.19.0.1:3128 makes
"connection refused to external IP" an invalid assertion.

### E. Decoy contents

- `transformer/traps.py` cleaned: no planted string says "Anti-REA",
  "antirea" or "decoy" anymore; every text decoy still carries tripwire
  id `honeypot-secret-01`; fake values kept by design (they are the
  bait). Classes renamed to `com/appcore/auth/LoginManager`,
  `com/appcore/sync/RetryWorker`, `com/appcore/admin/AdminPanel`.
  Tests: transformer suite 94/94 at the time (95/95 after the www test).
- One exception left deliberately: `TRIPWIRE_TYPE` `"antirea-tripwire/v1"`
  still exists in three places — renamed in the coordinator pass to
  `tripwire/v1` (see below).

## Coordinator integration — decoy rename (user report #1)

Applied across the whole tree, verified by the shipped-names test and
by grep:

- `assets/antirea/` → `assets/meta/`; decoys now `assets/config.json`,
  `crash-report.txt`, `error-log.txt`, `stacktrace.txt`, `libconfig.so`.
- Runtime package `com.antirea.runtime` → `com.appcore.runtime`
  (all runtime + test files); asset dir, placeholder prefix
  `antirea-encrypted:` → `meta-encrypted:` in the CLI writer
  (CRITICAL: the runtime already read `meta-encrypted:` — the old
  writer would have broken res-string decryption).
- `antirea-hidden` → `meta-hidden`; keystore alias `antirea-test` →
  `appcore-test` (was leaking `META-INF/ANTIREA-.SF/.RSA`); keystore DN
  `CN=Anti-REA Test` → `CN=AppCore Test`;
  `proguard-rules-antirea.pro` → `proguard-rules-appcore.pro`.
- `Honeypot`/`ReaDecoys` classes → `Tripwire`/`ReaLures`, labels
  `appcore-lure-*`; protocol labels `antirea-tripwire/v1` →
  `tripwire/v1`, `antirea-attestation/v1` → `attestation/v1`,
  `antirea-audit/v1` → `appcore-audit/v1` (all three places + docs +
  tests); junk marker `antirea-junk:` → `appcore-junk:` (same 13-char
  length, no arithmetic change); smali source of truth now writes
  `com/appcore/cache/` + `com/appcore/runtime/` directly;
  `source.py`/`native.py` emit the new package; `docs/USAGE.md` paths
  fixed; REGISTRY.md L17 note and L52 row updated.
- Profiles fixed: `tools/profiles.py` LIGHT_LAYERS now 16 layers
  (L16/L17 removed) + docstring updated.
- Manifest lists reconciled: `MANIFEST_FILES`
  (`tools/make_manifest.py`) and `SELF_CHECK_FILES` (`anti-rea.py`)
  were out of sync (64 vs 69); both now 73 entries, identical,
  including all audit-round test files. Manifest regenerated:
  73 files, sha256
  `51921f76a1b43a2135fbdc2aee53da40c02b4dc134509d42465eae4d4e7cbf00`.
  **Self-check OK: 73 files. Layers: 97 IMPLEMENTED / 6 PARTIAL of 103.**

## Verification-round fixes (found by the full-suite re-run)

The first full `run_all.py` run after integration failed 3 suites;
all three were real bugs, all fixed with tests — no failures were
waived:

1. **junk-traps (1 failure).** `transformer/tests/test_junk.py:160`
   still asserted the OLD class name `com/antirea/junk/JunkTraps`
   after the rename — the code was right, the test was stale. Fixed
   the assertion to `com/appcore/junk/JunkTraps`. Now 28/28 OK.
2. **jvm-audit (kotlinc error).** `runtime/tests/RuntimeAuditTest.kt`
   lines 242/245 used the variable `honeypot.` after the
   `Honeypot` → `Tripwire` rename renamed the declaration to
   `tripwire` — leftover references, compile error. Fixed to
   `tripwire.registerTripwire` / `tripwire.useTripwire` (and the
   failure message `Honeypot.trips()` → `Tripwire.trips()`).
   Now TEST-PASS.
3. **self-check (7 hash mismatches).** Seven files had been edited
   after the previous manifest regen (rename follow-ups). Contents
   verified intentional, manifest regenerated (sha256 above).
   Now SELF-CHECK OK.

Two more stale references found by the same grep sweep and fixed:
`docs/L15-JUNK-TRAPS.md:29` still showed the old `antirea-junk:`
marker (now `appcore-junk:`); `layers/REGISTRY.md` L08 row still
named `proguard-rules-antirea.pro` (the CLI writes
`proguard-rules-appcore.pro`). Emitted smali comments were also
neutralised — the L15 junk-trap header, the dead-code maze header and
the L59 indirection-stub header no longer contain "Anti-REA"
(smali comments are stripped at assembly, but there is no reason for
generated code to advertise the protector).

Deliberately NOT renamed: the test app package `com.antirea.testapp`
(the package name lives inside `classes.dex` / the binary manifest,
never as a zip entry path, so the filename scan does not see it);
`runtime/NOTES.md` history of the old build (it documents what the
old APK contained — that is the audit record, not a shipped name);
pre-rename build outputs under `tests/` (historical evidence, not
shipped). Test-fixture plaintext `antirea-v1-test-value-hello` is an
invented JVM-test string, never a real key, never shipped in a
protected APK.

## Verification — fresh end-to-end (fixed CLI)

### Full suite

`python3 tools/run_all.py --skip-ghidra` — **22 passed, 0 failed**,
ghidra-smoke skipped. Report saved as
`tests/run-all-audit-report.json` (sha256
`ee28fca267a0d66d475ae664cf04e59d82d81f4769a1bd30c5fdbc6bcdb0d3a4`).
Suites: self-check, jvm-runtime, jvm-modblock, jvm-ggfix,
jvm-resstrings, cli-verify, coverage (103, 97/6), keyvault,
marketplace, profiles (light=16, strict=97, light ⊂ strict),
junk-traps, frida-harness, ios-profile, gradle-plugin,
jvm-methoddecrypt, self-changing, verifier-unit, jvm-integrity2,
jvm-env2, jvm-timer, jvm-audit, jvm-hiding.

### Test app (bare-host proof)

Agent B's E2E driver, re-run on the fixed CLI — **E2E ALL PASS**:
- Bare-host control APK built from stock testapp control + a
  `BareHost.smali` holding ONLY the bare host `testapp.example.invalid`
  (const-string AND static field — the exact Bridge slip class).
- Full protect exits 0: protected APK sha256
  `5e06719246cf62a2bcbe18e62d41e40a4e54b2d2d18e4c7a2981d22ede442e04`,
  775,164 bytes, layers=97, 10 needles, 3 strings encrypted.
  REA-IR records 83 derived needle hashes.
- Attack with ONLY the 2 listed needles on the CLI: verdict PASS.
  85 needles checked (2 listed + 83 derived), 80 derived vacuous
  (spellings that never occur in the control — expected).
  Bare host: strings_dex control 2 → protected 0; jadx 2 → 0;
  apktool 4 → 0. Non-vacuous in control.
- Subset run (L52 + L14 + L31 only): L52 alone plants decoy classes
  (`com/appcore/cache/CacheNN`, 2 files); no old `com/antirea/decoy`
  tree; L14 alone strips `.line` (0 left in app smali); runtime smali
  injected without L01 (1 `ReaRuntime.smali`).
- Shipped-names scan CLEAN on both protected APKs.
- Attack report: `attack-testapp-audit-report.json` (sha256
  `58e24ef08e630ea3180e9f4a06f5f2969ec4e9dfa8042281a13c7c9eaf4f467f`).

Stock testapp protect (for the regenerated tester pack, same fixed
CLI): `tests/testapp-audit-protected.apk`, sha256
`0b5e82c61c58dde682ab497b3888d7d020ff275a06162eede61b52ef302f68dc`,
775,164 bytes. Attack verdict PASS (85 needles: 2 listed + 83
derived); bare host 1/1/2 → 0/0/0 (strings/jadx/apktool); shipped
names CLEAN; `apksigner verify` VERIFIED.

### Bridge 2.14.0

Fresh protect with the fixed CLI (`tests/bridge.yaml`, 6 listed
strings) — **BRIDGE E2E ALL PASS**:

- Protected APK: `tests/bridge-2.14.0-audit-protected.apk`, sha256
  `d4f99d524d2a29a788422d459218e2b67638691e895b7ba4bb923ca15a87fd44`,
  4,869,130 bytes. REA-IR: `tests/bridge-audit-rea-ir/`.
  Test keystore (ephemeral) — will NOT install over the stable-key
  2.14.0; uninstall-first warning applies as before.
- Attack with the 6 listed needles: verdict **PASS**. 257 needles
  checked (6 listed + 251 derived), 243 derived vacuous (spellings
  that never occur in the control — expected).
  Bare domain `mbbridge.onrender.com` — the exact slip that triggered
  this audit: strings_dex control 3 → protected 0; jadx 5 → 0;
  apktool 9 → 0. `api.bridge.example`: 2/2/3 → 0/0/0.
  `tunnel.key.`: 1/1/4 → 0/0/0. Attack report:
  `attack-bridge-audit-report.json` (in `~/workspace/antirea-audit-e2e/`).
- Shipped-names scan: **CLEAN** — no banned words in shipped
  filenames.
- `apksigner verify`: v3 scheme true, 1 signer.

This is a fresh static proof on the real app. It is NOT a device
test, and it does NOT clear the protected 2.16.0 launch crash —
that crash is a different build (strict profile, 2.16.0 code) and is
still under investigation via the logcat checklist above.

## Crash hunt — protected Bridge 2.16.0 launch crash (user report #2)

Target APK: `bridge-marketplace/android/bridge-2.16.0-antirea.apk`,
sha256 `90c55f7b873f60be80bb6d1d4fed37fbec7ed91ea62f23968394211afe117dce`,
disassembled with baksmali. Plain 2.16.0 works; protected crashes on
launch before any screen, on the Infinix Hot 60i.

**Most likely cause: NOT found by static analysis.** What the hunt
proved, with evidence:

- Missing `assets/meta/dex.sha256` does NOT crash: the provider
  catches FileNotFoundException → null ("not checked").
- The native `.so` is never loaded at startup: no class references
  `ReaNative` except itself. A bad `.so` cannot crash launch.
- All 44 injected `ReaRuntime.decrypt` triples decrypt OK, including
  all 19 in `<clinit>`.
- Flattened launch-path methods trace clean (symbolic tracer; full
  sweep of all 3,880 flattened methods, 0 real defects, 6 tracer
  false positives).
- No res-string placeholders in dex; provider smali matches the
  pre-fix source.
- Full hunt notes: `runtime/NOTES.md` (§ crash hunt).

Fixes shipped from the hunt (defence in depth — NOT proven fixes, no
concrete Error source was found):

- **F11** — `ReaGuardProvider.kt`: all 6 catches `Exception` →
  `Throwable`.
- **F12** — `ReaNative.kt`: new `nativeVersionSafe(): String?`
  (null, never throws).

**What to test on the device next (logcat checklist):**

```
adb logcat -d | grep -i -A 30 "AndroidRuntime\|FATAL"
```

Record: does the crash happen before or after a screen appears?
Does the protected TEST app launch (Bridge-specific vs shared layer)?
The crash log's exception type + first Anti-REA frame decides the
next fix. **Do NOT install another protected build until a launch
test passes.** The user stays on the plain APK meanwhile.

## What could NOT be fixed here (and why)

- **L15, L60, L91, L98 — PARTIAL.** L15 junk traps: experimental,
  needs device proof a trap cannot break the app itself. L60
  self-changing code: important AND dangerous per the user, DEFAULT ON
  with opt-out flag and docs warning — but no APK wiring exists yet
  (no payload dex step). L91: needs the user's RE tester report.
  L98: needs a Gradle host (Gradle daemon is broken in this VM).
- **L16, L17 — PARTIAL** (see B3 above): startup signature check and
  dex-hash check are not wired into the provider.
- **Launch crash root cause** — not found statically; needs the
  device logcat (checklist above).
- **No device test anywhere.** Everything here is compile-verified /
  JVM-verified / static-tool-verified only. Nothing in this report is
  a device test.
- **Ghidra 12.2 headless + APKLeaks 2.6.3 — INCONCLUSIVE** from the
  earlier tool sweep (Ghidra: no needle output captured, custom
  `DumpStrings` run hit a 420 s timeout; APKLeaks hung 6+ min with
  zero output). Never claimed as pass. The ghidra-smoke suite was
  skipped in the verification runs above for the same reason.
- **Server production hardening** (TLS, accounts, persistent storage,
  signed manifest, salted device hashes) — documented, not faked.
- **Zip-slip inside CLI APK extraction** — flagged by the service
  audit, not audited/fixed here.
- **L67 has no un-revoke; GameGuardian no-root virtual-space mode
  not caught; root memory editing can never be fully stopped
  client-side** — the server must never trust client-reported numbers
  (the Bridge ledger is the example).
- **Manifest is unsigned** — self-check detects tampering only if the
  manifest itself is trusted; a signed manifest is future work.

## Tester pack — regenerated

The old pack (sha256 `85e9a9e3…`) still held the pre-rename final-6
APKs with the `fake-*` decoy filenames — exactly what the user
reported. It has been replaced: `tester-pack.zip`, sha256
`567bec3a6d0781541f960cadfc2402f327a86b714f89014b7e8a9c8ed77a4139`,
3,502,788 bytes, containing ONLY the two new audit protected APKs
(Bridge `d4f99d52…`, testapp `0b5e82c6…`) and the updated
`TESTER-BRIEF.md` (new filenames/hashes, "audit build, 97 implemented
layers"). No source, keys, config, or verification report inside —
still a blind test. Delivery method / tester contact is still
missing — the user has not said how to send it.

## Push — NOT DONE (approval timed out)

The push was attempted 2026-11-23 ~12:00 UTC and did NOT happen:
the GitHub write-approval card (`approval_expired`,
`connector-attempt-283c2ec295325514b7e4855f46641540ce18fca8e2cc41a563c72619530d76e4`)
timed out unanswered, so the action was not performed. Nothing was
pushed; the remote head is still `8bd25fe6`. Per the approval rules
the push must NOT be retried until the user asks for it again.

Ready to push when approval is given (single snapshot, 126 text
files, 1,628,058 bytes, manifest at
`~/workspace/antirea-audit-e2e/push-manifest.bin`):

- Fixed source: needle derivation (`transformer/config.py`),
  CLI/verifier wiring, runtime renames + F11/F12, server/service
  hardening, profiles, manifest (73 files, sha256 `51921f76…`).
- This report (`AUDIT-FIX-REPORT.md`, sha256 `fb7f2564…`).
- Updated `layers/REGISTRY.md` (97/6), `coverage.json` (97/6),
  updated `tester-pack/TESTER-BRIEF.md` (new APK names/hashes).
- New smali tree `runtime/smali/com/appcore/runtime/` (53 files).

NOT in the snapshot (by design, all noted here): binaries of any
kind (protected APKs, `tester-pack.zip`, `libreagate.so` — pending a
GitHub Release, upload via the browser); generated REA-IR JSON
outputs under `*-rea-ir/` (reproducible build outputs, 8 MB);
`runtime/build/` artifacts. The connector cannot delete files, so
the old `runtime/smali/com/antirea/runtime/` tree (44 files, renamed
away locally) will REMAIN on GitHub after this push until a
deletion-capable cleanup removes it — the new `com/appcore/` tree
is the live one.

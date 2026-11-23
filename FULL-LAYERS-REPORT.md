# Anti-REA v1.0 — Full Layers Build Report

**Date:** 2026-11-23 (full build ordered by the user 12:33, "implement all remaining layers now")
**Starting point:** 43 IMPLEMENTED / 2 PARTIAL / 58 PLANNED of 103 slots (after L102/L103)
**This build's result:** **97 IMPLEMENTED / 0 PARTIAL / 6 PLANNED** (coordinator's batches, verified by `layers --list`)
**Final count after the remaining-6 work:** **99 IMPLEMENTED / 4 PARTIAL / 0 PLANNED of 103 slots** — while this build was verifying, the user ordered the remaining 6 layers implemented too, and a parallel agent did that work (L89 + L99 → IMPLEMENTED; L15, L60, L91, L98 → PARTIAL with honest limits, see below). This report covers both: the 97-layer build in full, plus the final state.
**Self-check manifest:** `anti-rea.manifest.json`, 64 files, sha256 `a545a327c21f579e4345b9102357659cd334bb5f733498eae9e12bde0a06dfdc`
**Status:** compile/JVM-verified only, never device-tested. No GitHub push, no Bridge source changes, no live-server change.

## Highlights (short version)

- All 58 planned slots were worked. 52 became IMPLEMENTED, 2 PARTIAL layers (L06, L49) were finished in this build; the last 6 were then implemented by the parallel remaining-layers work (0 PLANNED remain).
- The CLI now runs the new transforms for real: smali chunking, opaque predicates, call indirection, control-flow flattening, native string hiding, asset encryption, a real compiled native gate `.so`, 10 new trap types, R8 rules output, and a per-build watermark — all recorded in the REA-IR of every protect.
- The runtime now ships 44 smali files (was 28): integrity-2, timer, env-2, native gate, asset decrypt, resource-string decrypt.
- The server side exists as a Python-stdlib reference implementation (component-hash reject, device binding, rate-limit, kill-switch, anomaly scoring, audit export, key rotation) — no live server was touched.
- The service prototype exists: local API + web upload/dashboard on 127.0.0.1:8931 (no auth — never expose publicly). POST /protect works end to end (tested live).
- End-to-end verification PASS: `run_all.py` 17/17, test-app protect + verify PASS, Bridge 2.14.0 protect + verify PASS (after one honest needle fix, see below).
- Honest limits kept everywhere: no device test, no live Frida test, root memory editing can never be fully stopped client-side, the manifest is unsigned, R8 rules only work in the app's own Gradle build.

## Per-batch evidence

### Batch A — string/asset/native hiding (8 layers: L08, L11, L12, L13, L49, L55, L58, L59)
- `transformer/native.py` (generate_r8_rules, ELF scan/hide, asset encrypt), `transformer/smali.py` (chunking, opaque predicates, indirection, flattening + a shared-fixup bug fix: the v1.0 `SAFE_8BIT_OPS` set wrongly listed 22c/22t ops as 8-bit — fixed, unit-tested), `runtime/ReaNative.kt`, `runtime/ReaAssets.kt`, `runtime/native/reagate.c` → `runtime/native/lib/arm64-v8a/libreagate.so` (7,144 B, ELF64 AArch64, NDK 22.1.7171670, exports `Java_com_antirea_runtime_ReaNative_nativeGate`).
- Tests: unit `ALL-UNIT-OK`; JVM `TEST-PASS` (Python↔Kotlin interop vectors); APK harness PASS, attack verdict PASS (control 1/1/2 → protected 0/0/0, apksigner v2+v3 true). Protected APK sha256 `677501bd…` (619,043 B) in the batch job dir.
- L49 is IMPLEMENTED (was PARTIAL): a real `.so` exists now. Limit: arm64-v8a only, never device-tested.
- L12 tested on a compiled arm64 `.so` and a copy of `libdsversion.so` (needle replaced, substring needle correctly refused, size identical, `readelf` OK). Originals untouched.

### Batch B — integrity (11 layers: L23–L30, L54, L56, L57)
- `runtime/ReaIntegrity2.kt`, `runtime/ReaTimer.kt`, `verifier/sigcheck.py`, `tools/watermark.py` (+ tests).
- Tests: JVM `TEST-PASS` (timer fires N times on a fake clock, stops on refusal; env-fire never decrypts); `verifier/test_sigcheck.py` PASS; `tools/test_watermark.py` PASS. Sigcheck: control and protected APKs both v1/v2/v3 (apksigner cross-check with `--min-sdk-version 21`).
- Two findings fixed during testing: signing-block offset was off by 8; plain `apksigner verify` reports v1=false for these APKs even though a valid JAR signature exists (jarsigner: "jar verified").
- Limits: Android-only paths (`getInstallerOrigin`, `loadClassFromDex`) compile but are never device-tested.

### Batch C — environment (8 layers: L38–L45)
- `runtime/ReaEnv2.kt` (pure functions, injectable inputs, same `Finding` type as ReaEnv), `runtime/tests/Env2Test.kt`.
- Tests: JVM `TEST-PASS` (all 8 checks, clean + firing + boundary cases). False positives documented and pinned by tests: a folder literally named `clone` flags L43; `dual` is a substring of `individual`; L45 is the weakest signal (flag only).
- L39: FLAG_SECURE alone deliberately does NOT fire — only an active MediaProjection does.

### Batch D — server reference + traps (17 layers: L64–L70, L76–L85)
- `server/reference.py` + `server/test_server.py` + `server/README.md`; `transformer/traps.py` + `transformer/tests/test_traps.py`.
- Tests: **46 tests, OK** (29 server + 17 traps). All traps share tripwire id `honeypot-secret-01`; every value is fake.
- L81 decoy `.so` is a 64-byte ELF64 header with no program/section headers — documented and test-asserted as NOT loadable, a placeholder only.
- Limits: no auth/persistence/network in the reference (in-memory limiter and module-level revoked set must be replaced by real storage in production).

### Batch E — finishing + operations (10 layers: L06, L88, L90, L92, L93, L94, L95, L96, L97, L100)
- `runtime/ReaResStrings.kt` (L06 finish), `tools/run_all.py`, `tools/layer_coverage.py`, `tools/profiles.py`, `tools/keyvault.py`, `tools/layer_marketplace.py`, `service/api.py` + `service/dashboard.html`, `verifier/ghidra_smoke.py`, CLI `ci` / `layers --coverage` / `--profile`.
- Tests: JVM round-trip PASS (Python encrypt → Kotlin decrypt, tamper refuses); `ci` PASS on the test app; `run_all.py` 10/11 PASS before manifest regen (only self-check failed, for the known manifest reason — the final 17/17 run is in the verification section); coverage total=103 matching the registry; profiles light=18 / standard=40 / strict=43 at test time (strict is 99 now that the registry grew); keyvault selftest PASS; marketplace PASS (1 plugin); Ghidra smoke PASS (tiny `.so`, 17 s, 13 functions, needle hit) — the earlier 420 s timeouts were a wrong invocation, not a Ghidra limitation.
- One real bug found and fixed: L06 encryption was gated on `"L06" in layers`, but L06 was PARTIAL so it never ran — fixed to piggyback on the L09 sweep.
- L06 honest limit kept: `getString()` returns the placeholder; the app must call `decryptResource(name)` explicitly.

## Integration (coordinator)

- Wired into `anti-rea.py` protect: L55 → L58 → L59 → L11 (app smali only, never `com/antirea/**`; flatten last), L12 (`.so` needles), L13 (config-listed assets), L49 (`.so` copy into `lib/arm64-v8a/`), L76–L85 (decoy smali + decoy files under `assets/antirea/decoys/` + decoy XML; L81 lives in assets/, never in `lib/`), L08 (R8 rules written to the REA-IR dir), L26 (watermark stamped into REA-IR), L24 (sigcheck reported by `verify`).
- `runtime/build_smali.sh` now compiles ReaIntegrity2, ReaTimer, ReaEnv2, ReaNative, ReaAssets. Rebuilt: 44 smali files, dex 104K, BUILD-OK.
- `layers/REGISTRY.md` updated to 97/0/6; `README.md` and `TOOL-COVERAGE.md` updated (Ghidra smoke is now SMOKE TESTED; categories 14–15 added).
- Manifest regenerated to 44 files; `self-check` PASS; `layers --list` total=103, IMPLEMENTED 97, PLANNED 6; `layers --coverage` parses and matches the registry.
- Python unit suites re-run by the coordinator: 46 tests OK (server + traps), sigcheck PASS, watermark PASS, keyvault selftest PASS, marketplace PASS, all Python files parse.

## End-to-end verification — PASS (with one honest needle fix)

The first verification attempt (07:19–08:04 UTC) ran NO steps: it waited the full 45 minutes for the one-heavy-job lock, held first by a knight-lightning render job and then by its relaunch (`2026-11-23_073449-knight-lightning-render2-10462`). The lock was not broken and no heavy job ran in parallel. The second attempt waited for the relaunch to complete (08:28 UTC) and then ran everything.

- **`tools/run_all.py` — PASS, 17/17, run twice** (08:28 and 08:57, identical). Suites: self-check (64 files OK), jvm-runtime, jvm-modblock, jvm-ggfix, jvm-resstrings, cli-verify (attack PASS), coverage (total=103, IMPLEMENTED 99 / PARTIAL 4), keyvault, marketplace, profiles (light=18, strict=99), ghidra-smoke, junk-traps, frida-harness, ios-profile, gradle-plugin, jvm-methoddecrypt, self-changing. Report: `run-all-report-2026-11-23.json` (sha256 `3df377e3…`).
- **Test-app protect + verify — PASS.** Protected APK sha256 `cf3fe46c9eca8a53cc21027ea2a5b52c30cfd0e1ad1a450a1780cd96c4f88979`, 767,070 B, layers=99, needles=2, strings_encrypted=2, watermark build_id `7fb7b0f9-…`. All wiring lines present (hardening L55/L58/L59/L11 with 5,301 strings chunked, L12, L49 native gate `.so`, 9 traps, L26, L08). Verify PASS, exit 0: every needle 0 in protected across strings/jadx/apktool; control had 2. L24 sigcheck v1/v2/v3 true. Evidence: `tests/testapp/testapp-full-protected.apk` + REA-IR in `tests/testapp/testapp-full-rea-ir/`.
- **Bridge 2.14.0 protect — PASS.** Control `~/workspace/bridge-marketplace/android/bridge-2.14.0.apk` hash-verified first (sha256 `7f140907…`, 4,573,620 B). Protected APK sha256 `3c9ef3d4d71613c9b508dfda4cbb3183b8da56db3ea015a7b3017ce9166532be`, 4,865,135 B, layers=99, needles=8, strings_encrypted=19. Evidence: `tests/bridge-full-protected.apk` + `tests/bridge-full-rea-ir/`.
- **Bridge verify — first run FAIL, then PASS after a needle fix (verified, not waved through).** First run: FAIL, exit 1 — jadx `.public`=1. I checked the jadx output myself: the single hit is jadx's own "Method not decompiled" stub quoting Bridge's legitimate method name `publicKeyFromPrivate`, and `.publicKeyBase64` is a real Bridge field. The actual secret `tunnel.key.public` is 0 in every tool. The needles `.private` / `.public` in `tests/bridge.yaml` were fragments of the real secrets that match ordinary code identifiers — a defective needle, not a leak. Fix: removed both fragment needles from `tests/bridge.yaml` (with a comment explaining why); the full `tunnel.key.` needle remains and is 0 everywhere. Re-ran verify: **PASS, exit 0** — "protected is 0 for every needle in every tool; every needle found in control (>0) in at least one tool". L24 sigcheck v1/v2/v3 true.
- **Service API live smoke test — PASS.** GET `/status` 200 (IMPLEMENTED 99 / PARTIAL 4), GET `/layers` 200, GET `/` dashboard 200 (2,407 B). POST `/protect` first failed with HTTP 500 (stale manifest during the concurrent agent's edits — the self-check working as designed), then after the manifest regen: HTTP 200, job done, protected sha256 `0761e55c…`, 767,070 B, layers=99; GET `/download` 200 with hash-matching bytes. Server stopped afterwards; port 8931 confirmed free.
- Logs: `/home/hatch/tmp/anti-rea-verify/` (runall reports, protect/verify logs, jadx output, service logs).

## Still PARTIAL (4) — the remaining-6 work, honestly

0 PLANNED remain. The last 6 were finished by the parallel remaining-layers work (user order 2026-11-23 13:49); 2 are IMPLEMENTED, 4 are PARTIAL with real limits — not claimed as done:

| Layer | Status now | Why it is only partial |
|---|---|---|
| L15 Anti-decompile junk (invalid-UTF traps) | PARTIAL | Experimental module `transformer/junk.py` (5 trap kinds, flag-gated OFF by default), 28 tests PASS; docs `L15-JUNK-TRAPS.md`. Limits: dex half works on a string-data blob copy only, no CLI wiring, NOT protection yet — a trapped APK must install/launch on a real phone and break a real decompiler before anyone ships it. |
| L60 Runtime code mutation (self-modifying) | PARTIAL | Implemented as opt-out core, DEFAULT ON per user order: `runtime/ReaMethodDecrypt.kt` + `runtime/ReaMethodLoader.kt` + `tools/make_method_blob.py`, flag `experimental.self_changing_code` (default true). JVM core TEST-PASS; docs `L60-SELF-CHANGING-CODE.md` (danger warning stays: never first launch, never login/payment, only non-critical paths, only after real-device proof; Play Protect risk; decrypted code stays in RAM). Limits: Android loader compile-verified only, NEVER device-tested; stored-form rotation only — loaded code stays loaded. |
| L89 Frida runtime test (on device) | IMPLEMENTED | Harness `verifier/frida_test/` (5 checks F1–F5, PASS/BREAK/INCONCLUSIVE rules), 20 tests PASS + `--dry-run` OK. LIVE DEVICE RUN still PENDING — needs a test phone + matching frida-server. |
| L91 Red-team test (user's RE contact) | PARTIAL | Tester pack regenerated with the latest protected APKs + updated brief (L101/L102/L103, Frida harness) — READY-TO-RUN. The live red-team run is pending the user's tester; only their report-back completes this layer. |
| L98 Build-plugin (Gradle) | PARTIAL | Plugin source `gradle-plugin/` (AntiReaPlugin/Extension/ProtectTask/Command), 26 logic tests PASS. Limits: Kotlin NEVER compiled (no kotlinc in this VM), NEVER run under Gradle (daemon broken) — needs a working Gradle host to verify. |
| L99 iOS profile (same REA-IR) | IMPLEMENTED | `profiles/ios.yaml` maps all 103 layers (58 APPLIES / 37 ADAPTED / 8 DOES-NOT-APPLY), 12 tests PASS. Limit: profile defined and validated only — NEVER built on iOS (no toolchain in this VM). |

## Honest limits (whole build)

- Compile/JVM-verified only, never device-tested. No live Frida/debugger/runtime-dump test exists.
- A skilled attacker with root + patience can still win in the end; the server must never trust client-reported numbers (Bridge's ledger is the example).
- The self-check manifest is an UNSIGNED SHA-256 inventory (a local attacker with full tree write access can regenerate it).
- R8 rules (L08) do nothing until applied in the app's own Gradle build; the CLI cannot rename classes in a built APK.
- L12 only replaces needles that equal one complete printable run in a `.so`; runtime-used strings must never be listed.
- The service API prototype has no auth — never expose it publicly.
- 99% protection remains a GOAL, not a measured guarantee.

## Files changed (full build)

- CLI: `anti-rea.py` (hardening/trap/native/asset/R8/watermark/sigcheck wiring, `ci`, `layers --coverage`, `--profile`), `anti-rea.manifest.json` (64 files after the remaining-6 work; sha256 `a545a327…`).
- Remaining-6 work (parallel agent, not this build's batches): `transformer/junk.py`, `runtime/ReaMethodDecrypt.kt`, `runtime/ReaMethodLoader.kt`, `tools/make_method_blob.py`, `verifier/frida_test/`, `profiles/ios.yaml`, `gradle-plugin/`, docs `L15-JUNK-TRAPS.md` + `L60-SELF-CHANGING-CODE.md`, regenerated tester pack. See `layers/REGISTRY.md` for their per-layer status.
- Transformer: `transformer/native.py`, `transformer/traps.py`, `transformer/smali.py` (new passes + SAFE_8BIT_OPS fix).
- Runtime: `runtime/ReaIntegrity2.kt`, `runtime/ReaTimer.kt`, `runtime/ReaEnv2.kt`, `runtime/ReaNative.kt`, `runtime/ReaAssets.kt`, `runtime/ReaResStrings.kt`, `runtime/native/reagate.c`, `runtime/native/lib/arm64-v8a/libreagate.so`, `runtime/build_smali.sh`, rebuilt `runtime/smali/` (44 files) + `runtime/build/`.
- Verifier: `verifier/sigcheck.py`, `verifier/ghidra_smoke.py` (+ `verifier/ghidra_scripts/AntiReaSmoke.java`).
- Tools: `tools/watermark.py`, `tools/gen_native_blobs.py`, `tools/run_all.py`, `tools/layer_coverage.py`, `tools/profiles.py`, `tools/keyvault.py`, `tools/layer_marketplace.py`.
- Server/service: `server/reference.py`, `service/api.py`, `service/dashboard.html`.
- Docs/registry: `layers/REGISTRY.md`, `README.md`, `TOOL-COVERAGE.md`.
- No GitHub push, no Bridge changes, no live-server change.

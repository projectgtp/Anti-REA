# Anti-REA v1.0 — Final 6 Layers Report

**Date:** 2026-11-23 (ordered by the user 13:49, "This is important I know.. so implement")
**Starting point:** 97 IMPLEMENTED / 0 PARTIAL / 6 PLANNED of 103 slots (after the full-layers build)
**Final count:** **99 IMPLEMENTED / 4 PARTIAL / 0 PLANNED of 103 slots**
**Self-check manifest:** `anti-rea.manifest.json`, **63 files** (was 44 — the 19 new files are now covered)
**Manifest sha256:** `d611b3cfe41cf27cb0433f67a9d293167546c65b98a8c541bc81f7eab1ddbb8c`
**Status:** compile/JVM-verified only, never device-tested. No GitHub push, no Bridge source changes, no live-server change.

## Highlights (short version)

- All 6 remaining slots were worked honestly. 2 became IMPLEMENTED (L89, L99), 4 became PARTIAL (L15, L60, L91, L98), **0 stay PLANNED — every slot is now built**.
- The user asked for all 6, then overruled on L60 twice: first "implement it, danger depends on how I use it", then "Default is on man". L60 is now implemented and **ON by default**, with the danger warning kept in full. It is PARTIAL, not IMPLEMENTED, because its Android loader has never run on a device — the flag default is a usage decision, the registry status is a proof statement, and they are not the same thing.
- Two layers (L15, L98) have real code and passing tests but have never been proven on a real phone / under real Gradle, so they are PARTIAL, not IMPLEMENTED.
- 95 new unit tests pass (28 + 20 + 26 + 12 + 9), plus the L60 JVM core test (7 sections, TEST-PASS) and blob self-test (4/4) — all re-verified by the parent in this round.
- **A real regression was found during this round (see "Smali regression" below):** the full-layers CLI currently FAILS to protect the test app — it dies at apktool rebuild with an invalid-register error in `ArrayDeque.smali`. A fix is in progress; the tester pack is rebuilt only after the fix lands and the attack verdict passes. The old tester-pack APKs are NOT silently reused as "new".

## Per-layer evidence

### L15 — Anti-decompile junk (invalid-UTF traps): PARTIAL

- Code: `transformer/junk.py` — 5 trap kinds (lone high/low surrogates, overlong slash/NUL/DEL), wrapped in `antirea-junk:<kind>:…:end` markers. Two plant functions, append-only: smali appends a decoy class `com/antirea/junk/JunkTraps`; dex appends complete `string_data_item` entries. No live string is ever rewritten.
- Gate: `experimental.junk_traps` in config, default OFF. No CLI wiring — the wrappers must be invoked deliberately.
- Tests: `transformer/tests/test_junk.py` — **28 tests, OK** (flag OFF → byte-identical; flag ON → traps present; valid input round-trips; traps only where claimed; double-plant refused; overlong-in-smali refused).
- Docs: `docs/L15-JUNK-TRAPS.md` — plain words, 4 device-proof gates before anyone ships it.
- Why PARTIAL, not IMPLEMENTED: the dex half works on a string-data blob copy only (real `.dex` rebuild with re-linked string entries is unbuilt), and no trapped APK has ever installed/launched on a real phone or broken a real decompiler. Needs device proof first.

### L60 — Runtime code mutation (self-modifying): PARTIAL (implemented, DEFAULT ON, loader never device-tested)

- User decision, twice: first "Self changing code is important. And also dangerous. Depend on how I use", then "Default is on man". So L60 is implemented and **ON by default** — `experimental.self_changing_code` defaults to true; setting it to `false` turns it off. The danger warning was NOT softened.
- Code: `runtime/ReaMethodDecrypt.kt` — pure-Kotlin core (stdlib + JDK, no Android APIs): `seal` (XOR + split key + SHA-256, same REA-IR format as ReaRuntime), `open` in three forms returning `ByteArray?` (never throws, never a wrong value), `rotate` re-seals under a fresh key so the stored bytes CHANGE between runs (tampered blobs refuse rotation, never laundered), `verifyBlob`, `generateKey`. Header states the RAM limit plainly: once code is loaded it stays loaded; rotation only changes the stored form.
- Loader: `runtime/ReaMethodLoader.kt` — Android side (`DexClassLoader`): decrypts in memory, writes plaintext dex to one fresh random-named file under private `filesDir/rea-methods/`, loads via a fresh loader, invokes, deletes the plaintext file in a `finally` on every path and wipes the plaintext byte array. Fail-closed everywhere. Header says **compile-verified only, cannot be JVM-tested (no dalvik), never device-tested**.
- Tool: `tools/make_method_blob.py` — stdlib sealer (`--self-test`: round-trip + 1-byte flip refuses + rotation changes bytes and still opens + tampered blob refuses rotation — **4/4 OK**, parent-verified).
- Flag: `transformer/config.py` `self_changing_code_enabled()` — true unless explicitly false. `transformer/tests/test_self_changing_code.py` — **9 tests OK** (both directions pinned: empty config → ON, explicit false → OFF, explicit true → ON, L15 still defaults OFF). Real config check: `anti-rea.yaml` (no `experimental` section) → `self_changing_code = True`, `junk_traps = False`.
- JVM core test: `runtime/tests/MethodDecryptTest.kt` — **TEST-PASS** (ROUNDTRIP / DOUBLE-OPEN / TAMPER / WRONG-KEY / ROTATE / BAD-INPUT / VERIFY, 283 binary bytes incl. all values 0–255), parent-verified. Loader compile check: **LOADER-COMPILE-OK**. Python↔Kotlin cross-check: Python-sealed blob opened by the Kotlin core, plain_sha256 matched → CROSSCHECK-OK.
- Docs: `docs/L60-SELF-CHANGING-CODE.md` (old `docs/L60-WHY-NOT-SHIPPED.md` deleted) — top line: "ON BY DEFAULT — set `experimental.self_changing_code: false` to turn it off." Keeps all old warnings (the three rejected shapes and why, Play Protect risk, RAM limit) plus when-safe / when-not-safe (never first launch, never login/payment, only non-critical paths, only after real-device proof, only own sealed payloads) and a 5-point device-proof checklist.
- Why PARTIAL, not IMPLEMENTED: the Android loader has never run on a device. The core is proven on JVM; the loader path is compile-only until a device run proves it.

### L89 — Frida runtime test (on device): IMPLEMENTED (harness; live run PENDING)

- Harness: `verifier/frida_test/frida_test.py` (stdlib; 5 checks F1 attach, F2 gadget, F3 hook, F4 memread, F5 ssl-unpin; PASS/BREAK/INCONCLUSIVE rules; `--dry-run`, `--from-file`, live `--package`, `--list-checks`; BREAK always wins; empty output is INCONCLUSIVE, never PASS; live mode exits 2 when frida/adb/device is missing — never fakes a live result), `verifier/frida_test/frida_script.js` (node --check OK; hooks `ReaRuntime` via `INSTANCE`, reads `ReaEnv.checkAll()` through getters only, scans readable memory, hooks `SSLContext.init` / OkHttp `CertificatePinner.check`; plaintext logged as first 8 chars + length only), `verifier/frida_test/README.md` (step-by-step tester instructions, ~30 min).
- Tests: `verifier/tests/test_frida_harness.py` — **20 tests, OK**; `--dry-run` classifier OK (protected → PASS, attacker-wins → BREAK). One real classifier bug was caught and fixed during development (F1 needed `ATTACHED` + `ENV_CLEAN` together) with a regression test.
- Live device run: **PENDING** — no phone/emulator and no Frida in this VM; nothing here claims a live run happened. The tester needs a test phone + matching frida-server.

### L91 — Red-team test (user's RE contact): PARTIAL (pack ready, test pending)

- Tester pack regenerated with the latest protected APKs + updated brief (new layers L101/L102/L103, Frida harness reference). See "Tester pack" below.
- The layer completes only when the tester reports back. A human test cannot be implemented by writing code.

### L98 — Gradle build-plugin: PARTIAL

- Code: `gradle-plugin/` — `AntiReaPlugin.kt` (`Plugin<Project>`, `tasks.register()`, `afterEvaluate` wires `assembleRelease.finalizedBy("protectApk")` when it exists, warns only if not), `AntiReaExtension.kt` (lazy `Property` API), `AntiReaProtectTask.kt` (runs `python3 anti-rea.py protect …` via `ProcessBuilder`, `GradleException` on missing CLI/config/APK, CLI start failure, or non-zero exit — fail-closed; input APK never overwritten), `AntiReaCommand.kt` (pure logic, zero Gradle imports), `build.gradle.kts` + `settings.gradle.kts` (`java-gradle-plugin`, id `com.antirea.gradle`), `gradle-plugin/README.md` (exact `build.gradle.kts` snippet via `buildSrc`).
- Sources cited (in README and code comments): https://docs.gradle.org/8.11-rc-2/userguide/writing_plugins.html, https://docs.gradle.org/current/userguide/part1_gradle_init_plugin.html, https://docs.gradle.org/8.12-rc-1/userguide/plugins.html. No Gradle APIs guessed; the CLI command matches the real `protect` subcommand.
- Tests: `gradle-plugin/tests/test_antirea_command.py` — **26 tests, OK** (config resolution, exact CLI command construction, failure handling, drift guards).
- Why PARTIAL, not IMPLEMENTED: the Kotlin has NEVER been compiled (`kotlinc` is not installed in this VM) and the plugin has NEVER run under Gradle (daemon broken, not retried). First verification on a working Gradle host: `./gradlew build` in `gradle-plugin/`, then apply to a real Android app.

### L99 — iOS profile (same REA-IR): IMPLEMENTED (profile defined + validated; never built on iOS)

- Profile: `profiles/ios.yaml` (24 KB) — maps **all 103 layers** in 9 categories: **58 APPLIES, 37 ADAPTED, 8 DOES-NOT-APPLY** (L08 R8, L15 dex traps, L24 APK v2/v3, L41 Developer Options, L42 adb, L43 cloners, L60 self-modifying code, L98 Gradle). Every entry names its Android mechanism; APPLIES/ADAPTED entries carry a concrete iOS mechanism (e.g. sysctl `P_TRACED` for L31, dyld image scan for L34/L36, `SecCodeCheckValidity` for L16, App Store receipt for L23, jailbreak detection for L33/L101/L102). The whole server side (L61–L70) is APPLIES unchanged. Declares `status: defined`, `built_on_ios: false`, `device_tested: false`.
- Tests: `tools/test_ios_profile.py` — **12 tests, OK** (every registry layer mapped exactly once, verdicts restricted, every category has ≥1 APPLIES, DOES-NOT-APPLY has a reason and no mechanism, declared counts match).
- Docs: `profiles/ios-README.md` — plain words, how an iOS developer would use it, what is NOT done.
- Limit: profile only — no Xcode project, no Swift code, no compiled iOS app, no device test.

## Smali regression — FOUND in this round, FIXED and verified

Protecting an APK with the full-layers CLI failed deterministically at apktool rebuild. Two bugs in the same fixup code, found one after the other by real protects (not by re-deriving):

**Bug 1 — high parameter registers (test app).** The L55 `chunk_string_literals` pass bumps `.locals` by 4 in every method it touches. `ArrayDeque.retainAll`/`removeAll` have `.locals 11` → 15, so parameter `p1` maps to **v16**. `iput p1, …` is a **22c** instruction (both registers 4-bit, v0–v15), so v16 cannot be encoded. The old `_fixup_high_regs` only knew `invoke-*` (→`/range`), `move*` (→`/16`), `filled-new-array` (→`/range`) and `/2addr` (→23x); for every other nibble-limited form it raised `RuntimeError: unfixable high parameter register` and aborted the whole protect. Why the 07:17 UTC full-build protect succeeded: the hardening wiring (L55/L58/L59/L11) was only added to `anti-rea.py` at 07:56 UTC — the 07:17 run never ran chunking, so the bug was latent until the wiring went live.
**Fix (transformer/smali.py):** generalized fixup via `_plan_fix` — every nibble-limited format is rewritten by copying high parameters through temp registers with the type-correct copy (`move/16` / `move-object/16` / `move-wide/16`), copying results back afterwards: 22c field ops, `instance-of`, `new-array`, 22t branches, 12x unary ops, `const/4` (→`const/16`), plus the existing rewrites. Temp-budget growth: when the bump leaves too few temp slots, the fixup grows `.locals` and re-scans (fixpoint, capped at 255). It still raises loudly only when genuinely unfixable. Secondary fix: flatten's branch-target regex matched the `:I` type suffix of field refs, silently skipping every method with a primitive-typed field access — fixed with a negative lookbehind. Also fixed in the same round: `fake_error_messages()` returns a list, but the L83 wiring passed it to `write_text` → `TypeError`.
**Regression test:** `transformer/tests/test_smali_registers.py` — 9 tests with an independent Dalvik validity checker; **8 of 9 fail on the old code, all 9 pass on the new code.**

**Bug 2 — format-table errors (Bridge).** The Bridge protect then died on `sget-object v18` in `SessionActivity.refresh()`. Parent's diagnosis, verified with dexdump: the bytes are `62 12 a3 02` — `sget-object` is format **21c** (ONE 8-bit register + 16-bit field ref), so v18 is legal. The fixup had misclassified static field ops as 22c. A clean apktool rebuild of the untouched Bridge decode succeeds (4,555,269 bytes), proving the input was valid. Two more table errors fell out of the same Bridge run: `rsub-int/lit8` (22b, 8-bit) was missing from `SAFE_8BIT_OPS` (the table had the dead name `"rsub-int/lit16"` instead), and the 22s `*-lit16` family was wrongly listed as 8-bit — it is 4-bit (the 16-bit literal occupies the rest of the code unit), proved with the real smali assembler. Full audit against dexlib2's `Opcode` enum plus a smali assembly probe of every `SAFE` op at v16–v18: `SAFE_8BIT_OPS` now matches the canonical 8-bit+ set exactly (116/116, zero discrepancies).
**Regression test:** `test_smali_registers.py` grew to **14 tests** (new: `sget-object v18` / `sget v20` unchanged, 22c iput control, `rsub-int/lit8` unchanged, lit16 fixed, lit16 low-reg unchanged) — all pass; **all 68 transformer unit tests pass**. Fail-on-old verified by swapping the original `smali.py` back in.

**End-to-end verification after the fixes (real tree, parent-run):**
- Test app protect: `tests/testapp/testapp-protected-final6.apk`, 767,070 bytes, sha256 `02649b30…`, 99 layers, 2 needles. `apksigner verify` PASS (v2+v3). Attack verdict **PASS** (control 1/1/2, protected 0/0/0).
- Bridge 2.14.0 protect: `tests/bridge-2.14.0-final6-protected.apk`, 4,865,135 bytes, sha256 `e54bf39f…`, 99 layers, 8 needles, 19 strings encrypted. `apksigner verify` PASS (v2+v3). Attack verdict **PASS** (all 6 needles 0 in protected across strings/jadx/apktool; control >0 for every needle).
- Note: per-build random keys mean each protect run produces a different sha256 at the same size — the two builds above are the exact files in the tester pack, built by the real CLI after the manifest regen.
- Remaining limits: `invoke-custom`/`invoke-polymorphic` with a high register would raise (no method descriptor to fix from; none occur in Bridge or testapp); `const-method-handle`/`const-method-type` are 21c but smali 2.5.2 cannot assemble them at any register (pre-existing smali limitation; neither APK contains them). Assemble-verified only — no device test.

## Tester pack — REGENERATED 2026-11-23 (final6 builds)

- `tester-pack.zip` — 3,487,858 bytes, sha256 `85e9a9e3c2fb77ff78602d4e2d1095c2d9cf56b867195d0fb72e740e85596af3`. Contains ONLY: `bridge-2.14.0-final6-protected.apk` (4,865,135 bytes, sha256 `e54bf39f…`), `testapp-protected-final6.apk` (767,070 bytes, sha256 `02649b30…`), `TESTER-BRIEF.md` (updated). No source, keys, config, or report.
- The brief now tells the tester about the new defences to attack: L101 mod-app block (MT Manager etc.), L102 GameGuardian/memory editing, L103 rename/repack, L60 self-changing code (ON by default), and Frida (attach/hook/memread/unpin). Break criteria 5–6 added (memory-edit accepted by the app; app still works with a mod app installed or renamed/re-signed).
- L91 stays PARTIAL: the pack is READY-TO-RUN; the layer completes only when the tester reports back.
- Note: the pack tests the protector on Bridge **2.14.0**. Protecting Bridge 2.16.0 with Anti-REA is a separate next step (parent's track), not part of this pack.

## Regression suites

- `tools/run_all.py` now runs **17 suites** (was 11): added `junk-traps` (L15), `frida-harness` (L89, unit + `--dry-run`), `ios-profile` (L99), `gradle-plugin` (L98), `jvm-methoddecrypt` (L60 core), `self-changing` (L60 flag tests + blob self-test). **Full run 2026-11-23: 17 passed, 0 failed, VERDICT PASS** (report `tests/run-all-final6-report.json`).
- New suites re-verified individually by the parent in this round: 95 unit tests + L60 JVM core TEST-PASS + blob self-test 4/4 + 68 transformer tests + 14 register tests, all OK.
- Self-check: **OK, 64 files** (manifest sha256 `a545a327…`). The manifest list in `tools/make_manifest.py` and `SELF_CHECK_FILES` in `anti-rea.py` were extended identically (20 new files vs the 44-file list, minus the deleted `docs/L60-WHY-NOT-SHIPPED.md`) and verified identical by script before regenerating.
- `layers --list`: `total=103 {'IMPLEMENTED': 99, 'PARTIAL': 4}`. `tools/layer_coverage.py` agrees on the counts.
- README.md was NOT touched in this round (parent rewrote it as the GitHub-ready public README; honest limits live in this report and the internal reports only, never in README.md).

## Still PLANNED (0) — none

Every slot is now built. Nothing is unbuilt. The remaining work is proof, not building: device runs (L15, L60, L89), the tester's report (L91), and a Gradle host run (L98).

## Still PARTIAL (4) — what would finish each

| Layer | What is missing |
|---|---|
| L15 Junk traps | Device proof: trapped APK installs/launches on a real phone with no crash + breaks a real decompiler; dex rebuild with re-linked string entries. |
| L60 Self-changing code | Device proof: the Android loader runs on a real phone (seal → load → invoke → delete) with no crash, on a non-critical path first. |
| L91 Red-team test | The user's tester runs the pack and reports back. |
| L98 Gradle plugin | `./gradlew build` on a working Gradle host + apply to a real Android app + a broken config failing the build. |

## Honest limits (whole round)

- Compile/JVM-verified only, never device-tested. No live Frida/debugger/runtime-dump test exists.
- The smali regression above is FIXED and verified end to end (both protects + both attack verdicts PASS, full 17-suite run PASS). It is fixed, not hidden: the two root causes and the fail-on-old-code proof are in the section above.
- A skilled attacker with root + patience can still win in the end; the server must never trust client-reported numbers (Bridge's ledger is the example).
- The self-check manifest is an UNSIGNED SHA-256 inventory (a local attacker with full tree write access can regenerate it).
- L15 is experimental and OFF by default; L60 is ON by default per user order and its Android loader never ran on a device; L98's Kotlin never compiled; L99 never built on iOS; L89's live run is pending; L91's live run is pending.
- 99% protection remains a GOAL, not a measured guarantee.

## Files changed (final-6 round)

- L15: `transformer/junk.py`, `transformer/tests/test_junk.py`, `docs/L15-JUNK-TRAPS.md`, `transformer/config.py` (flag `experimental.junk_traps`, default OFF).
- L60: `docs/L60-WHY-NOT-SHIPPED.md` (no code, by decision).
- L89: `verifier/frida_test/frida_test.py`, `verifier/frida_test/frida_script.js`, `verifier/frida_test/README.md`, `verifier/tests/test_frida_harness.py`.
- L91: tester pack + `tester-pack/TESTER-BRIEF.md` (pending smali fix — see above).
- L98: `gradle-plugin/src/main/kotlin/com/antirea/gradle/` (4 files), `gradle-plugin/build.gradle.kts`, `gradle-plugin/settings.gradle.kts`, `gradle-plugin/README.md`, `gradle-plugin/tests/test_antirea_command.py`.
- L99: `profiles/ios.yaml`, `profiles/ios-README.md`, `tools/test_ios_profile.py`.
- L60: `runtime/ReaMethodDecrypt.kt`, `runtime/ReaMethodLoader.kt`, `runtime/tests/MethodDecryptTest.kt`, `tools/make_method_blob.py`, `transformer/tests/test_self_changing_code.py`, `docs/L60-SELF-CHANGING-CODE.md` (old `docs/L60-WHY-NOT-SHIPPED.md` deleted), `transformer/config.py` (flag default ON), `runtime/build_smali.sh` (compiles both new files).
- Smali fix: `transformer/smali.py` (generalized `_plan_fix`, temp-budget growth, flatten branch-regex fix, lit16 branch, 21c/22c/22b format-table corrections), `transformer/tests/test_smali_registers.py` (14 tests), `anti-rea.py` (L83 `fake_error_messages` join fix).
- Merge: `layers/REGISTRY.md` (99/4/0), `tools/run_all.py` (17 suites), `tools/make_manifest.py` + `anti-rea.py` (self-check lists extended to 64 files), `anti-rea.manifest.json` (64 files, sha256 `a545a327…`), `tester-pack.zip` (regenerated, sha256 `85e9a9e3…`), `tester-pack/TESTER-BRIEF.md` (updated).
- No GitHub push, no Bridge changes, no live-server change.

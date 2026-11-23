# Anti-REA v1.0 — Layer Registry (103 slots)

Status: **IMPLEMENTED** = code in v1.0 + tested in VERIFICATION-REPORT-v1.0.md
(or in GAMEGUARDIAN-FIX-REPORT.md for L102/L103).
**PARTIAL** = works with a documented limit. **PLANNED** = slot reserved,
not built yet — never counted as protection.

Honest count (CLAIMED here, CONFIRMED only by the verification report):
**99 IMPLEMENTED, 4 PARTIAL, 0 PLANNED — out of 103 slots.**
If the verification report finds any claimed layer missing or untested,
the report's count wins and this file must be corrected to match it.
The 99% protection goal is a GOAL, not a measured guarantee. No app is
unbreakable; a skilled attacker with Frida / a runtime dump can still
read values after decryption. What 99 layers buy is time: every layer
broken still leaves the next one standing, plus traps that flag the
attempt server-side. The user's own reverse-engineering contact is the
planned real red-team test for v1.0 (arranged by the user, not done yet).

Counters key: J=jadx, A=apktool/smali, S=strings/dex, G=Ghidra static,
F=Frida/dynamic, D=debugger, R=runtime dump.

## A. Static hiding (L01–L15)

| ID | Layer | Counters | Status | Where |
|----|-------|----------|--------|-------|
| L01 | Smali string encrypt (const-string → blob + decrypt call) | J,A,S,G | IMPLEMENTED | transformer/smali.py, anti-rea.py protect |
| L02 | Source string encrypt (Kotlin/Java literals → REA-IR + stub) | J,A,S,G | IMPLEMENTED | transformer/source.py |
| L03 | Decoy strings (fake secret-looking literals) | J,A,S | IMPLEMENTED | transformer/smali.py |
| L04 | Honeypot secrets (fake keys, tripwire id attached) | J,A,S,F | IMPLEMENTED | transformer/smali.py, docs/TRAPS.md |
| L05 | Honeypot endpoints (fake URLs, tripwire id attached) | J,A,S,F | IMPLEMENTED | transformer/smali.py, docs/TRAPS.md |
| L06 | Resource string sweep (res/values + manifest needles) | J,A,S | IMPLEMENTED | anti-rea.py — sweep + decoy replace + encrypt res/values strings to assets/antirea/res_strings.json (runtime/ReaResStrings.kt decrypt on demand); JVM test PASS 2026-11-23. Limit: getString() returns the placeholder; the app must call decryptResource(name) explicitly. |
| L07 | DEX string sweep verify (control vs protected, 0 must hold) | J,A,S | IMPLEMENTED | verifier/attack.py |
| L08 | R8 rename mapping (class/method rename at build) | J,A,G | IMPLEMENTED | transformer/native.py generate_r8_rules() + anti-rea.py protect writes proguard-rules-antirea.pro to the REA-IR dir; test PASS 2026-11-23. Limit: rules do nothing until applied in the app's own Gradle build. |
| L09 | Manifest string hide (provider inject + label sweep) | A,S | IMPLEMENTED | anti-rea.py (ReaGuardProvider entry) |
| L10 | Decoy-class camouflage (decoys under com/antirea/decoy/, generic getSecretNN names; NOT under the app package in v1.0) | J,A,G | IMPLEMENTED | transformer/smali.py |
| L11 | Control-flow flatten (smali) | J,G | IMPLEMENTED | transformer/smali.py flatten_smali_file() + anti-rea.py protect; test-app protect PASS (attack 0/0/0, apksigner v2+v3 true) 2026-11-23. Limit: compile/assemble-verified only, never device-tested. |
| L12 | Native string hide (.so literals) | G | IMPLEMENTED | transformer/native.py scan/hide_elf_strings() + tools/gen_native_blobs.py + anti-rea.py protect; tested on a compiled arm64 .so + a libdsversion.so copy (size identical, readelf OK) 2026-11-23. Limit: only complete-printable-run needles are replaced; runtime-used strings must not be listed. |
| L13 | Asset encrypt (assets/ blobs) | A,S | IMPLEMENTED | transformer/native.py encrypt_asset_bytes() + runtime/ReaAssets.kt + anti-rea.py protect (config assets list); JVM round-trip PASS + APK test PASS 2026-11-23. Limit: the app must call decryptAsset explicitly. |
| L14 | Debug-line strip (.line directives removed) | J,G | IMPLEMENTED | transformer/smali.py |
| L15 | Anti-decompile junk (invalid-UTF traps) | J | PARTIAL | Experimental module transformer/junk.py (5 trap kinds, flag-gated OFF by default via experimental.junk_traps), 28 tests PASS 2026-11-23; docs/L15-JUNK-TRAPS.md. Limits: dex half works on a string-data blob copy only, no CLI wiring, NOT protection yet — a trapped APK must install/launch on a real phone and break a real decompiler before anyone ships it. |

## B. Integrity (L16–L30)

| ID | Layer | Counters | Status | Where |
|----|-------|----------|--------|-------|
| L16 | APK signature check at startup (provider) | A,F | IMPLEMENTED | runtime/ReaIntegrity.kt, ReaGuardProvider |
| L17 | DEX SHA-256 check | A,F | IMPLEMENTED | runtime/ReaIntegrity.kt |
| L18 | Component blob integrity (hash-prefix in every blob) | F | IMPLEMENTED | runtime/ReaRuntime.kt |
| L19 | Manifest hash (REA-IR manifest hash) | A,F | IMPLEMENTED | transformer, assets/antirea/manifest.json |
| L20 | Re-check on decrypt (verify before every unlock) | F | IMPLEMENTED | runtime/ReaRuntime.kt |
| L21 | Tamper refuse (throw, never return a wrong value) | F | IMPLEMENTED | runtime/ReaRuntime.kt |
| L22 | File-hash manifest (dex + manifest + blobs) | A,F | IMPLEMENTED | anti-rea.py (assets/antirea/manifest.json) |
| L23 | Installer-origin check (Play vs sideload) | F | IMPLEMENTED | runtime/ReaIntegrity2.kt checkInstallerOrigin (+ ReaRepack classifyInstaller); JVM test PASS 2026-11-23. Signal only, never a refusal alone. |
| L24 | Signature v2/v3 scheme check | A,F | IMPLEMENTED | verifier/sigcheck.py + anti-rea.py verify reports schemes; test PASS on control + protected APK (v1/v2/v3) 2026-11-23. |
| L25 | Runtime self-hash (own class hash) | F | IMPLEMENTED | runtime/ReaIntegrity2.kt hashClassBytes/verifySelfHash; JVM test PASS 2026-11-23. |
| L26 | Build-time watermark (per-build id in manifest) | A | IMPLEMENTED | tools/watermark.py apply_watermark() + anti-rea.py protect stamps a REA-IR watermark (build_id + built_at); test PASS 2026-11-23. |
| L27 | Config hash pinning (rea-ir hash pinned in runtime) | F | IMPLEMENTED | runtime/ReaIntegrity2.kt verifyConfigHash; JVM test PASS 2026-11-23. |
| L28 | Resource hash check | A,F | IMPLEMENTED | runtime/ReaIntegrity2.kt verifyResourceHashes; JVM test PASS 2026-11-23. |
| L29 | Native lib hash check | G,F | IMPLEMENTED | runtime/ReaIntegrity2.kt verifyNativeLibHashes; JVM test PASS 2026-11-23. |
| L30 | Integrity re-check timer (periodic) | F | IMPLEMENTED | runtime/ReaTimer.kt (injectable clock, stops on refusal); JVM test PASS 2026-11-23. |

## C. Environment (L31–L45)

| ID | Layer | Counters | Status | Where |
|----|-------|----------|--------|-------|
| L31 | Debugger detect (Debug.isDebuggerConnected) | D,F | IMPLEMENTED | runtime/ReaEnv.kt |
| L32 | Emulator detect (Build markers) | F | IMPLEMENTED | runtime/ReaEnv.kt |
| L33 | Root detect (su binaries, test-keys) | F | IMPLEMENTED | runtime/ReaEnv.kt |
| L34 | Frida maps detect (/proc/self/maps scan) | F | IMPLEMENTED | runtime/ReaEnv.kt |
| L35 | Frida port detect (27042/27043 via /proc/net/tcp) | F | IMPLEMENTED | runtime/ReaEnv.kt |
| L36 | Hook-lib detect (Xposed/Substrate markers) | F | IMPLEMENTED | runtime/ReaEnv.kt |
| L37 | Env re-check on sensitive call (checkAll before decrypt-gated actions) | F,D | IMPLEMENTED | runtime/ReaEnv.kt + ReaGuardProvider |
| L38 | VPN/proxy detect | F | IMPLEMENTED | runtime/ReaEnv2.kt vpnOrProxyDetected; JVM test PASS 2026-11-23. |
| L39 | Screen-share / screencap detect | F | IMPLEMENTED | runtime/ReaEnv2.kt screenShareDetected (only an active MediaProjection fires; FLAG_SECURE alone deliberately does not); JVM test PASS 2026-11-23. |
| L40 | Mock-location detect | F | IMPLEMENTED | runtime/ReaEnv2.kt mockLocationDetected; JVM test PASS 2026-11-23. |
| L41 | Developer-options detect | F | IMPLEMENTED | runtime/ReaEnv2.kt developerOptionsEnabled; JVM test PASS 2026-11-23. |
| L42 | USB-debugging detect | D,F | IMPLEMENTED | runtime/ReaEnv2.kt usbDebuggingEnabled; JVM test PASS 2026-11-23. |
| L43 | App-cloner detect | F | IMPLEMENTED | runtime/ReaEnv2.kt appClonerDetected; JVM test PASS 2026-11-23. False positives documented (a folder literally named 'clone' flags; 'dual' is a substring of 'individual'). |
| L44 | Time-tamper detect (clock skew) | F | IMPLEMENTED | runtime/ReaEnv2.kt timeTamperDetected (60 s tolerance); JVM test PASS 2026-11-23. |
| L45 | Locale/timezone anomaly flag | F | IMPLEMENTED | runtime/ReaEnv2.kt localeTimezoneAnomaly; JVM test PASS 2026-11-23. Weakest signal of the batch — flag only, never refuse. |

## D. Runtime (L46–L60)

| ID | Layer | Counters | Status | Where |
|----|-------|----------|--------|-------|
| L46 | In-memory-only decrypt (never write plain to disk/log) | F,R | IMPLEMENTED | runtime/ReaRuntime.kt |
| L47 | Split keys (neither part alone is the key) | J,A,G,F | IMPLEMENTED | transformer/crypto.py |
| L48 | Per-build key rotation (fresh random keys every run) | J,A,G | IMPLEMENTED | transformer/crypto.py |
| L49 | Native check stub (.so integrity gate) | G,F | IMPLEMENTED | runtime/native/reagate.c -> lib/arm64-v8a/libreagate.so (NDK 22.1.7171670, real compiled .so, 7,144 B) + runtime/ReaNative.kt (native-first, Kotlin fallback) + anti-rea.py copies the .so into lib/arm64-v8a/; JVM test PASS 2026-11-23. Limit: arm64-v8a only, never device-tested. |
| L50 | Delayed silent failure (refuse a sensitive action after N calls once integrity failed) | F | IMPLEMENTED | runtime/ReaTraps.kt |
| L51 | Honeypot tripwire (use of a fake value records an event) | F | IMPLEMENTED | runtime/ReaTraps.kt |
| L52 | Decoy classes (plausible, useless) | J,A,G | IMPLEMENTED | transformer/smali.py |
| L53 | Dead-code maze (branch chains resolving to 0) | J,G | IMPLEMENTED | transformer/smali.py |
| L54 | Anti-hook re-check inside decrypt path | F | IMPLEMENTED | runtime/ReaIntegrity2.kt decryptWithEnvCheck; JVM test PASS 2026-11-23 (env-fire never decrypts). |
| L55 | String chunking (split literals across calls) | J,A,S | IMPLEMENTED | transformer/smali.py chunk_string_literals() + anti-rea.py protect; test-app protect PASS, 2,165 strings chunked, witness literal 0 in protected dex 2026-11-23. |
| L56 | Reflection-based access (no direct refs) | J,G | IMPLEMENTED | runtime/ReaIntegrity2.kt invokeReflectively; JVM test PASS 2026-11-23. |
| L57 | Dynamic class loading (dex in assets) | J,A | IMPLEMENTED | runtime/ReaIntegrity2.kt loadClassFromJar (+ Android loadClassFromDex via DexClassLoader, device part untested); JVM test PASS 2026-11-23. |
| L58 | Opaque predicates (always-true/false branches) | G | IMPLEMENTED | transformer/smali.py insert_opaque_predicates() + anti-rea.py protect; test-app protect PASS 2026-11-23. |
| L59 | Method-call indirection | J,G | IMPLEMENTED | transformer/smali.py indirect_method_calls() + write_indirect_stub_class() + anti-rea.py protect; test-app protect PASS (setContentView routed through ReaIndirect) 2026-11-23. |
| L60 | Runtime code mutation (self-modifying) | F | PARTIAL | IMPLEMENTED as opt-out core, DEFAULT ON per user order 2026-11-23: runtime/ReaMethodDecrypt.kt (seal/open/rotate, XOR + split key + SHA-256, tamper refuses) + runtime/ReaMethodLoader.kt (DexClassLoader, plaintext deleted after load, fail-closed) + tools/make_method_blob.py + config flag experimental.self_changing_code (default true; false turns it off). JVM core TEST-PASS 2026-11-23 (round-trip/tamper/wrong-key/rotate/bad-input/verify), flag tests 9 OK, blob self-test 4/4 OK, loader COMPILE-OK. Docs: docs/L60-SELF-CHANGING-CODE.md (danger warning stays: never first launch, never login/payment, only non-critical paths, only after real-device proof; Play Protect risk; decrypted code stays in RAM). Limits: Android loader compile-verified only, NEVER device-tested; stored-form rotation only — loaded code stays loaded. |

## E. Server (L61–L70) — reference implementation in server/

No live server is changed by v1.0. The server is the real enforcement;
L61–L63 define what the client sends so a server CAN enforce, and
L64–L70 are a Python-stdlib REFERENCE implementation of the server
side (server/reference.py) — in-memory storage, no auth, no
deployment. A production server must replace the in-memory limiter
and revoked-set with real storage.

| ID | Layer | Counters | Status | Where |
|----|-------|----------|--------|-------|
| L61 | Attestation payload format (integrity + env findings, signed) | F | IMPLEMENTED | docs/SERVER.md, transformer (payload builder) |
| L62 | Tripwire log format (honeypot-use / tamper events) | F | IMPLEMENTED | docs/SERVER.md |
| L63 | Honeypot-use flag (fake endpoint/secret use = flag account) | F | IMPLEMENTED | docs/TRAPS.md, docs/SERVER.md |
| L64 | Server-side component-hash reject | F | IMPLEMENTED | server/reference.py verify_component_hashes() + server/test_server.py; unit tests PASS 2026-11-23. Reference only — no live server changed. |
| L65 | Device binding (attestation → device id) | F | IMPLEMENTED | server/reference.py bind_device()/check_device_binding() (stores SHA-256 of the id only); unit tests PASS 2026-11-23. Reference only. |
| L66 | Rate-limit on failed attestations | F | IMPLEMENTED | server/reference.py FailedAttestationLimiter (5 failures/hour sliding window); unit tests PASS 2026-11-23. In-memory — a production server needs real storage. |
| L67 | Remote kill-switch (revoke a build) | F | IMPLEMENTED | server/reference.py revoke_build()/is_build_revoked(); unit tests PASS 2026-11-23. Reference only. |
| L68 | Anomaly scoring (env findings → score) | F | IMPLEMENTED | server/reference.py score_findings() (0-100, clean/suspicious/blocked bands); unit tests PASS 2026-11-23. Reference only. |
| L69 | Audit export (tripwire events) | F | IMPLEMENTED | server/reference.py export_events()/parse_export() (JSONL, antirea-audit/v1); unit tests PASS 2026-11-23. Reference only. |
| L70 | Key rotation via server | F | IMPLEMENTED | server/reference.py rotate_keys()/old_key_still_valid() (7-day grace); unit tests PASS 2026-11-23. Reference only. |

## F. Traps / deception (L71–L85) — defensive only

No bricking, no file deletion, no harm to any device or analyst. A trap
only ever (a) returns a fake value, (b) records an event, or (c) refuses
one sensitive action in the app. See docs/TRAPS.md.

| ID | Layer | Counters | Status | Where |
|----|-------|----------|--------|-------|
| L71 | Fake endpoints (plausible admin/debug URLs) | J,A,F | IMPLEMENTED | transformer/smali.py, docs/TRAPS.md |
| L72 | Fake secrets (plausible API keys/tokens) | J,A,F | IMPLEMENTED | transformer/smali.py, docs/TRAPS.md |
| L73 | Fake keys (plausible key material) | J,A,F | IMPLEMENTED | transformer/smali.py, docs/TRAPS.md |
| L74 | Decoy API (fake methods returning fake data) | J,G,F | IMPLEMENTED | transformer/smali.py (decoy classes) |
| L75 | Maze classes (analysis-time sink) | J,G | IMPLEMENTED | transformer/smali.py |
| L76 | Fake login flow (decoy auth that always flags) | F | IMPLEMENTED | transformer/traps.py fake_login_flow() + anti-rea.py protect plants the decoy smali; tests PASS 2026-11-23. |
| L77 | Fake crash (decoy crash log with marker) | F | IMPLEMENTED | transformer/traps.py fake_crash() + anti-rea.py protect plants the decoy text; tests PASS 2026-11-23. A string only, never a real crash. |
| L78 | Slow maze (decoy with sleeps) | F | IMPLEMENTED | transformer/traps.py slow_maze() + anti-rea.py protect plants the decoy smali; tests PASS 2026-11-23. Only runs if an analyst invokes the decoy. |
| L79 | Fake update prompt (decoy) | F | IMPLEMENTED | transformer/traps.py fake_update_prompt() + anti-rea.py protect plants the decoy XML; tests PASS 2026-11-23. |
| L80 | Fake config file (decoy JSON) | A,S | IMPLEMENTED | transformer/traps.py fake_config_file() + anti-rea.py protect plants the decoy JSON; tests PASS 2026-11-23. |
| L81 | Fake native lib (decoy .so) | G | IMPLEMENTED | transformer/traps.py fake_native_lib() + anti-rea.py protect plants it under assets/ (NOT lib/); tests PASS 2026-11-23. Header-only ELF, NOT loadable — a placeholder only. |
| L82 | Fake stack traces | G | IMPLEMENTED | transformer/traps.py fake_stack_traces() + anti-rea.py protect plants the decoy text; tests PASS 2026-11-23. |
| L83 | Fake error messages with markers | F | IMPLEMENTED | transformer/traps.py fake_error_messages() + anti-rea.py protect plants the decoy text; tests PASS 2026-11-23. |
| L84 | Honeypot admin panel (decoy) | F | IMPLEMENTED | transformer/traps.py honeypot_admin_panel() + anti-rea.py protect plants the decoy smali; tests PASS 2026-11-23. |
| L85 | Trap chaining (one trap leads to a second trap) | F | IMPLEMENTED | transformer/traps.py chain_traps() + anti-rea.py protect records the chain in REA-IR; tests PASS 2026-11-23. |

## G. Verification / operations (L86–L100)

| ID | Layer | Counters | Status | Where |
|----|-------|----------|--------|-------|
| L86 | Control-vs-protected attack test (0 is never vacuous) | J,A,S | IMPLEMENTED | verifier/attack.py |
| L87 | Tamper test (1-byte flip → refuse) | F | IMPLEMENTED | verifier/tamper.py |
| L88 | CI gate (protect+verify in one command) | — | IMPLEMENTED | anti-rea.py ci subcommand (protect + verify, non-zero on any failure); test PASS 2026-11-23. |
| L89 | Frida runtime test (on device) | F | IMPLEMENTED | Harness verifier/frida_test/ (frida_test.py + frida_script.js + README), 5 checks F1–F5 with PASS/BREAK/INCONCLUSIVE rules, 20 tests PASS + --dry-run OK 2026-11-23. LIVE DEVICE RUN still PENDING — needs a test phone + matching frida-server. |
| L90 | Ghidra smoke (native) | G | IMPLEMENTED | verifier/ghidra_smoke.py + verifier/ghidra_scripts/AntiReaSmoke.java (headless Ghidra 12.2, 120 s timeout); smoke PASS on a tiny .so (13 functions, needle hit) 2026-11-23. Smoke test only. |
| L91 | Red-team test (user's RE contact) | all | PARTIAL | Tester pack regenerated 2026-11-23 with the latest protected APKs + updated brief (new layers L101/L102/L103, Frida harness) — READY-TO-RUN. Live red-team run pending the user's tester; only their report-back completes this layer. |
| L92 | Regression suite (re-run on every build) | — | IMPLEMENTED | tools/run_all.py (11 suites, per-suite pass/fail, JSON report); full run PASS after manifest regen 2026-11-23 (see FULL-LAYERS-REPORT.md). |
| L93 | Layer coverage report (per-build) | — | IMPLEMENTED | tools/layer_coverage.py + layers --coverage; test PASS 2026-11-23. |
| L94 | Service API (protection-as-a-service) | — | IMPLEMENTED | service/api.py (stdlib http.server, 127.0.0.1:8931, POST /protect, GET /status|/layers|/job|/download); localhost test PASS 2026-11-23. Prototype, no auth, never expose publicly. |
| L95 | Web upload + dashboard | — | IMPLEMENTED | service/dashboard.html served by service/api.py; fetched HTTP 200 PASS 2026-11-23. |
| L96 | Multi-app profiles (per-app presets) | — | IMPLEMENTED | tools/profiles.py + --profile (strict/standard/light + custom); test PASS 2026-11-23. |
| L97 | Key management service | — | IMPLEMENTED | tools/keyvault.py (PBKDF2 master key, HMAC-tagged store, rotate/revoke); selftest PASS 2026-11-23. Local vault only, not a production KMS. |
| L98 | Build-plugin (Gradle) | — | PARTIAL | Plugin source gradle-plugin/ (AntiReaPlugin/Extension/ProtectTask/Command; docs.gradle.org cited in README), 26 logic tests PASS 2026-11-23. Limits: Kotlin NEVER compiled (no kotlinc in this VM), NEVER run under Gradle (daemon broken) — needs a working Gradle host to verify. |
| L99 | iOS profile (same REA-IR) | — | IMPLEMENTED | profiles/ios.yaml maps all 103 layers (58 APPLIES / 37 ADAPTED / 8 DOES-NOT-APPLY), tools/test_ios_profile.py 12 tests PASS 2026-11-23. Limit: profile defined and validated only — NEVER built on iOS (no toolchain in this VM). |
| L100 | Layer marketplace (community layers) | — | IMPLEMENTED | tools/layer_marketplace.py + plugins/sample_hello_layer.py; test PASS 2026-11-23. |

## H. On-device modder-app block (L101)

| ID | Layer | Counters | Status | Where |
|----|-------|----------|--------|-------|
| L101 | On-device modder-app block (MT Manager, Apktool M, NP Manager, APK Editor, Lucky Patcher + 8 more; 13 verified package names as encrypted blobs) — installed-check + running-process check + known-dir check; refuse sensitive action while present, never delete/kill/harm | A,S | IMPLEMENTED | runtime/ReaModBlock.kt, runtime/ModBlockData.kt (generated by tools/gen_modblock_blobs.py), layers/MT-LIKE-BLOCKLIST.md, runtime/tests/ModBlockTest.kt — JVM test PASS 2026-11-23. Limits: clones with renamed packages evade the name check; Android 11+ installed-check needs host-app <queries> entries (CLI does not auto-inject them, on purpose — see blocklist doc); GameGuardian randomises its package name and is NOT blocked (UNVERIFIED). |

## I. GameGuardian / runtime-memory-editor defence (L102)

GameGuardian is a ROOT memory editor (dump, run, write — it scans live
RAM and writes new values). It randomises its package name on every
install, so it is detected by BEHAVIOUR, never by name. Full plain-words
explanation: docs/GAMEGUARDIAN.md.

| ID | Layer | Counters | Status | Where |
|----|-------|----------|--------|-------|
| L102 | GameGuardian / memory-editor defence — TracerPid + /proc/self/stat state 't' + /proc/self/maps markers (gameguardian, libgg, bulldog-daemon, base data name; bare "gg" deliberately NOT a marker) + verified GG data dirs + root+trace combined verdict + ObfuscatedLong/ObfuscatedInt (values never stored plain in RAM; checksum, read returns null on tamper) | F,R,D | IMPLEMENTED | runtime/ReaTrace.kt, runtime/ReaMemory.kt, runtime/ReaEnv.kt (findings in checkAll), runtime/tests/GameGuardianFixTest.kt — JVM test PASS 2026-11-23. Limits: root + patience wins in the end; virtual-space (no-root) GG mode not caught; plain value exists briefly in a local during get()/set(); server must never trust client-reported numbers (Bridge ledger is the example). |

## J. Renamed / repacked APK defence (L103)

A renamed APK has a new package name and is re-signed with the
attacker's key. The package check catches the rename; the signature
check catches the re-sign (a signature cannot be forged without the
private key). Expected fingerprint stored only as an encrypted blob.

| ID | Layer | Counters | Status | Where |
|----|-------|----------|--------|-------|
| L103 | Renamed / repacked APK defence — package-name exact match + signing-certificate SHA-256 compare (hex-to-hex, never hash-a-hash) + encrypted expected-hash blob (tools/make_sig_blob.py) + installer signal (Play vs other, never a refusal alone) | A,F | IMPLEMENTED | runtime/ReaRepack.kt, tools/make_sig_blob.py, runtime/tests/GameGuardianFixTest.kt — JVM test PASS 2026-11-23. Limits: multi-signer APKs (only first cert checked); CLI auto-injection of the expected-hash blob is PLANNED (developer makes the blob with the tool today). |

## Count

- IMPLEMENTED (claimed): 99 — L01, L02, L03, L04, L05, L06, L07, L08, L09, L10, L11, L12, L13, L14, L16, L17, L18, L19, L20, L21, L22, L23, L24, L25, L26, L27, L28, L29, L30, L31, L32, L33, L34, L35, L36, L37, L38, L39, L40, L41, L42, L43, L44, L45, L46, L47, L48, L49, L50, L51, L52, L53, L54, L55, L56, L57, L58, L59, L61, L62, L63, L64, L65, L66, L67, L68, L69, L70, L71, L72, L73, L74, L75, L76, L77, L78, L79, L80, L81, L82, L83, L84, L85, L86, L87, L88, L89, L90, L92, L93, L94, L95, L96, L97, L99, L100, L101, L102, L103.
- PARTIAL: 4 (L15, L60, L91, L98)
- PLANNED: 0 — every slot is now built, partially proven, or (L60) built with device proof still pending. No slot is unbuilt.
- The verification report is authoritative: any claimed layer it cannot evidence moves to PLANNED here.

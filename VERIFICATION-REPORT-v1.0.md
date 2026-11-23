# Anti-REA v1.0 — Verification Report

Date: 2026-11-23. Status: **compile-verified only, never device-tested.**
No device or emulator exists in this VM, so no protected APK was ever
installed or run on Android. Everything below is static analysis,
build verification, or JVM-level testing. Nothing here claims runtime
behaviour on a phone.

## Highlights (short version)

- **What it is:** a standalone Python-stdlib CLI (`anti-rea.py`) that
  protects ANY Android APK (Kotlin/Java) with one command + one config
  file. No Bridge code inside the tool.
- **Layers: 40 IMPLEMENTED, 2 PARTIAL, 58 PLANNED — out of 100 slots.**
  The count is honest: a layer is IMPLEMENTED only with code + test
  evidence in this report. Anything else is PLANNED.
- **Attack test: PASS on both APKs.** Bridge 2.14.0 and a tiny generic
  test app: protected 0 on every needle in `strings`-on-dex, JADX,
  and Apktool, with control > 0 for every needle in at least one tool
  (so the 0 is not vacuous). One honest caveat: JADX does not render
  the sentence containing `bridge-marketplace.onrender.com`, so that
  needle is vacuous in JADX only — proven present and protected by
  the other two tools.
- **Tamper test: PASS (JVM level).** A 1-byte flip in an encrypted blob
  (dex checksums fixed) is refused by `ReaRuntime.decrypt` with
  "payload integrity check failed"; the original blob decrypts fine.
- **Tool coverage: by technique, not by name.** 10 categories mapped
  in `TOOL-COVERAGE.md`; decompilers / unpackers / DEX tools tested
  PASS; Frida/debugger/emulator detection code is present but has no
  live device test; network tools are explicitly NOT stopped
  client-side; Ghidra and static scanners were not run.
- **99% protection is the GOAL, not a measured guarantee.** No app is
  unbreakable. Static + environment checks slow experts down; they do
  NOT stop Frida, a debugger, or a runtime memory dump. XOR + split
  keys is obfuscation with integrity checks, not strong crypto.
- **No push was made.** This tree is push-ready; see `PUSH-CHECKLIST.md`.

## Inputs (hashes)

| APK | Size (bytes) | SHA-256 |
|---|---|---|
| Bridge 2.14.0 control (input, read-only) | 4,573,620 | `7f140907b2b10120a912ff767d00e9a242aae40515f0c956ef423d5939a8dec3` |
| Generic test app control (`com.antirea.testapp`) | 614,877 | `d1708e7e8f902a939b4afe6b698a126c8420c6f9f30d9bd580859b31f036fcf8` |
| Bridge 2.14.0 protected (v1.0 CLI, test keystore) | 4,500,018 | `e55801fda6b08704ed2d3f58bcc35bbc818a23b85c787ae31321926ddb81dc5d` |
| Test app protected (v1.0 CLI, test keystore) | 582,254 | `3fd12ca3bcac43ba532376c955fa719eb702575945442087d9a9bdcd7de11b14` |
| Test app tampered (1-byte blob flip, UNSIGNED) | 576,958 | `f5bf4717edf39aed6390bf78aec87eb50ddd8fe85cc237fd31a2d440aa8adc15` |

Both protected APKs use an **ephemeral test keystore** and will NOT
install over a stable-key build (Bridge 2.14.0 stable key, test app
control). The Bridge live source was never edited.

The generic test app is a minimal Kotlin app built in `tests/`
(one secret string `TEST-SECRET-7f3a9-generic`, one endpoint
`https://testapp.example.invalid/api`, one key method `getSecret()`).
It proves the CLI works on an app that is not Bridge.

## Protect runs

- Bridge: 1,416 smali files rewritten, **19 strings encrypted
  (4 embedded in sentences via StringBuilder concat),
  7 static fields encrypted**, 33,370 `.line` directives stripped,
  high-register fixup rewrote 5 original invokes + 2 original
  moves (see failure #8 below), 2 decoy classes + 3 maze classes
  written, 2 needle occurrences replaced in XML (PARTIAL, see
  L06), `ReaGuardProvider` injected into the manifest, 40 layers
  applied, 8 needles configured.
- Test app: 2 strings encrypted, 2 static fields encrypted,
  20,696 `.line` directives stripped, 40 layers applied,
  2 needles configured.
- Both runs applied the **same 40-layer set** (REA-IR
  `layers_applied` identical): L01, L02, L03, L04, L05, L07, L09,
  L10, L14, L16, L17, L18, L19, L20, L21, L22, L31, L32, L33, L34,
  L35, L36, L37, L46, L47, L48, L50, L51, L52, L53, L61, L62, L63,
  L71, L72, L73, L74, L75, L86, L87.
- REA-IR output contains **no plaintext needles** (verified by
  byte-search of `tests/bridge-rea-ir/*.json` for every needle:
  all absent). Payloads are keyed `k1`, `k2`, … with blob + key
  parts + SHA-256 only. Honeypot values are listed in REA-IR by
  design — they are fake values meant to be found; using one
  triggers a server-side tripwire.
- `assets/antirea/manifest.json` + `assets/antirea/build.json`
  (dex SHA-256) are present in both protected APKs.
- `anti-rea.py verify` (CLI, control vs protected) and
  `verifier/attack.py` agree. `layers --list` totals: 100 slots,
  40 IMPLEMENTED / 2 PARTIAL / 58 PLANNED.

## Attack test — per-tool results (verifier/attack.py)

Method: literal counting (never regex) in three tools —
`strings` on the extracted `classes.dex`, JADX decompiled sources,
Apktool decode. PASS requires: every tool ran, protected == 0 for
every needle in every tool, every needle has control > 0 in at
least one tool, every tool sees control > 0 for at least one
needle. Per-tool vacuity for a single needle is recorded, not a
failure (see "What failed and was fixed" for why the rule changed).

### Bridge 2.14.0, full config needle set (8 needles) — PASS

Report: `tests/attack-bridge-full-report.json`.

| Needle | strings_dex C→P | JADX C→P | Apktool C→P |
|---|---|---|---|
| `https://mbbridge.onrender.com` | 3→0 | 5→0 | 9→0 |
| `http://10.0.2.2:8000` | 1→0 | 1→0 | 3→0 |
| `https://api.bridge.example` | 1→0 | 1→0 | 2→0 |
| `api.bridge.example` | 2→0 | 2→0 | 3→0 |
| `bridge-marketplace.onrender.com` | 1→0 | 0→0 (vacuous in JADX) | 1→0 |
| `tunnel.key.` | 1→0 | 1→0 | 4→0 |
| `.private` | 1→0 | 1→0 | 4→0 |
| `.public` | 1→0 | 1→0 | 4→0 |

Vacuous in tool: `{"jadx": ["bridge-marketplace.onrender.com"]}` —
JADX does not render the sentence "Enter a full domain (for example
bridge-marketplace.onrender.com) or an IP address." (it drops that
method), so JADX control is 0 for that needle. The needle is proven
present in control and absent in protected by `strings_dex` and
Apktool. This is a JADX rendering gap, not a protection gap.

### Bridge 2.14.0, core needle set (5 needles) — PASS

Report: `tests/attack-bridge-report.json`. Same counts for the five
needles as above, no vacuous needles. This is the task's named
needle set (`mbbridge,onrender,10.0.2.2,api.bridge.example,tunnel.key.`).

### Generic test app (2 needles) — PASS

Report: `tests/attack-testapp-report.json`.

| Needle | strings_dex C→P | JADX C→P | Apktool C→P |
|---|---|---|---|
| `TEST-SECRET-7f3a9-generic` | 1→0 | 1→0 | 2→0 |
| `testapp.example.invalid` | 1→0 | 1→0 | 2→0 |

No vacuous needles.

### Non-vacuity proof

The comparator is not vacuous by construction: an attack self-test
(control vs itself, `tests/attack-selftest-report.json`) correctly
**FAILS**, proving the comparator can detect a failure. Every PASS
above has control > 0 for every needle in at least one tool.

## Frida / environment smoke — static presence only

Script: `verifier/frida_smoke.py` on the protected test app.
Report: `tests/frida-smoke-testapp-report.json`.

- Frida markers present in the protected dex: `frida-agent` ×1,
  `frida-gadget` ×1, `27042` ×2. (Expected: the runtime's own
  detection code has to name what it looks for.)
- Env-check methods present (via dexdump): `isDebuggerConnected`,
  `isEmulator`, `fridaMapsDetected`, `isRooted`. Absent (the
  runtime uses different names): `isFridaPresent`, `detectFrida`,
  `checkFrida`, `detectDebugger`, `isRunningOnEmulator`,
  `isDebuggable`, `isDebuggerAttached`, `detectEmulator`,
  `checkRoot`, `isFridaDetected`.
- **This does NOT prove Frida is stopped at runtime.** Runtime
  proof needs a device/emulator with Frida attached while the
  protected app runs; this VM has no device/emulator, so that test
  was NOT run and is NOT claimed.

## Tamper test — PASS (JVM level, not device)

- `verifier/tamper.py` flipped 1 byte in an encrypted blob inside
  the protected test app's dex (offset 937818, `'v'` → `'B'`,
  blob prefix `vdeqVofEvBKF…`), fixed the dex SHA-1 signature then
  the Adler-32 checksum, repackaged UNSIGNED
  (`tests/testapp/testapp-tampered.apk`).
- Dex header checksums verify after the fix (stored == recomputed
  for both Adler-32 and SHA-1). Note: `dexdump` reports
  "Out-of-order string_ids" for the tampered dex — the flip changed
  the blob string's sort position — but still processes the file.
  A tampered APK therefore fails at the dex-verification layer,
  the runtime-integrity layer, or both; it does not run with
  modified secrets.
- JVM test (kotlinc + `ReaRuntime.decrypt`, same blob + key parts
  from REA-IR): original blob → `DECRYPT-OK` (25 chars, the test
  secret); tampered blob → `IllegalStateException: Anti-REA:
  payload integrity check failed`. The runtime never returns a
  wrong value on tamper.
- No device install test of the tampered APK was run or claimed.

## Layer count — honest audit

**40 IMPLEMENTED, 2 PARTIAL, 58 PLANNED** (`layers/REGISTRY.md`;
`layers --list` totals match). This report is authoritative over
the registry: any claimed layer it cannot evidence moves to
PLANNED there. Evidence per group:

- **Static hiding (L01, L02, L03, L04, L05, L07, L09, L10, L14):**
  attack PASS on both APKs (L01/L07); source-mode transform tested
  fresh in v1.0 (3 replacements, zero plaintext left, including an
  embedded needle in source — L02); decoy/maze classes present in
  the protected APKs (L03/L04/L05/L10/L52/L53/L71–L75);
  33,370 `.line` directives stripped in the Bridge run (L14);
  `ReaGuardProvider` manifest entry present (L09). Note: L10
  decoys live under `com/antirea/decoy/`, NOT under the app
  package — the registry was corrected to say so.
- **Integrity (L16, L17, L18, L19, L20, L21, L22):** runtime code
  present + compiled to smali (`ReaIntegrity.kt`,
  `ReaRuntime.kt`); blob hash-prefix check proven by the JVM
  tamper test (L18/L20/L21); `assets/antirea/manifest.json` +
  `build.json` with dex SHA-256 present in protected APKs
  (L19/L22). Startup signature/DEX checks (L16/L17) are
  code-present, never executed on a device.
- **Environment (L31–L37):** `ReaEnv.kt` code present + compiled
  (6 checks + `checkAll`/`suspiciousCount`); Frida markers and
  method names confirmed present in the protected dex by the
  smoke check. **Never executed on a device — no runtime claim.**
- **Runtime (L46, L47, L48, L50, L51):** in-memory-only decrypt
  + split keys + per-build key rotation are code + unit-tested
  (same plaintext → different blobs and key parts every run, same
  plaintext hash; full key never stored). Delayed silent failure
  and honeypot tripwire (L50/L51) are code-present in
  `ReaTraps.kt`, never executed on a device.
- **Server (L61, L62, L63):** attestation
  (`antirea-attestation/v1`) + tripwire (`antirea-tripwire/v1`)
  payload formats defined in `docs/SERVER.md` and present in
  REA-IR output. **Spec only — no server code ships and no live
  server was changed.**
- **PARTIAL (2):** L06 resource/manifest string sweep — needles
  are replaced with a decoy placeholder in XML, but values are
  NOT runtime-decrypted in v1.0 (use only for non-functional
  strings). L49 native check stub — interface defined, no
  compiled `.so` in v1.0; the Java fallback is the real check.
- **PLANNED (58):** slots reserved in the registry, no code, no
  count. Includes R8 rename, resource encryption, native
  hardening, build plugin, key-management service, iOS profile.

## Tool coverage — per-category results (TOOL-COVERAGE.md)

| # | Category | v1.0 result |
|---|---|---|
| 1 | Decompilers (JADX, CFR, FernFlower, …) | **TESTED, PASS** (JADX; 0 needles in protected) |
| 2 | Disassemblers (Ghidra, IDA, …) | **NOT RUN.** Counter is the native-check stub + no plain logic in native. No DEX loader run; no claim. |
| 3 | APK unpackers (Apktool, …) | **TESTED, PASS** (Apktool; 0 needles) |
| 4 | DEX tools (dex2jar, baksmali, …) | **TESTED, PASS** (`strings` on dex + baksmali/smali round-trip; dex contains blobs only) |
| 5 | Static scanners (MobSF, APKiD, …) | **NOT RUN.** No plain secrets/URLs/keys for them to flag; they will still flag permissions etc. honestly. |
| 6 | Dynamic / hooking (Frida, Objection, Xposed, …) | **CODE PRESENT, no device test.** Static smoke confirms markers + methods in dex. Not claimed stopped. |
| 7 | Debuggers (LLDB, GDB, JDWP, strace, logcat) | **CODE PRESENT, no live test.** Debugger detect + re-check exist; not claimed stopped. |
| 8 | Network (Wireshark, mitmproxy, Burp, …) | **NOT a client claim.** Server must use TLS + pinning + attestation. No APK stops mitmproxy. |
| 9 | Emulators / sandboxes (Emulator, Genymotion, VirusTotal, …) | **CODE PRESENT, no emulator test.** Upload cannot be stopped; server attestation is what makes an uploaded copy useless. |
| 10 | Diffing (BinDiff, Diaphora, …) | **TESTED at unit level.** Per-build key rotation: same plaintext → different blobs/key parts, same plaintext hash. |

Out of scope (checked, not ignored): build tools, generic tools,
competitor protectors, datasets/standards, AI coding tools —
none are APK reverse-engineering tools. Full mapping in
`TOOL-COVERAGE.md`.

## What failed and was fixed during v1.0

Every failure below was caught by a test, fixed in code, and
re-verified. Nothing was papered over.

1. **First test-app protect failed at apktool rebuild** — maze
   smali used `rem-int v2, v0, 0x7` (invalid: `rem-int` takes no
   literal). Fixed to `rem-int/lit8`.
2. **Kotlin `const val` missed** — `const val` compiles to a
   static `.field` initializer, not `const-string`. Added
   `transform_static_fields`: strip the initializer, assign the
   decrypted value in `<clinit>` (creating it if absent).
3. **Sentences containing a needle missed** — whole-value matching
   skipped "Enter a server domain, for example
   https://mbbridge.onrender.com". Added segment splitting +
   StringBuilder concat for embedded needles (smali and source).
4. **`const-string` into `p` registers missed** — the regex only
   matched `v` registers. Fixed to `[vp]\d+`.
5. **Plain invoke form breaks above v15** — `invoke-virtual`
   only encodes v0–v15. All decrypt/append/toString/init invokes
   now use the `/range` form with contiguous registers.
6. **`move-object` breaks above v15** — it is a 12x instruction.
   Removed all `move-object` uses from injected code; results go
   via `move-result-object` directly into the target register.
7. **`<clinit>` temp order** — the `/range` invoke requires the
   instance register to be the lowest; temps are now allocated in
   invoke order `[instance, blob, part1, part2]`.
8. **The `.locals` bump shifts `p` registers** (the big one) —
   bumping `.locals` pushed parameters above v15, breaking the
   ORIGINAL code's non-range invokes and `move-object`s in
   `BridgeConfig$Companion` (p1 became v20). Added
   `_fixup_high_regs`: rewrites those instructions to `/range`
   with arguments copied via `move/16` / `move-object/16` /
   `move-wide/16` (typed from the callee descriptor), `move*` to
   `move*/16`, and `filled-new-array` to `/range`. Anything else
   still referencing a `p` register above v15 raises loudly
   instead of shipping a broken APK. Unit-tested on a
   `.locals 14` method mimicking the exact Bridge failure
   (4 invokes + 1 move fixed, assembles, no plaintext).
9. **Bare-domain needle missed** — `DeveloperActivity` contains
   "api.bridge.example is a placeholder, not a real server." and
   the full-URL needle did not match it. Added the bare domain
   as a needle in `tests/bridge.yaml` (longest needle wins, so
   the full URL still encrypts as one segment).
10. **Verifier false positives (jadx)** — raw substring counting
    matched Java identifiers (`this.privateKeyBase64` contains
    ".private"). JADX counting is now quote-aware: only
    occurrences inside `"..."` string literals count.
11. **Verifier false positives (apktool)** — tree counting read
    binary files, including the untouched WireGuard native
    library `libwg-go.so` (3.3 MB, shipped inside Bridge), whose
    Go symbol data contains ".private"/".public". Tree counting
    now skips binary files (non-UTF-8) and anything under `lib/`.
    v1.0 does not rewrite native libraries (L49 PARTIAL).
12. **Verifier verdict rule too strict** — it demanded control > 0
    for every needle in every tool, which is unachievable when a
    tool cannot render a needle (JADX drops the sentence
    containing `bridge-marketplace.onrender.com`). New rule: every
    needle needs control > 0 in at least one tool, every tool
    needs control > 0 for at least one needle, protected must be
    0 everywhere; per-tool vacuity is recorded in
    `vacuous_in_tool`. The anti-vacuity guarantee is preserved at
    the needle level and the tool level.
13. **Plaintext leak in REA-IR (caught before release)** — the
    first REA-IR keyed payloads by plaintext needle and listed
    plaintext in `needles_found`. Fixed to key-id-only +
    SHA-256-only; verified zero plaintext in the shipped REA-IR.

## Honest limits — read this before you trust it

- **No app is unbreakable. 99% is the GOAL, not a measured
  guarantee.** Nothing in this report measures attacker success
  rate. The traps waste an analyst's time; they do not make
  analysis impossible.
- **Static + environment checks slow experts down; they do NOT
  stop Frida, a debugger, or a runtime memory dump.** The
  real enforcement is server-side (attestation + tripwires);
  the client checks are tripwires, not walls.
- **XOR + split keys is obfuscation with integrity checks, not
  strong crypto.** A determined analyst with runtime access can
  recover decrypted values from memory. The integrity hash only
  proves a blob was not modified; it does not hide the value
  from a live process.
- **No device test exists.** No protected APK was installed or
  run. Runtime behaviour (decrypt at startup, env checks,
  provider init, delayed failure, honeypot tripwire) is
  compile-verified + JVM-tested where testable, and unproven on
  Android. The real red-team test is the user's
  reverse-engineering contact, on v1.0 when ready — not done yet.
- **L06 (XML sweep) is PARTIAL** — replaced values are decoy
  placeholders, not runtime-decrypted. Do not protect functional
  strings (URLs the app actually fetches, keys it actually uses)
  through L06.
- **L49 (native) is PARTIAL** — no compiled `.so` ships; native
  libraries inside the input APK (e.g. WireGuard's libwg-go.so)
  are passed through untouched.
- **Decoys are visible as a package** (`com/antirea/decoy/`) —
  an analyst can tell they are added. Their value is as
  honeypots/tripwires, not as camouflage.
- **Honeypots are fake and documented as fake** in the repo
  (`docs/TRAPS.md`, config comments). Using one triggers a
  server-side flag only if the server implements the tripwire
  format in `docs/SERVER.md`. No server code ships in v1.0.
- **Server attestation/tripwire are formats only.** No live
  server was changed; the Bridge server does not yet implement
  `antirea-attestation/v1` / `antirea-tripwire/v1`.

## Files (push-ready tree)

- `anti-rea.py` — CLI (`protect` / `verify` / `layers`)
- `anti-rea.yaml` — example config (example values only)
- `transformer/{crypto,config,smali,source}.py`
- `runtime/{ReaRuntime,ReaEnv,ReaIntegrity,ReaTraps,ReaGuardProvider}.kt`,
  `runtime/build_smali.sh`, `runtime/smali/…` (16 smali files),
  `runtime/NOTES.md`
- `layers/REGISTRY.md` — 100 slots, 40/2/58
- `docs/{USAGE,TRAPS,SERVER}.md`
- `TOOL-COVERAGE.md`, `README.md`, `PUSH-CHECKLIST.md`
- `tests/testapp.yaml`, `tests/bridge.yaml`,
  `tests/testapp/testapp-control.apk`,
  `tests/testapp/testapp-protected.apk`,
  `tests/testapp/testapp-tampered.apk`,
  `tests/bridge-2.14.0-v10-protected.apk`,
  `tests/bridge-2.14.0-v10-protected.apk.idsig`,
  `tests/attack-bridge-report.json`,
  `tests/attack-bridge-full-report.json`,
  `tests/attack-testapp-report.json`,
  `tests/attack-selftest-report.json`,
  `tests/frida-smoke-testapp-report.json`,
  `tests/frida-smoke-control.json`,
  `tests/testapp-rea-ir/`, `tests/bridge-rea-ir/`,
  `tests/build_testapp.sh`, `tests/README.md`
- `verifier/{attack,tamper,frida_smoke}.py`

No secrets, no keystores, no stable-key APKs in the tree. The
protected APKs use an ephemeral test keystore (keystore file
itself is NOT in the tree — it lived in the temporary workdir).

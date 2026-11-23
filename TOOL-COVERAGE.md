# Anti-REA v1.0 — Tool Coverage (by technique, not by name)

The user asked for protection against "almost all tools" after receiving
a list of ~500 names. Countering 500 names one by one is the wrong
approach: tools in one category all attack the same way, so Anti-REA
counters the TECHNIQUE. This file maps each technique category to the
layers that counter it, a representative test tool, and the honest
test status. A category is only claimed as "tested" when a real test
ran; everything else says so plainly.

Status words: **TESTED** = a real test ran and its numbers are in a
verification report. **CODE PRESENT** = the counter-code exists and
compiles, but no attack test has run against it yet. **NOT RUN** =
no test in v1.0. **NOT A CLIENT CLAIM** = this cannot be stopped
client-side at all; the requirement is server-side.

Prior evidence this file rests on (all verified, not assumed):
- v0.1: jadx control 7/7/2/2 vs protected 0/0/0/0; strings/dex 0;
  1-byte tamper refuses. (VERIFICATION-REPORT-v0.1.md)
- v0.2: Bridge 2.15.0 test APK vs stock 2.14.0 control — jadx /
  apktool / strings all 0 on protected, all found on control;
  tamper refuses. (VERIFICATION-REPORT-v0.2.md)
- v1.0: `verifier/attack.py` comparator proven non-vacuous (control
  vs itself = FAIL, control counts 1/1/2 per needle); per-build key
  rotation verified 2026-11-23 (same plaintext encrypted twice gives
  different blobs and different key parts, same plaintext hash).
- v1.0 protected-APK attack results: **TESTED, PASS 2026-11-23** —
  Bridge 2.14.0 protected (`e55801fd…`) and the generic test app
  protected (`3fd12ca3…`): protected 0 on every needle in
  strings-on-dex, JADX, and Apktool; control > 0 for every needle
  in at least one tool. One recorded caveat: JADX does not render
  the sentence containing `bridge-marketplace.onrender.com`, so that
  needle is vacuous in JADX only. Full numbers in
  `VERIFICATION-REPORT-v1.0.md` and `tests/attack-*-report.json`.

## 1. Decompilers — JADX, JADX-GUI, CFR, FernFlower, Vineflower, Procyon, JD-GUI, Krakatau, Recaf

- Counter: L01 smali string encrypt + L02 source string encrypt +
  L18 blob integrity + L14 debug-line strip. (R8 rename, L08, is
  PLANNED — the CLI does not rename app classes yet.)
- Representative test tool: JADX.
- Status: **TESTED** on v0.1/v0.2 and **TESTED, PASS in v1.0
  (2026-11-23)**: Bridge protected 0 on every needle in JADX
  (control 1–5 per needle); test app protected 0 in JADX
  (control 1 per needle). One caveat: JADX does not render the
  sentence containing `bridge-marketplace.onrender.com`, so that
  needle is vacuous in JADX only (proven by the other tools).
- What the attacker sees: blobs + hashes + stub calls. No plain
  URLs, keys, or endpoints in decompiled output.

## 2. Disassemblers — Ghidra, IDA, IDA Free, Binary Ninja, Hopper, radare2, Rizin, Cutter, objdump, Capstone

- Counter: L49 ships a real compiled `.so` now
  (`runtime/native/lib/arm64-v8a/libreagate.so`, NDK 22.1.7171670,
  from-scratch SHA-256 + constant-time compare; the Java fallback is
  the same gate) + L12 native string hiding + L53 dead-code maze +
  L01 (dex holds blobs). Native disassembly finds the maze and the
  runtime, not secrets.
- Representative test tool: Ghidra smoke (L90).
- Status: **SMOKE TESTED, PASS 2026-11-23 (full-layers build).**
  Headless Ghidra 12.2 with a 120 s timeout on a tiny test `.so`
  (15 KB): 17 s, exit 0, 13 functions found, needle `string_hits=1`
  — the smoke script works (the earlier 420 s timeouts were a wrong
  invocation, missing project dir, not a Ghidra limitation). This is
  a smoke test only: it proves the Ghidra pipeline runs and finds a
  planted needle in a small `.so`; it is NOT a needle-finding run on
  a real app `.so` (the 2026-11-23 sweep's `libwg-quick.so` run
  captured no needle output — see the sweep report). Do not treat
  this category as fully tested until a needle run on a real `.so`
  is done.
- Honest limit: a disassembler can still read the runtime's own logic
  (it is not encrypted). What it cannot read is the protected values.

## 3. APK unpackers — Apktool, APKLab, Androguard, APKTool M, APK Editor Studio, APKParser, APK Analyzer

- Counter: L06 resource/manifest string sweep (PARTIAL — decoy
  replace, not runtime-decrypted) + L09 manifest hide + L07 DEX
  string sweep verify.
- Representative test tool: Apktool.
- Status: **TESTED** on v0.2 and **TESTED, PASS in v1.0
  (2026-11-23)**: Bridge protected 0 on every needle in Apktool
  decode (control 1–10 per needle); test app protected 0 in
  Apktool (control 2 per needle).

## 4. DEX tools — dex2jar, Enjarify, Smali, Baksmali, dexlib2, DEXdump, DEXTools

- Counter: same as 1 + 3. The DEX contains blobs only; the runtime
  class is the only readable code, and it holds no secrets.
- Representative test tools: baksmali + `strings` on extracted dex.
- Status: **TESTED** on v0.1/v0.2 and **TESTED, PASS in v1.0
  (2026-11-23)**: `strings` on extracted `classes.dex`, Bridge
  protected 0 on every needle (control 1–3 per needle); test app
  protected 0 (control 1 per needle). (Methodology note from v0.1:
  `strings` on the raw `.jar`/`.apk` zip reads ~0 by construction
  because entries are deflated — always extract the dex first.)
  **2026-11-23 sweep addition — dex2jar 2.1 + CFR 0.152, TESTED, PASS**:
  Bridge control CFR finds 12, 1, 2, 3, 1, 1 per needle, protected 0;
  test app control 1, 1, protected 0. Full numbers in
  `TOOL-SWEEP-REPORT.md`.

## 5. Static scanners — MobSF, APKiD, QARK, Semgrep, CodeQL, SonarQube, Quark-Engine, AndroBugs

- Counter: no plain secrets / URLs / keys for them to flag (L01/L02/
  L06). The scanner's secret-detection rules find nothing to report.
- Representative test tool: none run in v1.0 (see status).
- Status: **NOT RUN in v1.0.** No MobSF/QARK/Semgrep scan has been
  run on a v1.0 protected APK. The counter is a consequence of the
  tested string hiding, not a separately tested claim.
  **2026-11-23 sweep addition — APKLeaks 2.6.3, INCONCLUSIVE**: installed
  in a venv but hung with no output for 6+ minutes on the tiny test
  app and was killed; not a tested PASS. MobSF/QARK/Semgrep remain
  NOT INSTALLED (checked).
- What they WILL still flag, honestly: permissions, exported
  components, cleartext-traffic settings, debuggable flags, weak
  crypto warnings about XOR if they pattern-match it, and the
  presence of a ContentProvider. Anti-REA does not hide the app's
  manifest or permissions, and does not claim to.

## 6. Dynamic / hooking — Frida, Frida-tools, Objection, Xposed, LSPosed, EdXposed, SandHook, YAHFA, Dobby, HookZz

- Counter: L34 Frida maps detect + L35 Frida port detect + L36
  hook-lib detect + L37 env re-check on sensitive calls + L20
  integrity re-check on decrypt + L46 in-memory-only decrypt.
  Detection is a SIGNAL the app can act on; it is not a block.
- Representative test: JVM smoke of the detection code + static
  presence check (`verifier/frida_smoke.py`).
- Status: **CODE PRESENT, NOT device-tested.** The detection
  functions exist in `runtime/ReaEnv.kt` (verified present:
  `isDebuggerConnected`, `isEmulator`, `isRooted`,
  `fridaMapsDetected`, `fridaPortsDetected`, `hookLibsDetected`,
  `checkAll`, `suspiciousCount`). `verifier/frida_smoke.py` was
  run 2026-11-23 on the PROTECTED test app (static presence
  check only): markers `frida-agent` ×1, `frida-gadget` ×1,
  `27042` ×2 present in the dex, and env-check methods
  `isDebuggerConnected`, `isEmulator`, `fridaMapsDetected`,
  `isRooted` present (report:
  `tests/frida-smoke-testapp-report.json`). **No live Frida
  test has run on a device or emulator in this VM, and none is
  claimed.** A skilled attacker with Frida can still read values
  after decryption — that is the known, stated limit of every
  client-side protector, including this one.

## 7. Debuggers — LLDB, GDB, JDWP, strace, logcat

- Counter: L31 debugger detect + L37 re-check on sensitive calls.
- Representative test: JVM smoke of `isDebuggerConnected`.
- Status: **CODE PRESENT, NOT live-tested.** No debugger has been
  attached to a protected app in this VM. `logcat` output is not
  stopped by Anti-REA — the runtime never logs plaintext, so there
  is nothing sensitive in the log to read.

## 8. Network — Wireshark, mitmproxy, Burp Suite, OWASP ZAP, Charles, Fiddler, PCAPdroid

- Counter: **NONE client-side — NOT A CLIENT CLAIM.** No APK can
  stop a proxy from seeing its own traffic. Anyone claiming an APK
  "stops mitmproxy" is wrong.
- Server-side requirement (documented, not implemented by this
  tool): TLS everywhere, certificate pinning, and server-side
  attestation (L61) so a proxied/tampered client is not trusted.
  The protected app's strings being hidden does not hide its
  network destinations from a proxy — it only hides them from
  static analysis.

## 9. Emulators / sandboxes — Android Emulator, Genymotion, Cuckoo, DroidBox, ANY.RUN, VirusTotal

- Counter: L32 emulator detect + L37 env re-check. Sandbox signals
  are findings, not a block.
- Representative test: none in this VM (no emulator here).
- Status: **CODE PRESENT, NOT tested.** No emulator run has happened.
- Honest limit: uploading an APK to VirusTotal or ANY.RUN cannot be
  stopped by any protector. What Anti-REA does is make the uploaded
  copy useless on its own: static analysis finds blobs, not secrets,
  and the server must refuse attestation from an unknown device
  (L61/L64 — L64 is PLANNED server code, not in v1.0).

## 10. Diffing — BinDiff, Diaphora, ApkDiff, JADX Diff

- Counter: L48 per-build key rotation — every `protect` run uses
  fresh random keys, so two builds of the same app have different
  blobs and different key parts. Diffing two builds tells the
  attacker what changed, not what the secrets are.
- Representative test: encrypt the same plaintext twice, compare.
- Status: **TESTED (unit-level, 2026-11-23):** same plaintext →
  different blob, different key parts, identical plaintext hash.
  No BinDiff/Diaphora run has been done — the rotation property is
  what a differ would measure, and it is verified.

## 11. On-phone modder apps — MT Manager, Apktool M, NP Manager, APK Editor, Lucky Patcher

- Counter: L101 — the protected app detects these apps on the
  device and refuses the sensitive action while one is present.
  Three signals: installed packages via PackageManager (13
  verified package names, stored as encrypted blobs only — see
  `layers/MT-LIKE-BLOCKLIST.md`), running processes, known
  working directories (`/MT2`, `/LuckyPatcher`, `/luckypatchers`,
  `Android/data/<blocked-package>`). Refuse-only: never deletes,
  never kills another app, never harms the device.
- Representative test: JVM unit test `runtime/tests/ModBlockTest.kt`
  with a fake installed set — block triggers on `bin.mt.plus` and
  `ru.maximoff.apktool`, does NOT trigger on Chrome/Gmail, empty
  set is clean, exact-match only, renamed clone not flagged.
- Status: **TESTED (JVM unit test, 2026-11-23): PASS.** No on-device
  test has run (compile-verified only, like everything in v1.0).
  Known limits: a clone with a renamed package evades the name
  check; on Android 11+ the installed-check needs host-app
  `<queries>` entries, which the CLI deliberately does NOT
  auto-inject (they would list the blocked names in plaintext in
  the manifest); GameGuardian randomises its package name and is
  NOT blocked (UNVERIFIED — recorded as a gap). False-positive
  tradeoff: a user who has MT Manager installed for lawful use is
  blocked from the sensitive action too — that is stated in the
  blocklist doc, not hidden.

## Out of scope — checked, not ignored

These appeared in the ~500-name list but are NOT APK
reverse-engineering tools. Anti-REA does not counter them, because
there is nothing to counter:

- **Build tools** (Gradle, Bazel, Maven, CMake, Ninja, Ant): they
  build apps; they do not attack them. (Gradle is used to build the
  test app's alternatives — it is not an adversary.)
- **Generic tools** (Git, Docker, Postman, Blender, FFmpeg,
  ImageMagick, jq, curl, wget, 7-Zip, Notepad++): general-purpose
  software. `curl` can download an APK; it cannot decompile one.
- **Competitor protectors** (DexGuard, Allatori, VMProtect, Themida,
  OLLVM, ProGuard/R8 as a product): they are other protectors, not
  attackers. R8's shrinking/renaming is something Anti-REA
  recommends using alongside it (L08, PLANNED as a CLI step), not
  something it fights.
- **Datasets / standards** (OWASP MASVS, MITRE ATT&CK, CVE/NVD,
  CWE): references and checklists, not tools. MASVS is a useful
  checklist Anti-REA's layers map to loosely; it is not an attack.
- **AI coding tools** (Copilot, Ollama, ChatGPT, Claude): they write
  code; they do not reverse-engineer APKs by themselves. An analyst
  can paste decompiled code into any of them — that is why the
  decompiled code must contain nothing to paste (categories 1–4).

## How to read the per-category result

| Category | Counter | Test tool | v1.0 status |
|----------|---------|-----------|-------------|
| 1 Decompilers | L01/L02/L14/L18 | JADX | TESTED, PASS v1.0 (2026-11-23) |
| 2 Disassemblers | L49 real .so + L12 + maze | Ghidra smoke (L90) | SMOKE TESTED, PASS 2026-11-23 (tiny .so, 13 functions, needle hit). NOT a needle run on a real app .so — see §2. |
| 3 APK unpackers | L06/L09/L07 | Apktool | TESTED, PASS v1.0 (2026-11-23); L06 finished in the full-layers build (res strings encrypted, JVM round-trip PASS). |
| 4 DEX tools | L01/L02/L55/L58/L59/L11 | baksmali + strings (+ dex2jar/CFR, sweep PASS) | TESTED, PASS v1.0 (2026-11-23); chunking/flattening/indirection verified on the test app in the full-layers build. |
| 5 Static scanners | no plain secrets | — | NOT RUN (APKLeaks INCONCLUSIVE, hung) |
| 6 Dynamic/hooking | L34/L35/L36/L37/L20/L38–L45/L54 | frida_smoke (static) + Env2Test/Integrity2Test (JVM) | CODE PRESENT, JVM TESTED PASS 2026-11-23; NO device test |
| 7 Debuggers | L31/L37 | JVM smoke | CODE PRESENT; NO live test |
| 8 Network | none client-side | — | NOT A CLIENT CLAIM |
| 9 Emulators/sandboxes | L32/L37 | — | CODE PRESENT; NO emulator test |
| 10 Diffing | L48 rotation | encrypt-twice check | TESTED (unit-level) |
| 11 On-phone modder apps | L101 | ModBlockTest (JVM) | TESTED, PASS 2026-11-23 (unit; no device test) |
| 12 GameGuardian / memory editors | L102 | GameGuardianFixTest (JVM) | TESTED, PASS 2026-11-23 (unit; no device test). TracerPid + stat 't' + maps markers + data dirs + obfuscated values. Root memory editing can NEVER be fully stopped client-side — server must not trust client numbers. |
| 13 Renamed / repacked APKs | L103 | GameGuardianFixTest (JVM) | TESTED, PASS 2026-11-23 (unit; no device test). Package-name match + signing-cert SHA-256 compare + encrypted expected-hash blob. |
| 14 Native strings / assets | L12/L13 | gen_native_blobs + readelf; ReaAssetsTest (JVM) | TESTED, PASS 2026-11-23 (compiled .so + libdsversion.so copy, size identical; asset round-trip incl. tamper-refuse). |
| 15 Server reference | L64–L70 | server/test_server.py (unit) | TESTED, PASS 2026-11-23 (29 tests). Reference only — no live server changed. |

The user's own reverse-engineering contact is the planned real
red-team test for v1.0 (arranged by the user, NOT done yet). When it
runs, its results go in VERIFICATION-REPORT-v1.0.md under the
categories above — per technique, not per name.

# GameGuardian + renamed-APK fix — L102 / L103

Date: 2026-11-23. Anti-REA v1.0 (standalone CLI). No GitHub push, no
Bridge change, no live-server change.

## Highlights (short version)

- **GameGuardian, in plain words:** it does NOT open your APK or read
  your code. It is a root memory editor. While your app runs, it scans
  the phone's live memory for a value (points = 100), writes a new
  value there (99999), and can dump memory to a file. Dump, run, write
  — exactly as the user described it.
- **Why it was left unverified before:** GameGuardian reinstalls itself
  with a random package name every time, on purpose, "to prevent
  detection by anti-cheats by package name" (its own FAQ). A name
  blocklist can never catch it. So L101 honestly left it unverified.
- **The fix:** catch it by what it DOES, not by what it is called.
  L102 — TracerPid (ptrace attach), `/proc/self/stat` state `t`,
  `/proc/self/maps` markers, known data folders, root + trace combined
  verdict, and obfuscated in-memory values (a points balance is never
  stored as the plain number in RAM, so a memory scan finds nothing;
  tampering returns refusal, not a wrong value). L103 — renamed /
  repacked APKs are caught by package-name match + signing-certificate
  SHA-256 compare (a repack is re-signed with the attacker's key, so
  the fingerprint WILL differ; the expected hash is stored only as an
  encrypted blob, made with `tools/make_sig_blob.py`).
- **Tests: all PASS.** JVM test, 8 sections (TEST-PASS). L101 ModBlock
  regression: TEST-PASS. Self-check: 25 files OK; 1-byte tamper in a
  copy refused, exit 2. CLI regression: test app re-protected with the
  new CLI — attack verifier VERDICT PASS (control 1/1, protected 0/0
  in strings / jadx / apktool); new classes present in the protected
  dex; apksigner verifies (v2 true).
- **Counts now:** 43 IMPLEMENTED / 2 PARTIAL / 58 PLANNED of 103
  slots (was 41/2/58 of 101).
- **Honest limit, said plainly:** root memory editing can NEVER be
  fully stopped client-side. A root attacker who watches the exact
  function that reads a hidden value can still win, and GameGuardian's
  no-root virtual-space mode is not caught by these checks. The real
  defence is the server: never trust a number the phone reports — the
  server recomputes from its own ledger (Bridge already does this).
  Everything else in this report is slowing the attacker down and
  catching the easy cases.

Full evidence follows. Nothing here is device-tested — compile-verified
and JVM-tested only. The user's reverse-engineering contact is the
planned real test.

---

## 1. What GameGuardian does (verified facts)

Sources checked 2026-11-23: `docs.gameguardian.net` (FAQ),
`gameguardian.net/forum` (author Enyby's posts). What was verified:

| Fact | Evidence |
|------|----------|
| Root memory editor — scans live RAM for a value, writes a new value, dumps memory to a file. Does NOT decompile the APK. | GG FAQ: "Searches for values, changes them, dumps memory". No APK parsing feature exists. |
| Works only through ptrace: "No other way. Only ptrace." (author) | FAQ + forum, author Enyby. Attaching via ptrace sets TracerPid in `/proc/self/status` — this is the signal L102 uses. |
| Needs root (or no-root virtual-space mode, where the target runs inside GG's sandbox) | FAQ Q9. |
| Randomises its own package name on every install: "to prevent detection by anti-cheats by package name". Base name `catch_.me_.if_.you_.can_`, daemon `bulldog-daemon`, data dirs `files/GG-xxxx` (random suffix). | FAQ Q9/15/16/17. Only the base name is a stable string — and even that is not what is installed on most phones. |

Consequence, stated plainly: **a package-name blocklist can never
catch GameGuardian.** That is why L101 left it UNVERIFIED — not an
oversight, a correct decision. The fix had to be behavioural.

## 2. What was built

### L102 — GameGuardian / runtime-memory defence

Files: `runtime/ReaTrace.kt`, `runtime/ReaMemory.kt`,
`runtime/ReaEnv.kt` (extended), `runtime/tests/GameGuardianFixTest.kt`.
Plain-words doc: `docs/GAMEGUARDIAN.md`.

| Check | How | Design decision |
|-------|-----|-----------------|
| TracerPid | Read `/proc/self/status`; `TracerPid != 0` means a process (ptrace) is attached. | Pure parser + live reader; never throws; null-safe on unreadable/malformed files. |
| Stat state | Read `/proc/self/stat`; state `'t'` = stopped/traced. | Parser handles process names containing spaces. Two signals for one fact. |
| Maps scan | Read `/proc/self/maps`; markers `gameguardian`, `libgg`, `bulldog-daemon`, `catch_.me_.if_.you_.can_`. | Bare `gg` deliberately NOT a marker — it appears in innocent words ("logged") and would false-positive on honest users. Anonymous rwx regions NOT flagged alone (normal in ART). |
| Known data dirs | Read-only `File.exists` on the two VERIFIED base paths: `/data/data/com.catch_.me_.if_.you_.can_` and `/storage/emulated/0/Android/data/com.catch_.me_.if_.you_.can_`. Randomised `GG-xxxx` dirs are NOT checked (unverifiable). | Weak signal alone (renames defeat it) — one piece of evidence among several. |
| Root + trace | ReaEnv's existing root check (`isRooted`) + any memory-editor signal = strong finding (`ReaEnv.Finding.MEMORY_EDITOR_RISK`). Root alone stays "no signal". | Rooted phones exist honestly; root is evidence, not proof. |
| Obfuscated values | `ObfuscatedLong` / `ObfuscatedInt` in `ReaMemory.kt`: value stored split (partA XOR partB) with a per-instance random salt + SHA-256 checksum; `get()` returns `null` on tamper (never a wrong value, never throws); `set()` re-splits with fresh randomness. | The plain value is never in RAM for a scan to find. Plain value exists briefly in a local during `get()`/`set()` — a root attacker watching the decrypt function can still win. Server validation is the real defence. |
| Server rule | Docs only, no server code changed: client-reported values (points, balance, usage) must NEVER be trusted; the server recomputes from its own ledger. Bridge already does this (ledger-based balances) — cited as the example. | Client checks slow the attacker; the server makes the cheating useless. |

All findings flow into `ReaEnv.checkAll()` (now 10 findings), so
`ReaGuardProvider` reports them automatically — no provider change
was needed. Refuse-only: every check returns a finding; nothing
deletes, kills, or harms; nothing executes `su`; checks never throw.

### L103 — Renamed / repacked APK defence

Files: `runtime/ReaRepack.kt`, `tools/make_sig_blob.py`.

| Check | How | Design decision |
|-------|-----|-----------------|
| Package name | Compare `context.packageName` with the expected package from config; mismatch = refuse. | Exact match; checked at startup and before sensitive actions. |
| Signature | Compare the running APK's signing-certificate SHA-256 with the expected hash. A repacked APK is re-signed with the attacker's key, so the hash WILL differ. | Hex-to-hex compare (`verifySigningCertHex`). One real bug was caught during this work: the first draft hashed the fingerprint a second time, which could never match — fixed before shipping, covered by the test. |
| Expected-hash storage | `tools/make_sig_blob.py` encrypts the expected SHA-256 (same REA-IR blob format as `crypto.py`) from the developer's own release certificate. | Never shipped as a plain string. `make_sig_blob.py --self-test` OK; a non-64-hex input is rejected, exit 2. |
| Installer | Record the installer package (Play vs third-party vs sideload/unknown). | Signal only — never a refusal alone, because honest users sideload apps. |

Limits: only the first certificate is checked on multi-signer APKs;
CLI auto-injection of the expected-hash blob is PLANNED (today the
developer makes the blob with the tool).

## 3. Tests — all PASS

### 3.1 JVM test — GameGuardianFixTest.kt — TEST-PASS (exit 0)

Exact command (big-tmp wrapper, never `/tmp`):
```
bash /home/hatch/tmp/_config/run-with-big-tmp.sh --job-name antirea-ggfix-jvm --kind general -- bash -c \
  'export JAVA_HOME=$HOME/workspace/tools/jdk17; export PATH=$JAVA_HOME/bin:$PATH; \
   cd $HOME/workspace/anti-rea/v1.0/runtime && \
   $HOME/workspace/tools/kotlin-2.0.21/bin/kotlinc -cp $HOME/workspace/tools/android-sdk/platforms/android-36/android.jar \
     -d tests/ggfix-test.jar ReaRuntime.kt ReaIntegrity.kt ReaTrace.kt ReaEnv.kt ReaMemory.kt ReaRepack.kt \
     tests/GameGuardianFixTest.kt && \
   java -cp tests/ggfix-test.jar:$HOME/workspace/tools/kotlin-2.0.21/lib/kotlin-stdlib.jar \
     com.antirea.runtime.GameGuardianFixTestKt'
```

| Section | What it covers | Result |
|---------|----------------|--------|
| TRACERPID | parse: `0`, `1234`, missing, malformed → correct values, no throw | PASS |
| STAT | parse: `S`, `t` (comm with spaces), `R`, garbage → correct, no throw | PASS |
| TRACED | traced logic: pid + state, null-safe | PASS |
| MAPS | clean maps 0; GG markers found; bare `gg` NOT a marker | PASS |
| DIRS | base path found when present, clean when absent | PASS |
| MEMORY | Long/Int round-trip; 1 flipped stored part → `get()` returns null; `set()` recovers | PASS |
| REPACK | package mismatch → refuse; cert-hash match/mismatch; blob decrypt + tamper refuse; installer classes | PASS |
| RISK | clean → none; root alone → none; traced/maps/files → high; root combo noted in message | PASS |

Exact output (exit 0):
```
TRACERPID-OK: 0 / 1234 / missing / malformed
STAT-OK: S / t (spaces in comm) / R / garbage
TRACED-OK: pid + state + null-safe
MAPS-OK: clean 0, GG markers found, bare 'gg' not a marker
DIRS-OK: base path found when present, clean when absent
MEMORY-OK: Long/Int round-trip, tamper refuses (null), set() recovers
REPACK-OK: package / cert hash / blob / installer
RISK-OK: clean none, root alone none, traced/maps/files high, root combo noted
TEST-PASS
```

Two problems were found and fixed during this work: (1) a compile
error — `return` inside an expression body in `ReaTrace.readTracerPid`;
(2) a real logic bug — the first `checkRepack` draft hashed the
certificate fingerprint a second time, which could never match —
fixed to hex-to-hex compare and covered by the test.

### 3.2 Regression — ModBlockTest (L101) — TEST-PASS

Re-run after the `ReaEnv` edit (first attempt failed only because
android.jar was missing from the *java* classpath — a command
mistake, not a code regression; re-run with android.jar on the java
classpath):
```
DECRYPT-OK: 13 entries, incl. bin.mt.plus / ru.maximoff.apktool / com.chelpus.lackypatch
BLOCK-OK: listed flagged, Chrome/Gmail not flagged
EDGE-OK: empty set clean, exact-match only
CLONE-LIMIT-OK: bin.mt.plus.clone NOT flagged (known L101 limit, see blocklist doc)
TEST-PASS
```

### 3.3 Self-protection — self-check + tamper — PASS

- Manifest regenerated: `anti-rea.manifest.json`, **25 files**
  (was 20; + `runtime/ReaTrace.kt`, `ReaMemory.kt`, `ReaRepack.kt`,
  `tools/make_sig_blob.py`, `docs/GAMEGUARDIAN.md`).
  Manifest sha256 `7ca67bfd8e0e9976eb77d5cb1749bfe58eb701beceaf205415009a55d0fb07ca`
  (was `3333bcb6…`).
- `python3 anti-rea.py self-check` → `SELF-CHECK OK: 25 files
  verified against anti-rea.manifest.json` (exit 0).
- Tamper test on a COPY (1 byte flipped in `runtime/ReaTrace.kt`):
  self-check refused with exit 2, naming the file
  (`hash mismatch (tampered?): runtime/ReaTrace.kt`); `layers
  --list` also refused (exit 2). The real tree still passes (exit 0).
- `python3 anti-rea.py layers --list` on the updated registry:
  `total=103 {'IMPLEMENTED': 43, 'PARTIAL': 2, 'PLANNED': 58}`.

### 3.4 CLI regression — re-protect test app — VERDICT PASS

The generic test app was re-protected with the new CLI:
`tests/testapp/testapp-protected-ggfix.apk`, 594,542 bytes, sha256
`c3c7924ce975a34074cdc5a5781fddc90f00c2de96c8baa398c9a8ee6d531f37`
(control `d1708e7e…`, 614,877 B). Attack verifier result:

| Tool / needle | Control | Protected |
|---------------|---------|-----------|
| strings — `TEST-SECRET-7f3a9-generic` | 1 | 0 |
| strings — `https://testapp.example.invalid/api` | 1 | 0 |
| jadx — both needles | 1 | 0 |
| apktool — both needles | 2 | 0 |

**VERDICT: PASS** — protected is 0 for every needle in every tool.
New classes confirmed in the protected dex: `ReaTrace` (3),
`ReaMemory` (4), `ReaRepack` (4), `ObfuscatedLong` (2), plus
`ReaModBlock` (9), `ReaGuardProvider` (10). apksigner verifies
(v1 false, v2 true). (Note: the CLI still reported `layers=41` in
the protect output — the count comes from the registry, which was
updated after the protect run; the runtime itself already shipped
the new layers, as the dex check proves.)

## 4. Files changed / created

| Path | What | sha256 (short) |
|------|------|----------------|
| `runtime/ReaTrace.kt` | NEW — L102 behaviour detection | `df92ed71…` |
| `runtime/ReaMemory.kt` | NEW — L102 obfuscated values | `6643ccc5…` |
| `runtime/ReaRepack.kt` | NEW — L103 repack defence | `ffc8bc65…` |
| `runtime/ReaEnv.kt` | EXTENDED — L102 findings in `checkAll()` (now 10 findings) | `b3a0d19a…` |
| `runtime/tests/GameGuardianFixTest.kt` | NEW — 8-section JVM test | `fb249b39…` |
| `runtime/build_smali.sh` | UPDATED — 11 sources | `9ffc8c01…` |
| `runtime/build/runtime.jar` | REBUILT — 52K | `49fbbbf9…` |
| `runtime/build/classes.dex` | REBUILT — 56K | `f2df8181…` |
| `runtime/smali/com/antirea/runtime/*.smali` | REBUILT — 26 files (was 19) | — |
| `tools/make_sig_blob.py` | NEW — encrypted expected-hash blob maker | `05a4bbbb…` |
| `docs/GAMEGUARDIAN.md` | NEW — plain-words doc, kind tone | `db6abcd3…` |
| `layers/REGISTRY.md` | UPDATED — L102 + L103 IMPLEMENTED; 43/2/58 of 103 | — |
| `TOOL-COVERAGE.md` | UPDATED — rows 12 (GameGuardian) + 13 (repack) | — |
| `docs/SELF-PROTECTION.md` | UPDATED — 25 files, new manifest hash | — |
| `runtime/NOTES.md` | UPDATED — new files, JVM test + smali rebuild sections | — |
| `PUSH-CHECKLIST.md` | UPDATED — 43 layers, new files listed | — |
| `anti-rea.manifest.json` | REGENERATED — 25 files | `3dc47103…` |
| `tests/testapp/testapp-protected-ggfix.apk` | NEW — re-protected test app (TEST keystore) | `c3c7924c…` |
| `GAMEGUARDIAN-FIX-REPORT.md` | NEW — this report | — |

Note: the GameGuardian detection strings (`gameguardian`,
`libgg`, `bulldog-daemon`) appear in plaintext in the runtime
smali BY DESIGN — they are public detection needles (the same as
`frida-agent` already was), not secrets. No plaintext blocklist
package names appear in the runtime.

## 5. Honest limits (read this)

- **Root memory editing can never be fully stopped client-side.**
  A root attacker with time and patience who watches the exact
  function that reads a hidden value can still win. These layers
  make it slow, noisy, and likely to trip a check — they do not make
  it impossible. The server rule (never trust client-reported
  numbers) is what makes the win useless.
- **Virtual-space GameGuardian (no-root mode) is NOT caught.**
  The app runs inside GameGuardian's virtual environment, so the
  tracer and maps checks see the virtual world, not the real one.
  Only server-side validation catches this mode.
- **Renamed clones of the tools** escape every name check — that is
  exactly why L102 checks behaviour instead of names.
- **TracerPid only fires while attached.** GameGuardian detaches
  between searches, so the check must run before every sensitive
  action, not once at startup.
- **False positives exist.** A tracer check can fire on a phone
  being debugged for honest reasons; a rooted phone is not proof of
  cheating. Every check returns a finding and refuses ONE sensitive
  action — never deletes, never kills, never blocks the app from
  opening.
- **No device test.** Everything here is compile-verified and
  JVM-tested only. No phone test has happened. The user's
  reverse-engineering contact is the planned real test.
- **The expected signature hash is a blob, not a guarantee.** If an
  attacker extracts the blob and the decryption code, they can read
  the expected hash — but they still cannot forge the developer's
  private key, so the re-sign check holds.

## 6. What is still NOT done (next steps)

- Device test of L102/L103 (needs a phone; never done in this VM).
- RE-tester red-team test on v1.0 (user's contact, tester pack
  `tester-pack.zip` — the pack contains the older protected APKs;
  re-generate it with `testapp-protected-ggfix.apk` before sending,
  or note the new build in the brief).
- GitHub push of v1.0 — still held at the user's order (tester
  first). This fix is included in the push list.
- CLI auto-injection of the expected-hash blob (PLANNED) and
  multi-signer support for L103 (PLANNED).
- Bridge protection — LATER, after the push (user order).

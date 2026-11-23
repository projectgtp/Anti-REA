# Anti-REA v1.0 — Test Harness + Verifier

Generic test harness for the standalone Anti-REA v1.0 protector.
**No Bridge code anywhere here.** The test app is a tiny invented app;
the verifier scripts work on any two APKs (control vs protected).

Test strings are INVENTED fakes, not real secrets:

- Secret: `TEST-SECRET-7f3a9-generic`
- Endpoint: `https://testapp.example.invalid/api` (`.invalid` can never resolve)

## Contents

| Path | What it is |
|---|---|
| `tests/testapp/` | Tiny generic Android test app (proves universality) |
| `tests/testapp/testapp-control.apk` | Built control APK (unprotected) |
| `tests/build_testapp.sh` | Gradle-free build script (aapt2 + kotlinc + d8 + zipalign + apksigner) |
| `verifier/attack.py` | jadx + apktool + strings-on-dex attack comparator, JSON report |
| `verifier/tamper.py` | 1-byte dex flip + dex checksum fix, repackages unsigned |
| `verifier/frida_smoke.py` | Static Frida/env-check presence smoke test (no device) |
| `tests/attack-selftest-report.json` | Self-test report (control vs itself — FAIL, as designed) |
| `tests/frida-smoke-control.json` | Frida smoke report on the control APK |

## 1. Build the test app

```bash
bash /home/hatch/tmp/_config/run-with-big-tmp.sh \
  --job-name antirea-v10-testapp --kind general -- \
  bash tests/build_testapp.sh
```

- Chain: aapt2 compile/link → kotlinc (Kotlin stdlib only) → jar → d8 →
  zipalign → apksigner. Gradle is not used (known-broken in this VM).
- Signing: a FRESH ephemeral test keystore generated in the job dir
  (`CN=Anti-REA Test`). Never the Bridge stable key, never any
  production key. The APK will NOT install over any other app.
- Never uses `/tmp` (512 MB tmpfs); heavy work goes through
  `run-with-big-tmp.sh` with `JOBDIR` under `/home/hatch/tmp/`.
- Output: `tests/testapp/testapp-control.apk`

Result (2026-11-23): **BUILD_OK**

```
apksigner verify: Verifies (v2 true, v3 true, 1 signer)
aapt dump badging: package name='com.antirea.testapp',
  minSdkVersion:'26', targetSdkVersion:'34',
  launchable-activity: com.antirea.testapp.MainActivity
testapp-control.apk: 614,877 bytes
sha256: d1708e7e8f902a939b4afe6b698a126c8420c6f9f30d9bd580859b31f036fcf8
```

The app: one `MainActivity` (`com.antirea.testapp`), one secret string
constant, one fake endpoint, one key method `getSecret()` returning the
secret. Minimal `AndroidManifest.xml` (package `com.antirea.testapp`,
minSdk 26, targetSdk 34, one MainActivity), minimal `res/` (strings.xml,
one layout). No dependencies beyond Kotlin stdlib + android.jar.

## 2. Run the attack verifier

```bash
# Heavy (jadx + apktool) — run through the wrapper:
bash /home/hatch/tmp/_config/run-with-big-tmp.sh \
  --job-name antirea-v10-attack --kind general -- \
  python3 verifier/attack.py \
    --control tests/testapp/testapp-control.apk \
    --protected <protected-apk> \
    --needles TEST-SECRET-7f3a9-generic,testapp.example.invalid \
    --out tests/attack-report.json

# Needles from a file instead (one literal needle per line):
python3 verifier/attack.py --control <control.apk> --protected <protected.apk> \
  --needles-file needles.txt --out attack-report.json
```

What it does, per tool, per needle (all counts are **literal**,
`grep -F` semantics — never regex):

1. `strings` on the **extracted** `classes.dex` (never on the raw APK).
2. `jadx` decompiled sources.
3. `apktool` decode (smali + resources).

It prints per-tool counts and writes a JSON report:

```json
{ "control":   { "strings_dex": { "<needle>": <n> }, "jadx": {...}, "apktool": {...} },
  "protected": { "strings_dex": { "<needle>": <n> }, "jadx": {...}, "apktool": {...} },
  "verdict": "PASS" | "FAIL", "reason": "..." }
```

### What PASS means

**PASS iff for EVERY needle and EVERY tool: control count > 0 AND
protected count == 0.** Exit code 0.

**FAIL otherwise** (exit code 1), including:

- protected count > 0 for any needle/tool (secret still visible), or
- control count == 0 for any needle/tool — a **vacuous test**: a test
  that finds nothing in the control proves nothing, so it can never PASS.
- any tool error (jadx produced no sources, apktool produced no output,
  dex missing). Missing jadx/apktool/`strings` exits non-zero with a
  clear message instead of faking a PASS.

Note: because attack.py exits 1 on FAIL, `run-with-big-tmp.sh` records
that wrapper job as failed and moves its temp dir to `failed/` — that
is the wrapper's bookkeeping, not a verifier failure; the JSON report
is still written to `--out`.

### Methodology bugs from v0.1/v0.2 — NOT repeated here

1. v0.1: jadx run without `JAVA_HOME` → exit 1, counts 0/0, looked like
   a pass. Fixed: `attack.py` always sets `JAVA_HOME=~/workspace/tools/jdk17`.
2. v0.1: `strings` on the raw `.jar`/APK → 0 even in the control, because
   entries are DEFLATED. Fixed: dex is extracted from the zip first and
   `strings` runs on the extracted `classes.dex`.
3. v0.2: regex grep made `tunnel.key.` match ordinary prose
   ("Seller tunnel key registered...") and reported protected=2.
   Fixed: all counting is literal substring matching, never regex.
4. v0.1/v0.2: jadx exits 1 on kotlin-stdlib decompile errors even on a
   good run. Fixed: a non-zero jadx exit is tolerated **only if** the
   sources directory was produced; no sources = tool error = FAIL.

## 3. Run the tamper tool

```bash
python3 verifier/tamper.py --apk <protected-apk> \
  --blob-b64 <first-12-chars-of-blob> --out <tampered-apk>
```

- Flips ONE byte in `classes.dex` at the blob location (first byte of
  the blob prefix: `B` if it isn't `B`, else `u` — same as v0.2).
- Fixes the dex header checksums (SHA-1 signature first, then Adler-32 —
  same technique as v0.2 `tests/apk_tamper_fix_checksum.py`; a raw flip
  breaks the dex so jadx refuses it and Android would reject it).
- Repackages **unsigned**. Does NOT sign — signing is the caller's job.
- Prints the dex offset flipped, the byte changed, and the new APK sha256.
- Exits non-zero if the blob prefix is not found in `classes.dex`.

This proves the *repackage* step only. Whether the protected app
*refuses at runtime* needs a device/emulator — this VM has none, so
that is NOT claimed here.

## 4. Run the Frida smoke check

```bash
python3 verifier/frida_smoke.py --apk <protected-apk> [--out report.json]
```

- (a) Lists whether the dex contains the Frida-detection markers
  `frida-agent`, `frida-gadget`, `27042`.
- (b) Reports which env-check method names are present in the dex
  (`isDebuggerConnected`, `isEmulator`, `fridaMapsDetected`, etc.)
  via `dexdump` (falls back to `strings`).
- (c) States plainly in its output that this is a **STATIC presence
  check only and does NOT prove Frida is stopped at runtime**.

Exit 0 means the check ran and reported; it does not pass/fail the APK.
A method name can be present without being called, and a check can exist
under a different name — presence alone means nothing about runtime
behaviour. (On the control APK, `isRooted` shows present=True — a stray
library reference, not a real check — which is exactly why presence is
only reported, never claimed as protection.)

## 5. Self-test results (2026-11-23)

### attack.py — control vs itself: FAIL, as designed

Command:

```bash
bash /home/hatch/tmp/_config/run-with-big-tmp.sh \
  --job-name antirea-v10-attack-selftest --kind general -- \
  python3 verifier/attack.py \
    --control tests/testapp/testapp-control.apk \
    --protected tests/testapp/testapp-control.apk \
    --needles TEST-SECRET-7f3a9-generic,testapp.example.invalid \
    --out tests/attack-selftest-report.json
```

Output (report: `tests/attack-selftest-report.json`):

```
strings_dex [TEST-SECRET-7f3a9-generic]: control=1 protected=1
strings_dex [testapp.example.invalid]:   control=1 protected=1
jadx [TEST-SECRET-7f3a9-generic]:        control=1 protected=1
jadx [testapp.example.invalid]:          control=1 protected=1
apktool [TEST-SECRET-7f3a9-generic]:     control=2 protected=2
apktool [testapp.example.invalid]:       control=2 protected=2
VERDICT: FAIL
REASON: strings_dex [TEST-SECRET-7f3a9-generic]: protected=1 (must be 0); ...
```

The comparator works: identical APKs are correctly FAIL, and the
control counts (>0 everywhere) prove the test is not vacuous — the
needles really are findable in the unprotected APK by all three tools.

### attack.py — control vs protected: NOT RUN — no protected APK exists yet

At the time of this self-test, no protected test-app APK had been
produced (the CLI worker builds it). No protected APK was invented.
Re-run §2 with the real protected APK once the CLI delivers it; a PASS
there requires protected=0 for both needles across all three tools.

### tamper.py — mechanical run on the control APK: OK

Command (flipping the first 12 chars of the plain secret string, as a
mechanical exercise — the control has no blob; the same code path flips
a real blob prefix on a protected APK):

```bash
python3 verifier/tamper.py --apk tests/testapp/testapp-control.apk \
  --blob-b64 TEST-SECRET- --out tests/testapp-tampered-demo.apk
```

Output:

```
dex offset flipped: 1599553
byte flipped: 'T' -> 'B' (blob prefix 'TEST-SECRET-')
dex checksums fixed: adler32=0x91db8127 (SHA-1 signature recomputed first)
output (UNSIGNED, not signed): tests/testapp-tampered-demo.apk
new sha256: 0b0651ab0e83df6ed4416a56fa9e4bd7b14eda6026a097da95a89b298a55f11c
output bytes: 608785
```

Verified afterwards: original prefix absent from the tampered dex,
flipped prefix (`BEST-SECRET-`) present, stored Adler-32 matches the
recomputed value, SHA-1 signature matches. The demo tampered APK was
deleted after verification (sha256 above is its record).

### frida_smoke.py — on the control APK: OK

```bash
python3 verifier/frida_smoke.py --apk tests/testapp/testapp-control.apk \
  --out tests/frida-smoke-control.json
```

Markers `frida-agent` / `frida-gadget` / `27042`: all absent (0).
Env-check methods: all absent except a stray `isRooted=True` (library
reference — see §4). Output states the static-only limit. Report:
`tests/frida-smoke-control.json`.

## 6. Honest limits

- Static checks only. Nothing here proves the protected app runs,
  refuses tampering, or stops Frida at runtime — that needs a device
  or emulator, which this VM does not have.
- `attack.py` PASS means the needles are absent from jadx/apktool/dex
  strings. It does not mean no other leak exists (resources, native
  libs, other dex files are not swept beyond apktool's full-tree scan).
- The test app was compile-verified and `apksigner`-verified only;
  it was never installed or launched on a phone.
- No real secrets are used anywhere in this harness; the only strings
  are the invented test values above.

## File hashes (2026-11-23)

```
8dc73d0285a0b9d612b87ce3b12813e81e5dbcf003429d1d29b90815c6369525  tests/testapp/AndroidManifest.xml
84bda34e0113d8c0b00c5eebc5ae6419ce73bb2da29bf4b96ff692a5316fb61c  tests/testapp/res/values/strings.xml
0768744c9947924444007b21659d1008a801a1e87fb047f2bb863fa6d71f66ba  tests/testapp/res/layout/activity_main.xml
14fd56ff37dcc3761c14b281bcba0972ff78ff29b9c092ffce80957f6698bfc1  tests/testapp/src/main/java/com/antirea/testapp/MainActivity.kt
f81b1992c308f1e51187f681cbefb4733ea1ff14002296664ae038b60db11ffe  tests/build_testapp.sh
2a61ec36c12415ef66a630812caefe2fd7c7a0251a7babe6371ddf6987e5b2a4  verifier/attack.py
cd28ca0897fd847b441e397f5162a8e50643f5d3e55336fb32ef0b1f9edcf258  verifier/tamper.py
5790bf4d021139f6ae8abab76770819191aa44751a14b61ca12bca22e701b6e0  verifier/frida_smoke.py
d1708e7e8f902a939b4afe6b698a126c8420c6f9f30d9bd580859b31f036fcf8  tests/testapp/testapp-control.apk (614,877 bytes)
```

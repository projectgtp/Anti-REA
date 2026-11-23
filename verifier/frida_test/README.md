# Anti-REA v1.0 — L89 Frida Runtime Test (on device)

**Status: HARNESS READY, LIVE DEVICE RUN PENDING.** Everything below is
ready to run. No live Frida run has happened yet — this VM has no
phone, no emulator and no Frida — so nothing here claims a live result.
The `--dry-run` mode proves the harness and its classifier work; the
live run is yours, on a test phone.

## What this test proves (and what it does not)

Frida is the tool a real attacker uses at runtime: attach to a running
app, hook a method, read live memory, strip TLS pinning. Static tools
(jadx, strings, Ghidra) can never prove those defences hold — only a
phone with Frida attached can. This harness runs five checks (F1–F5)
against a protected APK on a real phone and classifies each one:

| Check | Attacker move | PASS means | BREAK means |
|---|---|---|---|
| F1 attach | Frida agent attaches to the running app | App detects Frida (L34/L35) and refuses the sensitive action, or exits | Agent stays attached, app runs normally, `ReaEnv.checkAll()` reports nothing |
| F2 gadget | Repack APK with `frida-gadget`, re-sign, install | App refuses the repacked build (signature/integrity, L16/L103) | Gadget loads and the app runs normally |
| F3 hook | Hook `ReaRuntime.decrypt` / `verifyIntegrity` | Hook never fires, or the anti-hook re-check (L54) refuses anyway | Hook fires and returns a plaintext the app accepts, or a forced `verifyIntegrity()==true` lets a tampered blob through |
| F4 memread | Scan RAM for the test secret / Bridge URL | Scan finds nothing (value obfuscated, L102) | Plaintext bytes found in live memory |
| F5 ssl-unpin | Hook the TLS trust path, MITM proxy with a custom CA | Pinning holds / connection refused, no traffic through the proxy | App traffic flows through the proxy |

A BREAK in any check is a real finding — report it with the evidence
line. A PASS in all five is the runtime proof the static tests cannot
give. INCONCLUSIVE means the tooling failed or the app never did the
thing being tested (e.g. no network call during F5) — re-run, do not
call it a PASS.

**Honest limit, read this first:** even five PASSes do not prove the
app is unbreakable. A skilled attacker with root and patience can
still win in the end; the server must never trust client-reported
numbers. What five PASSes prove is that Frida attach / hook / memory
read / unpinning did not work *in this run, with these tools*.

## Files

- `frida_test.py` — the harness (Python stdlib only). Classifies
  Frida output, runs `--dry-run`, runs the live attach, writes a JSON
  report.
- `frida_script.js` — the Frida agent that runs inside the app on the
  phone. Plain-words comments throughout. It logs plaintext as first
  8 characters + length only — never a full secret.
- This README.
- `../tests/test_frida_harness.py` — unit tests for the harness
  (run them on any PC, no device needed).

## Step 0 — Check the harness works (5 min, no phone)

On any PC with Python 3.10+:

```bash
cd anti-rea/v1.0/verifier/frida_test
python3 frida_test.py --list-checks        # shows F1–F5 + expectations
python3 frida_test.py --dry-run            # canned output, must print OK
python3 ../tests/test_frida_harness.py     # unit tests, must print OK
```

If `--dry-run` does not print `dry-run classifier: OK`, stop — the
harness itself is broken, and a live run would be meaningless.

## Step 1 — What you need

**On the PC:** Python 3.10+, `adb` (Android platform-tools),
`frida-tools`:

```bash
pip install frida-tools        # gives the `frida` command
frida --version                # note the version for your report
adb --version
```

**On the test phone:** Android 8.0+, a test phone or emulator you
can wipe afterwards — **not your daily phone, not a phone with real
accounts on it.** The phone must be rooted (for F1/F3/F4/F5 attach
mode) **or** you use gadget mode (F2) which needs no root but needs
a repack. The protected APKs use a test keystore and will NOT install
over the real Bridge app.

**frida-server on the phone** — version MUST match `frida-tools`
exactly (same major.minor, e.g. tools 16.x needs server 16.x).
Download the right build for the phone's CPU from
https://github.com/frida/frida/releases (usually
`frida-server-*-android-arm64.xz`):

```bash
# on the PC — replace 16.5.0 with the version `frida --version` shows
adb push frida-server-16.5.0-android-arm64 /data/local/tmp/frida-server
adb shell "chmod 755 /data/local/tmp/frida-server"
adb shell "/data/local/tmp/frida-server &"     # keep this shell open
adb shell "ps -A | grep frida"                 # must show frida-server
```

Time: ~15 min first time, ~2 min once set up.

## Step 2 — Install the protected APK (~2 min)

```bash
adb install -r tester-pack/testapp-protected.apk     # test app first
# or: adb install -r tester-pack/bridge-2.14.0-v10-protected.apk
adb shell monkey -p com.antirea.testapp -c android.intent.category.LAUNCHER 1
```

Use the test app first. It is small, its secret is a fake test value,
and a BREAK there is cheap to understand. Run Bridge second.

**Before the Frida run, set the needle:** `frida_script.js` scans
memory for a string. For the test app it is already set to
`TEST-SECRET-7f3a9-generic`. For Bridge, edit the line
`var NEEDLE = NEEDLE_TESTAPP;` to `var NEEDLE = NEEDLE_BRIDGE;`
(the public URL `mbbridge.onrender.com`).

## Step 3 — Run the live checks (~10 min)

From this folder, one command runs F1 + F3 + F4 + F5 together
(the agent does all four once attached):

```bash
# Test app:
python3 frida_test.py --package com.antirea.testapp --timeout 120 \
    --out l89-testapp-report.json

# Bridge (after editing NEEDLE, see Step 2):
python3 frida_test.py --package com.bridge.mvp --timeout 120 \
    --out l89-bridge-report.json
```

What happens: the harness checks `adb devices`, then runs
`frida -U -f <package> -l frida_script.js --no-pause` for up to
120 seconds. While it runs, **use the app**: on the test app, open
the screen that shows the secret; on Bridge, log in and open the
Market (that is what triggers decrypt / network calls — a hook that
never fires because the app never called decrypt is INCONCLUSIVE,
not a PASS). Then wait for the run to finish and read the table it
prints: one line per check, PASS / BREAK / INCONCLUSIVE / ERROR.

**F2 gadget is separate** (~15 min) — it is a repack, done before
launch, not an attach:

```bash
# 1. Get frida-gadget for the phone arch, same version as frida-tools.
# 2. Unzip the APK, add lib/<arch>/libfrida-gadget.so, patch the
#    config (frida-gadget.config.so / .config) to load on start.
#    (Objection automates this: objection patchapk --source <apk> ...)
# 3. Re-sign with a test key (apksigner / jarsigner), install, launch.
# 4. Watch: does the app run normally (GADGET_LOADED = BREAK) or
#    refuse/exit (GADGET_BLOCKED / APP_REFUSED = PASS)?
# 5. Save the gadget output and classify it:
python3 frida_test.py --from-file gadget-transcript.txt --check F2 \
    --out l89-gadget-report.json
```

If you already have a Frida transcript from a manual run, classify it
without re-running anything:

```bash
python3 frida_test.py --from-file transcript.txt --out report.json
python3 frida_test.py --from-file transcript.txt --check F3   # one check only
```

## Step 4 — What to record (copy this template)

```
Phone / emulator:
Android version:
Rooted: yes / no (gadget mode if no)
frida-tools version:        frida-server version:
APK: testapp-protected / bridge-2.14.0-v10-protected
Time spent:
---
F1 attach:    PASS / BREAK / INCONCLUSIVE — evidence line:
F2 gadget:    PASS / BREAK / INCONCLUSIVE — evidence line:
F3 hook:      PASS / BREAK / INCONCLUSIVE — evidence line:
F4 memread:   PASS / BREAK / INCONCLUSIVE — evidence line:
F5 ssl-unpin: PASS / BREAK / INCONCLUSIVE — evidence line:
---
Notes (what you tapped in the app, anything odd, logcat lines):
```

Attach the JSON report(s) (`--out` files). For a BREAK, also attach
the raw transcript lines showing it — a BREAK without evidence is
not usable.

## What counts as a break

- Any check classified BREAK, with its evidence line.
- A tampered/repacked APK that runs and does the protected action
  (test app: shows the secret; Bridge: reaches the server / settles).
- A bypass of any integrity / debugger / emulator / Frida check —
  name the check, how, and proof it no longer blocks you.
- A real secret (not a planted decoy) recovered from anywhere.
  Finding a planted decoy is useful data, not a break — but report
  it and say how you found it.

## Rules

- Test phone/emulator only. Do NOT attack the live Bridge server:
  no login with a tampered app, no real user data, no backend abuse.
- Do NOT share the APKs further. Delete them when asked.
- Be honest: if you fail, say you failed and what you tried. A
  failed attack is a PASS for us.

## Troubleshooting

| Symptom | Likely cause / fix |
|---|---|
| `no adb device connected` | Cable / USB debugging off, or `adb devices` shows `unauthorized` — accept the prompt on the phone |
| `frida-server` version mismatch | `frida --version` and the server version must match; re-download the matching server |
| Agent attaches, then `APP_EXITED` at once | Could be the app refusing (PASS for F1) or a crash — check `adb logcat` and say which one it was |
| `HOOK_IDLE` / all INCONCLUSIVE | The app never called decrypt or made a network call while you watched — use the app (open the secret screen / Market) and re-run |
| `MEMSCAN_ERROR` | App exited before the 5 s scan delay, or ranges unreadable — re-run and keep the app in the foreground |
| `SSL_IDLE` | No network call during the run — trigger one (Bridge login / Market) and re-run; also check the proxy is actually intercepting |
| `ERROR: frida CLI not found` | `pip install frida-tools`, then re-run Step 0 |

# Anti-REA v1.0 — Red-Team Test Brief (for the RE tester)

You get 2 protected APKs only. No source code, no keys, no config, no report.
Test them like a real attacker. No help from us during the test.

## Files in this pack

1. `bridge-2.14.0-audit-protected.apk` — Bridge 2.14.0, protected by Anti-REA v1.0 (audit build, 97 implemented layers)
   - Size 4,869,130 bytes, SHA-256 `d4f99d524d2a29a788422d459218e2b67638691e895b7ba4bb923ca15a87fd44`
2. `testapp-audit-protected.apk` — tiny generic test app, protected by Anti-REA v1.0 (audit build, 97 implemented layers)
   - Size 775,164 bytes, SHA-256 `0b5e82c61c58dde682ab497b3888d7d020ff275a06162eede61b52ef302f68dc`
3. This brief. Nothing else.

Both APKs use a test keystore. They will NOT install over the real Bridge app.
Install on a test phone/emulator only if you want to run them. Static test alone is fine.

## New in this build (since the first pack)

- **Audit build:** decoy files now have realistic names (config.json, crash-report.txt, error-log.txt, stacktrace.txt, libconfig.so) instead of fake-* names; listing a full URL now also hides its bare host and scheme variants.
- **Mod-app block:** the app refuses its secret action while an APK-editor app is present (MT Manager, Apktool M, NP Manager, APK Editor, Lucky Patcher, and 8 more). Try installing one of those and running the app.
- **GameGuardian / memory editing:** the app detects tracing, watches its own memory, and hides numbers in RAM instead of storing them plain. Try GameGuardian (root) — scan for a value, change it, see if the app notices or if the changed value does anything.
- **Rename / repack:** the app checks its own package name and signing certificate. Try renaming the package or re-signing the APK and running it.
- **Self-changing code (ON by default):** some code arrives encrypted and changes between runs. Try to find the decrypted code in memory.
- **Frida:** try to attach Frida, hook a method, read memory, and unpin SSL. Any hook that works is a break — show the proof.

## Your targets — recover these, exactly

Test app (fake test values, not real secrets):
- `TEST-SECRET-7f3a9-generic`
- `https://testapp.example.invalid/api`

Bridge (public URLs, the point is whether you can find them in the APK):
- `https://mbbridge.onrender.com`
- `http://10.0.2.2:8000`
- `https://api.bridge.example`
- `api.bridge.example`
- `bridge-marketplace.onrender.com`
- `tunnel.key.`

## What counts as a BREAK (report each one)

1. You recover any target above in full, and you show WHERE you found it (tool + file + line/offset + screenshot or output).
2. You make a tampered/modified APK run and do the protected action (for Bridge: reach the server / settle; for test app: show the secret on screen) — show the steps.
3. You bypass an integrity / debugger / emulator / Frida check — show which check, how, and proof it no longer blocks you.
4. You find a real secret that is NOT in the target list — show it and where it came from.
5. You change a value in memory with GameGuardian (or any memory editor) and the app accepts the changed value — show the value before/after and what the app did with it.
6. You run the app with MT Manager (or a similar APK editor) installed, or with a renamed/re-signed APK, and the app still does the protected action — show how.

## Traps — read this

Fake decoy secrets and fake endpoints are planted in these APKs on purpose.
If you report one as a real find, say exactly how you found it. Finding a decoy is
useful data for us, not a break — but do NOT hide it. A break is only a REAL
target above, or a working tampered app.

## Rules

- Use any tool you want: JADX, Apktool, Ghidra, IDA, Frida, Objection, MobSF, anything.
- No time limit from us. Record how long you spent and which tools you used.
- Do NOT attack any live server. Testing the APK files is fine. Do not log in to
  the real Bridge server with a tampered app, do not try to steal real user data,
  do not try to break the live backend.
- Do NOT share these APKs further. Delete them when the test is done if we ask.
- Be honest: if you fail, say you failed and what you tried. A failed attack
  is a PASS for us and we will say so.

## Report back (copy this template)

```
Tools used:
Time spent:
Target 1 (testapp secret): FOUND / NOT FOUND — where + proof:
Target 2 (testapp endpoint): FOUND / NOT FOUND — where + proof:
Bridge targets (each): FOUND / NOT FOUND — where + proof:
Tampered app works: YES / NO — steps + proof:
Check bypassed: which one + how + proof:
Decoys found (if any): what + where:
Hardest part:
Easiest part:
What would you try next if you had more time:
```

Send the report back to NAYEM. If you break it, we fix it and test again.
That is the point — a break makes Anti-REA stronger, it is not an embarrassment.

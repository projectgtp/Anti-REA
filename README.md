# Anti-REA — Protection for Android apps

> Don't just hide an application's code. Make protection part of the application's construction.

Anti-REA is a **command-line protection tool** for Android apps, with a **runtime component** that lives inside your protected app. It is not an APK you install, and it is not a website you log into. You run one command on your computer, and it protects your app.

One command. One config file. Any Android app.

```
python3 anti-rea.py protect --apk app.apk --config anti-rea.yaml --out app-protected.apk
```

## What type of thing is it?

**A CLI tool + a runtime library.** Two parts, working together:

1. **The CLI (your computer).** A Python program you run at build time. It opens your APK, encrypts your secrets, hides your strings, adds integrity checks, plants traps, and rebuilds a protected APK. It uses Python standard library only — no extra dependencies to install, no account, no cloud upload.

2. **The runtime (inside your app).** A small Kotlin library that gets built into your protected APK. At runtime it decrypts secrets only in memory, checks the app has not been tampered with, checks the environment, and refuses sensitive actions when something is wrong. It uses Kotlin standard library only.

That is the whole product: a build-time tool plus a runtime guard. The service (API + web upload + dashboard) is the next phase, built on this same engine, for teams who prefer to upload an APK instead of running the CLI.

## How do you use it on your project?

Three steps, for any Android project:

**1. Install what you already need for Android builds** — Python 3, JDK 17, and the Android SDK tools (`apktool`, `aapt2`, `d8`, `zipalign`, `apksigner`, `kotlinc`, `jadx`). No new dependencies. The CLI finds them on your `PATH`.

**2. Copy the config** — `cp anti-rea.yaml myapp.yaml`. Put the strings and patterns you want protected in `protect.strings` / `protect.patterns`. Put only fake values in `honeypots:` — traps are built from decoys, never from your real secrets.

**3. Run one command, then verify it:**

```
python3 anti-rea.py protect --apk app.apk --config myapp.yaml --out app-protected.apk
python3 anti-rea.py verify --apk app-protected.apk --config myapp.yaml --control app.apk
```

Ship only if verify says PASS. Verify runs the attacker's own tools (JADX, Apktool, `strings`) on your original APK and your protected APK side by side, so you see the difference with your own eyes: secrets found in the original, zero found in the protected one.

See `docs/USAGE.md` for the full guide.

## What does it protect?

- **Secrets and API URLs** — encrypted in smali and in Kotlin/Java source, decrypted only in memory at runtime, with per-build key rotation so every build looks different.
- **Tampering** — integrity checks on the app's own files and signature. A modified APK refuses to run its protected parts.
- **The environment** — debugger, emulator, root, Frida, and hooking-framework detection, reported as findings your app acts on.
- **On-device modding apps** — detection and blocking of APK editor apps that open, edit, and repack apps on the phone itself.
- **Runtime memory editors** — trace detection, memory-map checks, and values that are never stored as plain numbers in RAM.
- **Renamed and repacked apps** — package-name and signing-certificate checks, so a repack signed with another key is refused.
- **Traps** — honeypot secrets and endpoints, decoy classes, dead-code mazes. A trap only ever returns a fake value, records an event, or refuses one sensitive action. It never bricks, deletes, or harms anything. See `docs/TRAPS.md`.
- **Your server** — a REA-IR manifest with every blob hash, the layers applied, and the attestation and tripwire formats your server needs, plus a server reference implementation. See `docs/SERVER.md`.

## 103 layers

Anti-REA is built as **103 protection layers** in one framework (`layers/REGISTRY.md`), grouped by what they defend: static hiding, integrity, environment, runtime, native code, assets, server, traps, verification, and modding-app defence. If one layer is beaten, the next one stands. That is the whole idea: layers, not one wall.

List them any time:

```
python3 anti-rea.py layers --list
```

## What kinds of projects can use it?

**Any Android app, any category.** Games, finance, messaging, shopping, streaming, tools — if it ships as a Kotlin or Java APK, Anti-REA protects it. It does not care what your app does. It protects the app itself: its secrets, its code, its integrity.

- **Indie developers** — one command, one config, no server to run.
- **Teams and companies** — the same CLI in CI, with profiles (light / standard / strict), a machine-readable manifest per build, and a verification step that gates the release.
- **Communities** — the service phase (API / web upload / dashboard) lets anyone protect an APK without installing the toolchain.
- **iOS projects** — an iOS profile maps the same REA-IR layers to iOS equivalents (`layers/REGISTRY.md`, L99).
- **Backends** — the server reference (`server/reference.py`) covers request signing, attestation checks, and tripwire handling, so protection continues on your server, not only in the app.

## Tool coverage — by technique, not by name

Anti-REA counters **techniques**, not a list of tool names. Full mapping: [TOOL-COVERAGE.md](TOOL-COVERAGE.md).

- **Decompilers and APK unpackers** (JADX, Apktool, DEX tools) — tested on Bridge 2.14.0 and a generic test app: protected APKs show **0** on every tested secret in `strings`, JADX, and Apktool, while the original APKs show the secrets. See `VERIFICATION-REPORT-v1.0.md`.
- **Disassemblers and static scanners** (Ghidra, MobSF and others) — the same hiding removes the plain secrets and URLs these tools flag.
- **Dynamic and hooking tools** (Frida, debuggers, emulators) — environment detection and runtime checks are built into every protected app.
- **Network tools** (Burp, mitmproxy) — the server reference covers TLS pinning and request signing, so intercepted traffic cannot be replayed or forged.
- **Diffing** — per-build key rotation means the same secret produces different protected output on every build.
- **Memory editors** (GameGuardian and similar) — trace detection and in-memory value protection, with the server as the final check on every value.

## Self-protection

Anti-REA protects itself the same way it protects your app: the tool checks its own files for tampering before it runs and refuses to work if they were changed. See `docs/SELF-PROTECTION.md`.

## Layout

```
anti-rea.py            CLI (protect / verify / layers / self-check / ci)
anti-rea.yaml          example config
transformer/           smali.py, source.py, crypto.py, config.py, traps.py, native.py
runtime/               ReaRuntime.kt, ReaEnv.kt, ReaIntegrity.kt, ReaTraps.kt,
                       ReaGuardProvider.kt, ReaModBlock.kt, ReaTrace.kt,
                       ReaMemory.kt, ReaRepack.kt, ReaNative.kt, ReaAssets.kt,
                       native/ (compiled .so gate), build_smali.sh
layers/REGISTRY.md     all 103 layer slots with status
layers/MT-LIKE-BLOCKLIST.md  modding-app blocklist
verifier/              attack.py, tamper.py, frida_smoke.py, sigcheck.py
server/                reference.py (server-side protection reference)
service/               api.py + dashboard.html (service prototype)
tools/                 make_manifest.py, watermark.py, profiles.py, run_all.py
docs/                  USAGE.md, TRAPS.md, SERVER.md, SELF-PROTECTION.md, GAMEGUARDIAN.md
tests/                 generic test app + how to run the verifiers
```

## License

See LICENSE in the repo root.

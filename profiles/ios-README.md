# L99 — iOS profile (same REA-IR)

## What this is

A definition, not a built iOS app. `profiles/ios.yaml` maps every
REA-IR layer (L01–L103) to its iOS equivalent, so that when an iOS
build exists, the same REA-IR manifest, keys, blobs and server
attestation can be reused. Nothing here was built on iOS: there is
no iOS toolchain in this VM, no Xcode project, no Swift code, and no
device test. The profile's status is `defined`, and its own test
(`tools/test_ios_profile.py`) enforces that honesty — it fails if
the file ever claims `built_on_ios` or `device_tested`.

## The mapping in one paragraph

- **58 APPLIES** — the layer transfers to iOS essentially unchanged
  (same technique, iOS-native API). The whole server side (L61–L70:
  attestation, tripwires, device binding, rate limit, kill-switch,
  anomaly scoring, audit export, key rotation) is unchanged, because
  the server does not care which platform the client runs on. So are
  the crypto core (L46–L48: in-memory-only decrypt, split keys,
  per-build rotation), the tamper rules (L18–L22) and most traps
  (L71–L85).
- **37 ADAPTED** — same protection goal, different mechanism. The
  pattern is always the same: Android file format becomes the iOS
  one. DEX becomes Mach-O (L07, L12, L17, L86, L87), smali becomes
  Swift source (L01, L02, L11, L52), APK signature becomes code
  signature (L16, L103), root becomes jailbreak (L33, L101, L102),
  `/proc` scans become dyld image scans (L34, L36), MediaProjection
  becomes `UIScreen.isCaptured` (L39), Play installer origin becomes
  App Store receipt validation (L23).
- **8 DOES-NOT-APPLY** — genuinely Android-only, each with its
  reason in the file: R8 rename mapping (L08), invalid-UTF dex traps
  (L15), APK Signature Schemes v2/v3 (L24), Developer Options
  (L41), USB debugging / adb (L42), app cloners (L43), runtime code
  mutation (L60 — planned and likely never on Android, and forbidden
  on iOS), Gradle build plugin (L98).

## How an iOS developer would use it

1. Read `profiles/ios.yaml` for the layer you are implementing.
   Each entry names the Android mechanism it comes from (`android:`)
   and the iOS mechanism to build (`mechanism:`). Entries with a
   `note:` carry an honest limit — read it before you build.
2. Build the Swift runtime first: blob decrypt (L01, L02, L47),
   integrity checks (L16–L30), environment checks (L31–L45), and
   the tamper-refuse rule (L21: throw, never return a wrong value).
   Reuse the REA-IR blob format as-is — the same manifest, keys and
   blobs the Android runtime reads.
3. Reuse the server unchanged: `server/reference.py` needs no iOS
   changes. The attestation payload (L61) carries iOS findings
   instead of Android ones; everything else (L62–L70) is identical.
4. Verify the way the Android side is verified, with iOS tools:
   `strings` / `nm` on the Mach-O for the control-vs-protected
   sweep (L07, L86), a 1-byte flip for the tamper test (L87),
   Ghidra headless smoke on the Mach-O (L90). A needle that is 0
   in the protected binary only counts if the control binary still
   shows it — otherwise the test is vacuous.
5. Run the profile test after any edit:
   `python3 tools/test_ios_profile.py`

## What is NOT done

- No Xcode project, no Swift code, no compiled iOS app.
- No build on iOS, no install, no device test, no App Store run.
- No Frida runtime test on iOS (L89 stays planned — it needs a
  device, same as on Android).
- No iOS red-team test (L91 — the user's reverse-engineering
  contact tests the iOS build when it exists).
- The `ADAPTED` entries are mappings, not implementations: each one
  still needs real Swift/C code, and the iOS build step
  (`xcodebuild`, L88) does not exist here.
- L99 itself stays `PLANNED` in `layers/REGISTRY.md` until the
  parent merges this profile and an iOS build exists. This profile
  does not change the registry, the manifest, or any other layer.

## Honest limits (carried over from Android, still true on iOS)

- A skilled attacker with a jailbroken device and patience can
  still win in the end; the server must never trust
  client-reported numbers.
- Jailbreak detection (L33) is a signal, not a wall: tools rename
  themselves, and on iOS an app cannot list installed apps, so the
  modder-tool block (L101) is weaker than on Android.
- The mock-location check (L40) is the weakest environment signal
  on iOS: flag only, never refuse.

## Files

- `profiles/ios.yaml` — the mapping (103 layers, 9 categories).
- `profiles/ios-README.md` — this file.
- `tools/test_ios_profile.py` — stdlib unittest; parses the YAML
  with its own strict parser, cross-checks it through the real
  REA-IR loader (`transformer/config.py`), and validates it against
  `layers/REGISTRY.md`.

# L60 — Runtime code mutation (self-changing code)

**Status: IMPLEMENTED as an experimental core. JVM-tested (seal /
open / rotate). The Android loader is COMPILE-VERIFIED ONLY — never
device-tested. Do not ship a build that uses this until it has
device proof.**

**ON BY DEFAULT — set `experimental.self_changing_code: false` in
your config to turn it off.** This is the user's explicit order
(2026-11-23: "Default is on man"). The default changes nothing
about the danger below: the warnings in this doc still apply in
full. The user takes the usage decision; this doc exists to make
that decision an informed one. If you turn it off, nothing else in
Anti-REA changes — the flag only arms the L60 helpers, and
`anti-rea.py protect` never calls them.

Written in simple words, on purpose. This doc replaces
`docs/L60-WHY-NOT-SHIPPED.md` (deleted): the old doc's warnings are
carried over here, not dropped. The old verdict was NOT-SHIPPED
because every version of "self-modifying code" that was on the table
could crash the app or get it flagged as malware. The user has now
decided the mechanism is important enough to build anyway — "Self
changing code is important. And also dangerous. Depend on how I
use." — so the safest defensible shape is implemented, with the
danger labelled on it, and the decision left to the user.

## What it does, in plain words

A method's code is stored scrambled, not readable in the APK file.
At runtime the app unscrambles it, loads it, and runs it. The
stored form CHANGES between runs: rotation re-encrypts the same
payload under a fresh key, so the bytes on disk are different every
time the payload is rotated. That changing stored form is the
"self-changing" part.

Concretely:

1. `tools/make_method_blob.py` seals a dex payload file into a
   blob triple (blob + two split key parts) — the same REA-IR
   pattern (XOR + split key) as the rest of Anti-REA.
2. `runtime/ReaMethodDecrypt.kt` opens the blob in memory only.
   A tampered blob or a wrong key refuses (returns null), never a
   wrong value. `rotate()` re-seals the payload under a fresh key.
3. `runtime/ReaMethodLoader.kt` (Android only) writes the
   decrypted dex to ONE file in the app's private storage, loads
   it with a fresh DexClassLoader, invokes the method, then
   deletes the plaintext file immediately.

## DANGER — read this before using it

This layer can break your app and can get it flagged. That is not
a footnote; it is the reason the old doc said not to ship it:

- **It can crash the app if misused.** A bad dex payload, a
  missing class, a method that throws, or a rotation that loses
  the new key all leave the app without the code it expected.
  The loader refuses (returns null) instead of crashing, but the
  app still has to handle "the method is not there" — if the
  missing method was load-bearing, the app breaks in the user's
  hands, on their phone.
- **Play Protect / antivirus may flag runtime-loaded code.**
  Loading code at runtime is one of the behaviours Google Play
  Protect and antivirus engines flag. A protector that gets your
  app flagged — or removed from the Play Store — is worse than no
  protector. There is no clean scan report for this yet; do not
  assume it passes.
- **Decrypted code stays in RAM.** Once code is loaded it stays
  loaded in plain form until the process dies. Re-encryption only
  changes the STORED form (the bytes on disk / in the blob). A
  memory dump after load still reads the code. Anyone who tells
  you rotation erases the loaded code is wrong.
- **It has never run on a phone.** The core is JVM-tested; the
  loader is compile-verified only. ART behaviour (whether the
  optimised dex survives deleting the source file, whether the
  loader works on every Android version) is unproven. A
  compile-verified loader is not a working loader.
- **It does not sandbox loaded code.** A loaded class runs with
  your app's FULL permissions. Loading a blob you did not seal
  yourself is remote code execution by another name.

## What "self-changing" honestly means — and what it is not

The old doc considered three shapes and rejected all three. This
implementation avoids the rejected mistakes, and it is honest
about what it does not do:

### 1. Truly patching running code in memory — REJECTED, still not done

Rewriting the bytes of a method that is already loaded, while the
app runs. Kotlin cannot do this at all; you would need native code
that unlocks the memory pages holding the code and writes new
bytes by hand. Android's runtime (ART) compiles methods ahead of
time or while the app runs, and the layout is not stable or
documented — patching the wrong offset gives you a crash, not a
cleverer app. It cannot be tested in this VM (no device, no ART),
and it looks like malware. **L60 does not do this. Nothing in
this layer patches live code.**

### 2. Runtime-decrypted method bodies (decrypt → run → re-encrypt) — the theatre, removed

The old "safe" version promised to re-encrypt the code after it
ran. That promise was impossible: once code is loaded into the
runtime, it stays loaded (L57's loader is deliberately never
closed, because the class must stay alive to be used). The
"re-encrypt" step would have been theatre. **L60 does not claim
it.** Rotation happens BETWEEN runs (or between loads), on the
stored blob — never on live code, never after a run as if that
erased anything. The doc says so, and the code has no
re-encrypt-after-run step.

### 3. Decrypt a payload and run it through a tiny interpreter — not code mutation

Decrypting data and feeding it to an evaluator is encrypted
*data*, already covered by L13 (asset encryption) plus L02/L01
(string encryption). Calling a data interpreter "runtime code
mutation" would have been dishonest labelling. **L60 does not do
this either.** It loads real dex code through DexClassLoader.

What L60 actually is, then: L57 (dynamic class loading) plus a
sealed blob plus rotation of the stored form. L57 without rotation
is not L60, and a sealed blob without a loader is only a sealed
blob. The "self-changing" is the stored bytes mutating on every
rotation — nothing more, and the doc does not claim more.

## When it is safe to use

Only ALL of these together:

- **Only on non-critical paths.** A feature the app can live
  without — a bonus, a cosmetic, an optional check. If the load
  refuses, the app must keep working and simply skip that
  feature. If a refusal would break the app, do not put that code
  behind L60.
- **Only after testing on a real device first.** A test APK with
  L60 enabled must install, launch, load, rotate, and run its
  normal flows on the user's real phone (Infinix Hot 60i) with no
  crash and no visible error — before any other build uses it.
- **Only with the payload you sealed yourself**, from your own
  build, with a key you control. Never a blob from the network,
  a download, or any untrusted source.
- **Only with the new key persisted.** Rotation returns a new
  triple; the caller must store it and drop the old one. Losing
  the new key loses the payload — there is no recovery.
- **Only after a clean Play Protect / antivirus scan** of a build
  that uses it, if the app goes to the Play Store.

## When it is NOT safe

- **First launch.** Never load a method the app needs to start.
  If the load refuses on first launch, the user gets a dead app.
- **Critical flows.** Never login, payment, account, or
  security-critical code. A refusal there is an outage; a
  successful load there still leaves the code in RAM.
- **Play Store builds without testing.** Do not ship it to the
  Store on the strength of a compile check. No device proof, no
  Store build.
- **Payloads you did not build.** See the DANGER section: loading
  an untrusted dex is remote code execution.
- **As a replacement for server checks.** A dumped client cannot
  fake the ledger; L61–L70 (server attestation) remain the real
  enforcement. L60 raises the cost of static reading; it does not
  make the client trustworthy.

## Honest limits

- XOR + split keys is obfuscation with integrity checking, NOT
  strong cryptography. A skilled attacker who finds both key
  parts can reconstruct the key, and Frida / a debugger / a
  runtime memory dump can read the code after it is loaded.
- Rotation changes the stored bytes, not the running code. The
  loaded class stays in RAM until the process dies.
- The loader deletes the plaintext dex file after load, but the
  optimised dex lives in codeCacheDir — that is how ART works,
  and it is why the file can be deleted at all. If ART ever needs
  the source dex again, the call fails (refuses) rather than
  crashing — but it is unproven on a device, because the loader
  has never run on one.
- A skilled attacker with root and patience can still win in the
  end. This project says so everywhere, and L60 is no exception.

## How to use it (and how to turn it off)

Turn it OFF (the only change the default needs):

```yaml
experimental:
  self_changing_code: false
```

Seal a payload (fresh random key, JSON out):

```bash
python3 tools/make_method_blob.py method.dex --out method-blob.json
python3 tools/make_method_blob.py --self-test method.dex
```

Load and invoke it on Android (fail-closed — null means refuse):

```kotlin
val sealed = ReaMethodDecrypt.SealedMethod(blob, part1, part2, blobSha, plainSha)
val result = ReaMethodLoader.loadAndInvoke(context, sealed,
    "com.example.HiddenFeature", "run")
if (result == null) { /* skip the feature, keep the app working */ }
```

Rotate the stored form (between runs, never on live code):

```kotlin
val rotated = ReaMethodDecrypt.rotate(sealed, ReaMethodDecrypt.generateKey())
    ?: return // tampered blob: refuse, never re-seal
// Persist `rotated` (the new triple) and drop the old one.
```

## What device proof must show before anyone ships it

1. A test APK with L60 enabled assembles, signs, installs, and
   launches on a real phone (the user's Infinix Hot 60i).
2. The sealed method loads, runs, and returns the right result,
   and the plaintext dex file is gone from private storage
   afterwards.
3. A rotation changes the stored blob bytes, the rotated blob
   still loads, and the old triple no longer opens anything.
4. A tampered blob refuses on the device (no crash, feature
   skipped, app keeps working).
5. A Play Protect / antivirus scan of the test build comes back
   clean — a clean report, not an assumption.

Until all five are shown, treat L60 as an experiment that happens
to be on by default, not as a proven layer.

## Files

- `runtime/ReaMethodDecrypt.kt` — the pure-Kotlin core (stdlib +
  JDK only, JVM-tested). Seal / open / rotate / verify.
- `runtime/ReaMethodLoader.kt` — the Android loader
  (DexClassLoader, compile-verified only, never device-tested).
- `runtime/tests/MethodDecryptTest.kt` — JVM test: round-trip,
  double-open, 1-byte tamper refuses, wrong key refuses, rotate
  changes stored bytes + still opens, bad inputs refuse.
- `tools/make_method_blob.py` — stdlib sealing tool, with
  `--self-test` (round-trip + tamper-refuse + rotation).
- `transformer/config.py` — `self_changing_code_enabled(cfg)`,
  default ON; `transformer/tests/test_self_changing_code.py`
  pins both directions (default ON, explicit false OFF).
- `runtime/build_smali.sh` — compiles both new runtime files
  into the runtime jar / smali.
- NOT touched, on purpose: `layers/REGISTRY.md`,
  `anti-rea.manifest.json`, and every other layer's files — the
  parent merges the registry and manifest. L60 stays PLANNED
  there until the parent merges it.

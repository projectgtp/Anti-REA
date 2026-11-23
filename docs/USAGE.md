# Anti-REA v1.0 — Usage

## Commands

```
# Protect an APK (main flow)
python3 anti-rea.py protect --apk app.apk --config myapp.yaml --out app-protected.apk

# Protect a source tree instead (Kotlin/Java literals only)
python3 anti-rea.py protect --source src/ --config myapp.yaml --out protected-src/

# Attack-test the result (needs the ORIGINAL as control)
python3 anti-rea.py verify --apk app-protected.apk --config myapp.yaml --control app.apk

# List layers
python3 anti-rea.py layers --list
python3 anti-rea.py layers --list --status implemented
python3 anti-rea.py layers --list --status planned
```

## Config

See `anti-rea.yaml` (annotated example). The rules:

- `protect.strings` — exact literals to hide. Start with the smallest
  set that matters (API base URL, signing endpoints, key labels).
  Protecting everything is slower and noisier; protecting the 3–5
  sensitive values is the smart cut.
- `protect.patterns` — regexes for families of literals (e.g. URLs).
  A pattern that matches too much will encrypt UI strings too — check
  the REA-IR `needles_found` list after the first run.
- `honeypots:` — FAKE values only. Never a real key, token, or URL.
- `layers.enable` — empty means all IMPLEMENTED layers. `layers.disable`
  removes ids. Naming a PLANNED layer in `enable` is an error — see
  `layers/REGISTRY.md` for what is actually built.
- `runtime.provider: true` injects `ReaGuardProvider` into the manifest
  (startup env + integrity check). It never blocks launch by itself;
  refusal is the app's decision.

## What protect does, step by step

1. Loads and validates the config (bad YAML subset or unknown/PLANNED
   layers fail loudly, before touching the APK).
2. Decodes the APK with `apktool` into a temp work dir under
   `/home/hatch/tmp/` (never `/tmp`).
3. Sweeps smali for the configured needles; encrypts each found needle
   (fresh random key per needle per run) and rewrites `const-string`
   to a `ReaRuntime.decrypt()` call.
4. Injects the runtime smali (`runtime/smali/`, built by
   `runtime/build_smali.sh`) and the guard provider manifest entry.
5. Writes decoy classes, honeypot strings, and dead-code mazes.
6. Sweeps XML resources/manifest for needles (L06 PARTIAL: replaced
   with a decoy placeholder, not runtime-decrypted).
7. Writes `assets/antirea/manifest.json` (blob hashes + layers) and
   the REA-IR JSON next to the output APK.
8. Rebuilds with `apktool`, injects `assets/antirea/build.json` (dex
   SHA-256), zipaligns, and signs with a fresh ephemeral test keystore.
9. Prints the output SHA-256, size, layers applied, and needles found.

## What verify does

Runs `verifier/attack.py` (jadx + apktool + strings) on control vs
protected and prints per-needle counts. PASS needs protected == 0 for
every needle AND control > 0 for every needle. A 0 with control == 0
is FAIL (vacuous test — the tool would have found nothing anyway).
Without `--control`, verify falls back to a decode + literal sweep
and says plainly that the 0 is not proven non-vacuous.

## Troubleshooting

- `runtime smali missing` — run `bash runtime/build_smali.sh` first.
- `unknown layer ids` / `PLANNED, not implemented` — fix `layers:` in
  the config; check `layers/REGISTRY.md`.
- `skipped (no .locals)` — a method uses `.registers`; v1.0 skips it
  and reports it. Move the secret to a `.locals` method or add the
  literal to a helper that uses `.locals`.
- `apksigner verify` fails — the output was signed with the ephemeral
  test keystore; that is expected. It will not upgrade an install
  signed with another key.
- The protected app crashes at a protected call — read the exception:
  `Anti-REA: payload integrity check failed` means a blob was
  tampered with (or the wrong key parts were injected); check the
  REA-IR blob hashes against the APK.

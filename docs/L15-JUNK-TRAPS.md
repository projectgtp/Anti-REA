# L15 — Anti-decompile junk (invalid-UTF traps)

**Status: EXPERIMENTAL, OPT-IN ONLY. Off by default. Never device-tested.
Do not ship a build with this enabled until it has device proof.**

## What it does, in plain words

Some decompilers (jadx, dex2jar, and similar tools) read every string
in an app's code by decoding it as ordinary UTF-8 text. DEX files do
not store strings as ordinary UTF-8, though — they use a variant
called Modified UTF-8, which has its own rules. L15 plants a few
extra strings that are legal-looking under Modified UTF-8 rules but
*illegal* as ordinary UTF-8, in the hope that a naive tool trips over
them and crashes or gives up, while the phone itself (Android's
runtime, ART) keeps working.

The illegal sequences are:

- **A lone high surrogate** (U+D800) and **a lone low surrogate**
  (U+DC00). Surrogates are half-characters that must always come in
  pairs; on their own they are not valid text at all. In a dex file
  they are stored as the bytes `ED A0 80` and `ED B0 80`.
- **Overlong encodings** — writing a plain character (such as `/` or
  the delete character) using more bytes than it needs (`C0 AF`,
  `E0 80 80`, `C1 BF`). Strict UTF-8 decoders reject these; they are
  never valid UTF-8.

Each trap string is wrapped in a plain ASCII marker so it can be
found in a hex dump: `appcore-junk:<kind>:<trap bytes>:end`.

## Why it is experimental

A bad trap can break the app itself. That is the whole risk, stated
plainly:

1. **ART may not tolerate the trap.** Android's runtime reads
   Modified UTF-8, but how it reacts to a lone surrogate or an
   overlong sequence inside a string it actually loads is not
   guaranteed — it may throw, it may replace the character, or it
   may refuse the whole file. Nobody has tested this on a phone.
2. **The build tools may reject the trap first.** The smali
   assembler, apktool, or the signer may refuse a file containing a
   lone surrogate before the app ever reaches a phone. The overlong
   kinds cannot even be written in smali — they only exist as raw
   dex bytes.
3. **A good decompiler may not care.** A tool that decodes strings
   correctly (as Modified UTF-8, or leniently) will sail straight
   past these traps. L15 only hurts naive decoders, and only if the
   traps survive steps 1 and 2.
4. **The dex integration is unbuilt.** The code works on a *copy of
   dex string data* (a blob of string entries). Splicing new entries
   into a real `.dex` file means rebuilding its string index, which
   this code does not do. Until that step exists and is tested, the
   dex half of L15 is a building block, not a finished layer.

Because of all four points, L15 is **not** counted as protection.
It stays PLANNED in `layers/REGISTRY.md` until the parent merges it
after device proof.

## How it is kept safe (as safe as an untested trap can be)

- **Off by default, always.** The flag is `experimental.junk_traps`
  in the config file. Absent, false, or unset means OFF, and OFF
  means the input comes back byte-identical — the tests prove this.
- **It never rewrites a live string.** Both plant functions only
  APPEND new decoy entries to the end of the input: new
  `const-string` lines inside a brand-new decoy class
  (`com/appcore/junk/JunkTraps`, smali), or new string entries
  appended to a copy of a string-data blob (dex bytes). The whole
  input is a verbatim prefix of the output. No string the app itself
  reads ever contains a trap.
- **The traps are decoys, never read by live code.** The decoy class
  is never called from real code, exactly like the L76–L85 decoys.
- **It is not wired into the CLI.** `anti-rea.py protect` does not
  call this code. The only entry points are the two `apply_*`
  wrappers in `transformer/junk.py`, which return the input
  unchanged unless the config flag is on.
- **Every trap is accounted for.** Each plant call returns a report
  (kind, line number or byte offset, exact bytes), and
  `verify_planted()` proves the traps exist *only* where the report
  claims — nowhere else in the output.
- **The flag is separate from layer enabling.** Putting `"L15"` in
  `layers.enable` still raises an error, because L15 is PLANNED.
  The experimental flag only arms this module's own wrappers.

## How to enable it (for testing only)

In your config file, add:

```yaml
experimental:
  junk_traps: true
```

Then call the wrappers from your own test harness:

```python
import sys
sys.path.insert(0, "transformer")
import junk

out_text, report = junk.apply_junk_traps_to_smali(smali_text, cfg)
assert junk.verify_planted(out_text, report, "smali")

out_bytes, report = junk.apply_junk_traps_to_dex_bytes(dex_blob, cfg)
assert junk.verify_planted(out_bytes, report, "dex")
```

With the flag off (or absent), both calls return the input unchanged
with an empty report.

## What device proof must show before anyone ships it

1. A test APK with the traps enabled assembles, signs, installs,
   and launches on a real phone (the user's Infinix Hot 60i).
2. The app runs its normal flows with no crash and no visible error.
3. A naive decompiler (jadx or dex2jar on the same APK) actually
   fails or degrades on the trapped strings — if it does not, L15
   buys nothing and should stay off.
4. The dex half is only proven once a real `.dex` rebuild with
   re-linked string entries exists and passes steps 1–3.

Until all four are shown, treat L15 as an experiment, not a layer.

## Files

- `transformer/junk.py` — the pass (stdlib only).
- `transformer/tests/test_junk.py` — 28 stdlib unittest tests.
- `transformer/config.py` — `junk_traps_enabled(cfg)` (flag reader,
  default OFF) and the schema note for `experimental.junk_traps`.

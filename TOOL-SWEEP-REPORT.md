# Anti-REA v1.0 — Full RE-Tool Sweep Report

Date: 2026-11-23. Status: **static sweep only — compile-verified, never device-tested.**
No device or emulator exists in this VM. No protected APK was installed or
run on Android. No live server was attacked. No GitHub push was made.

## Highlights (short version)

- **7 tools ran a real needle test and all 7 PASS**: `strings` on dex,
  baksmali, Apktool, JADX, dex2jar 2.1 + CFR 0.152, Androguard 4.1.4,
  and the Anti-REA `verify` CLI (with control). In every one, the control
  APKs reveal the secrets and the protected APKs reveal **0**. No tool
  found a single protected needle. **Zero FAILs.**
- **Per-part APK check (user's structure note, confirmed)**: an APK has
  no original `.java`/`.kt` source — it has `classes.dex`, smali,
  binary `AndroidManifest.xml`, `res/`, `assets/`, `lib/*.so`,
  `META-INF/`, and Kotlin metadata inside the dex. Every part was
  checked separately. `classes.dex`, `res/` (incl. `resources.arsc`),
  and `assets/` (REA-IR files) are 0 in protected; `lib/*.so` is
  byte-identical WireGuard code in both builds (untouched third-party,
  excluded from needle counts); `META-INF/` has 0 needles and all 4
  APKs pass `apksigner verify` (v2+v3 true).
- **2 tools INCONCLUSIVE, not hidden**: Ghidra headless runs and its
  auto-analysis succeeds, but no needle output was captured (the
  `Decompile` script does not exist in this install; a custom string-dump
  script run hit the 420 s timeout). APKLeaks 2.6.3 installed but hung
  with no output for 6+ minutes on the tiny test app and was killed.
- **Not installed / needs device / irrelevant**: ~60 named tools are not
  installed here (MobSF, IDA, JEB, Frida, … — checked, listed below);
  live tools (Frida, debuggers, emulators, device farms) need a device
  that does not exist in this VM; ~40 names are not APK RE tools at all
  (build tools, .NET/Unity/Flutter tools, forensics, OS distros, linters,
  crash SDKs, standards). Network tools are explicitly NOT a client claim.
- **99% is the GOAL, not a measured guarantee.** This sweep proves static
  hiding against the tools that ran. It does not prove Frida, a debugger,
  or a memory dump cannot read values after decryption. That is the
  user's RE contact's job next.

## Method (read this before the numbers)

- **Fixed-string matching only.** Every count is an exact byte search
  (`grep -F` semantics). A naive regex grep was NOT used: it previously
  gave a false "tunnel key" hit on the English sentences "Seller tunnel
  key registered…" / "The saved tunnel key no longer matches…". The real
  label `tunnel.key.` (with dots) is 0 in protected.
- **Non-vacuity rule.** A protected 0 only counts as PASS if the same
  tool found the same needle in the control (>0). A tool that finds
  nothing in either build is marked VACUOUS, not PASS.
- **Needles (8)**: `TEST-SECRET-7f3a9-generic`,
  `https://testapp.example.invalid/api`,
  `https://mbbridge.onrender.com`, `http://10.0.2.2:8000`,
  `https://api.bridge.example`, `api.bridge.example`,
  `bridge-marketplace.onrender.com`, `tunnel.key.`
  Only the first 2 apply to the test app; only the last 6 apply to
  Bridge. Counts are reported per APK, per needle.
- **Inputs (verified hashes)**: testapp control `d1708e7e…` (614,877 B),
  testapp protected `3fd12ca3…` (582,254 B), Bridge 2.14.0 control
  `7f140907…` (4,573,620 B), Bridge protected `e55801fd…` (4,500,018 B).
  Work was done on copies under `/home/hatch/tmp/antirea-sweep/`; the
  protected APKs were never modified.

## Per-tool results (needle tests — control vs protected)

| Tool | Version / how run | Test app control → protected | Bridge control → protected | Verdict |
|---|---|---|---|---|
| `strings` on extracted `classes.dex` | binutils `strings` | 1, 1 → 0, 0 | 3, 1, 1, 2, 1, 1 → 0 ×6 | **PASS** |
| baksmali (smali disassembly) | `baksmali` (system) | 2, 2 → 0, 0 | 7, 3, 2, 3, 1, 4 → 0 ×6 | **PASS** |
| Apktool (full decode) | `apktool` (system) | 2, 2 → 0, 0 | 9, 3, 2, 3, 1, 4 → 0 ×6 | **PASS** |
| JADX (decompiler) | jadx 1.5.1 (`~/workspace/tools/bin/jadx`) | 1, 1 → 0, 0 | 5, 1, 1, 2, 0\*, 1 → 0 ×6 | **PASS** |
| dex2jar + CFR | dex2jar 2.1 (downloaded) + CFR 0.152 (downloaded) | 1, 1 → 0, 0 | 12, 1, 2, 3, 1, 1 → 0 ×6 | **PASS** |
| Androguard | 4.1.4 (venv pip install) — dex + manifest + all files | dex 1, 1 / files 1, 1 → 0 | dex 3, 1, 1, 2, 1, 1 / files 5, 1, 1, 2, 1, 1 → 0 | **PASS** |
| Anti-REA `verify` CLI (with `--control`) | `anti-rea.py verify` | PASS, no vacuous needles | PASS, vacuous in JADX only: `bridge-marketplace.onrender.com` | **PASS** |
| aapt / aapt2 manifest dump | `aapt dump badging` + `aapt2 dump xmltree` | 0 → 0 (both) | 0 → 0 (both) | VACUOUS — manifest never contained needles |
| `strings` / `nm -D` / `readelf` on `lib/*.so` | binutils on extracted `.so` | no `.so` files | 0 → 0 (both), all 3 `.so` byte-identical | VACUOUS — `.so` is untouched WireGuard code, excluded from needle counts |
| `apksigner verify` (signature check, not a needle test) | system `apksigner` | exit 0, both | exit 0, both; Bridge control v2+v3 true | **PASS** (signatures intact) |
| Ghidra headless | 12.2 (`analyzeHeadless`, JDK 25) | — | analysis succeeded on `libwg-quick.so`, but no needle output captured | **INCONCLUSIVE** — see §Ghidra |
| APKLeaks | 2.6.3 (venv pip install) | hung, no output in 6+ min on the tiny test app, killed | not attempted after the hang | **INCONCLUSIVE** — see §APKLeaks |

\* `bridge-marketplace.onrender.com` is 0 in JADX control too: JADX
does not render the sentence containing it. It is proven present and
protected by `strings`, baksmali, Apktool, dex2jar+CFR, and Androguard
(control 1 in each). This is a per-tool vacuity, not a failure — the
verifier records it the same way.

## Per-part APK structure check (user's note, confirmed)

The user's note is correct: an APK normally has **no original
`.java`/`.kt` source**. What it has, and what was checked:

| APK part | What it is | Test app control → protected | Bridge control → protected |
|---|---|---|---|
| `classes.dex` | compiled Java/Kotlin (all code) | 1, 1 → 0, 0 | 3, 1, 1, 2, 1, 1 → 0 ×6 |
| smali (baksmali + Apktool decode) | readable DEX disassembly | 2, 2 → 0, 0 | 7–9 per needle → 0 |
| `AndroidManifest.xml` (binary XML) | `aapt dump xmltree` + Apktool decoded manifest | 0 → 0 | 0 → 0 |
| `res/` (layouts, XML, images) | raw bytes incl. compiled `resources.arsc` | 0 → 0 | `mbbridge` 1 (in `res/` bytes) → 0 |
| `resources.arsc` ("other" entry) | compiled resource table | n/a (test app has none) | `mbbridge` 1 → 0 |
| `assets/` | JSON/HTML/JS/fonts/config | no assets → 2 files, 0 needles (REA-IR `manifest.json` + `build.json` hold key-ids + SHA-256 only, no plaintext) | no assets → 2 files, 0 needles |
| `lib/arm64-v8a/*.so` | native C/C++ (WireGuard) | no `.so` files | 0 needles both builds; all 3 `.so` byte-identical to control (SHA-256 checked) — untouched third-party, excluded from needle counts |
| `META-INF/` | signatures | 0 needles, `apksigner verify` exit 0 | 0 needles, `apksigner verify` exit 0, v2+v3 true |
| `kotlin/` metadata dir | Kotlin metadata files | **no `kotlin/` dir in any of the 4 APKs** — Kotlin metadata lives as annotations inside `classes.dex`, already covered by the dex checks | same |

## Ghidra note (§Ghidra)

Ghidra 12.2 is installed and `analyzeHeadless` runs. Two attempts to get
decompiled/string output failed for tool reasons, not protection reasons:
(1) `-postScript "Decompile"` errors with "Script not found" — there is
no `Decompile.java` anywhere in this Ghidra install (verified by
`find`); (2) a custom `DumpStrings` GhidraScript was written and run —
auto-analysis reported "Analysis succeeded" for `libwg-quick.so`, but
the run hit the 420 s timeout before the script's output file appeared
(Ghidra headless is known to hang on exit), so no Ghidra-derived string
list was captured. The native question is still answered by
`strings`/`nm`/`readelf` (0 needles, `.so` byte-identical). Ghidra
needle-finding is therefore **NOT RUN**, not a PASS. The user's RE
contact with a working Ghidra setup is the right next check for this
category.

## APKLeaks note (§APKLeaks)

APKLeaks 2.6.3 was installed in a venv (`pip install apkleaks`) and its
console script exists, but running it on the 582 KB testapp-protected
APK produced no output for over 6 minutes (it shells out to jadx
internally) and was killed. It was not attempted on Bridge after that.
The secret-scanning question it would answer is already answered by
JADX/Apktool/`strings` (0 protected), so nothing material is lost — but
APKLeaks itself is **INCONCLUSIVE** here, not tested.

## List #2 inventory (second ChatGPT list)

Checked with `command -v` + pip/npm listings. Statuses: NOT INSTALLED =
checked and absent; NEEDS DEVICE = runs on a phone / live app only;
IRRELEVANT = not an APK RE tool for these apps; NOT A CLIENT CLAIM =
cannot be stopped client-side.

| Names | Status |
|---|---|
| MT Manager, GDA (GreenDao Analyzer) | NOT INSTALLED — Android-only apps, NEEDS DEVICE (run on a phone) |
| ReFlutter | IRRELEVANT here — Flutter-only; neither APK is Flutter |
| MARA, SuperAnalyzer, AppUse, AppSpear, ICCBot, DroidRA, DroidMate, r2frida | NOT INSTALLED (checked PATH; research tools, no package here) |
| Frida Gadget | NOT INSTALLED + NEEDS DEVICE for a live test |
| Il2CppDumper / Il2CppInspector, AssetStudio, UnityPy, UABEA, AssetRipper | IRRELEVANT here — Unity-only; neither APK has Unity assets (verified in zip listings) |
| dnSpy, ILSpy, dotPeek, Mono.Cecil | IRRELEVANT — .NET tools; no .NET in APKs |
| APKLeaks | Installed 2.6.3, but HUNG — INCONCLUSIVE (see §APKLeaks) |
| apk-mitm | NOT INSTALLED (npm global empty; not attempted — it rewrites APKs and needs a device to test MITM) |
| APK Signature Scheme v2/v3 verifier (= `apksigner`) | TESTED, PASS — all 4 APKs verify, v2+v3 true |
| ARSCBlamer | NOT INSTALLED; `resources.arsc` covered by per-part raw-bytes check (control 1 → protected 0) |
| Resource Hacker | NOT INSTALLED — Windows-only tool |
| Diffoscope | NOT INSTALLED (checked); diffing property covered by per-build key-rotation unit test in v1.0 |
| PatchDiff | NOT INSTALLED — IDA plugin, commercial, no license |
| CyberChef | NOT RUN — web tool, needs a browser |
| Hashcat, John the Ripper | NOT INSTALLED; IRRELEVANT anyway — no password hashes in these APKs to crack |
| ExifTool | NOT INSTALLED; would only read image metadata, not a needle vector |
| Netron, Model Explorer | IRRELEVANT — ML-model tools; no ML models in these APKs |
| Droidlysis | NOT INSTALLED (checked PATH + venv pip list) |
| Android Tamer, Kali / Parrot / BlackArch / REMnux / FLARE-VM | Not tools — OS distributions / VM images; NOT APPLICABLE |
| Autopsy, Sleuth Kit, Volatility, ALEAPP / iLEAPP, MVT | NOT INSTALLED (checked); forensics tools for device images, IRRELEVANT for APK string leaks |
| scrcpy, QtScrcpy, OpenSTF / DeviceFarmer, Firebase Test Lab, AWS Device Farm, BrowserStack, Sauce Labs | NEEDS DEVICE / external service — not run |
| Reproducible Builds, Fastlane | IRRELEVANT — release/build tooling |
| Sentry / Bugsnag / Datadog | IRRELEVANT — crash-monitoring SDKs |
| Detekt / KtLint / Android Lint | IRRELEVANT — source linters, need source code |
| Checkov / KICS / Terrascan | IRRELEVANT — infrastructure-as-code scanners |
| Falco / Tetragon / Tracee / eBPF | NEEDS DEVICE — Linux runtime monitors, not APK static tools |
| strace | Present (`/usr/bin/strace`) but NEEDS DEVICE — traces a live process; no running app here |
| GDB, LLDB | NOT INSTALLED (checked) + NEEDS DEVICE |
| Wireshark, tshark, tcpdump, mitmproxy, Burp, ZAP, nmap | NOT INSTALLED (checked) + NOT A CLIENT CLAIM — no APK stops a proxy from seeing its own traffic; server TLS + pinning + attestation required |

List #1 remainder (from TOOL-COVERAGE.md, unchanged): JADX-GUI,
FernFlower, Vineflower, Procyon, JD-GUI, Krakatau, Recaf, Enjarify (not
on PyPI — not attempted), JEB, IDA (+Free), Binary Ninja, Hopper,
Cutter, radare2/Rizin, APKLab, APKTool M, APK Editor Studio, APKParser,
APK Analyzer, MobSF, QARK, Semgrep, CodeQL, SonarQube, Quark-Engine,
AndroBugs, Frida-tools, Objection, Xposed/LSPosed/EdXposed, SandHook,
YAHFA, Dobby, HookZz — all NOT INSTALLED here (checked PATH/pip) except
where noted above; commercial ones were not downloaded, no cracks, no
paid tools. Their categories are covered by the representative tools
that did run (JADX for decompilers, Apktool for unpackers, baksmali for
DEX tools) — same technique, same target data.

## Summary counts

- **Needle-test tools run and PASS: 7** — `strings`, baksmali, Apktool,
  JADX, dex2jar+CFR, Androguard, Anti-REA `verify` CLI. Plus
  `apksigner verify` PASS (signature integrity, all 4 APKs).
- **FAILs (protected needle found by any tool): 0.**
- **INCONCLUSIVE: 2** — Ghidra (tool/output capture failed), APKLeaks
  (hung, killed).
- **VACUOUS (tool finds nothing in either build): 2 checks** —
  aapt manifest dump (manifest never had needles) and native `.so`
  needle search (untouched WireGuard code). Neither is claimed as PASS.
- **NOT INSTALLED (checked): ~60 named tools** across both lists.
- **NEEDS DEVICE / external service: ~20** — Frida live, debuggers,
  emulators, sandboxes, device farms, MT Manager/GDA, scrcpy.
- **IRRELEVANT for these APKs: ~40** — build tools, .NET/Unity/Flutter
  tools, forensics, OS distros, linters, IaC scanners, crash SDKs,
  standards/datasets, AI tools.
- **NOT A CLIENT CLAIM: 1 category** — network tools.

## Honest limits (read before believing the PASSes)

1. This sweep proves **static** hiding. A needle that cannot be found
   by decompiling the APK can still be read at runtime — after the app
   decrypts it in memory — by Frida, a debugger, or a memory dump. No
   tool run here tests that, because there is no device here.
2. XOR + split keys is obfuscation with integrity checks, not strong
   crypto. A determined analyst who finds the runtime can reconstruct
   the key parts and decrypt the blobs offline. The layers slow that
   down; they do not make it impossible.
3. Ghidra and APKLeaks — two tools the user explicitly named — did not
   produce a verdict here. Do not tell the user they passed.
4. 99% protection remains the GOAL, not a measured guarantee. What is
   measured is in the tables above: 0 protected needles in 7 tools,
   on 2 APKs, 8 needles.
5. The next real test is the user's RE contact with a live device and
   working Ghidra/Frida setup — arranged by the user, not done yet.
   When it runs, its results belong in this file and in
   VERIFICATION-REPORT-v1.0.md.

## Evidence files (this sweep, under /home/hatch/tmp/antirea-sweep/)

- `sweep-results.json` — strings/baksmali/apktool/jadx/aapt/native raw counts
- `extra-results.json` — androguard (fixed) + dex2jar/CFR raw counts
- `ag2.json` — androguard rerun (fixed script)
- `perpart.json` — per-part APK structure counts
- `sweep.log`, `extra.log`, `ghidra.log`, `ghidra2.log`, `ghidra3.log` —
  tool outputs (Ghidra logs show the script errors and the timeout)
- `DumpStrings.java` — custom GhidraScript (no output file produced)
- `cfr.jar` (0.152), `dex2jar21/` (2.1), `venv/` (androguard 4.1.4,
  apkleaks 2.6.3) — tools fetched for this sweep; not part of the
  Anti-REA repo

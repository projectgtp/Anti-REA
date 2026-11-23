#!/usr/bin/env python3
"""Anti-REA v1.0 — standalone protection CLI (Python stdlib only).

Usage:
    python3 anti-rea.py protect --apk in.apk --config anti-rea.yaml --out out.apk
    python3 anti-rea.py protect --source src/ --config anti-rea.yaml --out protected-src/
    python3 anti-rea.py protect --apk in.apk --config anti-rea.yaml --out out.apk --profile light
    python3 anti-rea.py ci --apk in.apk --config anti-rea.yaml --out out.apk
    python3 anti-rea.py verify --apk out.apk --config anti-rea.yaml [--control in.apk]
    python3 anti-rea.py layers --list [--status implemented|partial|planned|all]
    python3 anti-rea.py layers --coverage

One config file, one command. Works on ANY Android APK (Kotlin/Java),
not only Bridge: protection is driven by the config's strings/patterns,
never by Bridge names. The input APK is never modified; the output is
a new APK signed with a fresh ephemeral test keystore unless
--keystore is given explicitly.

Honest limits (also in README.md): static + environment checks slow
experts down; they do NOT stop Frida / runtime memory dumps. XOR +
split keys is obfuscation with integrity checks, not strong crypto.
99% protection is the GOAL, not a measured guarantee.
"""
import argparse
import hashlib
import json
import os
import re
import secrets
import shutil
import subprocess
import sys
import tempfile
import zipfile
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE / "transformer"))
from config import load_config, protect_lists, honeypots, enabled_layers, ConfigError  # noqa: E402
from crypto import encrypt_payload, decrypt_payload, sha256_hex, sha256_file  # noqa: E402
import smali as smali_mod  # noqa: E402
import source as source_mod  # noqa: E402
import native as native_mod  # noqa: E402
import traps as traps_mod  # noqa: E402

VERSION = "1.0.0"
ROOT = Path(__file__).resolve().parent
TOOLS_BIN = Path.home() / "workspace" / "tools" / "bin"
SDK_BT = Path.home() / "workspace" / "tools" / "android-sdk" / "build-tools" / "36.0.0"

# --- Self-protection (Task 2a) -------------------------------------------
# At startup the CLI hashes its own code tree against
# anti-rea.manifest.json and refuses to run if anything was tampered
# with. The manifest is generated ONLY by tools/make_manifest.py —
# never by this CLI. The manifest holds SHA-256 hashes only, no
# secrets. Keep this list in sync with MANIFEST_FILES in
# tools/make_manifest.py; verify_self_check() refuses if the manifest
# covers a different set of files than this list, so coverage cannot
# be silently shrunk. Honest limit (see docs/SELF-PROTECTION.md):
# the v1.0 manifest is an UNSIGNED inventory — it detects accidental
# corruption and tampering by anyone who cannot also regenerate it.
# A real signed manifest is PLANNED for the service phase.
MANIFEST_NAME = "anti-rea.manifest.json"
SELF_CHECK_FILES = [
    "anti-rea.py",
    "transformer/crypto.py",
    "transformer/config.py",
    "transformer/smali.py",
    "transformer/source.py",
    "transformer/native.py",
    "transformer/traps.py",
    "transformer/junk.py",
    "transformer/tests/test_junk.py",
    "transformer/tests/test_smali_registers.py",
    "runtime/ReaRuntime.kt",
    "runtime/ReaEnv.kt",
    "runtime/ReaIntegrity.kt",
    "runtime/ReaTraps.kt",
    "runtime/ReaGuardProvider.kt",
    "runtime/ReaModBlock.kt",
    "runtime/ModBlockData.kt",
    "runtime/ReaTrace.kt",
    "runtime/ReaMemory.kt",
    "runtime/ReaRepack.kt",
    "runtime/ReaResStrings.kt",
    "runtime/ReaIntegrity2.kt",
    "runtime/ReaTimer.kt",
    "runtime/ReaEnv2.kt",
    "runtime/ReaNative.kt",
    "runtime/ReaAssets.kt",
    "runtime/ReaMethodDecrypt.kt",
    "runtime/ReaMethodLoader.kt",
    "runtime/tests/MethodDecryptTest.kt",
    "runtime/build_smali.sh",
    "layers/REGISTRY.md",
    "layers/MT-LIKE-BLOCKLIST.md",
    "docs/GAMEGUARDIAN.md",
    "docs/L15-JUNK-TRAPS.md",
    "docs/L60-SELF-CHANGING-CODE.md",
    "verifier/attack.py",
    "verifier/tamper.py",
    "verifier/frida_smoke.py",
    "verifier/sigcheck.py",
    "verifier/ghidra_smoke.py",
    "verifier/frida_test/frida_test.py",
    "verifier/frida_test/frida_script.js",
    "verifier/tests/test_frida_harness.py",
    "tools/make_manifest.py",
    "tools/gen_modblock_blobs.py",
    "tools/make_sig_blob.py",
    "tools/watermark.py",
    "tools/gen_native_blobs.py",
    "tools/run_all.py",
    "tools/layer_coverage.py",
    "tools/profiles.py",
    "tools/keyvault.py",
    "tools/layer_marketplace.py",
    "tools/test_ios_profile.py",
    "tools/make_method_blob.py",
    "transformer/tests/test_self_changing_code.py",
    "profiles/ios.yaml",
    "gradle-plugin/src/main/kotlin/com/antirea/gradle/AntiReaPlugin.kt",
    "gradle-plugin/src/main/kotlin/com/antirea/gradle/AntiReaExtension.kt",
    "gradle-plugin/src/main/kotlin/com/antirea/gradle/AntiReaProtectTask.kt",
    "gradle-plugin/src/main/kotlin/com/antirea/gradle/AntiReaCommand.kt",
    "gradle-plugin/tests/test_antirea_command.py",
    "server/reference.py",
    "service/api.py",
]


def verify_self_check(root=None):
    """Check the code tree against the manifest.

    Returns (ok: bool, problems: list[str]). Missing manifest,
    unreadable manifest, a different file set than SELF_CHECK_FILES,
    a missing file, or a hash mismatch all fail. Never raises.
    """
    root = Path(root) if root is not None else ROOT
    problems = []
    manifest_path = root / MANIFEST_NAME
    if not manifest_path.is_file():
        return False, [
            "manifest missing: %s" % manifest_path,
            "The CLI never runs without its tree. Regenerate with: "
            "python3 tools/make_manifest.py",
        ]
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except Exception as e:
        return False, ["manifest unreadable: %s" % e]
    recorded = manifest.get("files")
    if not isinstance(recorded, dict):
        return False, ["manifest has no 'files' object"]
    missing = [f for f in SELF_CHECK_FILES if f not in recorded]
    extra = [f for f in recorded if f not in SELF_CHECK_FILES]
    if missing:
        problems.append("manifest missing entries: %s" % ", ".join(missing))
    if extra:
        problems.append("manifest has unexpected entries: %s" % ", ".join(extra))
    for f in SELF_CHECK_FILES:
        p = root / f
        if not p.is_file():
            problems.append("missing file: %s" % f)
            continue
        if f in recorded:
            actual = hashlib.sha256(p.read_bytes()).hexdigest()
            if actual != recorded[f]:
                problems.append("hash mismatch (tampered?): %s" % f)
    return (not problems), problems


def cmd_self_check(args):
    ok, problems = verify_self_check()
    if ok:
        print("SELF-CHECK OK: %d files verified against %s"
              % (len(SELF_CHECK_FILES), MANIFEST_NAME))
        return 0
    print("SELF-CHECK FAILED:", file=sys.stderr)
    for p in problems:
        print("  - %s" % p, file=sys.stderr)
    return 2


def find_tool(name):
    for cand in (TOOLS_BIN / name, SDK_BT / name,
                 Path("/usr/bin") / name, Path("/usr/local/bin") / name):
        if cand.is_file() and os.access(cand, os.X_OK):
            return str(cand)
    found = shutil.which(name)
    if found:
        return found
    return None


def run(cmd, cwd=None, env_extra=None, check=True):
    env = dict(os.environ)
    env.setdefault("JAVA_HOME", str(Path.home() / "workspace" / "tools" / "jdk17"))
    if env_extra:
        env.update(env_extra)
    p = subprocess.run(cmd, cwd=cwd, env=env, capture_output=True, text=True)
    if check and p.returncode != 0:
        raise RuntimeError("command failed (%d): %s\nstdout: %s\nstderr: %s"
                           % (p.returncode, " ".join(cmd), p.stdout[-2000:],
                              p.stderr[-2000:]))
    return p


def parse_registry():
    """Parse layers/REGISTRY.md tables into layer dicts (single source)."""
    layers = []
    for line in (HERE / "layers" / "REGISTRY.md").read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line.startswith("| L"):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) < 4 or not re.fullmatch(r"L\d+", cells[0]):
            continue
        layers.append({"id": cells[0], "name": cells[1],
                       "counters": cells[2], "status": cells[3],
                       "where": cells[4] if len(cells) > 4 else ""})
    return layers


def implemented_ids():
    return sorted(l["id"] for l in parse_registry() if l["status"] == "IMPLEMENTED")


def workdir(prefix):
    base = Path("/home/hatch/tmp")
    base.mkdir(parents=True, exist_ok=True)
    return Path(tempfile.mkdtemp(prefix=prefix, dir=str(base)))


# ---------------------------------------------------------------- L06
_RES_STRING_RE = re.compile(
    r'<string\s+name="([^"]+)"[^>]*>([^<]*)</string>')


def _res_value_is_sensitive(value, exact, patterns):
    if any(n in value for n in exact):
        return True
    return any(re.search(p, value) for p in patterns)


def encrypt_res_values(dec, exact, patterns):
    """L06 (finish PARTIAL): encrypt sensitive res/values strings.

    For every <string name="N">value</string> in res/values*.xml whose
    value contains a configured needle (exact or pattern), encrypt
    the WHOLE value with encrypt_payload() (same XOR + split-key blob
    format as L01) and replace the XML text with the placeholder
    "antirea-encrypted:N". Returns (payloads, encrypted_count) where
    payloads maps resource name -> crypto payload dict. The caller
    writes assets/antirea/res_strings.json from payloads so the
    runtime helper (runtime/ReaResStrings.kt) can decrypt on demand.

    Honest limit (unchanged): Android loads res/ itself, so
    getString(R.string.N) returns the PLACEHOLDER. The app must call
    ReaResStrings.decryptResource("N") explicitly for sensitive
    strings. Strings with child markup (e.g. <b> inside <string>)
    are skipped here and fall through to the placeholder sweep.
    """
    payloads = {}
    encrypted = 0
    for xf in sorted(dec.rglob("*.xml")):
        if not xf.parent.name.startswith("values"):
            continue
        try:
            text = xf.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue

        def repl(m):
            nonlocal encrypted
            name, value = m.group(1), m.group(2)
            if not _res_value_is_sensitive(value, exact, patterns):
                return m.group(0)
            key = name
            n = 2
            while key in payloads and payloads[key]["plain_sha256"] != \
                    sha256_hex(value.encode("utf-8")):
                key = "%s__%d" % (name, n)
                n += 1
            payloads[key] = encrypt_payload(value)
            encrypted += 1
            return '<string name="%s">antirea-encrypted:%s</string>' % (name, key)

        new = _RES_STRING_RE.sub(repl, text)
        if new != text:
            xf.write_text(new, encoding="utf-8")
    return payloads, encrypted


def _resolve_profile(cfg, name, impl):
    """Resolve a --profile name via tools/profiles.py (L96)."""
    import importlib.util
    spec = importlib.util.spec_from_file_location(
        "antirea_profiles", HERE / "tools" / "profiles.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.resolve_profile(cfg, name, impl)


# ---------------------------------------------------------------- protect
def cmd_protect(args):
    cfg = load_config(args.config)
    impl = implemented_ids()
    if getattr(args, "profile", None):
        layers = _resolve_profile(cfg, args.profile, impl)
        print("[anti-rea] profile %s: %d layers" % (args.profile, len(layers)))
    else:
        layers = enabled_layers(cfg, impl)
    needles_cfg = protect_lists(cfg)
    honey = honeypots(cfg)
    exact = list(needles_cfg["strings"])
    patterns = list(needles_cfg["patterns"])
    if args.source:
        return protect_source(args, cfg, layers, exact, patterns)
    if not args.apk:
        raise ConfigError("protect needs --apk or --source")
    apktool = find_tool("apktool")
    zipalign = find_tool("zipalign")
    apksigner = find_tool("apksigner")
    keytool = find_tool("keytool")
    for name, tool in (("apktool", apktool), ("zipalign", zipalign),
                       ("apksigner", apksigner), ("keytool", keytool)):
        if not tool:
            raise RuntimeError("required tool not found: %s" % name)
    in_apk = Path(args.apk)
    out_apk = Path(args.out)
    if not in_apk.is_file():
        raise ConfigError("input APK not found: %s" % in_apk)
    wd = workdir("antirea-v10-protect-")
    print("[anti-rea] workdir %s" % wd)
    dec = wd / "decoded"
    print("[anti-rea] apktool decode %s" % in_apk.name)
    run([apktool, "d", "-f", "-o", str(dec), str(in_apk)])
    manifest_xml = dec / "AndroidManifest.xml"
    manifest_text = manifest_xml.read_text(encoding="utf-8", errors="replace")
    m = re.search(r'package="([^"]+)"', manifest_text)
    app_package = m.group(1) if m else "com.antirea.unknown"

    # --- sweep smali for needles (L07 evidence base) ---
    smali_files = sorted(dec.rglob("*.smali"))
    found = {}  # needle -> [files]
    for sf in smali_files:
        try:
            text = sf.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        for needle in smali_mod.find_needles_in_text(text, exact, patterns):
            found.setdefault(needle, []).append(str(sf.relative_to(dec)))
    print("[anti-rea] needles found in smali: %d (%s)"
          % (len(found), sorted(found)[:5]))
    payloads = smali_mod.encrypt_needles(sorted(found))
    stats = {}
    changed = 0
    if "L01" in layers:
        runtime_smali = HERE / "runtime" / "smali"
        if not runtime_smali.is_dir():
            raise RuntimeError(
                "runtime smali missing at %s — run runtime/build_smali.sh "
                "first (L01 needs ReaRuntime in the APK)" % runtime_smali)
        for sf in smali_files:
            if transform_needed(sf, exact, patterns):
                if smali_mod.transform_smali_file(sf, exact, patterns, payloads, stats):
                    changed += 1
        # Static field initializers (Kotlin const val / Java static final)
        # are a separate leak: they hold the literal, not a const-string.
        for sf in smali_files:
            if smali_mod.transform_static_fields(sf, payloads, stats):
                changed += 1
        # inject runtime smali (L46/L47 runtime)
        smali_dirs = sorted(d for d in dec.iterdir()
                            if d.is_dir() and d.name.startswith("smali"))
        target = smali_dirs[0] if smali_dirs else dec / "smali"
        for src in runtime_smali.rglob("*.smali"):
            rel = src.relative_to(runtime_smali)
            dst = target / rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(src, dst)
        print("[anti-rea] L01: %d smali files rewritten, %d strings encrypted, "
              "%d static fields encrypted, %d .line directives stripped"
              % (changed, stats.get("strings_encrypted", 0),
                 stats.get("fields_encrypted", 0),
                 stats.get("lines_stripped", 0)))
        if stats.get("skipped_no_locals"):
            print("[anti-rea] WARNING skipped (no .locals): %d"
                  % len(stats["skipped_no_locals"]))
    # --- smali hardening (L55/L58/L59/L11) ---
    # Runs on the APP's smali only — never on com/antirea/** (runtime,
    # decoys, indirection stubs). Order: chunk -> opaque -> indirect
    # -> flatten LAST (flatten restructures the final instruction
    # stream, and Batch A verified the opaque guard survives it).
    hard_stats = {}
    trap_chain = []
    if any(l in layers for l in ("L55", "L58", "L59", "L11")):
        seed = secrets.randbits(32)
        app_smali = [sf for sf in smali_files
                     if "com/antirea/" not in
                     str(sf.relative_to(dec)).replace(os.sep, "/")]
        if "L55" in layers:
            excl = set()
            for v in payloads.values():
                excl.update((v["blob_b64"], v["key_part1_b64"],
                             v["key_part2_b64"]))
            for sf in app_smali:
                smali_mod.chunk_string_literals(
                    sf, stats=hard_stats, exclude=excl)
        if "L58" in layers:
            for sf in app_smali:
                smali_mod.insert_opaque_predicates(
                    sf, seed=seed, stats=hard_stats)
        indirection_stubs = {}
        if "L59" in layers:
            targets_cfg = (cfg.get("protect") or {}).get("indirect_calls")
            targets = [tuple(t) for t in targets_cfg] if targets_cfg else [
                ("Landroid/app/Activity;", "setContentView")]
            for sf in app_smali:
                smali_mod.indirect_method_calls(
                    sf, targets, indirection_stubs, stats=hard_stats)
            if indirection_stubs:
                smali_mod.write_indirect_stub_class(dec, indirection_stubs)
        if "L11" in layers:
            for sf in app_smali:
                smali_mod.flatten_smali_file(
                    sf, seed=seed, stats=hard_stats)
        print("[anti-rea] hardening L55/L58/L59/L11: %s" % hard_stats)
    # --- native strings (L12) + assets (L13) + native gate .so (L49) ---
    so_report = {"replaced": 0, "skipped": 0, "files": []}
    if "L12" in layers:
        for so in sorted(dec.rglob("*.so")):
            data = so.read_bytes()
            try:
                new_data, rep = native_mod.hide_elf_strings(data, exact)
            except Exception as e:
                print("[anti-rea] L12 skip %s: %s" % (so.name, e))
                continue
            if rep["replaced"]:
                so.write_bytes(new_data)
                so_report["replaced"] += len(rep["replaced"])
                so_report["files"].append(str(so.relative_to(dec)))
            so_report["skipped"] += len(rep["skipped"])
        print("[anti-rea] L12: %d native strings hidden in %d .so files "
              "(%d skipped: substring/not-found)" % (
                  so_report["replaced"], len(so_report["files"]),
                  so_report["skipped"]))
    asset_enc = []
    if "L13" in layers:
        for rel in native_mod.asset_entries_from_config(cfg):
            cand = dec / "assets" / rel
            if not cand.is_file():
                cand = dec / rel
            if not cand.is_file():
                print("[anti-rea] L13 skip missing asset: %s" % rel)
                continue
            enc = native_mod.encrypt_asset_file(cand, stats=hard_stats)
            if enc:
                asset_enc.append({
                    "path": str(cand.relative_to(dec)),
                    "key_part1_b64": enc["key_part1_b64"],
                    "key_part2_b64": enc["key_part2_b64"],
                    "blob_sha256": enc["blob_sha256"],
                    "plain_sha256": enc["plain_sha256"]})
        print("[anti-rea] L13: %d assets encrypted" % len(asset_enc))
    if "L49" in layers:
        gate = HERE / "runtime" / "native" / "lib" / "arm64-v8a" / \
            "libreagate.so"
        if gate.is_file():
            dst = dec / "lib" / "arm64-v8a" / "libreagate.so"
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(gate, dst)
            print("[anti-rea] L49: native gate .so copied (arm64-v8a)")
    # --- traps (L76-L85) ---
    # Smali decoys go under com/antirea/decoy/ (same as L03/L52);
    # text/JSON/XML decoys go under assets/antirea/decoys/ — never
    # loaded by real code. L81 is a header-only ELF placeholder, NOT
    # a loadable lib, so it lives in assets/, never in lib/.
    trap_count = 0
    if any(l in layers for l in
           ("L76", "L77", "L78", "L79", "L80", "L81", "L82", "L83",
            "L84", "L85")):
        decoy_dir = dec / "smali" / "com" / "antirea" / "decoy"
        decoy_dir.mkdir(parents=True, exist_ok=True)
        smali_traps = []
        if "L76" in layers:
            smali_traps.append(
                ("FakeLogin.smali", traps_mod.fake_login_flow()))
        if "L78" in layers:
            smali_traps.append(("SlowMaze.smali", traps_mod.slow_maze()))
        if "L84" in layers:
            smali_traps.append(
                ("DecoyAdmin.smali", traps_mod.honeypot_admin_panel()))
        for name, text in smali_traps:
            (decoy_dir / name).write_text(text, encoding="utf-8")
            trap_count += 1
        tdir = dec / "assets" / "antirea" / "decoys"
        tdir.mkdir(parents=True, exist_ok=True)
        text_traps = []
        if "L77" in layers:
            text_traps.append(("fake-crash.txt", traps_mod.fake_crash()))
        if "L82" in layers:
            text_traps.append(
                ("fake-stacktrace.txt", traps_mod.fake_stack_traces()))
        if "L83" in layers:
            # fake_error_messages() returns a LIST of decoy strings
            # (see transformer/traps.py), not one string — join them
            # or write_text raises TypeError and the protect aborts.
            text_traps.append(
                ("fake-errors.txt",
                 "\n".join(traps_mod.fake_error_messages()) + "\n"))
        if "L80" in layers:
            text_traps.append(
                ("fake-config.json", traps_mod.fake_config_file()))
        for name, text in text_traps:
            (tdir / name).write_text(text, encoding="utf-8")
            trap_count += 1
        if "L81" in layers:
            (tdir / "libantirea-decoy.so").write_bytes(
                traps_mod.fake_native_lib())
            trap_count += 1
        if "L79" in layers:
            rdir = dec / "res" / "values"
            rdir.mkdir(parents=True, exist_ok=True)
            (rdir / "antirea-decoy.xml").write_text(
                traps_mod.fake_update_prompt(), encoding="utf-8")
            trap_count += 1
        if "L85" in layers:
            trap_chain = traps_mod.chain_traps("L76")
        print("[anti-rea] traps L76-L85: %d planted, chain=%s"
              % (trap_count,
                 [c["trap_id"] for c in trap_chain] if trap_chain else []))
    # --- decoys + maze + honeypots (L03/L04/L05/L52/L53/L71-L75) ---
    decoy_count = 0
    if any(l in layers for l in ("L03", "L04", "L05", "L71", "L72", "L73")):
        fakes = list(honey["secrets"]) + list(honey["endpoints"])
        for i, fake in enumerate(fakes):
            smali_mod.write_decoy_smali(dec, i, fake, "getSecret%02d" % i)
            decoy_count += 1
        print("[anti-rea] decoys/honeypots written: %d" % decoy_count)
    maze_count = 0
    if "L53" in layers:
        for i in range(3):
            smali_mod.write_maze_smali(dec, i)
            maze_count += 1
    # --- resource + manifest sweep (L06, L09) ---
    # L06: sensitive res/values strings are ENCRYPTED (blob in
    # assets/antirea/res_strings.json, placeholder in the XML) and
    # decrypted on demand by runtime/ReaResStrings.kt — the app must
    # call decryptResource(name) explicitly; getString() returns the
    # placeholder (Android loads res/ itself, no transparent hook).
    res_replaced = 0
    res_encrypted = 0
    res_payloads = {}
    # L06 runs with the L09 resource sweep: it used to be PARTIAL and
    # piggybacked on L09; it is IMPLEMENTED now (Batch E finished it),
    # so "L06" in layers is the normal path and L09 keeps the sweep
    # contract for configs that enable L09 alone.
    if "L06" in layers or "L09" in layers:
        res_payloads, res_encrypted = encrypt_res_values(dec, exact, patterns)
        if res_payloads:
            assets = dec / "assets" / "antirea"
            assets.mkdir(parents=True, exist_ok=True)
            (assets / "res_strings.json").write_text(json.dumps(
                {"version": 1,
                 "entries": [{"name": n, **p}
                             for n, p in sorted(res_payloads.items())]},
                indent=2), encoding="utf-8")
        print("[anti-rea] L06: %d res/values strings encrypted to "
              "assets/antirea/res_strings.json (decrypt on demand via "
              "ReaResStrings.decryptResource(name); getString() returns "
              "the antirea-encrypted: placeholder)" % res_encrypted)
    if "L06" in layers or "L09" in layers:
        for xf in list(dec.rglob("*.xml")):
            try:
                t = xf.read_text(encoding="utf-8", errors="replace")
            except OSError:
                continue
            new = t
            for needle in exact:
                if needle in new:
                    new = new.replace(needle, "antirea-hidden")
                    res_replaced += 1
            if new != t:
                xf.write_text(new, encoding="utf-8")
        print("[anti-rea] L06/L09: %d needle occurrences replaced in xml "
              "with decoy placeholder (remaining non-values XML; values "
              "strings above are encrypted, not just hidden)" % res_replaced)
    if "L09" in layers:
        inject_provider(manifest_xml, app_package)
    # --- integrity manifest (L19/L22) + REA-IR ---
    rea_ir = {
        "anti_rea_version": VERSION,
        "component_id": "apk.%s" % app_package,
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "input_apk_sha256": sha256_file(in_apk),
        "layers_applied": layers,
        # Only hashes of needles are recorded — never plaintext.
        "needles_found_sha256": sorted(
            sha256_hex(n.encode("utf-8")) for n in found),
        # Payloads are keyed by key_id ONLY — the plaintext needle must
        # never appear in the REA-IR file (only its sha256).
        "payloads": {"k%d" % (i + 1): {
                         "blob_b64": v["blob_b64"],
                         "key_part1_b64": v["key_part1_b64"],
                         "key_part2_b64": v["key_part2_b64"],
                         "blob_sha256": v["blob_sha256"],
                         "plain_sha256": v["plain_sha256"]}
                     for i, (k, v) in enumerate(sorted(payloads.items()))},
        "payload_count": len(payloads),
        "honeypots": {"secrets": honey["secrets"],
                      "endpoints": honey["endpoints"],
                      "tripwire_note": "ANY use of a honeypot value must be "
                      "logged server-side per docs/SERVER.md (L62/L63)."},
        "attestation_format": attestation_format(),
        "tripwire_format": tripwire_format(),
        "stats": stats,
        "decoys": decoy_count,
        "mazes": maze_count,
        "hardening": hard_stats,
        "native_strings": so_report,
        "assets_encrypted": asset_enc,
        "traps": {"count": trap_count, "chain": trap_chain},
        "res_replaced": res_replaced,
        "res_strings": {
            "count": res_encrypted,
            "names": sorted(res_payloads),
            "file": ("assets/antirea/res_strings.json"
                     if res_payloads else None),
            "note": "Encrypted res/values strings. Android getString() "
                    "returns the antirea-encrypted:<name> placeholder; "
                    "the app must call ReaResStrings.decryptResource(name) "
                    "explicitly (L06).",
        },
    }
    # --- L08 R8 rules + L26 build watermark ---
    r8_text = None
    if "L08" in layers:
        r8_text = native_mod.generate_r8_rules(cfg)
    if "L26" in layers:
        import importlib.util as _ilu
        _spec = _ilu.spec_from_file_location(
            "antirea_watermark", HERE / "tools" / "watermark.py")
        _wm = _ilu.module_from_spec(_spec)
        _spec.loader.exec_module(_wm)
        rea_ir = _wm.apply_watermark(rea_ir)
        print("[anti-rea] L26: watermark build_id=%s"
              % rea_ir["watermark"]["build_id"])
    assets = dec / "assets" / "antirea"
    assets.mkdir(parents=True, exist_ok=True)
    (assets / "manifest.json").write_text(
        json.dumps({"rea_ir": "manifest.json", "layers": layers,
                    "blob_sha256": [v["blob_sha256"]
                                    for v in payloads.values()]},
                   indent=2), encoding="utf-8")
    # --- rebuild, inject build hash, align, sign ---
    unsigned = wd / "unsigned.apk"
    print("[anti-rea] apktool rebuild")
    run([apktool, "b", "-o", str(unsigned), str(dec)])
    dex_hash = dex_sha256(unsigned)
    build_info = {"dex_sha256": dex_hash,
                  "rea_ir_sha256": hashlib.sha256(
                      json.dumps(rea_ir, sort_keys=True).encode()).hexdigest(),
                  "layers": layers}
    inject_into_apk(unsigned, "assets/antirea/build.json",
                    json.dumps(build_info, indent=2).encode())
    rea_ir["output_dex_sha256"] = dex_hash
    out_apk.parent.mkdir(parents=True, exist_ok=True)
    aligned = wd / "aligned.apk"
    run([zipalign, "-f", "4", str(unsigned), str(aligned)])
    ks = Path(args.keystore) if args.keystore else wd / "test.keystore"
    if not args.keystore:
        run([keytool, "-genkeypair", "-keystore", str(ks),
             "-storepass", "android", "-keypass", "android",
             "-alias", "antirea-test", "-keyalg", "RSA", "-keysize", "2048",
             "-validity", "365",
             "-dname", "CN=Anti-REA Test, OU=Test, O=Test, C=BD", "-noprompt"])
    run([apksigner, "sign", "--ks", str(ks), "--ks-pass", "pass:android",
         "--key-pass", "pass:android", "--ks-key-alias",
         args.key_alias or "antirea-test",
         "--out", str(out_apk), str(aligned)])
    run([apksigner, "verify", "--verbose", str(out_apk)])
    rea_ir["output_apk_sha256"] = sha256_file(out_apk)
    rea_ir["output_apk_size"] = out_apk.stat().st_size
    rea_dir = Path(args.rea_ir_dir) if args.rea_ir_dir else out_apk.parent / "rea-ir"
    rea_dir.mkdir(parents=True, exist_ok=True)
    rea_path = rea_dir / ("%s.antirea.json" % out_apk.stem)
    rea_path.write_text(json.dumps(rea_ir, indent=2, sort_keys=True),
                        encoding="utf-8")
    if r8_text is not None:
        r8_path = rea_dir / "proguard-rules-antirea.pro"
        r8_path.write_text(r8_text, encoding="utf-8")
        print("[anti-rea] L08: R8 rules written to %s (apply in the "
              "app's own Gradle build; the CLI cannot rename classes "
              "in a built APK)" % r8_path)
    print("[anti-rea] DONE protected=%s sha256=%s size=%d layers=%d "
          "needles=%d strings_encrypted=%d"
          % (out_apk, rea_ir["output_apk_sha256"], rea_ir["output_apk_size"],
             len(layers), len(found), stats.get("strings_encrypted", 0)))
    print("[anti-rea] REA-IR: %s" % rea_path)
    print("[anti-rea] TEST keystore used — this APK will NOT upgrade an "
          "existing install signed with another key.")
    return 0


def transform_needed(sf, exact, patterns):
    try:
        text = sf.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return False
    return bool(smali_mod.find_needles_in_text(text, exact, patterns)
                or ".line " in text)


def dex_sha256(apk_path):
    with zipfile.ZipFile(apk_path) as z:
        names = [n for n in z.namelist() if n.endswith(".dex")]
        h = hashlib.sha256()
        for n in sorted(names):
            h.update(z.read(n))
        return h.hexdigest()


def inject_into_apk(apk_path, arcname, data):
    tmp = apk_path.with_suffix(".tmp.apk")
    with zipfile.ZipFile(apk_path) as zin, \
            zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            if item.filename == arcname:
                continue
            zout.writestr(item, zin.read(item.filename))
        zout.writestr(arcname, data)
    tmp.replace(apk_path)


def inject_provider(manifest_xml, app_package):
    text = manifest_xml.read_text(encoding="utf-8", errors="replace")
    if "ReaGuardProvider" in text:
        return
    provider = ('\n        <provider android:name="com.antirea.runtime.ReaGuardProvider" '
                'android:authorities="%s.antirea.guard" android:exported="false" '
                'android:enabled="true" />' % app_package)
    new, n = re.subn(r"(\s*</application>)", provider + r"\1", text, count=1)
    if n:
        manifest_xml.write_text(new, encoding="utf-8")
        print("[anti-rea] L09: ReaGuardProvider injected into manifest")


def attestation_format():
    return {"type": "antirea-attestation/v1",
            "fields": ["app_package", "build_id", "dex_sha256",
                       "env_findings", "integrity_passed", "timestamp_utc"],
            "note": "Client sends this to the app server; the server "
                    "decides whether to trust the session (L61). "
                    "v1.0 defines the format only — no server code ships."}


def tripwire_format():
    return {"type": "antirea-tripwire/v1",
            "fields": ["tripwire_id", "kind", "app_package", "device_hash",
                       "timestamp_utc"],
            "kinds": ["honeypot_secret_used", "honeypot_endpoint_used",
                      "integrity_failed", "env_suspicious"],
            "note": "Server must log the event and flag the account for "
                    "review (L62/L63). Never auto-punish on one event."}


def protect_source(args, cfg, layers, exact, patterns):
    src_dir, out_dir = Path(args.source), Path(args.out)
    if not src_dir.is_dir():
        raise ConfigError("source dir not found: %s" % src_dir)
    files = [src_dir / f for f in (protect_lists(cfg)["files"] or [])]
    if not files:
        files = sorted(p for p in src_dir.rglob("*") if p.suffix in (".kt", ".java"))
    payloads, total, skipped = {}, 0, []
    for f in files:
        if not f.is_file():
            print("[anti-rea] WARNING source file missing: %s" % f)
            continue
        rel = f.relative_to(src_dir)
        dst = out_dir / rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(f, dst)
        n, sk = source_mod.transform_source_file(dst, exact, patterns, payloads)
        total += n
        skipped.extend("%s:%s" % (rel, s) for _, s in sk)
    rea_ir = {"anti_rea_version": VERSION, "mode": "source",
              "created_utc": datetime.now(timezone.utc).isoformat(),
              "layers_applied": layers,
              "payloads": {"k%d" % (i + 1): {
                               "blob_b64": v["blob_b64"],
                               "key_part1_b64": v["key_part1_b64"],
                               "key_part2_b64": v["key_part2_b64"],
                               "blob_sha256": v["blob_sha256"],
                               "plain_sha256": v["plain_sha256"]}
                          for i, (k, v) in enumerate(sorted(payloads.items()))},
              "strings_replaced": total, "skipped": skipped}
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "rea-ir.json").write_text(json.dumps(rea_ir, indent=2),
                                         encoding="utf-8")
    print("[anti-rea] DONE source protected=%s strings_replaced=%d "
          "skipped=%d" % (out_dir, total, len(skipped)))
    return 0


def _report_sigcheck(apk):
    """L24 — report which signature schemes an APK carries.

    Reporting only; never fails the verify. Never raises.
    """
    try:
        import importlib.util as _ilu
        _spec = _ilu.spec_from_file_location(
            "antirea_sigcheck", HERE / "verifier" / "sigcheck.py")
        _sc = _ilu.module_from_spec(_spec)
        _spec.loader.exec_module(_sc)
        r = _sc.check_apk(apk)
        if r.get("error"):
            print("[anti-rea] L24 sigcheck: %s" % r["error"])
        else:
            print("[anti-rea] L24 sigcheck: v1=%s v2=%s v3=%s v3_1=%s "
                  "signing_block=%s" % (
                      r["v1"], r["v2"], r["v3"], r["v3_1"],
                      r["signing_block_found"]))
    except Exception as e:
        print("[anti-rea] L24 sigcheck unavailable: %s" % e)


# ---------------------------------------------------------------- verify
def cmd_verify(args):
    apk = Path(args.apk)
    if not apk.is_file():
        raise ConfigError("APK not found: %s" % apk)
    cfg = load_config(args.config) if args.config else None
    needles = []
    if cfg:
        needles = list(protect_lists(cfg)["strings"])
        for pat in protect_lists(cfg)["patterns"]:
            needles.append("PATTERN:%s" % pat)
    attack = HERE / "verifier" / "attack.py"
    if attack.is_file() and args.control:
        print("[anti-rea] delegating to verifier/attack.py")
        cmd = [sys.executable, str(attack), "--control", str(args.control),
               "--protected", str(apk), "--needles", ",".join(
                   n for n in needles if not n.startswith("PATTERN:"))]
        p = subprocess.run(cmd)
        _report_sigcheck(apk)
        return p.returncode
    # Built-in fallback: decode + literal sweep (no control comparison).
    apktool = find_tool("apktool")
    if not apktool:
        raise RuntimeError("apktool not found and verifier/attack.py missing")
    wd = workdir("antirea-v10-verify-")
    dec = wd / "decoded"
    run([apktool, "d", "-f", "-o", str(dec), str(apk)])
    hits = {}
    for pat in sorted(dec.rglob("*")):
        if not pat.is_file() or pat.suffix in (".apk", ".dex"):
            continue
        try:
            t = pat.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue
        for n in needles:
            if n.startswith("PATTERN:"):
                continue
            c = t.count(n)
            if c:
                hits[n] = hits.get(n, 0) + c
    print("[anti-rea] verify %s needle hits=%s (want 0)" % (apk.name, hits))
    print("[anti-rea] NOTE: no --control given, so this 0 is NOT proven "
          "non-vacuous — run with --control to prove the test works.")
    _report_sigcheck(apk)
    return 0 if not hits else 1


# ---------------------------------------------------------------- ci (L88)
def cmd_ci(args):
    """CI gate (L88): protect + verify in one command.

    protect runs first; if it fails, CI fails immediately. verify
    then runs the protected APK against the control (default: the
    input APK). Exit 0 only when BOTH pass; any failure is non-zero.
    APK mode only — --source has no APK to verify against.
    """
    if getattr(args, "source", None):
        print("[anti-rea] CI FAIL: ci needs --apk (source mode has no "
              "APK to verify)", file=sys.stderr)
        return 2
    from types import SimpleNamespace
    protect_args = SimpleNamespace(
        apk=args.apk, source=None, config=args.config, out=args.out,
        keystore=args.keystore, key_alias=args.key_alias,
        rea_ir_dir=args.rea_ir_dir, profile=args.profile)
    print("[anti-rea] CI step 1/2: protect")
    try:
        rc = cmd_protect(protect_args)
    except (ConfigError, RuntimeError, FileNotFoundError) as e:
        print("[anti-rea] CI FAIL: protect error: %s" % e, file=sys.stderr)
        return 2
    if rc != 0:
        print("[anti-rea] CI FAIL: protect exited %d" % rc, file=sys.stderr)
        return rc
    print("[anti-rea] CI step 2/2: verify %s against control %s"
          % (args.out, args.control or args.apk))
    verify_args = SimpleNamespace(apk=args.out, config=args.config,
                                  control=args.control or args.apk)
    try:
        rc = cmd_verify(verify_args)
    except (ConfigError, RuntimeError, FileNotFoundError) as e:
        print("[anti-rea] CI FAIL: verify error: %s" % e, file=sys.stderr)
        return 2
    if rc != 0:
        print("[anti-rea] CI FAIL: verify exited %d" % rc, file=sys.stderr)
        return rc
    print("[anti-rea] CI PASS: protect + verify both passed")
    return 0


# ---------------------------------------------------------------- layers
def cmd_layers(args):
    if getattr(args, "coverage", False):
        # L93: delegate to tools/layer_coverage.py, JSON to stdout.
        p = subprocess.run([sys.executable,
                            str(HERE / "tools" / "layer_coverage.py"),
                            "--out", "-"])
        return p.returncode
    layers = parse_registry()
    want = args.status or "all"
    rows = [l for l in layers if want == "all" or l["status"].lower() == want]
    for l in rows:
        print("%s  %-52s %-12s %s" % (l["id"], l["name"][:52], l["status"], l["counters"]))
    counts = {}
    for l in layers:
        counts[l["status"]] = counts.get(l["status"], 0) + 1
    print("total=%d %s" % (len(layers), counts))
    return 0


def main(argv=None):
    ap = argparse.ArgumentParser(prog="anti-rea",
                                 description="Anti-REA v%s — standalone Android protection CLI" % VERSION)
    sub = ap.add_subparsers(dest="cmd", required=True)
    pp = sub.add_parser("protect", help="protect an APK or source tree")
    pp.add_argument("--apk")
    pp.add_argument("--source")
    pp.add_argument("--config", required=True)
    pp.add_argument("--out", required=True)
    pp.add_argument("--keystore")
    pp.add_argument("--key-alias")
    pp.add_argument("--rea-ir-dir")
    pp.add_argument("--profile",
                    help="layer profile: strict, standard, light, or a "
                         "profile defined in the config (L96)")
    pp.set_defaults(fn=cmd_protect)
    cp = sub.add_parser("ci", help="CI gate: protect + verify in one "
                                   "command, non-zero on any failure (L88)")
    cp.add_argument("--apk", required=True)
    cp.add_argument("--config", required=True)
    cp.add_argument("--out", required=True)
    cp.add_argument("--control",
                    help="control APK for verify (default: the input APK)")
    cp.add_argument("--keystore")
    cp.add_argument("--key-alias")
    cp.add_argument("--rea-ir-dir")
    cp.add_argument("--profile",
                    help="layer profile (L96, see protect)")
    cp.set_defaults(fn=cmd_ci)
    vp = sub.add_parser("verify", help="attack-test an APK (control vs protected)")
    vp.add_argument("--apk", required=True)
    vp.add_argument("--config")
    vp.add_argument("--control")
    vp.set_defaults(fn=cmd_verify)
    lp = sub.add_parser("layers", help="list the 101 layer slots")
    lp.add_argument("--list", action="store_true")
    lp.add_argument("--status", choices=["implemented", "partial", "planned", "all"])
    lp.add_argument("--coverage", action="store_true",
                    help="print the L93 JSON coverage report instead")
    lp.set_defaults(fn=cmd_layers)
    sp = sub.add_parser("self-check", help="verify the CLI's own code tree against its manifest")
    sp.set_defaults(fn=cmd_self_check)
    args = ap.parse_args(argv)
    # Self-protection: refuse to run ANY subcommand on a tampered
    # tree. There is no --skip-self-check flag, on purpose.
    # Fail closed: any error inside the check itself is a refusal.
    try:
        ok, problems = verify_self_check()
    except Exception as e:
        ok, problems = False, ["self-check itself failed: %s" % e]
    if not ok:
        print("[anti-rea] SELF-CHECK FAILED — refusing to run:", file=sys.stderr)
        for p in problems:
            print("[anti-rea]   - %s" % p, file=sys.stderr)
        print("[anti-rea] If you just edited a file on purpose, bless it "
              "with: python3 tools/make_manifest.py", file=sys.stderr)
        return 2
    try:
        return args.fn(args)
    except (ConfigError, RuntimeError, FileNotFoundError) as e:
        print("[anti-rea] ERROR: %s" % e, file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())

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

# --- Needle auto-derivation (Agent A contract) -------------------------
# transformer/config.py ships derive_needles(strings) -> list[str] and
# all_needles(cfg) -> list[str]: from every listed protect string it
# derives the forms an attacker can also read — above all the BARE
# HOST of a URL needle (the Bridge slip: the full URL was encrypted
# but a static field holding just "mbbridge.onrender.com" leaked).
# Agent A shipped those functions (scheme/www/port/trailing-slash/
# encoded variants per URL; non-URLs pass through unchanged), and
# transformer/smali.py also derives internally. protect/verify MUST
# still use all_needles(cfg), never the raw listed strings, or
# verify would check a smaller set than protect hides and miss the
# slip. The local fallback below is only a safety net in case
# config.py ever loses the functions; it implements the same
# contract (same names, same minimal semantics: string itself,
# trailing-slash strip, bare host / host:port for every
# scheme://authority occurrence). verifier/attack.py carries the
# same fallback for its standalone runs; verifier/tests/test_needle_
# derivation.py asserts the two resolutions agree on a corpus.
# Deliberately NOT derived anywhere: parent domains
# ("onrender.com" from "mbbridge.onrender.com" is too broad) and
# bare-domain tokens inside prose (false positives).
_SCHEME_HOST_RE = re.compile(r"[A-Za-z][A-Za-z0-9+.-]*://([^/?#\s\"']+)")


def _derive_needles_fallback(strings):
    out, seen = [], set()

    def add(v):
        if v and v not in seen:
            seen.add(v)
            out.append(v)

    for s in strings or []:
        if not s:
            continue
        add(s)
        add(s.rstrip("/"))
        for m in _SCHEME_HOST_RE.finditer(s):
            netloc = m.group(1)
            hostport = netloc.rsplit("@", 1)[-1]
            if not hostport:
                continue
            add(hostport)
            if hostport.startswith("["):
                host = hostport.split("]", 1)[0] + "]"
            else:
                host = hostport.split(":")[0]
            # Bare host only — never the www-stripped form: the
            # fallback must stay a subset of config.derive_needles()
            # (which adds www. but never strips it), so a test
            # asserting fallback ⊆ resolved holds.
            add(host)
    return out


def _all_needles_fallback(cfg):
    return _derive_needles_fallback(protect_lists(cfg)["strings"])


try:
    from config import derive_needles as _cfg_derive_needles, all_needles as _cfg_all_needles  # noqa: E402
    derive_needles, all_needles = _cfg_derive_needles, _cfg_all_needles
    NEEDLE_DERIVATION_SOURCE = "transformer/config.py"
except ImportError:
    derive_needles, all_needles = _derive_needles_fallback, _all_needles_fallback
    NEEDLE_DERIVATION_SOURCE = ("anti-rea.py fallback "
                                "(transformer/config.py has no "
                                "derive_needles/all_needles yet)")

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
    "transformer/tests/test_needle_derivation.py",
    "transformer/tests/test_traps.py",
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
    "runtime/tests/CrashHuntTest.kt",
    "runtime/build_smali.sh",
    "layers/REGISTRY.md",
    "layers/MT-LIKE-BLOCKLIST.md",
    "docs/GAMEGUARDIAN.md",
    "docs/L15-JUNK-TRAPS.md",
    "docs/L60-SELF-CHANGING-CODE.md",
    "verifier/attack.py",
    "verifier/tamper.py",
    "verifier/shipped_names.py",
    "verifier/frida_smoke.py",
    "verifier/sigcheck.py",
    "verifier/ghidra_smoke.py",
    "verifier/frida_test/frida_test.py",
    "verifier/frida_test/frida_script.js",
    "verifier/tests/test_frida_harness.py",
    "verifier/tests/test_needle_derivation.py",
    "verifier/tests/test_cli_errors.py",
    "verifier/tests/test_attack_tamper.py",
    "verifier/tests/test_shipped_names.py",
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
    "service/test_api.py",
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


def partial_ids():
    return sorted(l["id"] for l in parse_registry() if l["status"] == "PARTIAL")


# Layers whose code lives in the injected runtime smali (runtime/*.kt
# compiled to runtime/smali/). They are injected into the APK by
# protect; at runtime the provider auto-invokes the env/mod-block
# ones (L31-L37, L101, L102-via-ReaEnv, L16/L17-via-dex-check) and
# the app itself invokes the rest at its sensitive entry points.
# L60 is deliberately NOT here: runtime/smali/ contains no
# ReaMethodDecrypt/Loader smali, so protect cannot inject it (see
# the L60 registry note). L01 is listed because the smali transform
# emits calls into ReaRuntime.
RUNTIME_LAYER_IDS = frozenset([
    "L01", "L06", "L09", "L13", "L16", "L17", "L18", "L20", "L21",
    "L23", "L25", "L27", "L28", "L29", "L30", "L31", "L32", "L33",
    "L34", "L35", "L36", "L37", "L38", "L39", "L40", "L41", "L42",
    "L43", "L44", "L45", "L46", "L47", "L48", "L49", "L50", "L51",
    "L54", "L56", "L57", "L101", "L102", "L103",
])


def _validate_config(cfg):
    """Fail fast on wrong-typed config sections.

    load_config() parses the YAML subset but never checks types, so
    a section written as a scalar (e.g. ``protect: some-string``)
    used to reach protect_lists()/enabled_layers() as ``str.get``
    and die with an unhandled AttributeError traceback. Every
    mistyped section or list field now raises ConfigError with the
    section name and what was expected.
    """
    if not isinstance(cfg, dict):
        raise ConfigError("config must be a mapping (got %r)" % type(cfg).__name__)
    for name in ("app", "protect", "honeypots", "layers", "runtime",
                 "experimental", "output", "profiles"):
        if name in cfg and cfg[name] is not None \
                and not isinstance(cfg[name], dict):
            raise ConfigError(
                "config section %r must be a mapping (got %r)"
                % (name, cfg[name]))
    p = cfg.get("protect") or {}
    for field in ("strings", "patterns", "classes", "files"):
        v = p.get(field)
        # The YAML-subset parser turns a bare `strings:` (null
        # intended) into {} — the project's own testapp.yaml relies
        # on that for `layers.enable:` — so an EMPTY dict counts as
        # unset here, exactly as enabled_layers()/protect_lists()
        # already treat any falsy value. Only a non-empty dict (or
        # any other non-list) is a real type error.
        if v is not None and not isinstance(v, list) and v != {}:
            raise ConfigError(
                "protect.%s must be a list (got %r)" % (field, v))
        if isinstance(v, list):
            for item in v:
                if not isinstance(item, str):
                    raise ConfigError(
                        "protect.%s items must be strings (got %r)"
                        % (field, item))
    h = cfg.get("honeypots") or {}
    for field in ("secrets", "endpoints"):
        v = h.get(field)
        if v is not None and not isinstance(v, list) and v != {}:
            raise ConfigError(
                "honeypots.%s must be a list (got %r)" % (field, v))
    lay = cfg.get("layers") or {}
    for field in ("enable", "disable"):
        v = lay.get(field)
        if v is not None and not isinstance(v, list) and v != {}:
            raise ConfigError(
                "layers.%s must be a list (got %r)" % (field, v))
    # A PARTIAL layer named in enable is not "PLANNED" — say so
    # exactly. enabled_layers() (transformer/config.py) reports every
    # non-implemented id as PLANNED, which misleads for L15/L60/L91/
    # L98; catch the partial case here first.
    partial = set(partial_ids())
    wanted = set(lay.get("enable") or [])
    hit = sorted(wanted & partial)
    if hit:
        raise ConfigError(
            "layers %s are PARTIAL, not implemented, in v1.0 — remove "
            "them from enable (see layers/REGISTRY.md for what is "
            "missing for each)" % hit)


def _is_protector_smali(rel_posix):
    """True when a decoded-tree-relative smali path belongs to the
    protector's own runtime/decoy classes (never to the app).

    The protector tree is exactly com/appcore/runtime/ (the runtime)
    and com/appcore/cache/ (decoy + maze classes). The OLD tree
    com/antirea/runtime/ + com/antirea/decoy/ is matched too, so
    the filters stay correct while Agent C's package rename is
    still landing. The match is on the exact subpaths — NEVER a
    bare "com/antirea/" or "com/appcore/" prefix, because an app
    may legitimately live under com.antirea.* (the test app is
    com.antirea.testapp) and must never be treated as runtime.
    """
    return any(p in rel_posix for p in (
        "com/appcore/runtime/", "com/appcore/cache/",
        "com/antirea/runtime/", "com/antirea/decoy/"))


def _decoy_dest(assets_dir, name):
    """Collision-safe destination for a planted decoy file.

    Decoy files now live at the top level of assets/ with realistic
    names (config.json, crash-report.txt, ...), so they can collide
    with a real app asset of the same name. Never overwrite a real
    file: try the plain name, then name-2, name-3, ... Returns the
    chosen path (parent already exists).
    """
    cand = assets_dir / name
    if not cand.exists():
        return cand
    stem, suffix = name.rsplit(".", 1) if "." in name else (name, "")
    n = 2
    while True:
        cand = assets_dir / ("%s-%d.%s" % (stem, n, suffix)
                             if suffix else "%s-%d" % (stem, n))
        if not cand.exists():
            return cand
        n += 1


def _rename_protector_paths(dec):
    """Rename the protector's own smali tree after planting, before
    rebuild (decoy-filename rename, user report 2026-11-23).

    What it does, and only this:
      * smali/com/antirea/runtime/ -> smali/com/appcore/runtime/
        (the compiled runtime; Agent C is regenerating it under the
        new package, in which case there is nothing to move and this
        is a no-op).
      * smali/com/antirea/decoy/ -> smali/com/appcore/cache/, with
        DecoyNN.smali -> CacheNN.smali and the .class line renamed
        the same way (MazeNN keeps its name: "maze" is not a banned
        word, and nothing references these classes).
      * In every .smali file, rewrite the two exact protector
        references Lcom/antirea/runtime/ -> Lcom/appcore/runtime/
        and Lcom/antirea/decoy/ -> Lcom/appcore/cache/ (the decrypt
        calls the transform emitted, the ReaIndirect stub refs).
    What it NEVER touches: the app's own smali. The rules match the
    exact protector subpaths only, so an app package such as
    com.antirea.testapp (test app) is byte-identical afterwards.
    Returns (moved_files, rewritten_files).
    """
    moved, rewritten = 0, 0
    old_root = dec / "smali" / "com" / "antirea"
    new_root = dec / "smali" / "com" / "appcore"
    for old_sub, new_sub in (("runtime", "runtime"), ("decoy", "cache")):
        src = old_root / old_sub
        if not src.is_dir():
            continue
        dst = new_root / new_sub
        dst.parent.mkdir(parents=True, exist_ok=True)
        if dst.is_dir():
            for f in src.rglob("*"):
                if f.is_file():
                    rel = f.relative_to(src)
                    target = dst / rel
                    target.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copyfile(f, target)
                    moved += 1
            shutil.rmtree(src)
        else:
            shutil.move(str(src), str(dst))
            moved += sum(1 for _ in dst.rglob("*") if _.is_file())
    if old_root.is_dir() and not any(old_root.rglob("*")):
        shutil.rmtree(old_root, ignore_errors=True)
    # Rename DecoyNN files / .class lines to CacheNN (only inside
    # the moved cache tree).
    cache = new_root / "cache"
    if cache.is_dir():
        for f in sorted(cache.glob("Decoy*.smali")):
            f.rename(cache / ("Cache" + f.name[len("Decoy"):]))
    rules = (("Lcom/antirea/runtime/", "Lcom/appcore/runtime/"),
             ("Lcom/antirea/decoy/", "Lcom/appcore/cache/"),
             ("Lcom/appcore/cache/Decoy", "Lcom/appcore/cache/Cache"))
    for sf in sorted(dec.rglob("*.smali")):
        try:
            text = sf.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        new = text
        for old, rep in rules:
            new = new.replace(old, rep)
        if new != text:
            sf.write_text(new, encoding="utf-8")
            rewritten += 1
    return moved, rewritten


def inject_runtime_smali(dec):
    """Copy the compiled runtime smali into the decoded APK tree.

    Shared by the L01 path and the L01-off path: runtime layers are
    useless if their classes are absent from the APK, so injection
    runs whenever any runtime layer is enabled, not only when L01
    is. Raises RuntimeError (never silently skips) when the smali
    tree is missing — a protect that silently dropped the runtime
    would ship an APK whose decrypt calls have no target.
    """
    runtime_smali = HERE / "runtime" / "smali"
    if not runtime_smali.is_dir():
        raise RuntimeError(
            "runtime smali missing at %s — run runtime/build_smali.sh "
            "first (runtime layers need the com/appcore classes in "
            "the APK)" % runtime_smali)
    smali_dirs = sorted(d for d in dec.iterdir()
                        if d.is_dir() and d.name.startswith("smali"))
    target = smali_dirs[0] if smali_dirs else dec / "smali"
    for src in runtime_smali.rglob("*.smali"):
        rel = src.relative_to(runtime_smali)
        dst = target / rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(src, dst)
    return target


def strip_debug_lines(dec):
    """L14 standalone pass: drop .line directives from app smali.

    transform_smali_file() strips .line only as part of the L01
    transform, so a config enabling L14 without L01 used to strip
    nothing. This pass covers exactly that case (L01 on: the
    transform already did it, do not run twice). Returns the count
    of directives removed.
    """
    removed = 0
    for sf in sorted(dec.rglob("*.smali")):
        if _is_protector_smali(
                str(sf.relative_to(dec)).replace(os.sep, "/")):
            continue
        try:
            lines = sf.read_text(encoding="utf-8", errors="replace").splitlines()
        except OSError:
            continue
        kept = [ln for ln in lines if not smali_mod.LINE_RE.match(ln)]
        if len(kept) != len(lines):
            removed += len(lines) - len(kept)
            sf.write_text("\n".join(kept) + "\n", encoding="utf-8")
    return removed


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
    "meta-encrypted:N". Returns (payloads, encrypted_count) where
    payloads maps resource name -> crypto payload dict. The caller
    writes assets/meta/res_strings.json from payloads so the
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
            return '<string name="%s">meta-encrypted:%s</string>' % (name, key)

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
    _validate_config(cfg)
    impl = implemented_ids()
    if getattr(args, "profile", None):
        layers = _resolve_profile(cfg, args.profile, impl)
        print("[anti-rea] profile %s: %d layers" % (args.profile, len(layers)))
    else:
        layers = enabled_layers(cfg, impl)
    needles_cfg = protect_lists(cfg)
    honey = honeypots(cfg)
    # Derived needles, not just the listed ones: a URL needle also
    # hides its bare host (L01 slip class), and verify checks the
    # same derived set — see the derivation note at the top of
    # this file. patterns are regexes and are never derived.
    exact = list(all_needles(cfg))
    print("[anti-rea] needles: %d listed, %d after derivation (%s)"
          % (len(needles_cfg["strings"]), len(exact),
             NEEDLE_DERIVATION_SOURCE))
    patterns = list(needles_cfg["patterns"])
    if args.source:
        return protect_source(args, cfg, layers, exact, patterns)
    if not args.apk:
        raise ConfigError("protect needs --apk or --source")
    in_apk = Path(args.apk)
    out_apk = Path(args.out)
    if not in_apk.is_file():
        raise ConfigError("input APK not found: %s" % in_apk)
    apktool = find_tool("apktool")
    zipalign = find_tool("zipalign")
    apksigner = find_tool("apksigner")
    keytool = find_tool("keytool")
    for name, tool in (("apktool", apktool), ("zipalign", zipalign),
                       ("apksigner", apksigner), ("keytool", keytool)):
        if not tool:
            raise RuntimeError("required tool not found: %s" % name)
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
        # Pass exact + patterns explicitly: without them the pass only
        # derives from payload keys already collected, and a field
        # value matching ONLY a pattern would be missed (see
        # transform_static_fields() docstring).
        for sf in smali_files:
            if smali_mod.transform_static_fields(sf, payloads, stats, exact, patterns):
                changed += 1
        # inject runtime smali (L46/L47 runtime)
        inject_runtime_smali(dec)
        print("[anti-rea] L01: %d smali files rewritten, %d strings encrypted, "
              "%d static fields encrypted, %d .line directives stripped"
              % (changed, stats.get("strings_encrypted", 0),
                 stats.get("fields_encrypted", 0),
                 stats.get("lines_stripped", 0)))
        if stats.get("skipped_no_locals"):
            print("[anti-rea] WARNING skipped (no .locals): %d"
                  % len(stats["skipped_no_locals"]))
    else:
        # Runtime layers without L01: the runtime classes must still
        # be in the APK or the provider / app-invoked checks have no
        # code to call (previously the injection lived inside the
        # L01 block, so disabling L01 silently dropped every runtime
        # layer). L14 without L01 gets its standalone strip pass.
        if set(layers) & RUNTIME_LAYER_IDS:
            inject_runtime_smali(dec)
            print("[anti-rea] runtime smali injected (L01 off, %d "
                  "runtime layers enabled)"
                  % len(set(layers) & RUNTIME_LAYER_IDS))
        if "L14" in layers:
            n = strip_debug_lines(dec)
            print("[anti-rea] L14: %d .line directives stripped "
                  "(standalone pass, L01 off)" % n)
    # --- smali hardening (L55/L58/L59/L11) ---
    # Runs on the APP's smali only — never on the protector's own
    # classes (runtime, decoys, indirection stubs). Order: chunk ->
    # opaque -> indirect -> flatten LAST (flatten restructures the
    # final instruction stream, and Batch A verified the opaque
    # guard survives it).
    hard_stats = {}
    trap_chain = []
    if any(l in layers for l in ("L55", "L58", "L59", "L11")):
        seed = secrets.randbits(32)
        app_smali = [sf for sf in smali_files
                     if not _is_protector_smali(
                         str(sf.relative_to(dec)).replace(os.sep, "/"))]
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
    # Decoy filenames are REALISTIC (user report 2026-11-23: files
    # literally named "fake-*" in a file manager advertise the
    # protector). No shipped filename or path may contain fake,
    # decoy, antirea, honeypot or trap — see verifier/shipped_names.py
    # and its scan test. The tripwire-id marker stays INSIDE the file
    # contents (that is what flags use); only names/paths changed.
    # Smali decoys live under com/appcore/<area>/ with plausible
    # class names (transformer/traps.py already declares them that
    # way); text/JSON/XML decoys live at the top level of assets/
    # with realistic names — never loaded by real code. The res
    # decoy is res/values/update.xml. Decoy destinations are
    # collision-safe: a real app file of the same name is never
    # overwritten (see _decoy_dest). L81 is a header-only ELF
    # placeholder, NOT a loadable lib, so it lives in assets/,
    # never in lib/.
    trap_count = 0
    trap_files = []
    if any(l in layers for l in
           ("L76", "L77", "L78", "L79", "L80", "L81", "L82", "L83",
            "L84", "L85")):
        smali_traps = []
        if "L76" in layers:
            smali_traps.append(
                ("auth", "LoginManager.smali", traps_mod.fake_login_flow()))
        if "L78" in layers:
            smali_traps.append(
                ("sync", "RetryWorker.smali", traps_mod.slow_maze()))
        if "L84" in layers:
            smali_traps.append(
                ("admin", "AdminPanel.smali",
                 traps_mod.honeypot_admin_panel()))
        for subpkg, name, text in smali_traps:
            d = dec / "smali" / "com" / "appcore" / subpkg
            d.mkdir(parents=True, exist_ok=True)
            (d / name).write_text(text, encoding="utf-8")
            trap_files.append("smali/com/appcore/%s/%s" % (subpkg, name))
            trap_count += 1
        assets_dir = dec / "assets"
        assets_dir.mkdir(parents=True, exist_ok=True)
        text_traps = []
        if "L77" in layers:
            text_traps.append(("crash-report.txt", traps_mod.fake_crash()))
        if "L82" in layers:
            text_traps.append(
                ("stacktrace.txt", traps_mod.fake_stack_traces()))
        if "L83" in layers:
            # fake_error_messages() returns a LIST of decoy strings
            # (see transformer/traps.py), not one string — join them
            # or write_text raises TypeError and the protect aborts.
            text_traps.append(
                ("error-log.txt",
                 "\n".join(traps_mod.fake_error_messages()) + "\n"))
        if "L80" in layers:
            text_traps.append(
                ("config.json", traps_mod.fake_config_file()))
        for name, text in text_traps:
            dest = _decoy_dest(assets_dir, name)
            dest.write_text(text, encoding="utf-8")
            trap_files.append("assets/%s" % dest.name)
            trap_count += 1
        if "L81" in layers:
            dest = _decoy_dest(assets_dir, "libconfig.so")
            dest.write_bytes(traps_mod.fake_native_lib())
            trap_files.append("assets/%s" % dest.name)
            trap_count += 1
        if "L79" in layers:
            rdir = dec / "res" / "values"
            rdir.mkdir(parents=True, exist_ok=True)
            dest = _decoy_dest(rdir, "update.xml")
            dest.write_text(traps_mod.fake_update_prompt(),
                            encoding="utf-8")
            trap_files.append("res/values/%s" % dest.name)
            trap_count += 1
        if "L85" in layers:
            trap_chain = traps_mod.chain_traps("L76")
        print("[anti-rea] traps L76-L85: %d planted (%s), chain=%s"
              % (trap_count, trap_files,
                 [c["trap_id"] for c in trap_chain] if trap_chain else []))
    # --- decoys + maze + honeypots (L03/L04/L05/L52/L53/L71-L75) ---
    # One shared decoy writer serves L03/L04/L05 (honeypot literals),
    # L10 (decoy-class camouflage), L52 (decoy classes), L71/L72/L73
    # (fake endpoints/secrets/keys) and L74 (decoy API methods):
    # every one of them is the same planted com/appcore/cache/ class,
    # so the gate must list all of them — L10/L52/L74 used to be
    # missing here, so enabling only those layers planted nothing.
    # The classes are written by transformer/smali.py under
    # com/antirea/decoy/ and renamed to com/appcore/cache/ (DecoyNN
    # -> CacheNN) by _rename_protector_paths() before rebuild.
    decoy_count = 0
    if any(l in layers for l in ("L03", "L04", "L05", "L10", "L52",
                                 "L71", "L72", "L73", "L74")):
        fakes = list(honey["secrets"]) + list(honey["endpoints"])
        for i, fake in enumerate(fakes):
            smali_mod.write_decoy_smali(dec, i, fake, "getSecret%02d" % i)
            decoy_count += 1
        print("[anti-rea] decoys/honeypots written: %d" % decoy_count)
    maze_count = 0
    # L75 (maze classes) is the same write_maze_smali() output as
    # L53 (dead-code maze) — the gate must list both, or enabling
    # only L75 plants nothing.
    if "L53" in layers or "L75" in layers:
        for i in range(3):
            smali_mod.write_maze_smali(dec, i)
            maze_count += 1
    # --- resource + manifest sweep (L06, L09) ---
    # L06: sensitive res/values strings are ENCRYPTED (blob in
    # assets/meta/res_strings.json, placeholder in the XML) and
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
            assets = dec / "assets" / "meta"
            assets.mkdir(parents=True, exist_ok=True)
            (assets / "res_strings.json").write_text(json.dumps(
                {"version": 1,
                 "entries": [{"name": n, **p}
                             for n, p in sorted(res_payloads.items())]},
                indent=2), encoding="utf-8")
        print("[anti-rea] L06: %d res/values strings encrypted to "
              "assets/meta/res_strings.json (decrypt on demand via "
              "ReaResStrings.decryptResource(name); getString() returns "
              "the meta-encrypted: placeholder)" % res_encrypted)
    if "L06" in layers or "L09" in layers:
        for xf in list(dec.rglob("*.xml")):
            try:
                t = xf.read_text(encoding="utf-8", errors="replace")
            except OSError:
                continue
            new = t
            for needle in exact:
                if needle in new:
                    new = new.replace(needle, "meta-hidden")
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
        # Derived needles (bare hosts etc.) that protect also hid;
        # listed strings are in the config, derived ones are not,
        # so record which forms derivation added (hashes only).
        "needles_derived_sha256": sorted(
            sha256_hex(n.encode("utf-8")) for n in
            set(exact) - set(needles_cfg["strings"])),
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
        "traps": {"count": trap_count, "chain": trap_chain,
                  "files": trap_files},
        "res_replaced": res_replaced,
        "res_strings": {
            "count": res_encrypted,
            "names": sorted(res_payloads),
            "file": ("assets/meta/res_strings.json"
                     if res_payloads else None),
            "note": "Encrypted res/values strings. Android getString() "
                    "returns the meta-encrypted:<name> placeholder; "
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
    assets = dec / "assets" / "meta"
    assets.mkdir(parents=True, exist_ok=True)
    (assets / "manifest.json").write_text(
        json.dumps({"rea_ir": "manifest.json", "layers": layers,
                    "blob_sha256": [v["blob_sha256"]
                                    for v in payloads.values()]},
                   indent=2), encoding="utf-8")
    # --- protector-path rename (decoy-filename fix) ---
    # Runs LAST before rebuild, after every planting step: moves
    # the protector's own smali tree from com/antirea/ to
    # com/appcore/ (runtime + decoy/cache) and rewrites the exact
    # protector references in smali text. See
    # _rename_protector_paths() — the app's own smali is untouched.
    moved, rewritten = _rename_protector_paths(dec)
    if moved or rewritten:
        print("[anti-rea] protector paths renamed: %d files moved to "
              "com/appcore/, %d smali files rewritten"
              % (moved, rewritten))
    # --- rebuild, inject build hash, align, sign ---
    unsigned = wd / "unsigned.apk"
    print("[anti-rea] apktool rebuild")
    run([apktool, "b", "-o", str(unsigned), str(dec)])
    dex_hash = dex_sha256(unsigned)
    build_info = {"dex_sha256": dex_hash,
                  "rea_ir_sha256": hashlib.sha256(
                      json.dumps(rea_ir, sort_keys=True).encode()).hexdigest(),
                  "layers": layers}
    inject_into_apk(unsigned, "assets/meta/build.json",
                    json.dumps(build_info, indent=2).encode())
    rea_ir["output_dex_sha256"] = dex_hash
    out_apk.parent.mkdir(parents=True, exist_ok=True)
    aligned = wd / "aligned.apk"
    run([zipalign, "-f", "4", str(unsigned), str(aligned)])
    ks = Path(args.keystore) if args.keystore else wd / "test.keystore"
    if not args.keystore:
        run([keytool, "-genkeypair", "-keystore", str(ks),
             "-storepass", "android", "-keypass", "android",
             "-alias", "appcore-test", "-keyalg", "RSA", "-keysize", "2048",
             "-validity", "365",
             "-dname", "CN=AppCore Test, OU=Test, O=Test, C=BD", "-noprompt"])
    run([apksigner, "sign", "--ks", str(ks), "--ks-pass", "pass:android",
         "--key-pass", "pass:android", "--ks-key-alias",
         args.key_alias or "appcore-test",
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
        r8_path = rea_dir / "proguard-rules-appcore.pro"
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
    provider = ('\n        <provider android:name="com.appcore.runtime.ReaGuardProvider" '
                'android:authorities="%s.appcore.guard" android:exported="false" '
                'android:enabled="true" />' % app_package)
    new, n = re.subn(r"(\s*</application>)", provider + r"\1", text, count=1)
    if n:
        manifest_xml.write_text(new, encoding="utf-8")
        print("[anti-rea] L09: ReaGuardProvider injected into manifest")


def attestation_format():
    return {"type": "attestation/v1",
            "fields": ["app_package", "build_id", "dex_sha256",
                       "env_findings", "integrity_passed", "timestamp_utc"],
            "note": "Client sends this to the app server; the server "
                    "decides whether to trust the session (L61). "
                    "v1.0 defines the format only — no server code ships."}


def tripwire_format():
    return {"type": "tripwire/v1",
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


def _report_shipped_names(apk):
    """Decoy-filename scan (user report 2026-11-23) — warning only.

    Flags shipped filenames/paths containing fake/decoy/antirea/
    honeypot/trap. Reporting only; never fails the verify and never
    raises — the scan test (verifier/tests/test_shipped_names.py)
    is the enforcing check. Wiring the scan into the verdict is a
    follow-up for after the committed testapp APKs are re-protected
    under the new naming (they still carry the old names).
    """
    try:
        import importlib.util as _ilu
        _spec = _ilu.spec_from_file_location(
            "antirea_shipped_names", HERE / "verifier" / "shipped_names.py")
        _sn = _ilu.module_from_spec(_spec)
        _spec.loader.exec_module(_sn)
        bad = _sn.scan_apk(apk)
        if bad:
            print("[anti-rea] WARNING shipped names: %d self-identifying "
                  "filename(s) (fake/decoy/antirea/honeypot/trap): %s"
                  % (len(bad), bad[:10]))
        else:
            print("[anti-rea] shipped names: OK (no banned words in "
                  "filenames)")
    except Exception as e:
        print("[anti-rea] shipped-names scan unavailable: %s" % e)


# ---------------------------------------------------------------- verify
def cmd_verify(args):
    apk = Path(args.apk)
    if not apk.is_file():
        raise ConfigError("APK not found: %s" % apk)
    cfg = load_config(args.config) if args.config else None
    needles = []
    if cfg:
        _validate_config(cfg)
        # Derived needles too — verify must check the bare host (and
        # every other derived form), not just the listed strings,
        # or a protect slip that leaves the bare host behind would
        # pass verify unnoticed.
        needles = list(all_needles(cfg))
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
        _report_shipped_names(apk)
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
    _report_shipped_names(apk)
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
    except (ConfigError, RuntimeError, FileNotFoundError, ValueError,
            OSError) as e:
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
    except (ConfigError, RuntimeError, FileNotFoundError, ValueError,
            OSError) as e:
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
    except (ConfigError, RuntimeError, FileNotFoundError, ValueError,
            OSError) as e:
        print("[anti-rea] ERROR: %s" % e, file=sys.stderr)
        return 2
    except Exception as e:  # backstop: bad input must never traceback
        print("[anti-rea] ERROR: %s: %s"
              % (type(e).__name__, e), file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())

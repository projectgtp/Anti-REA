#!/usr/bin/env python3
"""Anti-REA v1.0 — L92 regression suite (re-run on every build).

Runs every suite in one command and reports pass/fail per suite:

  1. self-check    anti-rea.py self-check (CLI code-tree manifest)
  2. jvm-runtime   ReaRuntime decrypt + tamper-refuse (fresh blob)
  3. jvm-modblock  L101 ModBlockTest (13 blocked packages)
  4. jvm-ggfix     L102/L103 GameGuardianFixTest
  5. jvm-resstrings L06 ReaResStringsTest (Python-encrypted JSON ->
                   Kotlin decrypt + tamper-refuse)
  6. cli-verify    verifier/attack.py control vs protected testapp
  7. coverage      tools/layer_coverage.py parses + total == 103
  8. keyvault      tools/keyvault.py selftest (round-trip + rotate)
  9. marketplace   tools/layer_marketplace.py test (sample plugin)
  10. profiles     light vs strict resolve to different layer sets
  11. ghidra-smoke verifier/ghidra_smoke.py on a tiny built .so
                   (skip with --skip-ghidra; ~20 s when run)
  12. junk-traps   L15 transformer/tests/test_junk.py (28 tests)
  13. frida-harness L89 verifier/tests/test_frida_harness.py (20 tests)
                   + frida_test.py --dry-run
  14. ios-profile  L99 tools/test_ios_profile.py (12 tests)
  15. gradle-plugin L98 gradle-plugin/tests/test_antirea_command.py
                   (26 tests; Kotlin itself uncompiled — see registry)
  16. jvm-methoddecrypt L60 ReaMethodDecrypt core (seal/open/rotate/
                   tamper/wrong-key/bad-input/verify)
  17. self-changing  L60 flag tests (default ON, explicit false OFF) +
                   make_method_blob.py --self-test

Usage:
  python3 tools/run_all.py [--skip-ghidra] [--out report.json]

Every suite compiles fresh from source into a temp dir under
/home/hatch/tmp (never /tmp, never the repo) — stale jars in
runtime/tests/ are NOT trusted. Exit 0 iff every suite passes.
A suite that cannot run (missing tool, missing file) is FAIL with
the reason, never skipped silently. Python stdlib only.
"""
import argparse
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
HOME = Path.home()
TOOLS = HOME / "workspace" / "tools"
KOTLINC = TOOLS / "kotlin-2.0.21" / "bin" / "kotlinc"
JDK17 = TOOLS / "jdk17"
ANDROID_JAR = TOOLS / "android-sdk" / "platforms" / "android-36" / "android.jar"
STDLIB = TOOLS / "kotlin-2.0.21" / "lib" / "kotlin-stdlib.jar"

sys.path.insert(0, str(ROOT / "transformer"))
from crypto import encrypt_payload  # noqa: E402


def run(cmd, cwd=None, env_extra=None, timeout=300):
    env = dict(os.environ)
    env.setdefault("JAVA_HOME", str(JDK17))
    if env_extra:
        env.update(env_extra)
    try:
        p = subprocess.run(cmd, cwd=cwd, env=env, capture_output=True,
                           text=True, timeout=timeout)
        return p.returncode, (p.stdout or "") + (p.stderr or "")
    except subprocess.TimeoutExpired:
        return -1, "TIMEOUT after %ds: %s" % (timeout, " ".join(cmd))
    except OSError as e:
        return -1, "could not run %s: %s" % (cmd[0], e)


def suite(name):
    def deco(fn):
        fn._suite_name = name
        return fn
    return deco


class Runner:
    def __init__(self, work, skip_ghidra):
        self.work = work
        self.skip_ghidra = skip_ghidra
        self.results = []
        self.java = str(JDK17 / "bin" / "java")

    def record(self, name, ok, detail):
        self.results.append({"suite": name, "pass": bool(ok),
                             "detail": detail[:2000]})
        print("[%s] %s — %s" % ("PASS" if ok else "FAIL", name,
                                detail.splitlines()[0][:160]
                                if detail else ""))

    def kotlinc(self, jar, sources):
        cmd = [str(KOTLINC), "-cp", str(ANDROID_JAR), "-d", str(jar),
               *[str(s) for s in sources]]
        return run(cmd, timeout=300)

    def java_run(self, jar, main, args, extra_cp=""):
        cp = str(jar) + ":" + str(STDLIB)
        if extra_cp:
            cp += ":" + extra_cp
        return run([self.java, "-cp", cp, main, *args], timeout=120)

    # --- suites ------------------------------------------------------
    def s_self_check(self):
        rc, out = run([sys.executable, str(ROOT / "anti-rea.py"),
                       "self-check"], timeout=60)
        self.record("self-check", rc == 0,
                    out.strip().splitlines()[-1] if out.strip() else
                    "rc=%d" % rc)

    def s_jvm_runtime(self):
        rt = ROOT / "runtime"
        jar = self.work / "test.jar"
        rc, out = self.kotlinc(jar, [rt / "ReaRuntime.kt",
                                     rt / "tests" / "Main.kt"])
        if rc != 0:
            return self.record("jvm-runtime", False,
                               "kotlinc failed: " + out[-500:])
        payload = encrypt_payload("antirea-v1-test-value-hello")
        tampered = ("B" if payload["blob_b64"][0] != "B" else "A") \
            + payload["blob_b64"][1:]
        rc, out = self.java_run(
            jar, "com.antirea.runtime.MainKt",
            [payload["blob_b64"], payload["key_part1_b64"],
             payload["key_part2_b64"], "antirea-v1-test-value-hello",
             tampered])
        self.record("jvm-runtime", rc == 0 and "TEST-PASS" in out,
                    out.strip().splitlines()[-1] if out.strip() else
                    "rc=%d" % rc)

    def s_jvm_modblock(self):
        rt = ROOT / "runtime"
        jar = self.work / "modblock-test.jar"
        rc, out = self.kotlinc(jar, [rt / "ReaRuntime.kt",
                                     rt / "ReaModBlock.kt",
                                     rt / "ModBlockData.kt",
                                     rt / "tests" / "ModBlockTest.kt"])
        if rc != 0:
            return self.record("jvm-modblock", False,
                               "kotlinc failed: " + out[-500:])
        rc, out = self.java_run(
            jar, "com.antirea.runtime.ModBlockTestKt", [],
            extra_cp=str(ANDROID_JAR))
        self.record("jvm-modblock", rc == 0 and "TEST-PASS" in out,
                    out.strip().splitlines()[-1] if out.strip() else
                    "rc=%d" % rc)

    def s_jvm_ggfix(self):
        rt = ROOT / "runtime"
        jar = self.work / "ggfix-test.jar"
        rc, out = self.kotlinc(jar, [rt / "ReaRuntime.kt",
                                     rt / "ReaIntegrity.kt",
                                     rt / "ReaTrace.kt",
                                     rt / "ReaEnv.kt",
                                     rt / "ReaMemory.kt",
                                     rt / "ReaRepack.kt",
                                     rt / "tests" / "GameGuardianFixTest.kt"])
        if rc != 0:
            return self.record("jvm-ggfix", False,
                               "kotlinc failed: " + out[-500:])
        rc, out = self.java_run(
            jar, "com.antirea.runtime.GameGuardianFixTestKt", [],
            extra_cp=str(ANDROID_JAR))
        self.record("jvm-ggfix", rc == 0 and "TEST-PASS" in out,
                    out.strip().splitlines()[-1] if out.strip() else
                    "rc=%d" % rc)

    def s_jvm_resstrings(self):
        rt = ROOT / "runtime"
        jar = self.work / "resstrings-test.jar"
        rc, out = self.kotlinc(jar, [rt / "ReaRuntime.kt",
                                     rt / "ReaResStrings.kt",
                                     rt / "tests" / "ReaResStringsTest.kt"])
        if rc != 0:
            return self.record("jvm-resstrings", False,
                               "kotlinc failed: " + out[-500:])
        payload = encrypt_payload("https://testapp.example.invalid/api")
        entry = {"name": "api_base", "blob_b64": payload["blob_b64"],
                 "key_part1_b64": payload["key_part1_b64"],
                 "key_part2_b64": payload["key_part2_b64"],
                 "plain_sha256": payload["plain_sha256"]}
        good = self.work / "res_strings.json"
        good.write_text(json.dumps({"version": 1, "entries": [entry]}))
        bad_entry = dict(entry, blob_b64=(
            ("B" if entry["blob_b64"][0] != "B" else "A")
            + entry["blob_b64"][1:]))
        bad = self.work / "res_strings_tampered.json"
        bad.write_text(json.dumps({"version": 1, "entries": [bad_entry]}))
        rc, out = self.java_run(
            jar, "com.antirea.runtime.ReaResStringsTestKt",
            [str(good), "api_base",
             "https://testapp.example.invalid/api", str(bad)])
        self.record("jvm-resstrings", rc == 0 and "TEST-PASS" in out,
                    out.strip().splitlines()[-1] if out.strip() else
                    "rc=%d" % rc)

    def s_cli_verify(self):
        control = ROOT / "tests" / "testapp" / "testapp-control.apk"
        protected = ROOT / "tests" / "testapp" / "testapp-protected.apk"
        if not control.is_file() or not protected.is_file():
            return self.record("cli-verify", False,
                               "control or protected testapp APK missing")
        out_path = self.work / "attack-report.json"
        rc, out = run([sys.executable, str(ROOT / "verifier" / "attack.py"),
                       "--control", str(control),
                       "--protected", str(protected),
                       "--needles",
                       "TEST-SECRET-7f3a9-generic,testapp.example.invalid",
                       "--out", str(out_path)], timeout=600)
        verdict = ""
        if out_path.is_file():
            try:
                verdict = json.loads(out_path.read_text()).get(
                    "verdict", "")
            except Exception:
                pass
        self.record("cli-verify", rc == 0 and verdict == "PASS",
                    "attack verdict=%s rc=%d" % (verdict, rc))

    def s_coverage(self):
        out_path = self.work / "coverage.json"
        rc, out = run([sys.executable,
                       str(ROOT / "tools" / "layer_coverage.py"),
                       "--out", str(out_path)], timeout=60)
        ok, detail = False, out.strip()
        if rc == 0 and out_path.is_file():
            try:
                rep = json.loads(out_path.read_text())
                ok = rep.get("total_layers") == 103
                detail = ("total=%d counts=%s" % (
                    rep.get("total_layers"), rep.get("counts_by_status")))
            except Exception as e:
                detail = "coverage JSON unreadable: %s" % e
        self.record("coverage", ok, detail)

    def s_keyvault(self):
        rc, out = run([sys.executable,
                       str(ROOT / "tools" / "keyvault.py"), "selftest"],
                      timeout=120)
        self.record("keyvault", rc == 0 and "KEYVAULT-SELFTEST-PASS" in out,
                    out.strip().splitlines()[-1] if out.strip() else
                    "rc=%d" % rc)

    def s_marketplace(self):
        rc, out = run([sys.executable,
                       str(ROOT / "tools" / "layer_marketplace.py"),
                       "test"], timeout=60)
        self.record("marketplace",
                    rc == 0 and "MARKETPLACE-TEST-PASS" in out,
                    out.strip().splitlines()[-1] if out.strip() else
                    "rc=%d" % rc)

    def s_profiles(self):
        cfg = ROOT / "tests" / "testapp.yaml"
        outs = {}
        for profile in ("light", "strict"):
            rc, out = run([sys.executable,
                           str(ROOT / "tools" / "profiles.py"),
                           "--config", str(cfg), "--profile", profile],
                          timeout=60)
            if rc != 0:
                return self.record("profiles", False,
                                   "%s resolve failed rc=%d" % (profile, rc))
            outs[profile] = json.loads(out)
        ok = (outs["light"]["layers"] != outs["strict"]["layers"]
              and set(outs["light"]["layers"])
              < set(outs["strict"]["layers"])
              and outs["light"]["count"] == 18)
        self.record("profiles", ok,
                    "light=%d strict=%d (light ⊂ strict)"
                    % (outs["light"]["count"], outs["strict"]["count"]))

    def s_junk_traps(self):
        rc, out = run([sys.executable,
                       str(ROOT / "transformer" / "tests" / "test_junk.py")],
                      timeout=120)
        self.record("junk-traps", rc == 0 and "OK" in out,
                    out.strip().splitlines()[-1] if out.strip() else
                    "rc=%d" % rc)

    def s_frida_harness(self):
        rc, out = run([sys.executable,
                       str(ROOT / "verifier" / "tests"
                           / "test_frida_harness.py")], timeout=120)
        if rc != 0 or "OK" not in out:
            return self.record("frida-harness", False,
                               out.strip().splitlines()[-1]
                               if out.strip() else "rc=%d" % rc)
        rc2, out2 = run([sys.executable,
                         str(ROOT / "verifier" / "frida_test"
                             / "frida_test.py"), "--dry-run"], timeout=120)
        self.record("frida-harness",
                    rc2 == 0 and "dry-run classifier: OK" in out2,
                    "unit OK + dry-run rc=%d" % rc2)

    def s_ios_profile(self):
        rc, out = run([sys.executable,
                       str(ROOT / "tools" / "test_ios_profile.py")],
                      timeout=120)
        self.record("ios-profile", rc == 0 and "OK" in out,
                    out.strip().splitlines()[-1] if out.strip() else
                    "rc=%d" % rc)

    def s_gradle_plugin(self):
        rc, out = run([sys.executable,
                       str(ROOT / "gradle-plugin" / "tests"
                           / "test_antirea_command.py")], timeout=120)
        self.record("gradle-plugin", rc == 0 and "OK" in out,
                    out.strip().splitlines()[-1] if out.strip() else
                    "rc=%d" % rc)

    def s_jvm_methoddecrypt(self):
        rt = ROOT / "runtime"
        jar = self.work / "methoddecrypt-test.jar"
        rc, out = self.kotlinc(jar, [rt / "ReaMethodDecrypt.kt",
                                     rt / "tests" / "MethodDecryptTest.kt"])
        if rc != 0:
            return self.record("jvm-methoddecrypt", False,
                               "kotlinc failed: " + out[-500:])
        rc, out = self.java_run(
            jar, "com.antirea.runtime.MethodDecryptTestKt", [])
        self.record("jvm-methoddecrypt", rc == 0 and "TEST-PASS" in out,
                    out.strip().splitlines()[-1] if out.strip() else
                    "rc=%d" % rc)

    def s_self_changing(self):
        rc, out = run([sys.executable,
                       str(ROOT / "transformer" / "tests"
                           / "test_self_changing_code.py")], timeout=120)
        if rc != 0 or "OK" not in out:
            return self.record("self-changing", False,
                               out.strip().splitlines()[-1]
                               if out.strip() else "rc=%d" % rc)
        payload = self.work / "l60-payload.bin"
        payload.write_bytes(b"L60-SELF-TEST-PAYLOAD-1234")
        rc2, out2 = run([sys.executable,
                         str(ROOT / "tools" / "make_method_blob.py"),
                         "--self-test", str(payload)], timeout=60)
        self.record("self-changing",
                    rc2 == 0 and "SELF-TEST OK" in out2,
                    "flag tests OK + blob self-test rc=%d" % rc2)

    def s_ghidra_smoke(self):
        if self.skip_ghidra:
            self.results.append({"suite": "ghidra-smoke", "pass": None,
                                 "detail": "skipped (--skip-ghidra)"})
            print("[SKIP] ghidra-smoke — --skip-ghidra")
            return
        src = self.work / "tiny.c"
        src.write_text(
            'const char *ghidra_smoke_string = '
            '"GHIDRA-SMOKE-STRING-1234";\n'
            'int ghidra_smoke_add(int a, int b) { return a + b; }\n')
        so = self.work / "libtiny.so"
        rc, out = run(["gcc", "-shared", "-fPIC", "-O2", "-o", str(so),
                       str(src)], timeout=60)
        if rc != 0:
            return self.record("ghidra-smoke", False,
                               "gcc failed: " + out[-300:])
        out_path = self.work / "ghidra-smoke-report.json"
        rc, out = run([sys.executable,
                       str(ROOT / "verifier" / "ghidra_smoke.py"),
                       "--so", str(so),
                       "--needles", "GHIDRA-SMOKE-STRING-1234",
                       "--out", str(out_path)], timeout=180)
        verdict = ""
        if out_path.is_file():
            try:
                rep = json.loads(out_path.read_text())
                verdict = rep.get("verdict", "")
            except Exception:
                pass
        self.record("ghidra-smoke", rc == 0 and verdict == "PASS",
                    "ghidra verdict=%s rc=%d" % (verdict, rc))

    def run_all(self):
        for fn in (self.s_self_check, self.s_jvm_runtime,
                   self.s_jvm_modblock, self.s_jvm_ggfix,
                   self.s_jvm_resstrings, self.s_cli_verify,
                   self.s_coverage, self.s_keyvault, self.s_marketplace,
                   self.s_profiles, self.s_ghidra_smoke,
                   self.s_junk_traps, self.s_frida_harness,
                   self.s_ios_profile, self.s_gradle_plugin,
                   self.s_jvm_methoddecrypt, self.s_self_changing):
            try:
                fn()
            except Exception as e:
                self.record(fn.__name__, False,
                            "suite raised: %s: %s" % (type(e).__name__, e))
        passed = sum(1 for r in self.results if r["pass"] is True)
        failed = [r["suite"] for r in self.results if r["pass"] is False]
        skipped = [r["suite"] for r in self.results if r["pass"] is None]
        return {"generated_utc": datetime.now(timezone.utc).isoformat(),
                "suites": self.results, "passed": passed,
                "failed": failed, "skipped": skipped,
                "verdict": "PASS" if not failed else "FAIL"}


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--skip-ghidra", action="store_true")
    ap.add_argument("--out", default="",
                    help="report JSON path (default: <work>/report.json)")
    args = ap.parse_args(argv)
    for tool, path in (("kotlinc", KOTLINC), ("android.jar", ANDROID_JAR),
                       ("kotlin-stdlib.jar", STDLIB)):
        if not Path(path).exists():
            print("ERROR: missing %s at %s" % (tool, path), file=sys.stderr)
            return 2
    base = Path("/home/hatch/tmp")
    base.mkdir(parents=True, exist_ok=True)
    work = Path(tempfile.mkdtemp(prefix="antirea-run-all-", dir=str(base)))
    print("workdir: %s" % work)
    runner = Runner(work, args.skip_ghidra)
    report = runner.run_all()
    out_path = Path(args.out) if args.out else work / "report.json"
    out_path.write_text(json.dumps(report, indent=2), encoding="utf-8")
    print("\nSUITES: %d passed, %d failed%s"
          % (report["passed"], len(report["failed"]),
             (", skipped: %s" % ", ".join(report["skipped"]))
             if report["skipped"] else ""))
    if report["failed"]:
        print("FAILED: %s" % ", ".join(report["failed"]))
    print("VERDICT: %s" % report["verdict"])
    print("report: %s" % out_path)
    return 0 if report["verdict"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())

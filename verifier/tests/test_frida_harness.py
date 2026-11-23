#!/usr/bin/env python3
"""Unit tests for the L89 Frida runtime-test harness.

Proves, with no device and no Frida installed:
  * frida_test.py parses and imports (stdlib only).
  * --dry-run exits 0 and classifies the protected-behaviour scenario
    as all PASS and the attacker-wins scenario as all BREAK.
  * Every check (F1..F5) has an expected result defined: a PASS
    description, a BREAK description, an INCONCLUSIVE description,
    and non-empty pass/break tag lists.
  * A fake "hook succeeded" transcript is classified BREAK (DETECTED),
    never silently passed — including the nasty case where the hook
    fired AND the app noticed Frida afterwards (BREAK still wins).
  * The Frida agent script exists and hooks the real runtime targets.
  * Live mode refuses cleanly when its prerequisites are missing
    (no device in this VM) instead of faking a live result.

Usage:
  python3 verifier/tests/test_frida_harness.py
Exit 0 on pass, non-zero on any failure. Python stdlib only.
"""
import json
import subprocess
import sys
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
V10 = HERE.parent.parent  # anti-rea/v1.0
FRIDA_DIR = V10 / "verifier" / "frida_test"
HARNESS = FRIDA_DIR / "frida_test.py"
AGENT = FRIDA_DIR / "frida_script.js"

sys.path.insert(0, str(FRIDA_DIR))
import frida_test  # noqa: E402


class TestHarnessParses(unittest.TestCase):
    def test_files_exist(self):
        for p in (HARNESS, AGENT, FRIDA_DIR / "README.md"):
            self.assertTrue(p.is_file(), f"missing {p}")

    def test_harness_compiles(self):
        r = subprocess.run([sys.executable, "-m", "py_compile", str(HARNESS)],
                           capture_output=True, text=True)
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_agent_js_is_plain_text(self):
        text = AGENT.read_text()
        self.assertIn("ReaRuntime", text)
        self.assertIn("decrypt", text)
        self.assertIn("verifyIntegrity", text)
        self.assertIn("ReaEnv", text)
        self.assertIn("checkAll", text)
        self.assertIn("MEMSCAN", text)
        self.assertIn("CertificatePinner", text)


class TestEveryCheckHasExpectations(unittest.TestCase):
    def test_five_checks(self):
        self.assertEqual([c["id"] for c in frida_test.CHECKS],
                         ["F1", "F2", "F3", "F4", "F5"])

    def test_each_check_fully_specified(self):
        for c in frida_test.CHECKS:
            for field in ("name", "title", "target", "method",
                          "pass_when", "break_when", "inconclusive_when"):
                self.assertTrue(c[field].strip(),
                                f"{c['id']}: empty {field}")
            self.assertTrue(c["pass_tags"], f"{c['id']}: no pass tags")
            # A check proves BREAK either by a single break tag or by
            # a compound rule (all listed tags together, e.g. F1).
            self.assertTrue(c["break_tags"] or c.get("break_needs_all"),
                            f"{c['id']}: no break evidence defined")
            # Pass and break tags must not overlap — else the
            # classifier could never tell them apart.
            self.assertFalse(set(c["pass_tags"]) & set(c["break_tags"]),
                             f"{c['id']}: tag overlap")

    def test_list_checks_runs(self):
        r = subprocess.run([sys.executable, str(HARNESS), "--list-checks"],
                           capture_output=True, text=True)
        self.assertEqual(r.returncode, 0, r.stderr)
        for cid in ("F1", "F2", "F3", "F4", "F5"):
            self.assertIn(cid, r.stdout)


class TestDryRun(unittest.TestCase):
    def test_dry_run_exits_zero(self):
        r = subprocess.run([sys.executable, str(HARNESS), "--dry-run"],
                           capture_output=True, text=True)
        self.assertEqual(r.returncode, 0, r.stderr + r.stdout)
        self.assertIn("dry-run classifier: OK", r.stdout)

    def test_dry_run_scenarios(self):
        results, ok = frida_test.run_dry_run()
        self.assertTrue(ok)
        clean = [r for r in results if r["scenario"] == "protected-behaviour"]
        broken = [r for r in results if r["scenario"] == "attacker-wins"]
        self.assertEqual(len(clean), 5)
        self.assertTrue(all(r["verdict"] == "PASS" for r in clean))
        self.assertEqual(len(broken), 5)
        self.assertTrue(all(r["verdict"] == "BREAK" for r in broken))

    def test_dry_run_report_json(self):
        out = Path("/home/hatch/tmp/l89-dry-run-report.json")
        r = subprocess.run([sys.executable, str(HARNESS), "--dry-run",
                            "--out", str(out)],
                           capture_output=True, text=True)
        self.assertEqual(r.returncode, 0, r.stderr)
        report = json.loads(out.read_text())
        self.assertEqual(report["layer"], "L89")
        self.assertEqual(report["mode"], "dry-run")
        self.assertTrue(report["dry_run_classifier_ok"])
        self.assertEqual(report["summary"]["PASS"], 5)
        self.assertIn("no live device run happened", report["claim"])
        out.unlink()


class TestClassification(unittest.TestCase):
    def test_f1_attach_alone_is_not_a_break(self):
        # The agent must attach to read ReaEnv at all, so ATTACHED
        # appears in the protected scenario too. Only ATTACHED +
        # ENV_CLEAN together is a break.
        attached_only = "[ANTIREA] ATTACHED pid=12345\n"
        verdict, _ = frida_test.classify("F1", attached_only)
        self.assertEqual(verdict, "INCONCLUSIVE")
        verdict, _ = frida_test.classify("F1", frida_test.FAKE_CLEAN["F1"])
        self.assertEqual(verdict, "PASS")
        verdict, _ = frida_test.classify("F1", frida_test.FAKE_BREAK["F1"])
        self.assertEqual(verdict, "BREAK")

    def test_hook_succeeded_is_break_not_pass(self):
        fake = ("[ANTIREA] ATTACHED pid=12345\n"
                "[ANTIREA] HOOK_FIRED decrypt\n"
                "[ANTIREA] DECRYPT_PLAINTEXT prefix=TEST-SEC len=24\n")
        verdict, evidence = frida_test.classify("F3", fake)
        self.assertEqual(verdict, "BREAK", evidence)
        self.assertIn("HOOK_FIRED", evidence)

    def test_hook_fired_then_app_noticed_is_still_break(self):
        # The nasty case: the hook worked AND the app later detected
        # Frida. The hook still worked, so BREAK must win over PASS.
        verdict, evidence = frida_test.classify(
            "F3", frida_test.FAKE_HOOK_THEN_DETECTED)
        self.assertEqual(verdict, "BREAK", evidence)

    def test_clean_hook_output_is_pass(self):
        verdict, _ = frida_test.classify("F3", frida_test.FAKE_CLEAN["F3"])
        self.assertEqual(verdict, "PASS")

    def test_memscan_found_is_break(self):
        verdict, _ = frida_test.classify("F4", frida_test.FAKE_BREAK["F4"])
        self.assertEqual(verdict, "BREAK")

    def test_memscan_clean_is_pass(self):
        verdict, _ = frida_test.classify("F4", frida_test.FAKE_CLEAN["F4"])
        self.assertEqual(verdict, "PASS")

    def test_ssl_intercept_is_break(self):
        verdict, _ = frida_test.classify("F5", frida_test.FAKE_BREAK["F5"])
        self.assertEqual(verdict, "BREAK")

    def test_empty_output_is_inconclusive_not_pass(self):
        for cid in ("F1", "F2", "F3", "F4", "F5"):
            verdict, _ = frida_test.classify(cid, "")
            self.assertEqual(verdict, "INCONCLUSIVE", cid)
            verdict, _ = frida_test.classify(cid, "some unrelated log line\n")
            self.assertEqual(verdict, "INCONCLUSIVE", cid)

    def test_from_file_classifies_a_break_transcript(self):
        transcript = Path("/home/hatch/tmp/l89-fake-transcript.txt")
        transcript.write_text(
            "[ANTIREA] ATTACHED pid=12345\n"
            "[ANTIREA] HOOK_FIRED decrypt\n"
            "[ANTIREA] DECRYPT_PLAINTEXT prefix=TEST-SEC len=24\n")
        r = subprocess.run([sys.executable, str(HARNESS), "--from-file",
                            str(transcript), "--check", "F3"],
                           capture_output=True, text=True)
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("BREAK", r.stdout)
        transcript.unlink()


class TestLiveModeRefusesWithoutDevice(unittest.TestCase):
    def test_prereqs_report_missing_frida(self):
        # Frida is not installed in this VM; the harness must say so.
        missing = frida_test.check_prereqs()
        self.assertTrue(any("frida" in m for m in missing), missing)

    def test_live_run_exits_two_not_zero(self):
        r = subprocess.run([sys.executable, str(HARNESS),
                            "--package", "com.antirea.testapp"],
                           capture_output=True, text=True, timeout=60)
        self.assertEqual(r.returncode, 2, r.stdout + r.stderr)
        self.assertIn("live run not possible", r.stderr)


if __name__ == "__main__":
    unittest.main(verbosity=2)

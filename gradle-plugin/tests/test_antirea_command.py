#!/usr/bin/env python3
"""Anti-REA Gradle plugin (L98) — pure-logic unit tests. Stdlib only.

These tests do NOT need Gradle, a Gradle daemon, or kotlinc (none of them
work in this VM). They test a Python MIRROR of the pure-logic object
`AntiReaCommand` in src/main/kotlin/com/antirea/gradle/AntiReaCommand.kt,
which is deliberately written with no Gradle imports so its logic is
independently testable.

Mirror risk, stated plainly: a Python copy can drift from the Kotlin
original. Two guards against that:
  1. test_kotlin_source_matches_mirror() reads the .kt file and asserts
     the default constants and the CLI argument words in it match the
     mirror's values.
  2. The mirror functions are kept line-for-line small and named the same
     as the Kotlin ones (resolve_config_path, build_command, ...).

Run:  python3 tests/test_antirea_command.py
"""
import os
import re
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
PLUGIN_DIR = os.path.dirname(HERE)
KT = os.path.join(
    PLUGIN_DIR, "src/main/kotlin/com/antirea/gradle/AntiReaCommand.kt")


# ---------------------------------------------------------------- mirror
# Python mirror of AntiReaCommand (Kotlin). Keep names and behaviour
# identical; if the Kotlin changes, this file must change with it.

DEFAULT_CONFIG_FILE_NAME = "anti-rea.yaml"
DEFAULT_CLI_FILE_NAME = "anti-rea.py"
DEFAULT_PYTHON = "python3"
DEFAULT_APK_RELATIVE_PATH = "build/outputs/apk/release/app-release.apk"
TASK_NAME = "protectApk"
ASSEMBLE_TASK_NAME = "assembleRelease"


def resolve_config_path(project_dir, configured):
    return configured if configured and configured.strip() \
        else os.path.join(project_dir, DEFAULT_CONFIG_FILE_NAME)


def resolve_cli_script_path(project_dir, configured):
    return configured if configured and configured.strip() \
        else os.path.join(project_dir, DEFAULT_CLI_FILE_NAME)


def resolve_apk_path(project_dir, configured):
    return configured if configured and configured.strip() \
        else os.path.join(project_dir, DEFAULT_APK_RELATIVE_PATH)


def default_output_path(apk_path):
    if apk_path.endswith(".apk"):
        return apk_path[:-len(".apk")] + "-protected.apk"
    return apk_path + "-protected.apk"


def build_command(python, cli_script, apk, config, out,
                  profile=None, keystore=None, key_alias=None):
    cmd = [python, cli_script, "protect",
           "--apk", apk, "--config", config, "--out", out]
    if profile and profile.strip():
        cmd += ["--profile", profile]
    if keystore and keystore.strip():
        cmd += ["--keystore", keystore]
    if key_alias and key_alias.strip():
        cmd += ["--key-alias", key_alias]
    return cmd


class ProtectionFailed(Exception):
    """Mirror of the Kotlin IllegalStateException raised on failure."""


def validate_inputs(cli_exists, cli_path, config_exists, config_path,
                    apk_exists, apk_path):
    missing = []
    if not cli_exists:
        missing.append("CLI script not found: %s" % cli_path)
    if not config_exists:
        missing.append("config not found: %s" % config_path)
    if not apk_exists:
        missing.append("input APK not found: %s" % apk_path)
    if missing:
        raise ProtectionFailed("[anti-rea] cannot protect: " + "; ".join(missing))


def check_exit_code(exit_code, command):
    if exit_code != 0:
        raise ProtectionFailed(
            "[anti-rea] protect failed with exit code %d: %s"
            % (exit_code, " ".join(command)))


# ---------------------------------------------------------------- tests
class TestConfigResolution(unittest.TestCase):
    def test_config_default(self):
        self.assertEqual(resolve_config_path("/proj", None),
                         "/proj/anti-rea.yaml")

    def test_config_override_wins(self):
        self.assertEqual(resolve_config_path("/proj", "/etc/my.yaml"),
                         "/etc/my.yaml")

    def test_config_blank_override_falls_back_to_default(self):
        self.assertEqual(resolve_config_path("/proj", "   "),
                         "/proj/anti-rea.yaml")

    def test_cli_default(self):
        self.assertEqual(resolve_cli_script_path("/proj", None),
                         "/proj/anti-rea.py")

    def test_cli_override_wins(self):
        self.assertEqual(resolve_cli_script_path("/proj", "/opt/anti-rea.py"),
                         "/opt/anti-rea.py")

    def test_apk_default_is_agp_release_path(self):
        self.assertEqual(
            resolve_apk_path("/proj", None),
            "/proj/build/outputs/apk/release/app-release.apk")

    def test_apk_override_wins(self):
        self.assertEqual(
            resolve_apk_path("/proj", "/proj/build/outputs/apk/debug/app.apk"),
            "/proj/build/outputs/apk/debug/app.apk")


class TestOutputPath(unittest.TestCase):
    def test_protected_suffix_before_extension(self):
        self.assertEqual(default_output_path("app-release.apk"),
                         "app-release-protected.apk")

    def test_input_apk_never_overwritten(self):
        out = default_output_path("/proj/app-release.apk")
        self.assertNotEqual(out, "/proj/app-release.apk")

    def test_non_apk_input_gets_suffix(self):
        self.assertEqual(default_output_path("/proj/app"),
                         "/proj/app-protected.apk")


class TestCommandConstruction(unittest.TestCase):
    def test_minimal_command_matches_cli(self):
        # Must match anti-rea.py: protect --apk --config --out
        self.assertEqual(
            build_command("python3", "/proj/anti-rea.py",
                          "/proj/app.apk", "/proj/anti-rea.yaml",
                          "/proj/app-protected.apk"),
            ["python3", "/proj/anti-rea.py", "protect",
             "--apk", "/proj/app.apk",
             "--config", "/proj/anti-rea.yaml",
             "--out", "/proj/app-protected.apk"])

    def test_profile_appended_only_when_set(self):
        cmd = build_command("python3", "anti-rea.py", "a.apk", "c.yaml",
                            "o.apk", profile="light")
        self.assertIn("--profile", cmd)
        self.assertEqual(cmd[cmd.index("--profile") + 1], "light")

    def test_no_profile_flag_when_absent(self):
        cmd = build_command("python3", "anti-rea.py", "a.apk", "c.yaml",
                            "o.apk", profile=None)
        self.assertNotIn("--profile", cmd)
        cmd2 = build_command("python3", "anti-rea.py", "a.apk", "c.yaml",
                             "o.apk", profile="  ")
        self.assertNotIn("--profile", cmd2)

    def test_keystore_and_alias_appended(self):
        cmd = build_command("python3", "anti-rea.py", "a.apk", "c.yaml",
                            "o.apk", keystore="/k.jks", key_alias="release")
        self.assertEqual(cmd[cmd.index("--keystore") + 1], "/k.jks")
        self.assertEqual(cmd[cmd.index("--key-alias") + 1], "release")

    def test_no_keystore_flags_when_absent(self):
        cmd = build_command("python3", "anti-rea.py", "a.apk", "c.yaml",
                            "o.apk")
        self.assertNotIn("--keystore", cmd)
        self.assertNotIn("--key-alias", cmd)


class TestFailureHandling(unittest.TestCase):
    def test_exit_zero_passes(self):
        check_exit_code(0, ["python3", "anti-rea.py"])  # no raise

    def test_exit_one_fails(self):
        with self.assertRaises(ProtectionFailed) as ctx:
            check_exit_code(1, ["python3", "anti-rea.py", "protect"])
        self.assertIn("exit code 1", str(ctx.exception))

    def test_exit_127_fails_and_names_command(self):
        with self.assertRaises(ProtectionFailed) as ctx:
            check_exit_code(127, ["python3", "missing.py"])
        self.assertIn("missing.py", str(ctx.exception))

    def test_missing_cli_fails(self):
        with self.assertRaises(ProtectionFailed) as ctx:
            validate_inputs(False, "/proj/anti-rea.py",
                            True, "/proj/anti-rea.yaml",
                            True, "/proj/app.apk")
        self.assertIn("CLI script not found", str(ctx.exception))

    def test_missing_config_fails(self):
        with self.assertRaises(ProtectionFailed):
            validate_inputs(True, "/proj/anti-rea.py",
                            False, "/proj/anti-rea.yaml",
                            True, "/proj/app.apk")

    def test_missing_apk_fails(self):
        with self.assertRaises(ProtectionFailed) as ctx:
            validate_inputs(True, "/proj/anti-rea.py",
                            True, "/proj/anti-rea.yaml",
                            False, "/proj/app.apk")
        self.assertIn("input APK not found", str(ctx.exception))

    def test_all_missing_lists_every_file(self):
        with self.assertRaises(ProtectionFailed) as ctx:
            validate_inputs(False, "cli.py", False, "c.yaml",
                            False, "a.apk")
        msg = str(ctx.exception)
        self.assertIn("cli.py", msg)
        self.assertIn("c.yaml", msg)
        self.assertIn("a.apk", msg)

    def test_all_present_passes(self):
        validate_inputs(True, "cli.py", True, "c.yaml",
                        True, "a.apk")  # no raise


class TestKotlinSourceMatchesMirror(unittest.TestCase):
    """Guard against mirror drift: the .kt defaults and CLI words must
    equal the mirror's. (Does not prove the Kotlin compiles.)"""

    def test_kotlin_source_matches_mirror(self):
        with open(KT, encoding="utf-8") as f:
            src = f.read()
        for const in (DEFAULT_CONFIG_FILE_NAME, DEFAULT_CLI_FILE_NAME,
                      DEFAULT_PYTHON, DEFAULT_APK_RELATIVE_PATH,
                      TASK_NAME, ASSEMBLE_TASK_NAME):
            self.assertIn('"%s"' % const, src,
                          "Kotlin source missing constant %r" % const)
        for word in ('"protect"', '"--apk"', '"--config"', '"--out"',
                     '"--profile"', '"--keystore"', '"--key-alias"',
                     '"-protected.apk"'):
            self.assertIn(word, src, "Kotlin source missing %s" % word)

    def test_plugin_wires_assemble_and_registers_task(self):
        plugin = os.path.join(
            PLUGIN_DIR,
            "src/main/kotlin/com/antirea/gradle/AntiReaPlugin.kt")
        with open(plugin, encoding="utf-8") as f:
            src = f.read()
        self.assertIn("tasks.register", src)
        self.assertIn("afterEvaluate", src)
        self.assertIn("finalizedBy", src)
        self.assertIn("Plugin<Project>", src)

    def test_task_fails_closed(self):
        task = os.path.join(
            PLUGIN_DIR,
            "src/main/kotlin/com/antirea/gradle/AntiReaProtectTask.kt")
        with open(task, encoding="utf-8") as f:
            src = f.read()
        self.assertIn("GradleException", src)
        self.assertIn("@TaskAction", src)
        self.assertIn("checkExitCode", src)
        self.assertIn("validateInputs", src)


if __name__ == "__main__":
    unittest.main(verbosity=2)

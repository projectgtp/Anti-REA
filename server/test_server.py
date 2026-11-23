#!/usr/bin/env python3
"""Anti-REA v1.0 — tests for server/reference.py (L64-L70).

Run from the v1.0 directory:
    python3 -m unittest server.test_server -v
or:
    python3 server/test_server.py
Stdlib only. No network, no live server, no deployment.
"""
import json
import sys
import unittest
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import reference as ref


def _ts(iso):
    return datetime.strptime(iso, "%Y-%m-%dT%H:%M:%SZ").replace(
        tzinfo=timezone.utc).timestamp()


class TestL64ComponentHashes(unittest.TestCase):
    def test_accept_all_match(self):
        r = ref.verify_component_hashes(
            {"classes.dex": "aa", "manifest": "bb"},
            {"classes.dex": "aa", "manifest": "bb"})
        self.assertTrue(r["accepted"])
        self.assertEqual(r["mismatched"], [])
        self.assertEqual(r["missing"], [])

    def test_reject_mismatch(self):
        r = ref.verify_component_hashes(
            {"classes.dex": "aa"}, {"classes.dex": "ff"})
        self.assertFalse(r["accepted"])
        self.assertEqual(r["mismatched"], ["classes.dex"])
        self.assertIn("mismatch", r["reason"])

    def test_reject_missing(self):
        r = ref.verify_component_hashes(
            {"classes.dex": "aa"}, {"classes.dex": "aa", "manifest": "bb"})
        self.assertFalse(r["accepted"])
        self.assertEqual(r["missing"], ["manifest"])

    def test_case_insensitive_hex(self):
        r = ref.verify_component_hashes(
            {"classes.dex": "AA"}, {"classes.dex": "aa"})
        self.assertTrue(r["accepted"])

    def test_unexpected_reported_not_fatal(self):
        r = ref.verify_component_hashes(
            {"classes.dex": "aa", "extra": "cc"}, {"classes.dex": "aa"})
        self.assertTrue(r["accepted"])
        self.assertEqual(r["unexpected"], ["extra"])

    def test_empty_expected_rejects_fail_closed(self):
        # A server with no expected hashes configured must never
        # accept everything (vacuous-accept bug, audit 2026-11-23).
        r = ref.verify_component_hashes({"classes.dex": "aa"}, {})
        self.assertFalse(r["accepted"])
        self.assertIn("no expected", r["reason"])
        r = ref.verify_component_hashes({}, {})
        self.assertFalse(r["accepted"])


class TestL65DeviceBinding(unittest.TestCase):
    def test_bind_and_check_accept(self):
        att = {"build_id": "1.0.0+abc", "dex_sha256": "aa",
               "integrity_passed": True}
        stored = ref.bind_device("server-issued-device-123", att)
        self.assertNotIn("server-issued-device-123",
                         json.dumps(stored))  # raw id never stored
        self.assertEqual(stored["build_id"], "1.0.0+abc")
        r = ref.check_device_binding(stored, "server-issued-device-123")
        self.assertTrue(r["accepted"])

    def test_check_reject_wrong_device(self):
        stored = ref.bind_device("device-A", {})
        r = ref.check_device_binding(stored, "device-B")
        self.assertFalse(r["accepted"])
        self.assertIn("does not match", r["reason"])

    def test_check_reject_no_binding(self):
        r = ref.check_device_binding(None, "device-A")
        self.assertFalse(r["accepted"])

    def test_check_accepts_dict_presented(self):
        stored = ref.bind_device("device-A", {})
        r = ref.check_device_binding(stored, {"device_id": "device-A"})
        self.assertTrue(r["accepted"])

    def test_bind_empty_device_id_raises(self):
        with self.assertRaises(ValueError):
            ref.bind_device("", {})

    def test_check_non_dict_stored_rejects(self):
        # A corrupt stored value must reject, not raise AttributeError.
        r = ref.check_device_binding("not-a-dict", "device-A")
        self.assertFalse(r["accepted"])


class TestL66RateLimit(unittest.TestCase):
    def test_allow_then_block_at_limit(self):
        lim = ref.FailedAttestationLimiter(max_failures=3, window_seconds=60)
        t = 1_000_000.0
        self.assertTrue(lim.allow("dev-1", now=t))
        self.assertFalse(lim.record_failure("dev-1", now=t))
        self.assertFalse(lim.record_failure("dev-1", now=t + 10))
        self.assertTrue(lim.record_failure("dev-1", now=t + 20))
        self.assertTrue(lim.is_blocked("dev-1", now=t + 20))
        self.assertFalse(lim.allow("dev-1", now=t + 20))
        self.assertEqual(lim.failures_in_window("dev-1", now=t + 20), 3)

    def test_window_slides_fake_timestamps(self):
        lim = ref.FailedAttestationLimiter(max_failures=2, window_seconds=60)
        t = 1_000_000.0
        lim.record_failure("dev-1", now=t)
        lim.record_failure("dev-1", now=t + 10)
        self.assertTrue(lim.is_blocked("dev-1", now=t + 30))
        # Oldest failures slide out after the window passes.
        self.assertFalse(lim.is_blocked("dev-1", now=t + 61))
        self.assertEqual(lim.failures_in_window("dev-1", now=t + 61), 1)
        self.assertTrue(lim.allow("dev-1", now=t + 61))

    def test_per_device_isolation(self):
        lim = ref.FailedAttestationLimiter(max_failures=1, window_seconds=60)
        lim.record_failure("dev-1", now=1000.0)
        self.assertTrue(lim.is_blocked("dev-1", now=1000.0))
        self.assertFalse(lim.is_blocked("dev-2", now=1000.0))

    def test_bad_params_raise(self):
        with self.assertRaises(ValueError):
            ref.FailedAttestationLimiter(max_failures=0)
        with self.assertRaises(ValueError):
            ref.FailedAttestationLimiter(window_seconds=0)
        with self.assertRaises(ValueError):
            ref.FailedAttestationLimiter(max_devices=0)

    def test_device_cap_bounds_state(self):
        # Spamming distinct device ids must not grow state without
        # limit (audit 2026-11-23).
        lim = ref.FailedAttestationLimiter(max_failures=5,
                                           window_seconds=3600,
                                           max_devices=3)
        for i in range(5):
            lim.record_failure("dev-%d" % i, now=1000.0 + i)
        self.assertLessEqual(len(lim._failures), 3)
        self.assertNotIn("dev-0", lim._failures)
        self.assertNotIn("dev-1", lim._failures)
        self.assertIn("dev-4", lim._failures)


class TestL67KillSwitch(unittest.TestCase):
    def test_revoke_and_check_with_explicit_set(self):
        revoked = set()
        self.assertFalse(ref.is_build_revoked("b1", revoked))
        ref.revoke_build("b1", revoked)
        self.assertTrue(ref.is_build_revoked("b1", revoked))
        self.assertFalse(ref.is_build_revoked("b2", revoked))

    def test_module_level_set(self):
        ref.revoke_build("build-module-test-xyz")
        self.assertTrue(ref.is_build_revoked("build-module-test-xyz"))
        self.assertFalse(ref.is_build_revoked("build-never-revoked"))

    def test_revoke_empty_raises(self):
        with self.assertRaises(ValueError):
            ref.revoke_build("", set())


class TestL68AnomalyScoring(unittest.TestCase):
    def test_clean(self):
        r = ref.score_findings([
            {"name": "debugger", "detected": False, "weight": 30},
            {"name": "root", "detected": False, "weight": 20},
        ])
        self.assertEqual(r["score"], 0)
        self.assertEqual(r["band"], "clean")
        self.assertEqual(r["detected"], [])

    def test_hostile_blocked(self):
        r = ref.score_findings([
            {"name": "debugger", "detected": True, "weight": 30},
            {"name": "frida", "detected": True, "weight": 40},
            {"name": "root", "detected": False, "weight": 30},
        ])
        self.assertEqual(r["score"], 70)
        self.assertEqual(r["band"], "blocked")
        self.assertEqual(r["detected"], ["debugger", "frida"])

    def test_suspicious_middle(self):
        r = ref.score_findings([
            {"name": "emulator", "detected": True, "weight": 40},
            {"name": "root", "detected": False, "weight": 60},
        ])
        self.assertEqual(r["score"], 40)
        self.assertEqual(r["band"], "suspicious")

    def test_empty_findings_clean(self):
        r = ref.score_findings([])
        self.assertEqual((r["score"], r["band"]), (0, "clean"))

    def test_default_weight(self):
        r = ref.score_findings([{"name": "x", "detected": True}])
        self.assertEqual(r["score"], 100)
        self.assertEqual(r["band"], "blocked")

    def test_score_capped_at_100(self):
        r = ref.score_findings([
            {"name": "a", "detected": True, "weight": 100},
            {"name": "b", "detected": True, "weight": 100}])
        self.assertEqual(r["score"], 100)

    def test_bad_weights_raise(self):
        # NaN/inf/str/bool/None weights must raise, not silently
        # corrupt the score and band (audit 2026-11-23).
        for bad in (float("nan"), float("inf"), float("-inf"),
                    "10", True, None):
            with self.assertRaises(ValueError, msg=repr(bad)):
                ref.score_findings([{"name": "x", "detected": True,
                                     "weight": bad}])
        with self.assertRaises(ValueError):
            ref.score_findings([{"name": "x", "detected": True,
                                 "weight": -1}])
        with self.assertRaises(ValueError):
            ref.score_findings(["not-a-dict"])


class TestL69AuditExport(unittest.TestCase):
    def test_round_trip(self):
        events = [
            {"type": "tripwire/v1", "tripwire_id": "honeypot-secret-01",
             "kind": "honeypot_secret_used", "app_package": "com.example.app",
             "timestamp_utc": "2026-11-23T00:00:00Z"},
            {"type": "tripwire/v1", "tripwire_id": "honeypot-secret-01",
             "kind": "integrity_failed", "app_package": "com.example.app"},
        ]
        out = ref.export_events(events, now=_ts("2026-11-23T01:00:00Z"))
        lines = out.strip().split("\n")
        self.assertEqual(len(lines), 2)
        parsed = [json.loads(line) for line in lines]
        self.assertEqual(parsed[0]["tripwire_id"], "honeypot-secret-01")
        self.assertEqual(parsed[0]["schema_version"], ref.SCHEMA_VERSION)
        self.assertEqual(parsed[1]["timestamp_utc"], "2026-11-23T01:00:00Z")
        self.assertEqual(ref.parse_export(out), parsed)

    def test_empty_export(self):
        self.assertEqual(ref.export_events([]), "")

    def test_event_cannot_forge_schema_version(self):
        # A caller-supplied schema_version must never relabel the
        # export format (audit 2026-11-23).
        out = ref.export_events(
            [{"type": "x", "schema_version": "forged/v9",
              "timestamp_utc": "2026-11-23T00:00:00Z"}])
        parsed = ref.parse_export(out)
        self.assertEqual(parsed[0]["schema_version"], ref.SCHEMA_VERSION)

    def test_non_dict_event_raises(self):
        with self.assertRaises(ValueError):
            ref.export_events(["not-a-dict"])


class TestL70KeyRotation(unittest.TestCase):
    def test_rotation(self):
        t = _ts("2026-11-23T00:00:00Z")
        r = ref.rotate_keys("key-old-1", now=t)
        self.assertNotEqual(r["new_key_id"], "key-old-1")
        self.assertEqual(r["old_key_id"], "key-old-1")
        self.assertEqual(r["effective_from_utc"], "2026-11-23T00:00:00Z")
        self.assertEqual(r["old_key_valid_until_utc"], "2026-11-30T00:00:00Z")
        self.assertEqual(r["grace_seconds"], ref.DEFAULT_GRACE_SECONDS)

    def test_grace_window(self):
        t = _ts("2026-11-23T00:00:00Z")
        r = ref.rotate_keys("key-old-1", grace_seconds=3600, now=t)
        self.assertTrue(ref.old_key_still_valid(r, now=t + 1800))
        self.assertFalse(ref.old_key_still_valid(r, now=t + 3601))

    def test_new_ids_differ_each_rotation(self):
        a = ref.rotate_keys("key-old-1")
        b = ref.rotate_keys("key-old-1")
        self.assertNotEqual(a["new_key_id"], b["new_key_id"])

    def test_empty_old_key_raises(self):
        with self.assertRaises(ValueError):
            ref.rotate_keys("")

    def test_malformed_rotation_raises(self):
        with self.assertRaises(ValueError):
            ref.old_key_still_valid({})
        with self.assertRaises(ValueError):
            ref.old_key_still_valid(
                {"old_key_valid_until_utc": "not-a-date"})


if __name__ == "__main__":
    unittest.main(verbosity=2)

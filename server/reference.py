#!/usr/bin/env python3
"""Anti-REA v1.0 — server-side reference implementation (L64-L70).

Python stdlib only. This is a REFERENCE: pure functions a real app
server can copy/adapt. It changes NO live server and deploys nothing.
The server is the real enforcement; client checks are signals, not
proof (see docs/SERVER.md). One tripwire event is never auto-punishment
— the server flags for human review; repeated events may escalate
per server policy.

Layers:
  L64 verify_component_hashes — reject when a component hash mismatches.
  L65 bind_device / check_device_binding — device binding.
  L66 FailedAttestationLimiter — sliding-window rate limit on failures.
  L67 revoke_build / is_build_revoked — remote kill-switch.
  L68 score_findings — anomaly score 0-100 + band.
  L69 export_events — audit export as JSONL.
  L70 rotate_keys — key rotation with a grace window for the old key.
"""
import hashlib
import hmac
import json
import secrets
import time
from datetime import datetime, timedelta, timezone

SCHEMA_VERSION = "antirea-audit/v1"
ATTESTATION_TYPE = "antirea-attestation/v1"
TRIPWIRE_TYPE = "antirea-tripwire/v1"

# L67: module-level revoked-build set, used when no explicit set is
# passed. A real server would persist this in its database instead.
_REVOKED_BUILDS = set()

# L70: how long the old key stays valid after a rotation (7 days).
DEFAULT_GRACE_SECONDS = 7 * 24 * 3600


def _utc_iso(ts=None):
    """ISO-8601 UTC timestamp for `ts` (epoch seconds, default now)."""
    if ts is None:
        ts = time.time()
    return datetime.fromtimestamp(ts, tz=timezone.utc).strftime(
        "%Y-%m-%dT%H:%M:%SZ")


# ---------------------------------------------------------------- L64
def verify_component_hashes(attestation_hashes, expected_hashes):
    """L64 — server-side component-hash reject.

    attestation_hashes / expected_hashes: dicts mapping component
    name (e.g. "classes.dex", "manifest") to a hex sha256 string.
    Returns {"accepted": bool, "reason": str, "mismatched": [...],
    "missing": [...], "unexpected": [...]}. Accept only when every
    expected component is present and matches exactly; extra
    components in the attestation are reported, not fatal.
    """
    attestation_hashes = dict(attestation_hashes or {})
    expected_hashes = dict(expected_hashes or {})
    mismatched = sorted(
        name for name, want in expected_hashes.items()
        if name in attestation_hashes
        and not hmac.compare_digest(
            str(attestation_hashes[name]).lower(), str(want).lower()))
    missing = sorted(
        name for name in expected_hashes if name not in attestation_hashes)
    unexpected = sorted(
        name for name in attestation_hashes if name not in expected_hashes)
    if mismatched or missing:
        parts = []
        if mismatched:
            parts.append("hash mismatch: %s" % ", ".join(mismatched))
        if missing:
            parts.append("missing components: %s" % ", ".join(missing))
        return {"accepted": False, "reason": "; ".join(parts),
                "mismatched": mismatched, "missing": missing,
                "unexpected": unexpected}
    reason = "all %d component hashes match" % len(expected_hashes)
    if unexpected:
        reason += "; unexpected components ignored: %s" % ", ".join(unexpected)
    return {"accepted": True, "reason": reason,
            "mismatched": [], "missing": [], "unexpected": unexpected}


# ---------------------------------------------------------------- L65
def bind_device(device_id, attestation):
    """L65 — bind a device to an attestation.

    SECURITY: `device_id` MUST be generated server-side (e.g. a random
    token issued at registration) and stored server-side. It must
    NEVER be trusted from the client alone: a client-supplied id is
    trivially forged, so the server must only ever bind an id it
    issued itself, over an authenticated channel, and must store only
    its SHA-256 hash — never the raw id — in logs/exports.
    `attestation` is the attestation dict (L61); its build_id /
    dex_sha256 are recorded so a binding is tied to one build.
    Returns a binding dict (safe to persist server-side).
    """
    if not device_id:
        raise ValueError("Anti-REA L65: device_id must be server-issued, "
                         "never empty or client-invented")
    attestation = dict(attestation or {})
    device_hash = hashlib.sha256(str(device_id).encode("utf-8")).hexdigest()
    return {
        "device_hash": device_hash,
        "build_id": attestation.get("build_id"),
        "dex_sha256": attestation.get("dex_sha256"),
        "bound_at_utc": _utc_iso(),
        "integrity_passed_at_bind": bool(attestation.get("integrity_passed")),
    }


def check_device_binding(stored, presented):
    """L65 — check a presented device id against a stored binding.

    `stored`: binding dict from bind_device(). `presented`: the device
    id string presented by the client, or a dict with a "device_id"
    key. Returns {"accepted": bool, "reason": str}. Uses a constant-
    time hash comparison. A mismatch is a reject, never a re-bind:
    re-binding happens only through the server's own registration flow.
    """
    if isinstance(presented, dict):
        presented_id = presented.get("device_id")
    else:
        presented_id = presented
    if not stored or not presented_id:
        return {"accepted": False,
                "reason": "no stored binding or no device id presented"}
    presented_hash = hashlib.sha256(
        str(presented_id).encode("utf-8")).hexdigest()
    if hmac.compare_digest(presented_hash, str(stored.get("device_hash", ""))):
        return {"accepted": True, "reason": "device id matches stored binding"}
    return {"accepted": False,
            "reason": "device id does not match stored binding"}


# ---------------------------------------------------------------- L66
class FailedAttestationLimiter:
    """L66 — in-memory sliding-window limiter on failed attestations.

    max_failures failures from one device within window_seconds block
    further attempts until the oldest failure slides out of the window.
    In-memory only: a restart clears the state (a real server would
    persist this in Redis/its database). `now` is injectable (epoch
    seconds) so tests can use fake timestamps; production passes None
    for real time. Only failures count — successes never consume quota.
    """

    def __init__(self, max_failures=5, window_seconds=3600):
        if max_failures < 1:
            raise ValueError("Anti-REA L66: max_failures must be >= 1")
        if window_seconds <= 0:
            raise ValueError("Anti-REA L66: window_seconds must be > 0")
        self.max_failures = max_failures
        self.window_seconds = window_seconds
        self._failures = {}  # device_id -> sorted list of epoch seconds

    def _prune(self, device_id, now):
        cutoff = now - self.window_seconds
        kept = [t for t in self._failures.get(device_id, []) if t > cutoff]
        if kept:
            self._failures[device_id] = kept
        else:
            self._failures.pop(device_id, None)
        return kept

    def record_failure(self, device_id, now=None):
        """Record one failed attestation. Returns True if the device
        is now blocked, False otherwise."""
        now = time.time() if now is None else now
        failures = self._prune(device_id, now)
        failures.append(now)
        self._failures[device_id] = failures
        return len(failures) >= self.max_failures

    def is_blocked(self, device_id, now=None):
        """True when the device has hit the failure limit in the window."""
        now = time.time() if now is None else now
        return len(self._prune(device_id, now)) >= self.max_failures

    def failures_in_window(self, device_id, now=None):
        """How many failures this device has inside the current window."""
        now = time.time() if now is None else now
        return len(self._prune(device_id, now))

    def allow(self, device_id, now=None):
        """Allow/block decision: True = attempt may proceed."""
        return not self.is_blocked(device_id, now)


# ---------------------------------------------------------------- L67
def revoke_build(build_id, revoked_set=None):
    """L67 — remote kill-switch: revoke a build id.

    Adds `build_id` to `revoked_set` (or the module-level set when
    None) and returns the set. A revoked build must be refused by the
    server on every later attestation; the client only ever learns
    "this build is no longer accepted", never why.
    """
    if not build_id:
        raise ValueError("Anti-REA L67: build_id must not be empty")
    target = _REVOKED_BUILDS if revoked_set is None else revoked_set
    target.add(build_id)
    return target


def is_build_revoked(build_id, revoked_set=None):
    """L67 — True when `build_id` is revoked. Checks `revoked_set`
    when given, otherwise the module-level set."""
    target = _REVOKED_BUILDS if revoked_set is None else revoked_set
    return build_id in target


# ---------------------------------------------------------------- L68
def score_findings(findings):
    """L68 — anomaly scoring.

    findings: list of {"name": str, "detected": bool, "weight": number}
    (weight defaults to 10 when absent). Score is the detected weight
    as a percentage of total weight, 0-100. Bands: <30 clean,
    30-69 suspicious (step-up verification), >=70 blocked.
    Returns {"score": int, "band": "clean"|"suspicious"|"blocked",
    "detected": [names], "total_weight": number}.
    An empty findings list scores 0 / clean — no evidence, no alarm.
    """
    findings = list(findings or [])
    total = 0
    detected_weight = 0
    detected = []
    for f in findings:
        weight = f.get("weight", 10)
        if weight < 0:
            raise ValueError("Anti-REA L68: finding weight must be >= 0")
        total += weight
        if f.get("detected"):
            detected_weight += weight
            detected.append(f.get("name", ""))
    score = 0 if total == 0 else min(100, round(100 * detected_weight / total))
    if score >= 70:
        band = "blocked"
    elif score >= 30:
        band = "suspicious"
    else:
        band = "clean"
    return {"score": score, "band": band, "detected": detected,
            "total_weight": total}


# ---------------------------------------------------------------- L69
def export_events(events, now=None):
    """L69 — audit export: events -> JSONL string.

    Each line is one JSON object: {"schema_version": "antirea-audit/v1",
    "timestamp_utc": ..., plus the event's own fields}. Events that
    lack timestamp_utc get the export time (or `now`, epoch seconds,
    when given). Returns a "" string for an empty list. Every line is
    independently parseable with json.loads (round-trip safe).
    """
    lines = []
    for event in events or []:
        record = {"schema_version": SCHEMA_VERSION}
        record.update(dict(event))
        if not record.get("timestamp_utc"):
            record["timestamp_utc"] = _utc_iso(now)
        lines.append(json.dumps(record, sort_keys=True))
    return "".join(line + "\n" for line in lines)


def parse_export(jsonl):
    """L69 — parse an export_events() string back into a list of dicts."""
    return [json.loads(line) for line in jsonl.splitlines() if line.strip()]


# ---------------------------------------------------------------- L70
def rotate_keys(old_key_id, grace_seconds=DEFAULT_GRACE_SECONDS, now=None):
    """L70 — key rotation via server.

    Returns {"old_key_id", "new_key_id", "effective_from_utc",
    "old_key_valid_until_utc", "grace_seconds"}. The new key id is a
    fresh random token (never derived from the old id). The old key
    stays valid until effective_from + grace_seconds, so builds still
    in flight are not cut off mid-session; after that instant the
    server must reject the old key. `now` (epoch seconds) is
    injectable for tests.
    """
    if not old_key_id:
        raise ValueError("Anti-REA L70: old_key_id must not be empty")
    if grace_seconds < 0:
        raise ValueError("Anti-REA L70: grace_seconds must be >= 0")
    effective = time.time() if now is None else now
    valid_until = effective + grace_seconds
    return {
        "old_key_id": old_key_id,
        "new_key_id": "key-%s" % secrets.token_hex(16),
        "effective_from_utc": _utc_iso(effective),
        "old_key_valid_until_utc": _utc_iso(valid_until),
        "grace_seconds": grace_seconds,
    }


def old_key_still_valid(rotation, now=None):
    """L70 — True while the rotated-out key is still inside its grace
    window. `rotation` is a rotate_keys() result; `now` epoch seconds."""
    check = time.time() if now is None else now
    valid_until = datetime.strptime(
        rotation["old_key_valid_until_utc"], "%Y-%m-%dT%H:%M:%SZ").replace(
            tzinfo=timezone.utc).timestamp()
    return check <= valid_until

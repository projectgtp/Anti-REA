# Anti-REA v1.0 — server reference (L64–L70)

Python stdlib only. This is a **reference implementation**: pure
functions a real app server can copy/adapt. It changes **no live
server** and deploys nothing. Run the tests with:

```sh
python3 -m unittest server.test_server -v
# or
python3 server/test_server.py
```

## Files

| File | Contents |
|------|----------|
| `reference.py` | The reference: L64–L70 as pure functions |
| `test_server.py` | Unit tests (fake timestamps where time matters) |
| `README.md` | This file |

## Layers

- **L64 — component-hash reject** (`verify_component_hashes`):
  accept only when every expected component hash is present and
  matches exactly (case-insensitive hex, constant-time compare).
  Mismatches/missing components reject with a reason; extra
  components are reported, not fatal.
- **L65 — device binding** (`bind_device` / `check_device_binding`):
  the device id **must be generated server-side** (e.g. a random
  token issued at registration) and stored server-side. It must
  **never be trusted from the client alone** — a client-supplied id
  is trivially forged. Only the SHA-256 hash of the id is stored or
  logged, never the raw id. A mismatch rejects; it never re-binds
  (re-binding happens only through the server's own registration flow).
- **L66 — rate-limit on failed attestations** (`FailedAttestationLimiter`):
  in-memory sliding-window limiter, max N failures per device per
  window (default 5 per hour). Only failures count. In-memory only —
  a restart clears state; a real server persists this in Redis/its
  database. `now` is injectable for tests.
- **L67 — remote kill-switch** (`revoke_build` / `is_build_revoked`):
  revoke a build id; later attestations from it must be refused.
  The module-level set is a convenience for the reference — a real
  server persists revocations in its database.
- **L68 — anomaly scoring** (`score_findings`): detected weight as a
  percentage of total weight, 0–100. Bands: <30 `clean`, 30–69
  `suspicious` (step-up verification), ≥70 `blocked`.
- **L69 — audit export** (`export_events` / `parse_export`): events
  → JSONL, one JSON object per line, each stamped with
  `schema_version: "appcore-audit/v1"` and `timestamp_utc`. Every line
  parses independently with `json.loads`.
- **L70 — key rotation via server** (`rotate_keys` /
  `old_key_still_valid`): fresh random new key id (never derived from
  the old id); the old key stays valid for a grace window (default
  7 days) so builds still in flight are not cut off, then the server
  must reject it.

## Honest limits

- This is reference code, not a deployed service. It has no auth, no
  persistence, no network, and no rate-limit storage beyond memory.
- Client-reported values (including `integrity_passed: true`) are
  signals, not proof — the server must verify component hashes
  against the build it shipped (L64) and never trust the client
  alone (see `docs/SERVER.md`).
- One tripwire event is never auto-punishment: flag for human review;
  repeated events may escalate per server policy.
- L65 stores an **unsalted** SHA-256 of the device id. That is only
  safe because the id must be a high-entropy random token issued by
  the server: a low-entropy id (serial number, IMEI, sequential id)
  can be brute-forced from its hash. Never bind a low-entropy id.
- L66's in-memory device cap evicts the first-seen entry when full,
  which can unblock an evicted device early; a real server persists
  the limiter in Redis/its database instead of relying on the cap.
- L67 has no un-revoke: revocation is one-way in this reference.
  A real server needs an explicit un-revoke path if it ever wants
  to restore a build.

## Audit fixes (2026-11-23)

- **L64 — fail closed on empty expected set.** `verify_component_hashes`
  used to accept everything when `expected_hashes` was empty
  (vacuous accept); it now rejects with "no expected component
  hashes configured".
- **L65 — corrupt stored binding rejects.** `check_device_binding`
  used to raise `AttributeError` on a non-dict stored value; it now
  rejects cleanly.
- **L66 — bounded state.** `FailedAttestationLimiter` used to grow
  its per-device dict without limit (distinct device ids are
  attacker-controlled); it now takes `max_devices` (default 10000)
  and evicts first-seen entries past the cap.
- **L68 — weight validation.** `score_findings` used to accept NaN /
  infinite / string / bool / `None` weights, which silently corrupt
  the score and band (a NaN total scores "clean" no matter what was
  detected); weights must now be finite numbers >= 0 and findings
  must be dicts.
- **L69 — canonical schema_version.** `export_events` used to let an
  event's own `schema_version` field overwrite the canonical one
  (export relabelling); the canonical version now always wins.
  Non-dict events are rejected.
- **L70 — malformed rotation rejects.** `old_key_still_valid` used
  to raise raw `KeyError`/`ValueError` on a bad rotation dict; it
  now raises a clear `ValueError`.
- Verified by the 36 tests in `test_server.py` (29 original + 7 new).

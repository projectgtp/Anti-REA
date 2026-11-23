# Anti-REA v1.0 — Server formats (spec only, no server code ships)

v1.0 changes NO live server. It defines what the protected app sends
so a server CAN enforce. The server remains the real enforcement:
client checks are signals, not proof.

## Attestation payload — `attestation/v1` (L61)

The app sends this (over its normal authenticated channel) when it
starts and before sensitive actions:

```json
{
  "type": "attestation/v1",
  "app_package": "com.example.app",
  "build_id": "1.0.0+<rea-ir hash>",
  "dex_sha256": "<sha256 of classes.dex>",
  "env_findings": [{"name": "debugger", "detected": false, "evidence": ""}],
  "integrity_passed": true,
  "timestamp_utc": "2026-11-23T00:00:00Z"
}
```

Server rules (recommended, not implemented here):
- Reject the session when `integrity_passed` is false or `dex_sha256`
  does not match the build the server shipped.
- Score `env_findings` (debugger / emulator / root / Frida markers);
  a high score means step-up verification, not instant punishment.
- Rate-limit failed attestations per device/account (L66, planned).

## Tripwire event — `tripwire/v1` (L62/L63)

Sent (or logged locally and synced) when a honeypot is used, integrity
fails, or the environment is suspicious:

```json
{
  "type": "tripwire/v1",
  "tripwire_id": "honeypot-secret-01",
  "kind": "honeypot_secret_used",
  "app_package": "com.example.app",
  "device_hash": "<sha256 of device id, never the raw id>",
  "timestamp_utc": "2026-11-23T00:00:00Z"
}
```

Kinds: `honeypot_secret_used`, `honeypot_endpoint_used`,
`integrity_failed`, `env_suspicious`.

Server rules (recommended):
- Log every event. Flag the account for human review.
- Never auto-ban on one event — a single event can be a false
  positive (a curious user, a broken build).
- Repeated events from one device/account escalate per server policy.

## What the server must NOT do

- Never trust a client-side `integrity_passed: true` on its own.
  Verify the dex hash against the shipped build.
- Never embed the tripwire decision in the app. The app reports;
  the server decides.

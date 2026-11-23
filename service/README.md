# Anti-REA service (L94 API + L95 dashboard) — PROTOTYPE

## What this is

A minimal protection-as-a-service prototype: POST an APK, get back a
protected APK. Python stdlib only (`http.server`).

```
python3 service/api.py [--host 127.0.0.1] [--port 8931]
```

Open http://127.0.0.1:8931/ for the upload page + status view
(`service/dashboard.html`).

## Endpoints

| Method | Path | What it does |
|---|---|---|
| GET | `/` | Dashboard (upload form + status) |
| GET | `/status` | Service + layer counts (+ whether token auth is on) |
| GET | `/layers` | Layer list from `layers/REGISTRY.md` |
| POST | `/protect` | multipart `apk` (+ optional `config`); runs the CLI; returns job JSON with `download_url` |
| GET | `/job/<job>` | Job status JSON (internal server paths stripped) |
| GET | `/download/<job>` | The protected APK (streamed from disk) |

## Security posture (audited 2026-11-23)

- **Localhost by default.** Default bind is `127.0.0.1`. A
  non-loopback bind is refused unless `--allow-network` is passed
  **and** `ANTIREA_API_TOKEN` is set — the unauthenticated
  prototype can never be exposed to a network by accident.
- **DNS-rebinding guard.** When bound to loopback, requests with a
  non-loopback `Host` header are rejected with 403, so a malicious
  web page cannot drive the service through the browser.
- **Optional token auth for `/protect`.** Set `ANTIREA_API_TOKEN`
  (a long random string). When set, `/protect` requires
  `Authorization: Bearer <token>` (or `X-Anti-Rea-Token`),
  compared in constant time; anything else gets 401. When unset,
  the service stays localhost-only and prints a loud startup
  warning — a localhost demo that used to work keeps working.
  The dashboard has a token field that sends the header.
  `/download` is not separately gated: job ids are unguessable
  12-hex tokens and the service is localhost-only.
- **Streaming uploads, no OOM.** Request bodies are streamed to
  disk in 1 MiB chunks (never held fully in RAM) and the 512 MB cap
  is enforced while reading; oversize uploads get 413 and the
  connection is closed. The multipart body is split by scanning a
  memory-mapped spool file, the APK part is streamed out to the job
  dir with a running SHA-256, and the protected APK is streamed
  back on download — a 500 MB upload never loads ~1.5 GB into RAM
  the way the old `rfile.read()` + `body.split()` code did.
- **Upload validation.** The `apk` part must be a ZIP (`PK`
  magic) before a protect run is spent on it; the optional
  `config` part is capped at 1 MB. A disk-free guard refuses new
  uploads with 507 when less than upload-cap + 1 GiB is free.
- **No path traversal.** Job ids are server-generated 12-hex
  tokens; `/job` and `/download` reject anything else with 404,
  and the served file is containment-checked under
  `/home/hatch/tmp/` — `../` in a job id cannot read other files
  (verified by tests, including a poisoned job record pointing at
  `/etc/passwd`). Job JSON never includes internal server paths.
- **No zip-slip surface here.** The API never extracts the
  uploaded APK itself; extraction happens inside the CLI
  subprocess. The uploaded config is passed straight to the CLI,
  so a config that names paths is trusted exactly as far as the
  CLI trusts its own config file.
- **Tests:** `python3 -m unittest service.test_api -v` (21 tests:
  traversal, oversize, streaming extraction, token 401/200, Host
  403, disk guard, bind policy, and one end-to-end protect of
  `tests/testapp/testapp-control.apk` through the real CLI).

## Limits — read before using

- **PROTOTYPE, NO AUTH BY DEFAULT.** Anyone who can reach it can
  protect APKs and download results. Default bind is `127.0.0.1`
  only. Never expose it on a public port without real auth + TLS
  in front; set `ANTIREA_API_TOKEN` as a minimum.
- Upload cap 512 MB (same as the REA input limit).
- One protect at a time (serialised by a lock); concurrent uploads wait.
- Output is signed with the CLI's fresh ephemeral TEST keystore
  unless the uploaded config names a keystore — a test-signed APK
  will not upgrade an install signed with another key.
- Jobs live under `/home/hatch/tmp/antirea-service-<job>-*/` (never
  `/tmp`); there is no persistence or cleanup beyond that.
- The API does not change any live server; it only runs the local CLI.

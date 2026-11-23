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
| GET | `/status` | Service + layer counts |
| GET | `/layers` | Layer list from `layers/REGISTRY.md` |
| POST | `/protect` | multipart `apk` (+ optional `config`); runs the CLI; returns job JSON with `download_url` |
| GET | `/job/<job>` | Job status JSON |
| GET | `/download/<job>` | The protected APK |

## Limits — read before using

- **PROTOTYPE, NO AUTH.** Anyone who can reach it can protect APKs
  and download results. Default bind is `127.0.0.1` only. Never
  expose it on a public port without real auth + TLS in front.
- Upload cap 512 MB (same as the REA input limit).
- One protect at a time (serialised by a lock); concurrent uploads wait.
- Output is signed with the CLI's fresh ephemeral TEST keystore
  unless the uploaded config names a keystore — a test-signed APK
  will not upgrade an install signed with another key.
- Jobs live under `/home/hatch/tmp/antirea-service-<job>-*/` (never
  `/tmp`); there is no persistence or cleanup beyond that.
- The API does not change any live server; it only runs the local CLI.

#!/usr/bin/env python3
"""Anti-REA v1.0 — L94 service API (PROTOTYPE, Python stdlib only).

A minimal protection-as-a-service prototype: POST an APK, get back a
protected APK. Uses only http.server from the stdlib.

    python3 service/api.py [--host 127.0.0.1] [--port 8931]

Endpoints:
  GET  /            dashboard (service/dashboard.html)
  GET  /status      {"service": "anti-rea", "version": "1.0.0", ...}
  GET  /layers      layer list from layers/REGISTRY.md (read-only)
  POST /protect     multipart/form-data, fields:
                      apk    (required) the APK file
                      config (optional) an anti-rea.yaml config file
                    Runs `anti-rea.py protect` on the upload in a job
                    dir under /home/hatch/tmp/ (never /tmp) and
                    returns JSON {job, status, protected_sha256,
                    download_url}. The protected APK is kept in the
                    job dir for download.
  GET  /download/<job>   the protected APK for a finished job
  GET  /job/<job>        job status JSON

Limits, stated plainly:
  * PROTOTYPE — NO AUTHENTICATION. Anyone who can reach it can
    protect APKs with it and download results. Bind to 127.0.0.1
    (the default) and put it behind real auth + TLS before exposing
    it to any network. Never run this on a public port as-is.
  * Upload cap 512 MB (same as the REA input limit); larger uploads
    are refused with 413.
  * One protect runs at a time (a lock serialises jobs); concurrent
    uploads wait. This is a prototype, not a production queue.
  * The CLI signs output with its fresh ephemeral TEST keystore
    unless the uploaded config names a keystore — same limit as the
    CLI itself. A test-signed APK will not upgrade an existing
    install signed with another key.
  * No persistence beyond the job dirs under /home/hatch/tmp/.
"""
import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
import threading
import uuid
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SERVICE_DIR = Path(__file__).resolve().parent
MAX_UPLOAD_BYTES = 512 * 1024 * 1024
BASE_TMP = Path("/home/hatch/tmp")

_lock = threading.Lock()
_jobs = {}  # job_id -> dict(status, ...)


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def parse_registry():
    layers = []
    text = (ROOT / "layers" / "REGISTRY.md").read_text(encoding="utf-8")
    for line in text.splitlines():
        line = line.strip()
        if not line.startswith("| L"):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) < 4 or not re.fullmatch(r"L\d+", cells[0]):
            continue
        layers.append({"id": cells[0], "name": cells[1],
                       "counters": cells[2], "status": cells[3]})
    return layers


def parse_multipart(body, boundary):
    """Minimal multipart/form-data parser (stdlib only). Returns
    {field_name: (filename_or_None, bytes)}. Raises ValueError on
    malformed input. Never writes to /tmp."""
    parts = {}
    sep = b"--" + boundary
    chunks = body.split(sep)
    for chunk in chunks[1:]:
        if chunk in (b"--\r\n", b"--", b"--\r\n\r\n"):
            continue
        if chunk.startswith(b"--"):
            break
        if chunk.startswith(b"\r\n"):
            chunk = chunk[2:]
        if chunk.endswith(b"\r\n"):
            chunk = chunk[:-2]
        head, sep2, data = chunk.partition(b"\r\n\r\n")
        if not sep2:
            raise ValueError("multipart part without header/body split")
        headers = head.decode("utf-8", errors="replace")
        m = re.search(r'name="([^"]+)"(?:;\s*filename="([^"]*)")?',
                      headers)
        if not m:
            continue
        parts[m.group(1)] = (m.group(2) or None, data)
    return parts


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, fmt, *args):
        sys.stderr.write("[api] %s - %s\n" % (self.address_string(),
                                              fmt % args))

    def _send_json(self, code, obj):
        data = json.dumps(obj, indent=2).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _send_bytes(self, code, data, ctype):
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        if self.path == "/":
            page = SERVICE_DIR / "dashboard.html"
            if page.is_file():
                self._send_bytes(200, page.read_bytes(), "text/html")
            else:
                self._send_json(404, {"error": "dashboard.html missing"})
        elif self.path == "/status":
            counts = {}
            for layer in parse_registry():
                counts[layer["status"]] = counts.get(layer["status"], 0) + 1
            self._send_json(200, {
                "service": "anti-rea", "version": "1.0.0",
                "prototype": True,
                "warning": "NO AUTH — prototype only, bind to "
                           "127.0.0.1, never expose publicly",
                "layers": counts, "jobs": len(_jobs)})
        elif self.path == "/layers":
            self._send_json(200, {"layers": parse_registry()})
        elif self.path.startswith("/job/"):
            job = self.path[len("/job/"):].strip("/")
            if job in _jobs:
                self._send_json(200, _jobs[job])
            else:
                self._send_json(404, {"error": "unknown job %r" % job})
        elif self.path.startswith("/download/"):
            job = self.path[len("/download/"):].strip("/")
            info = _jobs.get(job)
            if not info or info.get("status") != "done":
                self._send_json(404, {"error": "no finished job %r" % job})
                return
            data = Path(info["protected_apk"]).read_bytes()
            self._send_bytes(200, data,
                             "application/vnd.android.package-archive")
        else:
            self._send_json(404, {"error": "unknown path %r" % self.path})

    def do_POST(self):
        if self.path != "/protect":
            self._send_json(404, {"error": "unknown path %r" % self.path})
            return
        length = int(self.headers.get("Content-Length") or 0)
        if length <= 0 or length > MAX_UPLOAD_BYTES:
            self._send_json(413, {"error":
                "upload must be 1..%d bytes" % MAX_UPLOAD_BYTES})
            return
        ctype = self.headers.get("Content-Type") or ""
        m = re.search(r"multipart/form-data;\s*boundary=(.+)", ctype)
        if not m:
            self._send_json(400, {"error":
                "Content-Type must be multipart/form-data"})
            return
        body = self.rfile.read(length)
        try:
            parts = parse_multipart(body, m.group(1).encode("ascii"))
        except ValueError as e:
            self._send_json(400, {"error": "bad multipart body: %s" % e})
            return
        if "apk" not in parts or not parts["apk"][1]:
            self._send_json(400, {"error": "field 'apk' (file) required"})
            return
        job = uuid.uuid4().hex[:12]
        BASE_TMP.mkdir(parents=True, exist_ok=True)
        jobdir = Path(tempfile.mkdtemp(prefix="antirea-service-%s-" % job,
                                       dir=str(BASE_TMP)))
        in_apk = jobdir / "input.apk"
        in_apk.write_bytes(parts["apk"][1])
        cfg_path = ROOT / "anti-rea.yaml"
        if "config" in parts and parts["config"][1]:
            cfg_path = jobdir / "config.yaml"
            cfg_path.write_bytes(parts["config"][1])
        out_apk = jobdir / "protected.apk"
        _jobs[job] = {"job": job, "status": "running",
                      "input_bytes": len(parts["apk"][1]),
                      "input_sha256": sha256_file(in_apk)}
        # Serialise protects: the CLI + apktool work is not safe to
        # run concurrently against one tree, and this is a prototype.
        with _lock:
            try:
                p = subprocess.run(
                    [sys.executable, str(ROOT / "anti-rea.py"), "protect",
                     "--apk", str(in_apk), "--config", str(cfg_path),
                     "--out", str(out_apk)],
                    capture_output=True, text=True, timeout=900)
            except subprocess.TimeoutExpired:
                _jobs[job] = {**_jobs[job], "status": "failed",
                              "error": "protect timed out (900s)"}
                self._send_json(500, _jobs[job])
                return
        if p.returncode != 0 or not out_apk.is_file():
            _jobs[job] = {**_jobs[job], "status": "failed",
                          "error": (p.stderr or p.stdout)[-2000:]}
            self._send_json(500, _jobs[job])
            return
        _jobs[job] = {**_jobs[job], "status": "done",
                      "protected_apk": str(out_apk),
                      "protected_sha256": sha256_file(out_apk),
                      "protected_bytes": out_apk.stat().st_size,
                      "download_url": "/download/%s" % job,
                      "log_tail": (p.stdout or "")[-1000:]}
        self._send_json(200, _jobs[job])


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--port", type=int, default=8931)
    args = ap.parse_args(argv)
    server = ThreadingHTTPServer((args.host, args.port), Handler)
    print("Anti-REA service API (PROTOTYPE — no auth) on "
          "http://%s:%d/  (Ctrl-C to stop)" % (args.host, args.port))
    print("WARNING: bind is %s — never expose this publicly without "
          "real auth + TLS." % args.host)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nstopping")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

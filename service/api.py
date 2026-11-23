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

Security posture (audited 2026-11-23, see service/README.md):
  * Default bind is 127.0.0.1. A non-loopback bind is refused unless
    --allow-network is passed AND ANTIREA_API_TOKEN is set.
  * Requests to a loopback-bound server with a non-loopback Host
    header are rejected (403) — this blocks DNS-rebinding attacks
    from a malicious web page.
  * Optional shared-secret auth for /protect: set ANTIREA_API_TOKEN.
    When set, /protect requires `Authorization: Bearer <token>` (or
    the X-Anti-Rea-Token header); without it, 401. When unset, the
    service stays localhost-only and prints a loud startup warning
    — a localhost demo that used to work keeps working.
  * Uploads are streamed to disk in 1 MB chunks (never held fully in
    RAM) and the 512 MB cap is enforced while reading; larger
    uploads are refused with 413 and the connection is closed.
  * The protected APK is streamed back from disk on download, never
    loaded whole into memory.
  * Job ids are server-generated 12-hex tokens; /job and /download
    validate the format and the served file is containment-checked
    under the job base dir, so ../ traversal cannot read other files.
  * Job status JSON never includes internal server paths.

Limits, stated plainly:
  * PROTOTYPE — no persistence, no per-user accounts, no TLS. Put
    it behind real auth + TLS before exposing it to any network.
  * Upload cap 512 MB (same as the REA input limit); larger uploads
    are refused with 413.
  * One protect runs at a time (a lock serialises jobs); concurrent
    uploads wait. This is a prototype, not a production queue.
  * The CLI signs output with its fresh ephemeral TEST keystore
    unless the uploaded config names a keystore — same limit as the
    CLI itself. A test-signed APK will not upgrade an existing
    install signed with another key.
  * No persistence beyond the job dirs under /home/hatch/tmp/.
  * The API never extracts the uploaded APK itself (no zip-slip
    surface here); extraction happens inside the CLI subprocess.
    The uploaded config is passed straight to the CLI, so a
    config that names paths is trusted exactly as far as the CLI
    trusts its own config file.
"""
import argparse
import hashlib
import hmac
import json
import mmap
import os
import re
import shutil
import subprocess
import sys
import tempfile
import threading
import uuid
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parent.parent
SERVICE_DIR = Path(__file__).resolve().parent
MAX_UPLOAD_BYTES = 512 * 1024 * 1024
MAX_CONFIG_BYTES = 1 * 1024 * 1024
DISK_RESERVE_BYTES = MAX_UPLOAD_BYTES + (1 << 30)  # upload + 1 GiB spare
BASE_TMP = Path("/home/hatch/tmp")
CHUNK = 1 << 20  # 1 MiB streaming chunk

# Optional shared secret for /protect. Empty env value == unset.
API_TOKEN = os.environ.get("ANTIREA_API_TOKEN") or None

_LOOPBACK_HOSTS = {"127.0.0.1", "localhost", "::1"}
_JOB_ID_RE = re.compile(r"[0-9a-f]{12}")

_lock = threading.Lock()
_jobs = {}  # job_id -> dict(status, ...)


class UploadTooLarge(ValueError):
    """Raised while spooling when the body exceeds the size cap."""


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(CHUNK), b""):
            h.update(chunk)
    return h.hexdigest()


def disk_free_ok(required_bytes=DISK_RESERVE_BYTES, path=BASE_TMP):
    """True when `path` has at least `required_bytes` free. Guards
    against disk-fill denial of service from repeated big uploads."""
    try:
        return shutil.disk_usage(str(path)).free >= required_bytes
    except OSError:
        return False


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


# ------------------------------------------------------- upload streaming
def spool_request_body(rfile, length, cap, dest_path):
    """Stream exactly `length` bytes from `rfile` to `dest_path` in
    1 MiB chunks. Never holds more than one chunk in RAM, so a
    500 MB upload cannot OOM the machine. Raises UploadTooLarge as
    soon as the cap is exceeded, and ValueError on a short read
    (client disconnected early). Returns bytes written."""
    written = 0
    with open(dest_path, "wb") as out:
        remaining = length
        while remaining > 0:
            chunk = rfile.read(min(CHUNK, remaining))
            if not chunk:
                raise ValueError("client closed connection early "
                                 "(%d of %d bytes)" % (written, length))
            written += len(chunk)
            if written > cap:
                raise UploadTooLarge(
                    "upload exceeds %d bytes" % cap)
            out.write(chunk)
            remaining -= len(chunk)
    return written


def split_multipart_file(path, boundary):
    """Locate the parts of a spooled multipart/form-data body WITHOUT
    loading it into RAM: the file is memory-mapped and only the
    boundary positions are scanned. Returns a list of
    (headers_bytes, data_start, data_end). Raises ValueError on a
    malformed body. A boundary sequence occurring inside file data
    would truncate that part early — the same ambiguity every naive
    multipart parser has; clients use long random boundaries, and a
    truncated APK then fails the ZIP-magic check below."""
    if not boundary:
        raise ValueError("empty multipart boundary")
    sep = b"--" + boundary
    size = os.path.getsize(path)
    if size == 0:
        raise ValueError("empty multipart body")
    parts = []
    with open(path, "rb") as f:
        mm = mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ)
        try:
            pos = 0
            first = True
            while True:
                i = mm.find(sep, pos)
                if i == -1:
                    if first:
                        raise ValueError("multipart body does not "
                                         "contain its boundary")
                    break
                if first and i != 0:
                    raise ValueError("multipart body does not start "
                                     "with its boundary")
                first = False
                after = i + len(sep)
                if mm[after:after + 2] == b"--":
                    break  # closing boundary
                if mm[after:after + 2] != b"\r\n":
                    pos = after  # false positive inside file data
                    continue
                head_start = after + 2
                hdr_end = mm.find(b"\r\n\r\n", head_start)
                if hdr_end == -1:
                    raise ValueError("multipart part without "
                                     "header/body split")
                headers = bytes(mm[head_start:hdr_end])
                data_start = hdr_end + 4
                nxt = mm.find(b"\r\n" + sep, data_start)
                if nxt == -1:
                    raise ValueError("unterminated multipart part")
                parts.append((headers, data_start, nxt))
                pos = nxt + 2
        finally:
            mm.close()
    return parts


def parse_part_headers(headers):
    """(field_name, filename) from one part's raw header block."""
    text = headers.decode("utf-8", errors="replace")
    m = re.search(r'name="([^"]+)"(?:;\s*filename="([^"]*)")?', text)
    if not m:
        return None, None
    return m.group(1), m.group(2) or None


def copy_part_to_file(spooled_path, data_start, data_end, dest_path):
    """Stream-copy one part's byte range to `dest_path`, returning
    its SHA-256 hex digest. Never loads the part into RAM."""
    h = hashlib.sha256()
    remaining = data_end - data_start
    with open(spooled_path, "rb") as src, open(dest_path, "wb") as out:
        src.seek(data_start)
        while remaining > 0:
            chunk = src.read(min(CHUNK, remaining))
            if not chunk:
                raise ValueError("multipart part truncated on disk")
            h.update(chunk)
            out.write(chunk)
            remaining -= len(chunk)
    return h.hexdigest()


def read_small_part(spooled_path, data_start, data_end, cap):
    """Read one (small) part fully into RAM, enforcing `cap`."""
    size = data_end - data_start
    if size > cap:
        raise UploadTooLarge("multipart part exceeds %d bytes" % cap)
    with open(spooled_path, "rb") as src:
        src.seek(data_start)
        return src.read(size)


# ------------------------------------------------------------- auth / bind
def is_loopback_host(host):
    """True for 127.0.0.1 / localhost / ::1, with or without :port
    and with or without IPv6 brackets."""
    host = (host or "").strip().lower()
    if host.startswith("["):
        host = host[1:].split("]", 1)[0]
    else:
        host = host.split(":", 1)[0]
    return host in _LOOPBACK_HOSTS


def validate_bind(host, allow_network, token):
    """Bind policy, pure function so tests can check it without
    starting a server. Returns an error string, or None when the
    bind is allowed. A non-loopback bind needs an explicit
    --allow-network AND a token, so the unauthenticated prototype
    can never be exposed to a network by accident."""
    if is_loopback_host(host):
        return None
    if not allow_network:
        return ("refusing non-loopback bind %r: pass --allow-network "
                "to expose this prototype, and set ANTIREA_API_TOKEN "
                "first" % host)
    if not token:
        return ("refusing network bind without ANTIREA_API_TOKEN: "
                "set a token before exposing /protect to a network")
    return None


def _valid_job_id(job):
    return bool(job) and _JOB_ID_RE.fullmatch(job) is not None


def _public_job(info):
    """Job status safe to return to a client: internal server paths
    (protected_apk) are stripped — they used to leak the job-dir
    layout in every /job response."""
    return {k: v for k, v in info.items() if k != "protected_apk"}


def _resolve_protected_apk(info):
    """Resolve the stored output path and containment-check it under
    BASE_TMP. Returns the Path, or None when the stored path is
    missing/unexpected (never serve a file outside the job dirs)."""
    raw = info.get("protected_apk") if isinstance(info, dict) else None
    if not raw:
        return None
    try:
        path = Path(raw).resolve()
        base = BASE_TMP.resolve()
    except (OSError, RuntimeError):
        return None
    if path == base or base not in path.parents:
        return None
    return path if path.is_file() else None


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    daemon_threads = True

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

    def _send_file(self, path, ctype):
        """Stream a file back in 1 MiB chunks; never loads it whole."""
        size = path.stat().st_size
        self.send_response(200)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(size))
        self.send_header("Content-Disposition",
                         'attachment; filename="protected.apk"')
        self.end_headers()
        with open(path, "rb") as f:
            shutil.copyfileobj(f, self.wfile, length=CHUNK)

    def _host_allowed(self):
        """DNS-rebinding guard: when this server is bound to a
        loopback address, only loopback Host headers are accepted.
        A page on evil.example.com resolving to 127.0.0.1 sends
        Host: evil.example.com, so it is rejected here. Skipped
        only when the operator explicitly bound a network address
        with --allow-network (and a token)."""
        bound = self.server.server_address[0]
        if not is_loopback_host(bound):
            return True
        return is_loopback_host(self.headers.get("Host"))

    def _token_authorized(self):
        """True when no token is configured (localhost demo mode) or
        the request carries the right token. Constant-time compare."""
        if not API_TOKEN:
            return True
        auth = (self.headers.get("Authorization") or "").strip()
        token = ""
        if auth.lower().startswith("bearer "):
            token = auth[7:].strip()
        elif self.headers.get("X-Anti-Rea-Token"):
            token = self.headers.get("X-Anti-Rea-Token").strip()
        return bool(token) and hmac.compare_digest(token, API_TOKEN)

    def do_GET(self):
        path = urlsplit(self.path).path
        if not self._host_allowed():
            self._send_json(403, {"error": "Host header not allowed "
                                  "for this localhost service"})
            return
        if path == "/":
            page = SERVICE_DIR / "dashboard.html"
            if page.is_file():
                self._send_bytes(200, page.read_bytes(), "text/html")
            else:
                self._send_json(404, {"error": "dashboard.html missing"})
        elif path == "/status":
            counts = {}
            for layer in parse_registry():
                counts[layer["status"]] = counts.get(layer["status"], 0) + 1
            self._send_json(200, {
                "service": "anti-rea", "version": "1.0.0",
                "prototype": True,
                "auth": ("token required for /protect"
                         if API_TOKEN else
                         "NO TOKEN — localhost only, never expose "
                         "publicly"),
                "layers": counts, "jobs": len(_jobs)})
        elif path == "/layers":
            self._send_json(200, {"layers": parse_registry()})
        elif path.startswith("/job/"):
            job = path[len("/job/"):].strip("/")
            if not _valid_job_id(job) or job not in _jobs:
                self._send_json(404, {"error": "unknown job"})
            else:
                self._send_json(200, _public_job(_jobs[job]))
        elif path.startswith("/download/"):
            job = path[len("/download/"):].strip("/")
            info = _jobs.get(job) if _valid_job_id(job) else None
            if not info or info.get("status") != "done":
                self._send_json(404, {"error": "no finished job"})
                return
            apk_path = _resolve_protected_apk(info)
            if apk_path is None:
                self._send_json(404, {"error": "no finished job"})
                return
            self._send_file(apk_path,
                            "application/vnd.android.package-archive")
        else:
            self._send_json(404, {"error": "unknown path %r" % path})

    def do_POST(self):
        # One-shot upload: close afterwards so bytes a client sends
        # beyond Content-Length can never be parsed as a next request.
        self.close_connection = True
        if urlsplit(self.path).path != "/protect":
            self._send_json(404, {"error": "unknown path %r" % self.path})
            return
        if not self._host_allowed():
            self._send_json(403, {"error": "Host header not allowed "
                                  "for this localhost service"})
            return
        if not self._token_authorized():
            self._send_json(401, {"error": "missing or wrong API token "
                                  "for /protect"})
            return
        try:
            length = int(self.headers.get("Content-Length") or 0)
        except ValueError:
            self._send_json(400, {"error": "bad Content-Length header"})
            return
        if length <= 0 or length > MAX_UPLOAD_BYTES:
            self._send_json(413, {"error":
                "upload must be 1..%d bytes" % MAX_UPLOAD_BYTES})
            return
        if not disk_free_ok():
            self._send_json(507, {"error":
                "server disk too full for another upload "
                "(needs %d bytes free)" % DISK_RESERVE_BYTES})
            return
        ctype = self.headers.get("Content-Type") or ""
        m = re.search(r"multipart/form-data;\s*boundary=(.+)", ctype)
        if not m:
            self._send_json(400, {"error":
                "Content-Type must be multipart/form-data"})
            return
        try:
            boundary = m.group(1).strip().strip('"').encode("ascii")
        except UnicodeEncodeError:
            self._send_json(400, {"error": "bad multipart boundary"})
            return
        if not boundary:
            self._send_json(400, {"error": "bad multipart boundary"})
            return
        job = uuid.uuid4().hex[:12]
        BASE_TMP.mkdir(parents=True, exist_ok=True)
        jobdir = Path(tempfile.mkdtemp(prefix="antirea-service-%s-" % job,
                                       dir=str(BASE_TMP)))
        in_apk = jobdir / "input.apk"
        spool_path = jobdir / "upload.bin"
        try:
            spool_request_body(self.rfile, length, MAX_UPLOAD_BYTES,
                               spool_path)
        except UploadTooLarge:
            self._send_json(413, {"error":
                "upload must be 1..%d bytes" % MAX_UPLOAD_BYTES})
            return
        except ValueError as e:
            self._send_json(400, {"error": "incomplete upload: %s" % e})
            return
        try:
            parts = split_multipart_file(spool_path, boundary)
            apk_part = None
            cfg_part = None
            for headers, start, end in parts:
                name, _filename = parse_part_headers(headers)
                if name == "apk" and apk_part is None:
                    apk_part = (start, end)
                elif name == "config" and cfg_part is None:
                    cfg_part = (start, end)
            if apk_part is None or apk_part[1] <= apk_part[0]:
                self._send_json(400, {"error":
                    "field 'apk' (file) required"})
                return
            # Stream the APK part out of the spool file (never into
            # RAM); the config part is small and read with its own cap.
            input_sha256 = copy_part_to_file(
                spool_path, apk_part[0], apk_part[1], in_apk)
            cfg_bytes = None
            if cfg_part is not None and cfg_part[1] > cfg_part[0]:
                cfg_bytes = read_small_part(
                    spool_path, cfg_part[0], cfg_part[1],
                    MAX_CONFIG_BYTES)
        except UploadTooLarge:
            self._send_json(413, {"error":
                "config part exceeds %d bytes" % MAX_CONFIG_BYTES})
            return
        except ValueError as e:
            self._send_json(400, {"error": "bad multipart body: %s" % e})
            return
        finally:
            try:
                spool_path.unlink()
            except OSError:
                pass
        # An APK is a ZIP: refuse obvious non-APKs before spending a
        # protect run on them.
        with open(in_apk, "rb") as f:
            if f.read(2) != b"PK":
                self._send_json(400, {"error":
                    "field 'apk' is not a ZIP/APK file"})
                return
        cfg_path = ROOT / "anti-rea.yaml"
        if cfg_bytes:
            cfg_path = jobdir / "config.yaml"
            cfg_path.write_bytes(cfg_bytes)
        out_apk = jobdir / "protected.apk"
        _jobs[job] = {"job": job, "status": "running",
                      "input_bytes": in_apk.stat().st_size,
                      "input_sha256": input_sha256}
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
                self._send_json(500, _public_job(_jobs[job]))
                return
        if p.returncode != 0 or not out_apk.is_file():
            _jobs[job] = {**_jobs[job], "status": "failed",
                          "error": (p.stderr or p.stdout)[-2000:]}
            self._send_json(500, _public_job(_jobs[job]))
            return
        _jobs[job] = {**_jobs[job], "status": "done",
                      "protected_apk": str(out_apk),
                      "protected_sha256": sha256_file(out_apk),
                      "protected_bytes": out_apk.stat().st_size,
                      "download_url": "/download/%s" % job,
                      "log_tail": (p.stdout or "")[-1000:]}
        self._send_json(200, _public_job(_jobs[job]))


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--port", type=int, default=8931)
    ap.add_argument("--allow-network", action="store_true",
                    help="allow a non-loopback bind (requires "
                         "ANTIREA_API_TOKEN to be set)")
    args = ap.parse_args(argv)
    err = validate_bind(args.host, args.allow_network, API_TOKEN)
    if err:
        ap.error(err)
    server = ThreadingHTTPServer((args.host, args.port), Handler)
    print("Anti-REA service API (PROTOTYPE) on "
          "http://%s:%d/  (Ctrl-C to stop)" % (args.host, args.port),
          flush=True)
    if API_TOKEN:
        print("AUTH: /protect requires the ANTIREA_API_TOKEN "
              "(Authorization: Bearer <token>).", flush=True)
    else:
        print("WARNING: NO API TOKEN SET (ANTIREA_API_TOKEN is empty) — "
              "/protect accepts any request from this machine. "
              "Localhost-only bind; never expose publicly without a "
              "token + TLS.", flush=True)
    if not is_loopback_host(args.host):
        print("WARNING: bound to a non-loopback address %s — you asked "
              "for this with --allow-network; token auth is on." %
              args.host, flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nstopping")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

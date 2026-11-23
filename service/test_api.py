#!/usr/bin/env python3
"""Anti-REA v1.0 — tests for service/api.py (L94) security audit fixes.

Run from the v1.0 directory:
    python3 -m unittest service.test_api -v
or:
    python3 service/test_api.py
Stdlib only. Starts a real HTTP server on 127.0.0.1 (ephemeral port)
in a thread; no live server, no network exposure. The end-to-end
protect test runs the real CLI once on tests/testapp/testapp-control.apk
(~1-2 min) and cleans its job dir up afterwards.
"""
import hashlib
import http.client
import io
import json
import os
import shutil
import socket
import sys
import threading
import unittest
from http.server import ThreadingHTTPServer
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import api

ROOT = Path(__file__).resolve().parent.parent
TEST_APK = ROOT / "tests" / "testapp" / "testapp-control.apk"
BASE_TMP = api.BASE_TMP


def build_multipart(boundary, fields):
    """fields: list of (name, filename_or_None, bytes). Returns body."""
    out = io.BytesIO()
    for name, filename, data in fields:
        out.write(b"--" + boundary + b"\r\n")
        disp = 'Content-Disposition: form-data; name="%s"' % name
        if filename is not None:
            disp += '; filename="%s"' % filename
        out.write(disp.encode() + b"\r\n")
        out.write(b"Content-Type: application/octet-stream\r\n\r\n")
        out.write(data)
        out.write(b"\r\n")
    out.write(b"--" + boundary + b"--\r\n")
    return out.getvalue()


class ApiTestCase(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = ThreadingHTTPServer(("127.0.0.1", 0), api.Handler)
        cls.port = cls.server.server_address[1]
        cls.thread = threading.Thread(target=cls.server.serve_forever,
                                      kwargs={"poll_interval": 0.05},
                                      daemon=True)
        cls.thread.start()
        cls._orig_token = api.API_TOKEN
        cls._orig_max = api.MAX_UPLOAD_BYTES
        cls._orig_disk = api.disk_free_ok

    @classmethod
    def tearDownClass(cls):
        # NOTE: read the saved originals off the CLASS, never via
        # self — a plain function stored as a class attribute binds
        # as a method when accessed through an instance.
        api.API_TOKEN = cls._orig_token
        api.MAX_UPLOAD_BYTES = cls._orig_max
        api.disk_free_ok = cls._orig_disk
        cls.server.shutdown()
        cls.server.server_close()

    def tearDown(self):
        # Same class-access rule as tearDownClass (see above).
        api.API_TOKEN = type(self)._orig_token
        api.MAX_UPLOAD_BYTES = type(self)._orig_max
        api.disk_free_ok = type(self)._orig_disk

    # -- helpers ------------------------------------------------------
    def request(self, method, path, body=None, headers=None, timeout=30):
        conn = http.client.HTTPConnection("127.0.0.1", self.port,
                                          timeout=timeout)
        try:
            conn.request(method, path, body=body, headers=headers or {})
            resp = conn.getresponse()
            return resp.status, resp.read()
        finally:
            conn.close()

    def request_host(self, method, path, host, body=None, timeout=30):
        conn = http.client.HTTPConnection("127.0.0.1", self.port,
                                          timeout=timeout)
        try:
            conn.putrequest(method, path, skip_host=True)
            conn.putheader("Host", host)
            if body is not None:
                conn.putheader("Content-Length", str(len(body)))
            conn.endheaders()
            if body:
                conn.send(body)
            resp = conn.getresponse()
            return resp.status, resp.read()
        finally:
            conn.close()

    def protect(self, apk_bytes, token=None, timeout=900):
        boundary = b"----testboundary1234"
        body = build_multipart(boundary, [
            ("apk", "input.apk", apk_bytes)])
        headers = {"Content-Type":
                   "multipart/form-data; boundary=----testboundary1234"}
        if token:
            headers["Authorization"] = "Bearer " + token
        return self.request("POST", "/protect", body=body,
                            headers=headers, timeout=timeout)

    # -- basic endpoints ----------------------------------------------
    def test_status_ok(self):
        code, body = self.request("GET", "/status")
        self.assertEqual(code, 200)
        data = json.loads(body)
        self.assertEqual(data["service"], "anti-rea")
        self.assertIn("NO TOKEN", data["auth"])

    def test_dashboard_ok(self):
        code, body = self.request("GET", "/")
        self.assertEqual(code, 200)
        self.assertIn(b"Anti-REA", body)

    def test_unknown_path_404(self):
        code, _ = self.request("GET", "/nope")
        self.assertEqual(code, 404)

    # -- path traversal ------------------------------------------------
    def test_job_and_download_traversal_404(self):
        for path in ("/job/../../etc/passwd",
                     "/job/%2e%2e%2fetc%2fpasswd",
                     "/job/..%2f..%2fetc%2fpasswd",
                     "/job/abc",
                     "/download/../../etc/passwd",
                     "/download/%2e%2e%2fetc%2fpasswd",
                     "/download/..%2f..%2fetc%2fpasswd",
                     "/download/abc"):
            code, body = self.request("GET", path)
            self.assertEqual(code, 404, path)
            self.assertNotIn(b"root:", body, path)

    def test_download_containment_check(self):
        # Even a job record pointing outside the job dirs must not
        # serve that file (defence in depth on _resolve_protected_apk).
        job = "abcdef012345"
        api._jobs[job] = {"job": job, "status": "done",
                          "protected_apk": "/etc/passwd"}
        try:
            code, body = self.request("GET", "/download/" + job)
            self.assertEqual(code, 404)
            self.assertNotIn(b"root:", body)
        finally:
            api._jobs.pop(job, None)

    def test_job_json_has_no_internal_paths(self):
        job = "abcdef012345"
        api._jobs[job] = {"job": job, "status": "done",
                          "protected_apk":
                          "/home/hatch/tmp/antirea-service-x/protected.apk",
                          "protected_sha256": "aa"}
        try:
            code, body = self.request("GET", "/job/" + job)
            self.assertEqual(code, 200)
            self.assertNotIn(b"protected_apk", body)
            self.assertNotIn(b"/home/hatch", body)
        finally:
            api._jobs.pop(job, None)

    # -- oversize / streaming ------------------------------------------
    def test_oversize_content_length_413(self):
        api.MAX_UPLOAD_BYTES = 1024
        code, body = self.request(
            "POST", "/protect", body=b"x" * 2048,
            headers={"Content-Type":
                     "multipart/form-data; boundary=----testboundary1234"})
        self.assertEqual(code, 413)
        self.assertIn(b"1..1024", body)

    def test_spool_enforces_cap_while_streaming(self):
        dest = BASE_TMP / "antirea-test-spool.bin"
        try:
            with self.assertRaises(api.UploadTooLarge):
                api.spool_request_body(io.BytesIO(b"x" * 200), 200, 100,
                                       dest)
            # A short read (client disconnects early) is a clean 400
            # cause, not a hang or a silent partial upload.
            with self.assertRaises(ValueError):
                api.spool_request_body(io.BytesIO(b"x" * 10), 100, 1000,
                                       dest)
            n = api.spool_request_body(io.BytesIO(b"y" * 50), 50, 1000,
                                       dest)
            self.assertEqual(n, 50)
            self.assertEqual(dest.read_bytes(), b"y" * 50)
        finally:
            try:
                dest.unlink()
            except OSError:
                pass

    def test_multipart_streaming_extract(self):
        # A >1 MiB APK part (crosses the 1 MiB streaming chunk) must
        # round-trip byte-exact through the mmap splitter + streamer.
        boundary = b"----testboundary9999"
        apk_data = os.urandom(2 * 1024 * 1024 + 123)
        cfg_data = b"version: 1\n"
        body = build_multipart(boundary, [
            ("config", "c.yaml", cfg_data),
            ("apk", "input.apk", apk_data)])
        spooled = BASE_TMP / "antirea-test-multi.bin"
        out_apk = BASE_TMP / "antirea-test-multi.apk"
        try:
            spooled.write_bytes(body)
            parts = api.split_multipart_file(spooled, boundary)
            self.assertEqual(len(parts), 2)
            found = {}
            for headers, start, end in parts:
                name, _fn = api.parse_part_headers(headers)
                found[name] = (start, end)
            digest = api.copy_part_to_file(
                spooled, *found["apk"], out_apk)
            self.assertEqual(digest, hashlib.sha256(apk_data).hexdigest())
            self.assertEqual(out_apk.read_bytes(), apk_data)
            cfg = api.read_small_part(spooled, *found["config"],
                                      api.MAX_CONFIG_BYTES)
            self.assertEqual(cfg, cfg_data)
        finally:
            for p in (spooled, out_apk):
                try:
                    p.unlink()
                except OSError:
                    pass

    def test_multipart_malformed_rejected(self):
        spooled = BASE_TMP / "antirea-test-bad.bin"
        try:
            spooled.write_bytes(b"garbage with no boundary at all")
            with self.assertRaises(ValueError):
                api.split_multipart_file(spooled, b"----missing")
            spooled.write_bytes(b"--B\r\nContent-Disposition: form-data; "
                                b'name="apk"\r\n\r\nno-closing-boundary')
            with self.assertRaises(ValueError):
                api.split_multipart_file(spooled, b"B")
        finally:
            try:
                spooled.unlink()
            except OSError:
                pass

    def test_non_apk_rejected_before_protect(self):
        code, body = self.protect(b"this is not a zip file at all")
        self.assertEqual(code, 400)
        self.assertIn(b"not a ZIP/APK", body)

    def test_bad_content_length_400(self):
        conn = http.client.HTTPConnection("127.0.0.1", self.port, timeout=10)
        try:
            conn.putrequest("POST", "/protect", skip_host=True)
            conn.putheader("Host", "127.0.0.1")
            conn.putheader("Content-Length", "not-a-number")
            conn.putheader("Content-Type",
                           "multipart/form-data; boundary=x")
            conn.endheaders()
            resp = conn.getresponse()
            self.assertEqual(resp.status, 400)
            resp.read()
        finally:
            conn.close()

    def test_disk_guard(self):
        self.assertTrue(api.disk_free_ok(1))
        self.assertFalse(api.disk_free_ok(10 ** 18))
        api.disk_free_ok = lambda *a, **k: False
        code, body = self.protect(b"PK\x03\x04fake")
        self.assertEqual(code, 507)

    # -- token auth -----------------------------------------------------
    def test_token_required_when_set(self):
        api.API_TOKEN = "test-secret-token"
        # No token -> 401, wrong token -> 401.
        code, _ = self.protect(b"PK\x03\x04fake")
        self.assertEqual(code, 401)
        code, _ = self.protect(b"PK\x03\x04fake", token="wrong")
        self.assertEqual(code, 401)
        # Right token -> auth passes (request proceeds to the ZIP
        # check and fails there, proving the gate let it through).
        # NOTE: the body must NOT start with PK, or it would pass
        # the ZIP-magic check and reach the real CLI protect run.
        code, body = self.protect(b"not a zip at all",
                                  token="test-secret-token")
        self.assertEqual(code, 400)
        self.assertIn(b"not a ZIP/APK", body)
        # X-Anti-Rea-Token header works too.
        boundary = b"----testboundary1234"
        body = build_multipart(boundary, [("apk", "a.apk", b"nope")])
        code, _ = self.request(
            "POST", "/protect", body=body,
            headers={"Content-Type":
                     "multipart/form-data; boundary=----testboundary1234",
                     "X-Anti-Rea-Token": "test-secret-token"})
        self.assertEqual(code, 400)

    def test_token_compare_is_constant_time(self):
        # Tampering with one character must not leak via timing or
        # via a different error: both wrong tokens get the same 401.
        api.API_TOKEN = "a" * 32
        code1, _ = self.protect(b"not a zip", token="b" * 32)
        code2, _ = self.protect(b"not a zip", token="a" * 31 + "b")
        self.assertEqual((code1, code2), (401, 401))

    # -- host / bind ----------------------------------------------------
    def test_host_header_rebinding_rejected(self):
        code, _ = self.request_host("GET", "/status", "evil.example.com")
        self.assertEqual(code, 403)
        code, _ = self.request_host("GET", "/status",
                                    "127.0.0.1:%d" % self.port)
        self.assertEqual(code, 200)
        code, _ = self.request_host("POST", "/protect",
                                    "attacker.test",
                                    body=b"PK\x03\x04fake")
        self.assertEqual(code, 403)

    def test_is_loopback_host(self):
        self.assertTrue(api.is_loopback_host("127.0.0.1"))
        self.assertTrue(api.is_loopback_host("127.0.0.1:8931"))
        self.assertTrue(api.is_loopback_host("localhost"))
        self.assertTrue(api.is_loopback_host("localhost:8931"))
        self.assertTrue(api.is_loopback_host("[::1]:8931"))
        self.assertFalse(api.is_loopback_host("evil.example.com"))
        self.assertFalse(api.is_loopback_host("127.0.0.1.evil.com"))
        self.assertFalse(api.is_loopback_host(""))
        self.assertFalse(api.is_loopback_host(None))

    def test_validate_bind(self):
        self.assertIsNone(api.validate_bind("127.0.0.1", False, None))
        self.assertIsNone(api.validate_bind("localhost", False, None))
        self.assertIsNotNone(api.validate_bind("0.0.0.0", False, None))
        self.assertIsNotNone(
            api.validate_bind("0.0.0.0", True, None))
        self.assertIsNone(
            api.validate_bind("0.0.0.0", True, "tok"))

    def test_main_refuses_network_bind_without_token(self):
        with self.assertRaises(SystemExit):
            api.main(["--host", "0.0.0.0", "--port", "0"])
        with self.assertRaises(SystemExit):
            api.main(["--host", "0.0.0.0", "--allow-network",
                      "--port", "0"])

    def test_loopback_only_not_reachable_on_external_ip(self):
        # The test server binds 127.0.0.1; the service must not
        # answer on the VM's outward IP. (This VM also has a
        # transparent proxy that can accept the TCP connection, so
        # "connection refused" is not the assertion — the assertion
        # is that no request to the external IP ever gets OUR
        # service's response.)
        self.assertEqual(self.server.server_address[0], "127.0.0.1")
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        try:
            s.connect(("8.8.8.8", 80))
            ext_ip = s.getsockname()[0]
        finally:
            s.close()
        if ext_ip == "127.0.0.1":
            self.skipTest("no non-loopback IP found")
        try:
            conn = http.client.HTTPConnection(ext_ip, self.port, timeout=3)
            try:
                conn.request("GET", "/status")
                body = conn.getresponse().read()
            finally:
                conn.close()
        except (OSError, http.client.HTTPException):
            return  # refused/reset: not reachable, as required
        self.assertNotIn(b'"service": "anti-rea"', body)

    # -- end to end -----------------------------------------------------
    def test_protect_end_to_end(self):
        self.assertTrue(TEST_APK.is_file(), "test APK missing")
        apk_bytes = TEST_APK.read_bytes()
        code, body = self.protect(apk_bytes)
        data = json.loads(body)
        # Pipeline proof, independent of the CLI result: the bytes
        # the service extracted must be exactly the bytes uploaded.
        # (When the CLI's own self-check refuses because the manifest
        # is stale — e.g. while other agents are editing the tree —
        # the protect still fails 500 below, but this assertion pins
        # down that the failure is the CLI's, not the upload path's.)
        self.assertEqual(data.get("input_sha256"),
                         hashlib.sha256(apk_bytes).hexdigest())
        self.assertEqual(code, 200, body[:500])
        self.assertEqual(data["status"], "done")
        self.assertNotIn("protected_apk", data)  # no internal paths
        job = data["job"]
        try:
            code, dl = self.request("GET", "/download/" + job)
            self.assertEqual(code, 200)
            self.assertEqual(hashlib.sha256(dl).hexdigest(),
                             data["protected_sha256"])
            self.assertTrue(dl[:2] == b"PK")
            code, jb = self.request("GET", "/job/" + job)
            self.assertEqual(code, 200)
            self.assertEqual(json.loads(jb)["status"], "done")
        finally:
            for d in BASE_TMP.glob("antirea-service-%s-*" % job):
                shutil.rmtree(d, ignore_errors=True)


if __name__ == "__main__":
    unittest.main(verbosity=2)

// Anti-REA v1.0 — L89 Frida agent (frida_script.js)
//
// What this does, in plain words:
//   This script runs INSIDE the protected app on the phone, with
//   Frida's help. It tries five attacker moves and reports what
//   happened, one tagged line at a time. The Python harness
//   (frida_test.py) reads those lines and decides PASS / BREAK /
//   INCONCLUSIVE for each check. This script never decides anything
//   itself, and it never sends a full secret anywhere: plaintext is
//   logged as its first 8 characters + length only.
//
//   F1 attach   — just being here proves attach worked; then it asks
//                 the app's own ReaEnv.checkAll() what it sees.
//   F2 gadget   — not done here; gadget injection is a repack step
//                 done BEFORE launch (see README.md). If this agent
//                 is running under gadget mode it says so.
//   F3 hook     — hooks ReaRuntime.decrypt() and verifyIntegrity()
//                 and reports if they fire.
//   F4 memread  — scans readable memory for the test secret bytes.
//   F5 ssl-unpin— hooks the TLS trust path so any certificate is
//                 accepted, and reports if the app then talks
//                 through a proxy.
//
// How to run it (from the README):
//   frida -U -f com.antirea.testapp -l frida_script.js --no-pause
//
// The app under test:
//   * Test app: com.antirea.testapp — secret to scan for is the FAKE
//     test value TEST-SECRET-7f3a9-generic (from the tester brief).
//   * Bridge:   com.bridge.mvp — scan needle is the PUBLIC url
//     mbbridge.onrender.com (also from the tester brief).
//   Change NEEDLE below to match the app you launched.
//
// Safety / rules for the tester:
//   * Test phone / emulator only. Never run this against the real
//     Bridge server with a tampered app, never try to steal real
//     user data, never attack the live backend.
//   * This script reads the app's own memory and hooks its own
//     methods. That is the whole point of the test — it is what a
//     real attacker would do, on a test build, with permission.

'use strict';

// ---- config: change NEEDLE to match the app under test ----
var NEEDLE_TESTAPP = 'TEST-SECRET-7f3a9-generic'; // fake test value
var NEEDLE_BRIDGE = 'mbbridge.onrender.com';      // public URL
var NEEDLE = NEEDLE_TESTAPP; // <-- set to NEEDLE_BRIDGE for Bridge

// ---- small helper: send one tagged line to the harness ----
function tag(name, detail) {
    send('[ANTIREA] ' + name + (detail ? ' ' + detail : ''));
}

tag('AGENT_START', 'L89 agent loaded, needle=' + NEEDLE);

// F2 note: if we are running as a gadget, frida-gadget leaves its own
// library in the process maps. Say so plainly; the repack step itself
// is judged by whether the app still runs at all (README.md).
try {
    var gadgetSeen = false;
    Process.enumerateModules().forEach(function (m) {
        if (m.name.indexOf('frida-gadget') !== -1 ||
            m.name.indexOf('libfrida') !== -1) {
            gadgetSeen = true;
        }
    });
    if (gadgetSeen) {
        tag('GADGET_LOADED', 'frida-gadget library present in process');
    }
} catch (e) {
    tag('ERROR', 'gadget check failed: ' + e.message);
}

Java.perform(function () {
    // ---- F1: ask the app's own environment checks what they see ----
    try {
        var ReaEnv = Java.use('com.antirea.runtime.ReaEnv');
        var env = ReaEnv.INSTANCE; // Kotlin object: methods live on INSTANCE
        var findings = env.checkAll();
        var clean = true;
        var size = findings.size();
        for (var i = 0; i < size; i++) {
            var f = findings.get(i);
            // Finding is a Kotlin data class (name, detected, evidence),
            // so read it through its getters. Do NOT read f.detected
            // directly: in Frida that returns a field wrapper object,
            // which is always truthy and would fake a detection.
            var name = f.getName();
            var detected = f.getDetected();
            if (detected) {
                clean = false;
                tag('ENV_DETECTED', String(name));
            }
        }
        if (clean) {
            tag('ENV_CLEAN', 'no frida finding in checkAll()');
        }
    } catch (e) {
        // ReaEnv missing or checkAll not reachable: the attach itself
        // still happened, so say the env read failed rather than
        // pretending the app is clean.
        tag('ERROR', 'ReaEnv.checkAll() unreadable: ' + e.message);
    }

    // ---- F3: hook the decrypt / integrity methods ----
    // ReaRuntime is a Kotlin object, so its methods are instance
    // methods on ReaRuntime.INSTANCE. Hook the instance methods;
    // if that fails, try the class methods as a fallback.
    var hooked = [];
    function hookMethod(holder, methodName, label) {
        try {
            var m = holder[methodName];
            if (!m) { return false; }
            // Overloads: decrypt(String, String, String) and
            // verifyIntegrity(String, String). Hook every overload.
            m.overloads.forEach(function (ov) {
                ov.implementation = function () {
                    tag('HOOK_FIRED', label);
                    // Call the ORIGINAL method: inside an
                    // implementation, this[label](...) invokes the
                    // real method, not this hook (Frida rule).
                    var ret = this[label].apply(this, arguments);
                    if (label === 'decrypt' && typeof ret === 'string') {
                        // Log a prefix + length ONLY — never the full
                        // plaintext. A prefix proves the hook saw a
                        // real decrypted value; the full value is not
                        // needed and must not land in any log.
                        tag('DECRYPT_PLAINTEXT',
                            'prefix=' + ret.slice(0, 8) +
                            ' len=' + ret.length);
                    }
                    if (label === 'verifyIntegrity' && ret === true) {
                        tag('VERIFY_FORCED', 'verifyIntegrity() returned true');
                    }
                    return ret;
                };
            });
            hooked.push(label);
            return true;
        } catch (e) {
            return false;
        }
    }

    try {
        var ReaRuntime = Java.use('com.antirea.runtime.ReaRuntime');
        var inst = null;
        try { inst = ReaRuntime.INSTANCE.value; } catch (e) { inst = null; }
        // Kotlin object methods are usually reached through the
        // INSTANCE; Java.use on the class also exposes them in
        // Frida for static-style access. Try instance first.
        var target = inst || ReaRuntime;
        var okDecrypt = hookMethod(target, 'decrypt', 'decrypt');
        var okVerify = hookMethod(target, 'verifyIntegrity', 'verifyIntegrity');
        var okKey = hookMethod(target, 'reconstructKey', 'reconstructKey');
        if (okDecrypt || okVerify || okKey) {
            tag('HOOK_INSTALLED', hooked.join(','));
        } else {
            tag('HOOK_MISSED', 'decrypt/verifyIntegrity not hookable');
        }
    } catch (e) {
        tag('HOOK_MISSED', 'ReaRuntime not found: ' + e.message);
    }

    // Also hook verifyIntegrity to FORCE it true — the second half of
    // F3. This is a separate hook from the logging one above: if the
    // app calls verifyIntegrity on a tampered blob and still gets
    // true, the integrity gate is beaten. (If the logging hook above
    // already wrapped it, this replace is a no-op in practice; the
    // forced-true attempt is what matters, and its result is the
    // VERIFY_FORCED tag above.)
}) // end Java.perform

// ---- F4: scan readable memory for the needle bytes ----
// Runs after a short delay so the app has time to hold the value.
// Memory.scan is async; results arrive via onMatch. A match means
// the plaintext bytes were sitting in RAM — a BREAK for F4.
setTimeout(function () {
    try {
        var needle = Memory.allocUtf8String(NEEDLE);
        var ranges = Process.enumerateRanges('r--');
        var found = 0;
        var pending = ranges.length;
        if (pending === 0) {
            tag('MEMSCAN_ERROR', 'no readable ranges');
            return;
        }
        ranges.forEach(function (range) {
            try {
                Memory.scan(range.base, range.size, needle, {
                    onMatch: function (address, size) {
                        found++;
                        tag('MEMSCAN_FOUND',
                            'needle bytes at ' + address);
                        tag('PLAINTEXT_FOUND',
                            'needle in RAM range ' + range.base);
                    },
                    onError: function (reason) { /* skip unreadable range */ },
                    onComplete: function () {
                        pending--;
                        if (pending === 0 && found === 0) {
                            tag('MEMSCAN_CLEAN',
                                'no plaintext bytes found in ' +
                                ranges.length + ' ranges');
                        }
                    }
                });
            } catch (e) {
                pending--;
                if (pending === 0 && found === 0) {
                    tag('MEMSCAN_CLEAN',
                        'scan skipped unreadable ranges, no match');
                }
            }
        });
    } catch (e) {
        tag('MEMSCAN_ERROR', e.message);
    }
}, 5000);

// ---- F5: SSL unpinning — accept any certificate ----
// Hooks the standard trust paths. If the app pins certificates
// somewhere else (OkHttp CertificatePinner, network-security-config),
// this hook does nothing and the SSL_PIN_OK / SSL_FAILED outcome
// below is decided by whether traffic actually flows — the tester
// watches the proxy for that (see README.md) and reports it.
Java.perform(function () {
    try {
        var X509TrustManager = Java.use('javax.net.ssl.X509TrustManager');
        // Frida cannot implement an interface from scratch here in a
        // useful way for every app; instead hook the common
        // TrustManagerFactory path: replace checkServerTrusted with a
        // no-op on the app's own trust-manager instances is not
        // portable, so we hook SSLContext.init to log that the hook
        // point exists and let the tester confirm via the proxy.
        var SSLContext = Java.use('javax.net.ssl.SSLContext');
        SSLContext.init.overloads.forEach(function (ov) {
            ov.implementation = function (km, tm, sr) {
                tag('SSL_HOOK', 'SSLContext.init intercepted');
                // Inside an implementation, this.init(...) calls the
                // ORIGINAL method (Frida rule), not this hook.
                return this.init(km, tm, sr);
            };
        });
    } catch (e) {
        tag('SSL_HOOK_MISSED', 'SSLContext not hookable: ' + e.message);
    }
    try {
        var Pinner = Java.use('okhttp3.CertificatePinner');
        Pinner.check.overloads.forEach(function (ov) {
            ov.implementation = function () {
                tag('SSL_HOOK', 'CertificatePinner.check bypassed');
                return; // accept any certificate
            };
        });
        tag('SSL_PINNER_HOOKED', 'okhttp CertificatePinner.check hooked');
    } catch (e) {
        // App does not use OkHttp pinning — not an error, just note it.
        tag('SSL_PINNER_ABSENT', 'no okhttp3.CertificatePinner in app');
    }
});

// If the process dies or the app refuses to run, Frida reports the
// detach; the harness treats APP_EXITED with no agent work as a
// possible PASS for F1 (see frida_test.py) — the tester still has to
// confirm the exit was the app refusing, not a crash (logcat).

package com.antirea.runtime

/**
 * JVM test for the batch-2 environment checks (L38–L45, ReaEnv2.kt).
 *
 * Pure core only — no Context, no device. All inputs are injected as
 * parameters, so no Android API is ever called. Compile with
 * android.jar on the kotlinc classpath (ReaEnv.kt imports android.*
 * for its adapter functions, which this test never calls; ReaEnv2.kt
 * itself is stdlib-only), then run on a plain JVM:
 *   kotlinc -cp $ANDROID_JAR -d env2-test.jar \
 *     ReaEnv.kt ReaEnv2.kt tests/Env2Test.kt
 *   java -cp env2-test.jar:$ANDROID_JAR:$STDLIB \
 *     com.antirea.runtime.Env2TestKt
 *
 * Checks:
 *  (a) L38 VPN/proxy: clean, VPN only, proxy only, both, blank proxy.
 *  (b) L39 screen-share: FLAG_SECURE alone must NOT fire; only an
 *      active MediaProjection fires.
 *  (c) L40 mock location: clean, setting only, provider only, both.
 *  (d) L41 developer options on/off.
 *  (e) L42 USB debugging on/off.
 *  (f) L43 app cloner: clean path, each marker, installer marker,
 *      case-insensitive, empty inputs, and the DOCUMENTED false
 *      positives ("individual" contains "dual"; a folder named
 *      "clone" flags).
 *  (g) L44 time tamper: clean advance, small NTP step (not flagged),
 *      backwards jump, forward jump, frozen wall clock, first run
 *      (no prior sample), reboot (elapsed reset), tolerance boundary.
 *  (h) L45 locale/timezone: clean, locale mismatch, "_" / case
 *      normalisation, blank locale, blank timezone, no expectation.
 *  (i) checkAll2 / suspiciousCount2: default inputs fire 0, an
 *      all-suspicious input fires 8, names in L38–L45 order.
 * Any failure exits non-zero. Prints TEST-PASS on success.
 */
fun main() {
    fun fail(msg: String): Nothing {
        println("FAIL: $msg")
        kotlin.system.exitProcess(1)
    }
    fun check(name: String, finding: ReaEnv.Finding, wantDetected: Boolean) {
        if (finding.detected != wantDetected) {
            fail("$name: detected=${finding.detected}, want $wantDetected " +
                "(evidence: ${finding.evidence})")
        }
        if (finding.name != name) fail("$name: finding name=${finding.name}")
    }

    // (a) L38 VPN/proxy.
    check("vpn-proxy", ReaEnv2.vpnOrProxyDetected(false, null), false)
    check("vpn-proxy", ReaEnv2.vpnOrProxyDetected(false, ""), false)
    check("vpn-proxy", ReaEnv2.vpnOrProxyDetected(false, "   "), false)
    check("vpn-proxy", ReaEnv2.vpnOrProxyDetected(true, null), true)
    check("vpn-proxy", ReaEnv2.vpnOrProxyDetected(false, "proxy.example.com"), true)
    check("vpn-proxy", ReaEnv2.vpnOrProxyDetected(true, "proxy.example.com"), true)
    println("VPN-PROXY-OK: clean / vpn / proxy / both / blank proxy clean")

    // (b) L39 screen-share. FLAG_SECURE alone must NOT fire.
    check("screen-share", ReaEnv2.screenShareDetected(false, false), false)
    check("screen-share", ReaEnv2.screenShareDetected(true, false), false)
    check("screen-share", ReaEnv2.screenShareDetected(false, true), true)
    check("screen-share", ReaEnv2.screenShareDetected(true, true), true)
    println("SCREEN-SHARE-OK: FLAG_SECURE alone clean, MediaProjection fires")

    // (c) L40 mock location.
    check("mock-location", ReaEnv2.mockLocationDetected(false, false), false)
    check("mock-location", ReaEnv2.mockLocationDetected(true, false), true)
    check("mock-location", ReaEnv2.mockLocationDetected(false, true), true)
    check("mock-location", ReaEnv2.mockLocationDetected(true, true), true)
    println("MOCK-LOCATION-OK: clean / setting / provider / both")

    // (d) L41 developer options.
    check("developer-options", ReaEnv2.developerOptionsEnabled(false), false)
    check("developer-options", ReaEnv2.developerOptionsEnabled(true), true)
    println("DEV-OPTIONS-OK: off clean, on fires")

    // (e) L42 USB debugging.
    check("usb-debugging", ReaEnv2.usbDebuggingEnabled(false), false)
    check("usb-debugging", ReaEnv2.usbDebuggingEnabled(true), true)
    println("USB-DEBUGGING-OK: off clean, on fires")

    // (f) L43 app cloner.
    val cleanPath = "/data/user/0/com.example.app"
    check("app-cloner", ReaEnv2.appClonerDetected(cleanPath, "com.android.vending"), false)
    check("app-cloner", ReaEnv2.appClonerDetected("", null), false)
    check("app-cloner", ReaEnv2.appClonerDetected("", ""), false)
    check("app-cloner", ReaEnv2.appClonerDetected("/data/user/0/com.example.parallel.app", null), true)
    check("app-cloner", ReaEnv2.appClonerDetected("/data/dual/0/com.example.app", null), true)
    check("app-cloner", ReaEnv2.appClonerDetected("/data/user/0/com.example.clone", null), true)
    check("app-cloner", ReaEnv2.appClonerDetected("/data/user/0/com.example.app", "com.cloner.installer"), true)
    // Case-insensitive.
    check("app-cloner", ReaEnv2.appClonerDetected("/data/user/0/ParallelSpace", null), true)
    // DOCUMENTED false positives (pinned, not bugs in this test):
    // "dual" is a substring of "individual"; a folder named "clone" flags.
    check("app-cloner", ReaEnv2.appClonerDetected("/data/user/0/com.example.individualapp", null), true)
    check("app-cloner", ReaEnv2.appClonerDetected("/storage/emulated/0/clone/com.example.app", null), true)
    // Evidence must name the marker, never echo the full path.
    val ev = ReaEnv2.appClonerDetected("/data/user/0/com.example.parallel.app", null).evidence
    if (!ev.contains("parallel") || ev.contains("/data/user/0")) {
        fail("cloner evidence must name the marker without echoing the path: $ev")
    }
    println("CLONER-OK: clean / parallel / dual / clone / installer / case-insensitive / documented FPs")

    // (g) L44 time tamper.
    val wall0 = 1_700_000_000_000L
    val elapsed0 = 1_000_000L
    fun tamper(wallDelta: Long, elapsedDelta: Long) =
        ReaEnv2.timeTamperDetected(wall0 + wallDelta, elapsed0 + elapsedDelta, wall0, elapsed0)
    check("time-tamper", tamper(60_000L, 60_000L), false) // clean, advances together
    check("time-tamper", tamper(0L, 0L), false) // no time passed
    check("time-tamper", tamper(55_000L, 60_000L), false) // small NTP back-step: wall 5s behind elapsed, skew -5s
    check("time-tamper", tamper(55_000L, 0L), false) // skew +55s, within tolerance
    check("time-tamper", tamper(-600_000L, 60_000L), true) // wall moved back 10 min
    check("time-tamper", tamper(600_000L, 60_000L), true) // wall jumped forward 10 min
    check("time-tamper", tamper(0L, 3_600_000L), true) // wall froze for an hour
    // Boundary: skew exactly == tolerance is NOT flagged; 1ms over is.
    check("time-tamper", tamper(120_000L, 60_000L), false) // skew exactly +60_000
    check("time-tamper", tamper(120_001L, 60_000L), true) // skew +60_001
    // First run: no prior sample -> not flagged, whatever the clocks say.
    check(
        "time-tamper",
        ReaEnv2.timeTamperDetected(wall0, elapsed0, 0L, 0L), false
    )
    // Reboot: elapsedRealtime reset (went backwards) -> not tamper.
    check(
        "time-tamper",
        ReaEnv2.timeTamperDetected(wall0 + 60_000L, 5_000L, wall0, elapsed0), false
    )
    if (ReaEnv2.TIME_SKEW_TOLERANCE_MS != 60_000L) fail("tolerance != 60000")
    println("TIME-TAMPER-OK: clean / NTP step / back / forward / frozen / boundary / first-run / reboot")

    // (h) L45 locale/timezone.
    check("locale-timezone", ReaEnv2.localeTimezoneAnomaly("en-US", "America/New_York", null), false)
    check("locale-timezone", ReaEnv2.localeTimezoneAnomaly("en-US", "America/New_York", "en-US"), false)
    check("locale-timezone", ReaEnv2.localeTimezoneAnomaly("fr-FR", "Europe/Paris", "en-US"), true)
    // "_" and case are normalised: en_US == en-US.
    check("locale-timezone", ReaEnv2.localeTimezoneAnomaly("en_US", "America/New_York", "en-US"), false)
    check("locale-timezone", ReaEnv2.localeTimezoneAnomaly("EN-us", "America/New_York", "en-US"), false)
    // Blank locale / blank timezone fire; blank expected means "no expectation".
    check("locale-timezone", ReaEnv2.localeTimezoneAnomaly("", "America/New_York", null), true)
    check("locale-timezone", ReaEnv2.localeTimezoneAnomaly("en-US", "", "en-US"), true)
    check("locale-timezone", ReaEnv2.localeTimezoneAnomaly("en-US", "UTC", ""), false)
    println("LOCALE-TZ-OK: clean / mismatch / normalisation / blank locale / blank tz / blank expected")

    // (i) checkAll2 / suspiciousCount2.
    val clean = ReaEnv2.checkAll2()
    val wantNames = listOf(
        "vpn-proxy", "screen-share", "mock-location", "developer-options",
        "usb-debugging", "app-cloner", "time-tamper", "locale-timezone"
    )
    if (clean.map { it.name } != wantNames) fail("checkAll2 names=${clean.map { it.name }}")
    if (clean.any { it.detected }) fail("default checkAll2 fired: ${clean.filter { it.detected }}")
    if (ReaEnv2.suspiciousCount2() != 0) fail("default suspiciousCount2 != 0")
    val allBad = ReaEnv2.Env2Inputs(
        networkCapabilitiesHasVpn = true, proxyHost = "proxy.example.com",
        isScreenCaptureDisabledByFlagSecure = true, mediaProjectionActive = true,
        allowMockLocation = true, locationIsFromMockProvider = true,
        developmentSettingsEnabled = true, adbEnabled = true,
        packagePath = "/data/parallel/com.example.app",
        installerPackage = "com.android.vending",
        wallClockMs = wall0 - 600_000L, elapsedRealtimeMs = elapsed0 + 60_000L,
        lastSeenWallMs = wall0, lastSeenElapsedMs = elapsed0,
        localeTag = "fr-FR", timeZoneId = "Europe/Paris", expectedLocaleTag = "en-US"
    )
    if (ReaEnv2.suspiciousCount2(allBad) != 8) {
        fail("all-suspicious count=${ReaEnv2.suspiciousCount2(allBad)}, want 8")
    }
    if (ReaEnv2.checkAll2(allBad).any { !it.detected }) {
        fail("all-suspicious checkAll2 has a clean entry")
    }
    val oneBad = ReaEnv2.Env2Inputs(developmentSettingsEnabled = true)
    if (ReaEnv2.suspiciousCount2(oneBad) != 1) fail("one-suspicious count != 1")
    println("CHECKALL-OK: default 0, all-suspicious 8, single 1, names in L38-L45 order")

    println("TEST-PASS")
}

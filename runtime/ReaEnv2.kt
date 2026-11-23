package com.antirea.runtime

/**
 * Anti-REA v1.0 environment checks, batch 2 — L38–L45.
 *
 * Extends the SAME pattern as [ReaEnv] (L31–L37): every check is a pure
 * function returning a [ReaEnv.Finding] — a SIGNAL, never a verdict.
 * Nothing here refuses, kills, deletes, writes, or touches the network.
 * Nothing here crashes: every function catches exceptions and returns
 * detected=false on failure.
 *
 * Unlike [ReaEnv], this file has NO Android imports (Kotlin stdlib
 * only). Every Android value a check needs is passed in as a parameter,
 * so every check is testable on a plain JVM with no device. The KDoc on
 * each function documents the Android API the caller uses to obtain
 * that input on a real device. The caller (app / ReaGuardProvider) owns
 * reading Settings / ConnectivityManager / the clock; this file only
 * judges the values it is given.
 *
 * Honest limit, same as L31–L37: env checks are SIGNALS, not proof.
 * A VPN can be a legitimate corporate VPN, developer options can be on
 * for a legitimate developer, a "clone" substring can be an innocent
 * folder name. A clean result does NOT prove the device is
 * uncompromised — Frida can hide itself. The app decides what a
 * finding means (refuse, degrade, report to the server); this file
 * only reports. L45 (locale/timezone) is the weakest signal of the
 * batch — see its KDoc.
 */
object ReaEnv2 {

    /** Clone markers checked (substring, case-insensitive) in L43. */
    val CLONE_MARKERS: List<String> = listOf("parallel", "dual", "clone")

    /**
     * L44 tolerance: wall-clock vs elapsed-time skew within this many
     * milliseconds is treated as normal (NTP corrections, scheduling
     * jitter). Only a larger skew is flagged.
     */
    const val TIME_SKEW_TOLERANCE_MS: Long = 60_000L // 1 minute

    /**
     * All inputs for [checkAll2], with clean-device defaults, so
     * `checkAll2()` with no arguments is the "nothing suspicious"
     * baseline (0 findings fired). Fill in the fields the caller can
     * actually read on the device; leave the rest at their defaults.
     */
    data class Env2Inputs(
        val networkCapabilitiesHasVpn: Boolean = false,
        val proxyHost: String? = null,
        val isScreenCaptureDisabledByFlagSecure: Boolean = false,
        val mediaProjectionActive: Boolean = false,
        val allowMockLocation: Boolean = false,
        val locationIsFromMockProvider: Boolean = false,
        val developmentSettingsEnabled: Boolean = false,
        val adbEnabled: Boolean = false,
        val packagePath: String = "",
        val installerPackage: String? = null,
        val wallClockMs: Long = 0L,
        val elapsedRealtimeMs: Long = 0L,
        val lastSeenWallMs: Long = 0L,
        val lastSeenElapsedMs: Long = 0L,
        val localeTag: String = "en-US",
        val timeZoneId: String = "UTC",
        val expectedLocaleTag: String? = null
    )

    // -- L38: VPN / proxy -------------------------------------------------

    /**
     * L38 — VPN/proxy detect.
     *
     * Android API mapping (caller reads these, passes the values in):
     * - VPN: `ConnectivityManager.getNetworkCapabilities(activeNetwork)
     *   ?.hasTransport(NetworkCapabilities.TRANSPORT_VPN)` — true when
     *   the active network is a VPN tunnel.
     * - Proxy: `System.getProperty("http.proxyHost")` — non-empty when
     *   an HTTP proxy is configured for the process (also check
     *   `"https.proxyHost"` the same way and pass either value in).
     *
     * Detected when a VPN transport is active OR a proxy host is set.
     * Either alone is a signal: a VPN hides the real network path and
     * a proxy can intercept traffic. Both are also legitimate
     * (corporate VPN, corporate proxy), so this is a signal only.
     */
    fun vpnOrProxyDetected(
        networkCapabilitiesHasVpn: Boolean,
        proxyHost: String?
    ): ReaEnv.Finding {
        return try {
            val proxySet = !proxyHost.isNullOrBlank()
            val detected = networkCapabilitiesHasVpn || proxySet
            val evidence = when {
                networkCapabilitiesHasVpn && proxySet ->
                    "VPN transport active and proxy host set: $proxyHost"
                networkCapabilitiesHasVpn ->
                    "VPN transport active (no proxy host set)"
                proxySet ->
                    "proxy host set: $proxyHost (no VPN transport)"
                else -> "no VPN transport, no proxy host"
            }
            ReaEnv.Finding("vpn-proxy", detected, evidence)
        } catch (e: Exception) {
            ReaEnv.Finding("vpn-proxy", false, "check failed: ${e.javaClass.simpleName}")
        }
    }

    // -- L39: screen-share / screencap ------------------------------------

    /**
     * L39 — Screen-share / screencap detect.
     *
     * Android API mapping (caller reads these, passes the values in):
     * - FLAG_SECURE: whether the app's window has
     *   `WindowManager.LayoutParams.FLAG_SECURE` set (the app asks
     *   Android to block screenshots / screen recording of its own
     *   window). There is no system query for "is FLAG_SECURE on";
     *   the caller knows because it set the flag itself.
     * - MediaProjection active: whether a screen-capture / screen-share
     *   session is in progress. There is NO public system-wide query
     *   for this — the caller must supply it from its own session
     *   tracking (e.g. it created a MediaProjection, or a
     *   MediaProjection callback / AccessibilityService observed one).
     *
     * WEAK SIGNAL, by design: FLAG_SECURE alone only proves the app
     * *asked* for protection — it is NOT a detection, and this function
     * deliberately does NOT fire on it. Only an active MediaProjection
     * fires, and even that only proves *something* is capturing or
     * sharing the screen (legitimate casting, a user-started recording,
     * an accessibility tool) — not that secrets were captured. Never a
     * refusal by itself.
     */
    fun screenShareDetected(
        isScreenCaptureDisabledByFlagSecure: Boolean,
        mediaProjectionActive: Boolean
    ): ReaEnv.Finding {
        return try {
            // Only the active projection is a detection. FLAG_SECURE
            // alone is protection requested, not capture observed.
            val detected = mediaProjectionActive
            val evidence = when {
                mediaProjectionActive && isScreenCaptureDisabledByFlagSecure ->
                    "MediaProjection active while FLAG_SECURE is set — this app's window is " +
                        "protected, but screen sharing/recording is in progress"
                mediaProjectionActive ->
                    "MediaProjection active and FLAG_SECURE is not set — screen may be shared/recorded"
                isScreenCaptureDisabledByFlagSecure ->
                    "no MediaProjection active; FLAG_SECURE is set (protection requested, not a detection)"
                else -> "no MediaProjection active; FLAG_SECURE is not set"
            }
            ReaEnv.Finding("screen-share", detected, evidence)
        } catch (e: Exception) {
            ReaEnv.Finding("screen-share", false, "check failed: ${e.javaClass.simpleName}")
        }
    }

    // -- L40: mock location ------------------------------------------------

    /**
     * L40 — Mock-location detect.
     *
     * Android API mapping (caller reads these, passes the values in):
     * - `allowMockLocation`: `Settings.Secure.getInt(contentResolver,
     *   Settings.Secure.ALLOW_MOCK_LOCATION, 0) == 1` — the device
     *   allows mock-location apps. Deprecated since API 23 (mock apps
     *   are now picked in developer options), so on modern Android this
     *   is usually 0 even when a mock app is active; it is kept as a
     *   supporting signal, not the main one.
     * - `locationIsFromMockProvider`: `Location.isFromMockProvider()`
     *   on the last known location — true when that fix came from a
     *   mock provider. This is the reliable per-fix signal.
     *
     * Detected when either is true.
     */
    fun mockLocationDetected(
        allowMockLocation: Boolean,
        locationIsFromMockProvider: Boolean
    ): ReaEnv.Finding {
        return try {
            val detected = allowMockLocation || locationIsFromMockProvider
            val evidence = when {
                allowMockLocation && locationIsFromMockProvider ->
                    "mock locations allowed in Settings and last location is from a mock provider"
                allowMockLocation ->
                    "mock locations allowed in Settings (ALLOW_MOCK_LOCATION)"
                locationIsFromMockProvider ->
                    "last location is from a mock provider"
                else -> "mock locations not allowed; last location not from a mock provider"
            }
            ReaEnv.Finding("mock-location", detected, evidence)
        } catch (e: Exception) {
            ReaEnv.Finding("mock-location", false, "check failed: ${e.javaClass.simpleName}")
        }
    }

    // -- L41: developer options --------------------------------------------

    /**
     * L41 — Developer-options detect.
     *
     * Android API mapping: `Settings.Global.getInt(contentResolver,
     * Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0) == 1`.
     *
     * Detected when developer options are enabled. Very common on
     * legitimate developer / power-user devices, so this is a weak
     * signal on its own — it matters mainly in combination with
     * L40/L42 (mock location, USB debugging).
     */
    fun developerOptionsEnabled(developmentSettingsEnabled: Boolean): ReaEnv.Finding {
        return try {
            ReaEnv.Finding(
                name = "developer-options",
                detected = developmentSettingsEnabled,
                evidence = if (developmentSettingsEnabled) {
                    "developer options enabled (DEVELOPMENT_SETTINGS_ENABLED=1)"
                } else {
                    "developer options not enabled"
                }
            )
        } catch (e: Exception) {
            ReaEnv.Finding("developer-options", false, "check failed: ${e.javaClass.simpleName}")
        }
    }

    // -- L42: USB debugging -------------------------------------------------

    /**
     * L42 — USB-debugging detect.
     *
     * Android API mapping: `Settings.Global.getInt(contentResolver,
     * Settings.Global.ADB_ENABLED, 0) == 1`.
     *
     * Detected when USB debugging (adb) is enabled. An enabled adb is
     * the usual route for a debugger / shell session, which is why this
     * is grouped with the debugger counter (D), but it is also normal
     * on a developer's own device — a signal, not a verdict.
     */
    fun usbDebuggingEnabled(adbEnabled: Boolean): ReaEnv.Finding {
        return try {
            ReaEnv.Finding(
                name = "usb-debugging",
                detected = adbEnabled,
                evidence = if (adbEnabled) {
                    "USB debugging enabled (ADB_ENABLED=1)"
                } else {
                    "USB debugging not enabled"
                }
            )
        } catch (e: Exception) {
            ReaEnv.Finding("usb-debugging", false, "check failed: ${e.javaClass.simpleName}")
        }
    }

    // -- L43: app cloner ----------------------------------------------------

    /**
     * L43 — App-cloner detect.
     *
     * Android API mapping (caller reads these, passes the values in):
     * - `packagePath`: the app's own data/code path, e.g.
     *   `applicationInfo.dataDir` or `sourceDir`
     *   (`/data/user/0/<package>` on a normal install). Cloners
     *   (Parallel Space, Dual Space, app cloners) run the app from a
     *   different data dir whose path contains a clone marker.
     * - `installerPackage`: `PackageManager.getInstallerPackageName(
     *   packageName)` — who installed the app. Checked with the same
     *   substring markers, in case the installer itself is a cloner.
     *
     * Detected when any of [CLONE_MARKERS] ("parallel", "dual",
     * "clone") appears as a substring (case-insensitive) in the
     * package path or the installer package name.
     *
     * FALSE POSITIVES, stated plainly: this is a substring match, so
     * ANY innocent name containing one of those words flags. A user
     * folder literally named "clone" flags. Worse, "dual" is a
     * substring of "individual" — a package or path containing
     * "individual" flags. A cloned app whose cloner hides its path
     * evades this entirely. This is a cheap heuristic signal, never
     * proof the app is cloned and never a refusal by itself.
     *
     * The evidence names only the matched marker and where it was
     * found (path vs installer) — it never echoes the full path.
     */
    fun appClonerDetected(packagePath: String, installerPackage: String?): ReaEnv.Finding {
        return try {
            val lowerPath = packagePath.lowercase()
            val lowerInstaller = installerPackage?.lowercase() ?: ""
            val hits = mutableListOf<String>()
            for (marker in CLONE_MARKERS) {
                if (lowerPath.contains(marker)) hits.add("path:'$marker'")
                if (lowerInstaller.contains(marker)) hits.add("installer:'$marker'")
            }
            ReaEnv.Finding(
                name = "app-cloner",
                detected = hits.isNotEmpty(),
                evidence = if (hits.isEmpty()) {
                    if (packagePath.isEmpty() && installerPackage.isNullOrEmpty()) {
                        "empty package path, no installer — nothing to check"
                    } else {
                        "no clone markers in package path or installer package"
                    }
                } else {
                    "clone markers: ${hits.joinToString(", ")}"
                }
            )
        } catch (e: Exception) {
            ReaEnv.Finding("app-cloner", false, "check failed: ${e.javaClass.simpleName}")
        }
    }

    // -- L44: time tamper ---------------------------------------------------

    /**
     * L44 — Time-tamper detect (clock skew).
     *
     * Android API mapping (caller reads these, passes the values in):
     * - `wallClockMs`: `System.currentTimeMillis()` — wall time, which
     *   the user / an attacker / NTP can move.
     * - `elapsedRealtimeMs`: `SystemClock.elapsedRealtime()` — time
     *   since boot, monotonic, NOT settable by the user; it advances
     *   even in deep sleep and only resets on reboot.
     * - `lastSeenWallMs` / `lastSeenElapsedMs`: the previous sample of
     *   the same two clocks (e.g. stored at last launch / last
     *   sensitive action). First run has no prior sample (pass 0).
     *
     * Logic: wall time and elapsed time must advance together.
     * `skew = (wall - lastWall) - (elapsed - lastElapsed)`. Detected
     * when the skew exceeds [TIME_SKEW_TOLERANCE_MS] (60 s) in either
     * direction — the wall clock moved backwards, jumped forward, or
     * froze while elapsed time kept running. A small step (seconds) is
     * normal NTP correction and is NOT flagged.
     *
     * Not flagged: no prior sample (first run); `elapsedRealtime`
     * going backwards, which means the monotonic clock reset — almost
     * always a reboot, not tamper.
     */
    fun timeTamperDetected(
        wallClockMs: Long,
        elapsedRealtimeMs: Long,
        lastSeenWallMs: Long,
        lastSeenElapsedMs: Long
    ): ReaEnv.Finding {
        return try {
            if (lastSeenWallMs <= 0L || lastSeenElapsedMs <= 0L) {
                return ReaEnv.Finding(
                    "time-tamper", false,
                    "no prior clock sample (first run) — nothing to compare"
                )
            }
            val wallDelta = wallClockMs - lastSeenWallMs
            val elapsedDelta = elapsedRealtimeMs - lastSeenElapsedMs
            if (elapsedDelta < 0L) {
                return ReaEnv.Finding(
                    "time-tamper", false,
                    "elapsedRealtime went backwards (reset, likely reboot) — not treated as tamper"
                )
            }
            val skew = wallDelta - elapsedDelta
            val detected = skew > TIME_SKEW_TOLERANCE_MS || skew < -TIME_SKEW_TOLERANCE_MS
            val evidence = when {
                skew > TIME_SKEW_TOLERANCE_MS ->
                    "wall clock jumped forward: wall advanced ${wallDelta}ms but elapsed " +
                        "only ${elapsedDelta}ms (skew +${skew}ms)"
                skew < -TIME_SKEW_TOLERANCE_MS ->
                    "wall clock moved backwards / froze: wall advanced ${wallDelta}ms but " +
                        "elapsed advanced ${elapsedDelta}ms (skew ${skew}ms)"
                else ->
                    "wall and elapsed agree within tolerance " +
                        "(wall +${wallDelta}ms, elapsed +${elapsedDelta}ms, skew ${skew}ms)"
            }
            ReaEnv.Finding("time-tamper", detected, evidence)
        } catch (e: Exception) {
            ReaEnv.Finding("time-tamper", false, "check failed: ${e.javaClass.simpleName}")
        }
    }

    // -- L45: locale / timezone anomaly -------------------------------------

    /**
     * L45 — Locale/timezone anomaly flag.
     *
     * Android API mapping (caller reads these, passes the values in):
     * - `localeTag`: `Locale.getDefault().toLanguageTag()` (BCP 47,
     *   e.g. "en-US"). Compared against `expectedLocaleTag`, the
     *   locale the app expects for this user/account (e.g. recorded at
     *   registration) — null when the app has no expectation.
     * - `timeZoneId`: `TimeZone.getDefault().id` (e.g.
     *   "Asia/Dhaka"). Recorded in the evidence; with only these
     *   inputs it can only be checked for blank/unknown — there is no
     *   expected-timezone parameter, and a timezone by itself proves
     *   nothing (see below).
     *
     * WEAKEST SIGNAL OF THE BATCH. A locale or timezone that differs
     * from expectation is completely normal: travel, a VPN, a
     * multilingual user, a manually set timezone, a device bought
     * abroad. This function only FLAGS (never refuses — nothing in
     * this file refuses, and this layer least of all). It fires when
     * the locale is blank, the timezone is blank/unknown, or the
     * locale differs from the expected locale (compared
     * case-insensitively, "_" treated as "-"). With no expected locale
     * and non-blank values, it does not fire — there is nothing to
     * call anomalous.
     */
    fun localeTimezoneAnomaly(
        localeTag: String,
        timeZoneId: String,
        expectedLocaleTag: String?
    ): ReaEnv.Finding {
        return try {
            val locale = normalizeTag(localeTag)
            val expected = expectedLocaleTag?.let { normalizeTag(it) }?.ifEmpty { null }
            val tz = timeZoneId.trim()
            val (detected, evidence) = when {
                locale.isEmpty() ->
                    true to "locale is blank/unknown (timezone: ${tz.ifEmpty { "blank" }})"
                expected != null && locale != expected ->
                    true to "locale '$localeTag' differs from expected '$expectedLocaleTag' (timezone: $timeZoneId)"
                tz.isEmpty() ->
                    true to "timezone is blank/unknown (locale: $localeTag)"
                else ->
                    false to "locale '$localeTag', timezone '$timeZoneId'" +
                        if (expected != null) " (matches expected locale)" else " (no expected locale to compare)"
            }
            ReaEnv.Finding("locale-timezone", detected, evidence)
        } catch (e: Exception) {
            ReaEnv.Finding("locale-timezone", false, "check failed: ${e.javaClass.simpleName}")
        }
    }

    /** BCP 47 normalisation for comparison: trim, "_" -> "-", lowercase. */
    private fun normalizeTag(tag: String): String =
        tag.trim().replace('_', '-').lowercase()

    // -- Aggregate ----------------------------------------------------------

    /** Run every batch-2 check (L38–L45, in order). Fixed order, stable output. */
    fun checkAll2(inputs: Env2Inputs = Env2Inputs()): List<ReaEnv.Finding> = listOf(
        vpnOrProxyDetected(inputs.networkCapabilitiesHasVpn, inputs.proxyHost),
        screenShareDetected(inputs.isScreenCaptureDisabledByFlagSecure, inputs.mediaProjectionActive),
        mockLocationDetected(inputs.allowMockLocation, inputs.locationIsFromMockProvider),
        developerOptionsEnabled(inputs.developmentSettingsEnabled),
        usbDebuggingEnabled(inputs.adbEnabled),
        appClonerDetected(inputs.packagePath, inputs.installerPackage),
        timeTamperDetected(
            inputs.wallClockMs, inputs.elapsedRealtimeMs,
            inputs.lastSeenWallMs, inputs.lastSeenElapsedMs
        ),
        localeTimezoneAnomaly(inputs.localeTag, inputs.timeZoneId, inputs.expectedLocaleTag)
    )

    /** Number of batch-2 checks that fired. 0 does NOT prove a clean device. */
    fun suspiciousCount2(inputs: Env2Inputs = Env2Inputs()): Int =
        checkAll2(inputs).count { it.detected }
}

package com.antirea.runtime

/**
 * Anti-REA v1.0 defensive traps — detection and delay only.
 *
 * These traps NEVER harm the device, the analyst, or the app process:
 * no bricking, no file deletion, no killing, no network, no wiping.
 * They record that something suspicious happened and let the APP decide
 * what to do (refuse a sensitive action, report to the server, degrade).
 * A trap that fires is a signal, not proof of an attack.
 */

/** Event recorded when a honeypot value is touched. No secrets in here. */
data class TripwireEvent(val honeypotId: String, val timestampMillis: Long)

/**
 * Honeypot: a fake value that legitimate code never touches. If anything
 * reads it, the trip is recorded via the caller-supplied [onTrip]
 * callback. This class NEVER sends network itself — the callback belongs
 * to the app, which decides whether (and how) to report it.
 *
 * Typical use: register a plausible-looking fake key/label at startup;
 * if useHoneypot() is ever called, an automated scanner or a tampered
 * build is probing values it should not know about.
 */
class Honeypot(private val onTrip: (TripwireEvent) -> Unit = {}) {

    private val values = mutableMapOf<String, String>()
    private val trips = mutableListOf<TripwireEvent>()

    /** Register a fake value under [id]. Overwrites any previous value for [id]. */
    fun registerHoneypot(id: String, fakeValue: String) {
        values[id] = fakeValue
    }

    /**
     * Returns the fake value for [id] (or null if never registered) AND
     * records a tripwire event via [onTrip]. The return value is fake by
     * design — it must never be used as a real key, URL, or credential.
     */
    fun useHoneypot(id: String): String? {
        val value = values[id] ?: return null
        val event = TripwireEvent(id, System.currentTimeMillis())
        trips.add(event)
        try {
            onTrip(event)
        } catch (e: Exception) {
            // A failing callback must never break the caller.
        }
        return value
    }

    /** How many times any honeypot has been touched. */
    fun tripCount(): Int = trips.size

    /** All recorded trips, oldest first. Returns a copy. */
    fun trips(): List<TripwireEvent> = trips.toList()

    /** Forget all registered values and trips (e.g. on logout). */
    fun clear() {
        values.clear()
        trips.clear()
    }
}

/**
 * Delayed failure: refuses a sensitive action only AFTER a threshold
 * number of integrity failures, instead of failing loudly on the first
 * one. The delay makes automated probing slower and noisier without
 * punishing a single transient failure (e.g. a bad read).
 *
 * The APP must call [recordIntegrityFailure] whenever a component
 * integrity check fails, and must call [allowSensitiveAction] at every
 * sensitive entry point (login, buy, settle, key generation) BEFORE
 * performing the action. This class does not hook or block anything by
 * itself — refusal is the app's decision at its own entry points.
 */
class DelayedFailure(private val threshold: Int = 3) {

    private var failureCount: Int = 0

    init {
        require(threshold >= 1) { "Anti-REA: DelayedFailure threshold must be >= 1" }
    }

    /** Record one integrity failure (blob hash mismatch, dex mismatch, ...). */
    fun recordIntegrityFailure() {
        failureCount++
    }

    /** True while failures are below the threshold; false once it is reached. */
    fun allowSensitiveAction(): Boolean = failureCount < threshold

    /** Current failure count. */
    fun failureCount(): Int = failureCount

    /** Reset after a verified-clean state (e.g. fresh install, re-verified blobs). */
    fun reset() {
        failureCount = 0
    }
}

/**
 * Decoy marker constants. These are inert labels a protected build may
 * scatter so that a naive string scan finds plausible-looking (but fake)
 * values instead of real ones. They are NOT real keys, URLs, or
 * credentials, and must never be used as such.
 */
object ReaDecoys {
    const val FAKE_API_KEY_LABEL: String = "antirea-decoy-api-key"
    const val FAKE_ENDPOINT_LABEL: String = "antirea-decoy-endpoint"
    const val FAKE_TOKEN_LABEL: String = "antirea-decoy-token"
    const val MARKER: String = "antirea-decoy"
}

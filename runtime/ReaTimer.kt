package com.appcore.runtime

import java.util.Timer
import java.util.TimerTask

/**
 * Anti-REA v1.0 — L30 integrity re-check timer.
 *
 * A scheduler that re-runs a supplied integrity check at a
 * configurable interval, using an INJECTABLE clock/tick so it is
 * fully testable on the JVM without real time passing. The app
 * supplies the check (e.g. "re-verify the dex hash + env findings");
 * the timer only decides WHEN it runs and stops it when the check
 * refuses.
 *
 * REFUSE-ONLY: when a check returns false (tamper / hooked env),
 * the timer stops itself ([stopped] = true) and never fires again
 * until the app explicitly calls reset(). The app then refuses the
 * sensitive action. The timer never throws, never kills, never
 * deletes — a check that throws is treated as a failure (stop).
 *
 * Two modes:
 *   1. MANUAL (testable): the caller drives time with [tick(nowMs)]
 *      or [advance(ms)]. The clock is whatever the caller passes —
 *      a fake clock in tests, System.currentTimeMillis() in prod.
 *   2. REAL-TIME: [startRealTime] runs the same logic on a daemon
 *      java.util.Timer. Same stop-on-refusal rule.
 */
class ReaTimer(
    /** Interval between re-checks, in milliseconds. Must be > 0. */
    val intervalMs: Long,
    /** The integrity check to re-run. True = clean, false = refuse. */
    private val check: () -> Boolean,
    /** Clock source, in ms. Defaults to wall clock; tests inject a fake. */
    private val clockMs: () -> Long = { System.currentTimeMillis() }
) {
    init {
        require(intervalMs > 0) { "AppCore: ReaTimer intervalMs must be > 0" }
    }

    /** How many times the check has fired (including failures). */
    var fireCount: Int = 0
        private set

    /** How many times the check has passed. */
    var passCount: Int = 0
        private set

    /** True once a check has failed (or the timer was stopped). */
    var stopped: Boolean = false
        private set

    /** Last time a check fired, in clock ms. Null before the first fire. */
    var lastFireMs: Long? = null
        private set

    private var nextFireMs: Long? = null
    private var realTimer: Timer? = null

    companion object {
        /**
         * Max check invocations in one tick() call (see [tick]).
         * A clock jump must never turn one tick into thousands of
         * back-to-back checks on the calling thread.
         */
        const val MAX_FIRES_PER_TICK: Int = 10
    }

    /** Arm the timer: the first check fires after [intervalMs]. */
    fun arm() {
        nextFireMs = clockMs() + intervalMs
    }

    /**
     * Drive the timer to [nowMs]: fires the check once per elapsed
     * interval (catching up if several intervals passed), and stops
     * on the first failure. Returns how many times the check fired
     * in this call. Safe to call when stopped or unarmed (0 fires).
     *
     * Catch-up is CAPPED at [MAX_FIRES_PER_TICK] fires per call:
     * without the cap, a clock jump (device asleep for hours, a
     * manual clock change) with a short interval would run the
     * check once per elapsed interval in a single call — thousands
     * of invocations blocking the calling thread. When the cap is
     * hit and intervals are still due, the timer skips ahead so
     * the next check is one interval after [nowMs], not still
     * buried in the past.
     */
    fun tick(nowMs: Long): Int {
        if (stopped) return 0
        val next = nextFireMs ?: return 0
        var fired = 0
        var due = next
        while (nowMs >= due && !stopped && fired < MAX_FIRES_PER_TICK) {
            val ok = try {
                check()
            } catch (e: Exception) {
                false
            }
            fireCount++
            fired++
            lastFireMs = due
            if (ok) {
                passCount++
                due += intervalMs
            } else {
                stopped = true
            }
        }
        if (!stopped) {
            nextFireMs = if (fired >= MAX_FIRES_PER_TICK && nowMs >= due) {
                // Cap hit with intervals still due: skip ahead.
                nowMs + intervalMs
            } else {
                due
            }
        }
        return fired
    }

    /**
     * One-shot convenience used by tests with a fake clock: set the
     * clock to [nowMs] and fire any due checks. Identical to tick().
     */
    fun runDue(nowMs: Long): Int = tick(nowMs)

    /** Re-arm after a stop (app's decision, e.g. after re-attestation). */
    fun reset() {
        stopped = false
        fireCount = 0
        passCount = 0
        lastFireMs = null
        nextFireMs = clockMs() + intervalMs
    }

    /** Stop the timer (manual mode and real-time mode). Never throws. */
    fun stop() {
        stopped = true
        try {
            realTimer?.cancel()
        } catch (e: Exception) {
            // Ignore: stopping must never crash the app.
        }
        realTimer = null
    }

    /**
     * Start real-time firing on a daemon Timer thread. The check
     * runs every [intervalMs]; on the first failure the timer stops
     * itself. The timer thread is a daemon, so it never keeps the
     * app process alive. Call [stop] to cancel early.
     */
    fun startRealTime() {
        stop()
        stopped = false
        arm()
        val timer = Timer("rea-integrity-timer", true)
        realTimer = timer
        timer.scheduleAtFixedRate(
            object : TimerTask() {
                override fun run() {
                    tick(clockMs())
                    if (stopped) {
                        try {
                            timer.cancel()
                        } catch (e: Exception) {
                            // Ignore.
                        }
                    }
                }
            },
            intervalMs,
            intervalMs
        )
    }
}

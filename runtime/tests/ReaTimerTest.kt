package com.appcore.runtime

/**
 * JVM test for ReaTimer (runtime/ReaTimer.kt) — L30 integrity
 * re-check timer, manual (fake-clock) mode.
 *
 * Pure core only — no Android imports, no device. Compile with
 * android.jar on the kotlinc classpath (for uniformity with the
 * other runtime tests), then run on a plain JVM:
 *   kotlinc -cp $ANDROID_JAR -d timer-test.jar \
 *     ReaTimer.kt tests/ReaTimerTest.kt
 *   java -cp timer-test.jar:$STDLIB \
 *     com.appcore.runtime.ReaTimerTestKt
 *
 * Checks:
 *  (a) arm/tick: nothing fires before the first interval; one fire
 *      at the due time; the next fire is one interval later.
 *  (b) a failing check stops the timer and later ticks fire 0.
 *  (c) a throwing check is treated as a failure (stop, never throw).
 *  (d) reset() re-arms after a stop.
 *  (e) catch-up CAP (runtime audit 2026-11-23): a clock jump of 100
 *      intervals fires at most MAX_FIRES_PER_TICK times in one
 *      tick(), and the timer skips ahead so the next check is one
 *      interval after the jump time — it does not stay buried in
 *      the past firing hundreds of back-to-back checks.
 *  (f) unarmed / stopped timers fire 0; intervalMs <= 0 is rejected.
 * Any failure exits non-zero. Prints TEST-PASS on success.
 */
fun main() {
    fun fail(msg: String): Nothing {
        println("FAIL: $msg")
        kotlin.system.exitProcess(1)
    }

    // (a) arm/tick basics with a fake clock.
    var now = 0L
    var fires = 0
    val t = ReaTimer(1000L, { fires++; true }, { now })
    t.arm() // first fire due at 1000
    if (t.tick(500) != 0 || fires != 0) fail("fired before the first interval")
    if (t.tick(999) != 0 || fires != 0) fail("fired 1ms early")
    if (t.tick(1000) != 1 || fires != 1) fail("did not fire at the due time")
    if (t.fireCount != 1 || t.passCount != 1 || t.lastFireMs != 1000L) {
        fail("counters wrong after first fire: fire=${t.fireCount} pass=${t.passCount} last=${t.lastFireMs}")
    }
    if (t.tick(1500) != 0 || fires != 1) fail("fired between intervals")
    if (t.tick(2000) != 1 || fires != 2) fail("did not fire at the second interval")
    println("ARM-TICK-OK: fires at due times only, counters correct")

    // (b) a failing check stops the timer.
    var calls = 0
    val failing = ReaTimer(100L, { calls++; calls < 3 }, { 0L })
    failing.arm()
    if (failing.tick(100) != 1 || failing.stopped) fail("first passing fire wrong")
    if (failing.tick(200) != 1 || failing.stopped) fail("second passing fire wrong")
    if (failing.tick(300) != 1 || !failing.stopped) fail("third (failing) fire did not stop the timer")
    if (failing.tick(400) != 0) fail("stopped timer fired again")
    if (failing.fireCount != 3 || failing.passCount != 2) {
        fail("failing timer counters wrong: fire=${failing.fireCount} pass=${failing.passCount}")
    }
    println("STOP-ON-FAIL-OK: stops on the first failed check, stays stopped")

    // (c) a throwing check is a failure, never a throw out of tick().
    val throwing = ReaTimer(100L, { throw RuntimeException("boom") }, { 0L })
    throwing.arm()
    try {
        if (throwing.tick(100) != 1 || !throwing.stopped) {
            fail("throwing check did not count as one failed fire + stop")
        }
    } catch (e: Exception) {
        fail("tick() threw out of a throwing check: $e")
    }
    println("THROW-OK: throwing check counts as a failure, tick() never throws")

    // (d) reset() re-arms after a stop.
    failing.reset()
    if (failing.stopped || failing.fireCount != 0 || failing.passCount != 0 || failing.lastFireMs != null) {
        fail("reset() did not clear the stopped state/counters")
    }
    calls = 0
    if (failing.tick(100) != 1 || failing.stopped) fail("reset timer did not fire again")
    println("RESET-OK: reset clears state and re-arms")

    // (e) catch-up cap: 100 intervals elapsed in one jump.
    var capFires = 0
    val cap = ReaTimer(1000L, { capFires++; true }, { 0L })
    cap.arm() // due at 1000
    val fired = cap.tick(100_000L) // 100 intervals due at once
    if (fired != ReaTimer.MAX_FIRES_PER_TICK) {
        fail("cap: tick fired $fired times for 100 due intervals, want ${ReaTimer.MAX_FIRES_PER_TICK}")
    }
    if (capFires != ReaTimer.MAX_FIRES_PER_TICK) {
        fail("cap: check ran $capFires times, want ${ReaTimer.MAX_FIRES_PER_TICK}")
    }
    if (cap.fireCount != ReaTimer.MAX_FIRES_PER_TICK || cap.lastFireMs != 10_000L) {
        fail("cap: fireCount=${cap.fireCount} lastFireMs=${cap.lastFireMs}, want 10 / 10000")
    }
    // Next check must be one interval after the jump time (101000),
    // not still buried 90 intervals in the past.
    if (cap.tick(100_500L) != 0) fail("cap: fired again before the skipped-ahead due time")
    if (cap.tick(101_000L) != 1 || capFires != ReaTimer.MAX_FIRES_PER_TICK + 1) {
        fail("cap: did not fire exactly once at the skipped-ahead time 101000")
    }
    if (cap.tick(102_000L) != 1) fail("cap: schedule did not resume at 1s intervals")
    println("CAP-OK: 100 due intervals -> ${ReaTimer.MAX_FIRES_PER_TICK} fires, skip-ahead to 101000, schedule resumes")

    // (f) unarmed / stopped / bad interval.
    val unarmed = ReaTimer(100L, { true }, { 0L })
    if (unarmed.tick(10_000L) != 0) fail("unarmed timer fired")
    unarmed.arm()
    unarmed.stop()
    if (unarmed.tick(10_000L) != 0 || !unarmed.stopped) fail("stopped timer fired")
    try {
        ReaTimer(0L, { true })
        fail("intervalMs=0 accepted (must be rejected)")
    } catch (e: IllegalArgumentException) {
        // Expected.
    }
    try {
        ReaTimer(-5L, { true })
        fail("negative intervalMs accepted (must be rejected)")
    } catch (e: IllegalArgumentException) {
        // Expected.
    }
    println("EDGE-OK: unarmed/stopped fire 0, intervalMs <= 0 rejected")

    println("TEST-PASS")
}

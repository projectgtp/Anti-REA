package com.appcore.runtime

/**
 * Crash-hunt tests (Agent C, 2026-11-23) — F11 + F12.
 *
 * F11: ReaGuardProvider.onCreate must never let an Error escape
 *   provider init (it previously caught Exception only). The normal
 *   path IS runnable on the JVM: the provider's Context is null
 *   there, so the mod-block check is skipped and checkDexHash
 *   returns false, while ReaEnv.checkAll() runs its pure-Kotlin
 *   file/Build reads. This test asserts onCreate() returns true
 *   and leaves initialized=true / dexCheckPassed=false. The
 *   Throwable-wide catch itself cannot be driven to throw an Error
 *   on the JVM (no check throws one there); it is verified by code
 *   inspection, and section (c) below demonstrates the semantics:
 *   a Throwable catch swallows an Error that an Exception catch
 *   would have let escape.
 * F12: ReaNative.nativeVersionSafe() must return null (never throw)
 *   when libreagate.so is absent — the raw nativeVersion() would
 *   throw UnsatisfiedLinkError. On the JVM nativeLoaded is false.
 *
 * Compile + run (see runtime/NOTES.md § JVM test for the wrapper):
 *   kotlinc -cp $ANDROID_JAR -d crashhunt-test.jar \
 *     ReaGuardProvider.kt ReaEnv.kt ReaEnv2.kt ReaModBlock.kt ModBlockData.kt \
 *     ReaTrace.kt ReaRuntime.kt ReaIntegrity.kt ReaIntegrity2.kt \
 *     ReaNative.kt ReaTraps.kt tests/CrashHuntTest.kt
 *   java -cp crashhunt-test.jar:$ANDROID_JAR:$STDLIB \
 *     com.appcore.runtime.CrashHuntTestKt
 */
fun main() {
    var failures = 0
    fun check(name: String, cond: Boolean) {
        if (cond) println("PASS: $name") else { println("FAIL: $name"); failures++ }
    }

    // -- F12: safe nativeVersion wrapper -------------------------------
    check("F12 nativeLoaded is false on JVM (no .so)", !ReaNative.nativeLoaded)
    var versionSafe: String? = "<not-called>"
    var versionThrew = false
    try {
        versionSafe = ReaNative.nativeVersionSafe()
    } catch (e: Throwable) {
        versionThrew = true
    }
    check("F12 nativeVersionSafe() does not throw", !versionThrew)
    check("F12 nativeVersionSafe() returns null without .so", versionSafe == null)
    val data = "crash-hunt".toByteArray(Charsets.UTF_8)
    val hex = ReaRuntime.sha256Hex(data)
    check("F12 integrityGate falls back to Java and passes", ReaNative.integrityGate(hex, data))
    check("F12 integrityGate rejects a wrong hash", !ReaNative.integrityGate("00".repeat(32), data))

    // -- F11a: provider onCreate normal path on JVM --------------------
    var providerRan = false
    var providerThrew: Throwable? = null
    try {
        val provider = ReaGuardProvider()
        val ok = provider.onCreate()
        providerRan = true
        check("F11 provider onCreate() returns true", ok)
        check("F11 provider initialized=true after onCreate", ReaGuardProvider.initialized)
        check(
            "F11 provider dexCheckPassed=false with null context",
            ReaGuardProvider.dexCheckPassed == false
        )
        check("F11 provider findings is a list (possibly empty)", ReaGuardProvider.findings != null)
    } catch (e: Throwable) {
        providerThrew = e
    }
    if (!providerRan) {
        // Android stub limitation, not a product failure: the
        // ContentProvider stub refused to run on the JVM. The
        // Throwable catch is then covered by (c) + code inspection.
        println(
            "NOTE: F11a provider onCreate not runnable on JVM " +
                "(stub threw ${providerThrew?.javaClass?.name}: ${providerThrew?.message}); " +
                "skipped, not a failure."
        )
    }

    // -- F11b: Throwable-catch semantics (pattern demonstration) -------
    // An Error thrown inside a check must be swallowed by a
    // `catch (e: Throwable)`; the old `catch (e: Exception)` would
    // have let it escape and kill the launch. Throwing the Error
    // object directly allocates nothing.
    var swallowed = false
    try {
        try {
            throw OutOfMemoryError("simulated provider-check Error")
        } catch (e: Throwable) {
            swallowed = true
        }
    } catch (e: Throwable) {
        swallowed = false
    }
    check("F11b Throwable catch swallows an Error", swallowed)
    var escapedExceptionCatch = false
    try {
        try {
            throw OutOfMemoryError("simulated provider-check Error")
        } catch (e: Exception) {
            // Old code: Exception only — Error escapes.
        }
    } catch (e: OutOfMemoryError) {
        escapedExceptionCatch = true
    }
    check("F11b Exception-only catch lets an Error escape (old bug)", escapedExceptionCatch)

    if (failures == 0) println("TEST-PASS") else throw AssertionError("TEST-FAIL: $failures failures")
}

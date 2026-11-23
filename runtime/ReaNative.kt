package com.appcore.runtime

/**
 * Anti-REA v1.0 — L49 native integrity gate.
 *
 * A tiny JNI gate compiled from runtime/native/reagate.c into
 * lib/arm64-v8a/libreagate.so (arm64-v8a only in v1.0). The native
 * side computes SHA-256 over the bytes it is given and compares the
 * result with the expected hex in constant time — the comparison
 * happens in native code, so a static patch of one Java boolean does
 * not defeat it. It is still a GATE, not a proof: a determined
 * attacker with root can patch the .so or hook the JNI call. The
 * server-side checks remain the real enforcement.
 *
 * The Java fallback is the real check when the .so is absent (wrong
 * ABI, stripped APK, plain-JVM test): integrityGate() prefers the
 * native gate when loaded and falls back to the identical pure-Kotlin
 * computation otherwise. Callers pass the SAME bytes and expected
 * hash either way, so the verdict is the same on both paths.
 *
 * Loading is best-effort and never throws: a missing .so is a normal
 * "native gate unavailable" state, not a crash. The app decides what
 * a failed gate means; this object only reports it.
 *
 * The CLI must copy libreagate.so into the APK at
 * lib/<abi>/libreagate.so for the gate to load. Without that file,
 * nativeLoaded is false and the Java fallback runs.
 */
object ReaNative {

    /** True only when libreagate.so loaded successfully. */
    val nativeLoaded: Boolean

    init {
        var loaded = false
        try {
            System.loadLibrary("reagate")
            loaded = true
        } catch (e: Throwable) {
            // Missing .so / wrong ABI / stripped APK: normal, the
            // Java fallback below is the real check.
            loaded = false
        }
        nativeLoaded = loaded
    }

    /**
     * JNI: SHA-256 [data], constant-time compare with [expectedHex].
     * Implemented in runtime/native/reagate.c. Returns false (never
     * throws) on any native-side failure.
     */
    @JvmStatic
    external fun nativeGate(expectedHex: String, data: ByteArray): Boolean

    /** JNI: the gate's own version string, e.g. "reagate-1". */
    @JvmStatic
    external fun nativeVersion(): String

    /**
     * Safe wrapper for [nativeVersion]: null (never a throw) when the
     * .so is absent or the JNI call fails. The raw [nativeVersion] is
     * an external fun with no wrapper, so a direct call throws
     * UnsatisfiedLinkError when libreagate.so is missing — callers
     * must use this wrapper, not the raw JNI method. (Crash hunt
     * 2026-11-23: nothing calls it at startup in v1.0, but any
     * future caller must not be able to kill the app this way.)
     */
    fun nativeVersionSafe(): String? {
        if (!nativeLoaded) return null
        return try {
            nativeVersion()
        } catch (e: Throwable) {
            null
        }
    }

    /**
     * Pure-Kotlin gate (the fallback): SHA-256 [data] compared with
     * [expectedHex] (case-insensitive). Compared with
     * [ReaIntegrity2.hexEqualsConstantTime] — the old plain `==`
     * short-circuited on the first differing character, leaking the
     * mismatch position by timing, while the native gate this
     * mirrors compares in constant time. False on any error, never
     * throws.
     */
    fun javaGate(expectedHex: String, data: ByteArray): Boolean {
        return try {
            ReaIntegrity2.hexEqualsConstantTime(ReaRuntime.sha256Hex(data), expectedHex)
        } catch (e: Exception) {
            false
        }
    }

    /**
     * The gate apps call: prefer the native gate when it loaded,
     * otherwise the identical Java computation. A native exception
     * falls back to Java instead of crashing the caller.
     */
    fun integrityGate(expectedHex: String, data: ByteArray): Boolean {
        if (nativeLoaded) {
            try {
                return nativeGate(expectedHex, data)
            } catch (e: Throwable) {
                // Fall through to the Java gate.
            }
        }
        return javaGate(expectedHex, data)
    }
}

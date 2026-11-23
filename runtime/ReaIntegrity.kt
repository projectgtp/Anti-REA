package com.antirea.runtime

import java.io.File
import java.security.MessageDigest

/**
 * Anti-REA v1.0 integrity checks.
 *
 * The pure functions in the top section use Kotlin stdlib + JDK only and
 * have NO Android imports, so they can be unit-tested on the JVM. The
 * Context-based helper at the bottom is in a clearly-marked Android-only
 * section and is the only part that needs android.jar.
 *
 * Integrity here proves a blob/file was not altered since it was built.
 * It does NOT prove the device is clean — that is ReaEnv's job, and even
 * there the result is a signal, not proof.
 */
object ReaIntegrity {

    // ------------------------------------------------------------------
    // Pure functions — no Android imports.
    // ------------------------------------------------------------------

    /** Result of an integrity check run. `passed` is false if any check failed. */
    data class IntegrityResult(val passed: Boolean, val failedChecks: List<String>)

    /** sha256 hex of raw bytes. */
    fun sha256Hex(bytes: ByteArray): String {
        return MessageDigest.getInstance("SHA-256").digest(bytes)
            .joinToString("") { "%02x".format(it) }
    }

    /** True only when sha256([bytes]) equals [expectedHex] (case-insensitive). */
    fun verifyBytesSha256(bytes: ByteArray, expectedHex: String): Boolean {
        return try {
            sha256Hex(bytes) == expectedHex.lowercase()
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Verify a DEX (or any file's) bytes against an expected sha256 hex.
     * False (never throws) on mismatch, unreadable input, or bad hex.
     */
    fun verifyDexSha256(dexBytes: ByteArray, expectedHex: String): Boolean {
        return verifyBytesSha256(dexBytes, expectedHex)
    }

    /** Verify a file's bytes against an expected sha256 hex. False on any error. */
    fun verifyFileSha256(file: File, expectedHex: String): Boolean {
        return try {
            if (!file.canRead()) return false
            verifyBytesSha256(file.readBytes(), expectedHex)
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Verify a protected component blob against its expected blob sha256.
     * Delegates to [ReaRuntime.verifyIntegrity] — the blob itself is NOT
     * decrypted here, so a passing check says "untampered", not "decryptable".
     * Callers should still call ReaRuntime.decrypt(), which re-checks the
     * embedded plaintext hash and refuses on any tamper.
     */
    fun verifyComponentBlob(blobBase64: String, expectedSha256: String): Boolean {
        return ReaRuntime.verifyIntegrity(blobBase64, expectedSha256)
    }

    /**
     * Run several named blob checks at once and collect the failures.
     * [checks] maps a check name to (blobBase64, expectedSha256).
     */
    fun verifyAllBlobs(checks: Map<String, Pair<String, String>>): IntegrityResult {
        val failed = mutableListOf<String>()
        for ((name, pair) in checks) {
            if (!verifyComponentBlob(pair.first, pair.second)) failed.add(name)
        }
        return IntegrityResult(passed = failed.isEmpty(), failedChecks = failed)
    }

    // ------------------------------------------------------------------
    // Android-only section — needs android.jar (android.content.Context).
    // Everything above works on the plain JVM; everything below does not.
    // ------------------------------------------------------------------

    /**
     * Android-only: verify the running APK's own bytes (packageCodePath,
     * i.e. base.apk) against an expected sha256 hex. Returns false — never
     * throws — when the context, the APK file, or the hash is unavailable.
     * The app calls this at startup (or ReaGuardProvider does) and decides
     * itself what a failure means; this function never blocks or kills.
     */
    fun verifyOwnApkSha256(context: android.content.Context, expectedHex: String): Boolean {
        return try {
            val apkPath = context.applicationInfo.sourceDir ?: return false
            verifyFileSha256(File(apkPath), expectedHex)
        } catch (e: Exception) {
            false
        }
    }
}

package com.appcore.runtime

import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.pm.Signature
import android.os.Build

/**
 * Anti-REA L103 — renamed / repacked APK defence.
 *
 * THE PROBLEM (simple words, see docs/GAMEGUARDIAN.md): a renamed
 * APK is the same app with a new name. An attacker takes your APK,
 * changes the package name (so a name blocklist never matches it),
 * changes a string or two, re-signs it with THEIR OWN key, and
 * installs it. The app still runs — but it is no longer your app.
 * L101's package-name blocklist cannot catch this, because the
 * renamed copy has a new name. L103 catches it two other ways:
 *
 *   1. PACKAGE NAME: the app knows what its own package name must
 *      be (from the developer's config). At startup and before
 *      every sensitive action it compares the running package name
 *      with the expected one. A renamed copy fails — refuse.
 *   2. SIGNATURE: every APK is signed with a key. The developer's
 *      release key has a fingerprint (SHA-256 of the signing
 *      certificate). A repacked APK is re-signed with the
 *      attacker's key, so the fingerprint WILL be different — the
 *      attacker cannot forge the developer's key. Compare the
 *      running app's signing-certificate SHA-256 with the expected
 *      one. Mismatch — refuse. This is the strong check: renaming
 *      is free, forging a signature is not possible without the
 *      private key.
 *
 * HOW THE EXPECTED HASH IS STORED: never as a plain string in the
 * APK (that would be a needle to steal and replace). It is stored
 * as an encrypted blob in the standard REA-IR pattern — generate
 * it with tools/make_sig_blob.py from the developer's own release
 * certificate SHA-256, and pass the (blob, part1, part2) triple to
 * verifyExpectedHashBlob(). The blob decrypts in memory only, via
 * ReaRuntime, and a tampered blob refuses.
 *
 * INSTALLER CHECK (best-effort signal only): records which app
 * installed us (Play Store = com.android.vending, anything else =
 * third-party/sideload, null = unknown). It is NEVER a refusal on
 * its own — legitimate users sideload, and stores vary by country.
 * It is one more signal for the server to score.
 *
 * REFUSE-ONLY. A failure means the app refuses ONE sensitive action.
 * Nothing is deleted, nothing is killed, nothing is written. Every
 * function returns false/null on error, never throws — a failed
 * check must never crash the app.
 *
 * Honest limit: this proves the running APK is the one the
 * developer signed, with the expected package name. It does NOT
 * prove the device is clean — a rooted memory editor (L102) can
 * still read values after decryption, and the server remains the
 * real enforcement for money/points.
 */
object ReaRepack {

    /** Result of a repack check. [signatureOk] is null when the
     *  signature was not checked (no expected hash supplied). */
    data class RepackResult(
        val packageOk: Boolean,
        val signatureOk: Boolean?,
        val installer: String,
        val allowSensitiveAction: Boolean
    )

    // -- Pure core (JVM-testable, no Android imports) -------------------

    /** True only when the running package name is exactly the
     *  expected one (case-sensitive). A null actual name fails. */
    fun verifyPackageName(actual: String?, expected: String): Boolean {
        if (actual == null) return false
        return actual == expected
    }

    /** True only when SHA-256([certBytes]) equals [expectedHex]
     *  (case-insensitive). False on any error, never throws. */
    fun verifySigningCertSha256(certBytes: ByteArray, expectedHex: String): Boolean {
        return try {
            if (certBytes.isEmpty()) return false
            if (expectedHex.isBlank()) return false
            ReaIntegrity.sha256Hex(certBytes) == expectedHex.lowercase()
        } catch (e: Exception) {
            false
        }
    }

    /** True only when a live certificate fingerprint ([liveHex],
     *  the SHA-256 hex already computed by getSigningCertSha256)
     *  equals [expectedHex] (case-insensitive, trimmed). This is
     *  the hex-to-hex compare the Android path uses — it must NOT
     *  hash again (hashing a hash would never match). */
    fun verifySigningCertHex(liveHex: String?, expectedHex: String): Boolean {
        if (liveHex.isNullOrBlank()) return false
        if (expectedHex.isBlank()) return false
        return liveHex.trim().lowercase() == expectedHex.trim().lowercase()
    }

    /**
     * Decrypt the expected certificate hash from an encrypted blob
     * triple (standard ReaRuntime blob format, made by
     * tools/make_sig_blob.py) and compare it with [certBytes].
     * False — never throws — on any decrypt failure, bad hash, or
     * mismatch. A tampered blob refuses instead of passing.
     */
    fun verifyExpectedHashBlob(
        blobBase64: String,
        keyPart1B64: String,
        keyPart2B64: String,
        certBytes: ByteArray
    ): Boolean {
        return try {
            val expectedHex = ReaRuntime.decrypt(blobBase64, keyPart1B64, keyPart2B64)
            verifySigningCertSha256(certBytes, expectedHex.trim())
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Classify an installer package name. Only the Play Store is a
     * VERIFIED "play-store" value (com.android.vending). Anything
     * else that is non-blank is "third-party-or-sideload"; null or
     * blank is "unknown". Never a refusal on its own.
     */
    fun classifyInstaller(installerPackage: String?): String {
        if (installerPackage.isNullOrBlank()) return "unknown"
        return if (installerPackage == "com.android.vending") "play-store"
        else "third-party-or-sideload"
    }

    // -- Android wrappers (need Context, never throw) -------------------

    /** The running app's signing-certificate SHA-256 (lowercase hex),
     *  or null when it cannot be read. Reads the first certificate
     *  only; multi-signer APKs are out of scope in v1.0 (documented
     *  in docs/GAMEGUARDIAN.md). */
    @Suppress("DEPRECATION")
    fun getSigningCertSha256(context: Context): String? {
        return try {
            val pm = context.packageManager
            val pkg = context.packageName
            val info: PackageInfo = if (Build.VERSION.SDK_INT >= 28) {
                pm.getPackageInfo(pkg, PackageManager.GET_SIGNING_CERTIFICATES)
            } else {
                pm.getPackageInfo(pkg, PackageManager.GET_SIGNATURES)
            }
            val certs: Array<Signature>? = if (Build.VERSION.SDK_INT >= 28) {
                info.signingInfo?.apkContentsSigners
            } else {
                info.signatures
            }
            val first = certs?.firstOrNull() ?: return null
            ReaIntegrity.sha256Hex(first.toByteArray())
        } catch (e: Exception) {
            null
        }
    }

    /** The package that installed this app, or null when unknown. */
    fun getInstallerPackage(context: Context): String? {
        return try {
            val pm = context.packageManager
            val pkg = context.packageName
            if (Build.VERSION.SDK_INT >= 30) {
                pm.getInstallSourceInfo(pkg).installingPackageName
            } else {
                @Suppress("DEPRECATION")
                pm.getInstallerPackageName(pkg)
            }
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Full repack check for the app to gate on. [expectedPackage] is
     * the developer's package name; [expectedCertBlob] is null when
     * no signature check is configured (then [signatureOk] is null
     * and does not block). allowSensitiveAction is true only when
     * the package matches AND the signature did not fail.
     */
    fun checkRepack(
        context: Context,
        expectedPackage: String,
        expectedCertBlob: Triple<String, String, String>? = null
    ): RepackResult {
        val actualPackage = try {
            context.packageName
        } catch (e: Exception) {
            null
        }
        val packageOk = verifyPackageName(actualPackage, expectedPackage)
        val signatureOk: Boolean? = if (expectedCertBlob == null) {
            null
        } else {
            try {
                val certHex = getSigningCertSha256(context)
                if (certHex == null) {
                    false
                } else {
                    val expectedHex = try {
                        ReaRuntime.decrypt(
                            expectedCertBlob.first,
                            expectedCertBlob.second,
                            expectedCertBlob.third
                        ).trim()
                    } catch (e: Exception) {
                        return RepackResult(
                            packageOk = packageOk,
                            signatureOk = false,
                            installer = classifyInstaller(getInstallerPackage(context)),
                            allowSensitiveAction = false
                        )
                    }
                    // Hex-to-hex compare: certHex is ALREADY a SHA-256
                    // hex fingerprint, so it must not be hashed again.
                    verifySigningCertHex(certHex, expectedHex)
                }
            } catch (e: Exception) {
                false
            }
        }
        val installer = classifyInstaller(
            try {
                getInstallerPackage(context)
            } catch (e: Exception) {
                null
            }
        )
        val allow = packageOk && (signatureOk != false)
        return RepackResult(packageOk, signatureOk, installer, allow)
    }
}

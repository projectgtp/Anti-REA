package com.antirea.runtime

import android.content.ContentProvider
import android.content.ContentValues
import android.content.Context
import android.content.pm.ProviderInfo
import android.database.Cursor
import android.net.Uri
import java.io.File

/**
 * Anti-REA v1.0 guard provider.
 *
 * An Android ContentProvider whose onCreate() runs the environment checks
 * ([ReaEnv.checkAll]) plus a dex/APK hash check when a manifest asset
 * exists, and stores the findings in a static volatile list for the app
 * to read. It ALWAYS returns true from onCreate(): it never crashes the
 * app, never blocks launch, and never refuses anything itself.
 *
 * REFUSAL IS THE APP'S DECISION, NOT THE PROVIDER'S. The app reads
 * [findings] / [dexCheckPassed] at its own sensitive entry points and
 * decides whether to proceed, degrade, or report to the server. A
 * provider that blocked launch would brick legitimate installs on the
 * first false positive; this one only observes and reports.
 *
 * Manifest entry (the CLI writes this into the protected app's manifest;
 * ${applicationId} is the app's own applicationId):
 *
 *   <provider
 *       android:name="com.antirea.runtime.ReaGuardProvider"
 *       android:authorities="${applicationId}.antirea.guard"
 *       android:exported="false"
 *       android:enabled="true" />
 *
 * The dex/APK hash check reads the optional asset "antirea/dex.sha256"
 * (one line: the expected lowercase hex sha256 of base.apk, as emitted
 * by the CLI). If the asset is absent, [dexCheckPassed] is null
 * ("not checked") — that is normal for builds the CLI did not hash.
 * ContentProvider methods other than onCreate() are stubs: this provider
 * serves no data and is not queryable.
 */
class ReaGuardProvider : ContentProvider() {

    companion object {
        /** Latest environment findings from onCreate(). Empty before onCreate runs. */
        @Volatile
        var findings: List<ReaEnv.Finding> = emptyList()
            private set

        /**
         * Result of the optional dex/APK hash check: true = hash matched,
         * false = hash mismatched or unreadable, null = no dex.sha256
         * asset present (check not run).
         */
        @Volatile
        var dexCheckPassed: Boolean? = null
            private set

        /** True once onCreate() has run (even if every check failed safely). */
        @Volatile
        var initialized: Boolean = false
            private set
    }

    override fun onCreate(): Boolean {
        try {
            val envFindings = try {
                ReaEnv.checkAll()
            } catch (e: Exception) {
                emptyList()
            }
            // L101: on-device modder apps (MT Manager etc.). Signals
            // only — refusal is the app's decision at its sensitive
            // entry points (ReaModBlock.allowSensitiveAction).
            val modFindings = try {
                val ctx = context
                if (ctx != null) {
                    ReaModBlock.checkAll(ctx).map {
                        ReaEnv.Finding(
                            "mod-tool-${it.source}", true,
                            "modder app present: ${it.signal}"
                        )
                    }
                } else emptyList()
            } catch (e: Exception) {
                emptyList()
            }
            findings = envFindings + modFindings
            dexCheckPassed = try {
                checkDexHash(context)
            } catch (e: Exception) {
                false
            }
        } catch (e: Exception) {
            // Never let a guard check take the app down.
            if (findings.isEmpty()) findings = emptyList()
            if (dexCheckPassed == null) dexCheckPassed = false
        } finally {
            initialized = true
        }
        // ALWAYS true: the provider observes, it never blocks launch.
        return true
    }

    /**
     * Optional dex/APK hash check. Reads "antirea/dex.sha256" from assets;
     * returns null when the asset is absent, otherwise whether the running
     * APK's sha256 matches it. Never throws.
     */
    private fun checkDexHash(context: Context?): Boolean? {
        if (context == null) return false
        val expected = try {
            context.assets.open("antirea/dex.sha256").bufferedReader().use { it.readLine() }
                ?.trim()?.lowercase()
        } catch (e: Exception) {
            null
        } ?: return null // No asset -> check not run, not a failure.
        if (expected.isEmpty()) return null
        return try {
            val apkPath = context.applicationInfo.sourceDir ?: return false
            val apk = File(apkPath)
            if (!apk.canRead()) return false
            ReaIntegrity.verifyFileSha256(apk, expected)
        } catch (e: Exception) {
            false
        }
    }

    // -- Stubs: this provider serves no data. ---------------------------

    override fun query(
        uri: Uri, projection: Array<String>?, selection: String?,
        selectionArgs: Array<String>?, sortOrder: String?
    ): Cursor? = null

    override fun getType(uri: Uri): String? = null

    override fun insert(uri: Uri, values: ContentValues?): Uri? = null

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<String>?): Int = 0

    override fun update(
        uri: Uri, values: ContentValues?, selection: String?,
        selectionArgs: Array<String>?
    ): Int = 0

    @Suppress("DEPRECATION")
    override fun attachInfo(context: Context?, info: ProviderInfo?) {
        super.attachInfo(context, info)
    }
}

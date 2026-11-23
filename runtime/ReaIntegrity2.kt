package com.antirea.runtime

import java.io.File
import java.io.InputStream
import java.net.URLClassLoader
import java.security.MessageDigest

/**
 * Anti-REA v1.0 — Batch B integrity layers (L23, L25, L27, L28, L29, L54, L56, L57).
 *
 * Pure Kotlin stdlib + JDK only in the top section, no Android imports,
 * so the JVM test (tests/Integrity2Test.kt) can exercise it directly.
 * The Android-only section at the bottom is clearly marked; it needs
 * android.jar to compile and a device to run (never device-tested in
 * v1.0 — same honest limit as the rest of the runtime).
 *
 * REFUSE-ONLY, READ-ONLY, NEVER CRASH: every check returns a result
 * object or false/null on failure, never throws out of a public check
 * function. A failed check means the app refuses ONE sensitive action;
 * nothing is deleted, killed, or written.
 *
 * Honest limits (same as the rest of v1.0): these checks raise the
 * cost of static tampering and make a hook visible at the point of
 * use. A skilled attacker with Frida / a runtime dump can still read
 * values after decryption and can hide from these checks. The server
 * remains the real enforcement.
 */
object ReaIntegrity2 {

    // ------------------------------------------------------------------
    // Shared helpers.
    // ------------------------------------------------------------------

    /** SHA-256 hex (lowercase) of raw bytes. Never throws on valid input. */
    fun sha256Hex(bytes: ByteArray): String {
        return MessageDigest.getInstance("SHA-256").digest(bytes)
            .joinToString("") { "%02x".format(it) }
    }

    /**
     * Constant-time-ish equality for two hex strings: compares the
     * decoded bytes with MessageDigest.isEqual (not a short-circuit
     * string ==, which leaks the mismatch position by timing).
     * Case-insensitive, trims whitespace. False on any malformed hex.
     */
    fun hexEqualsConstantTime(a: String?, b: String?): Boolean {
        if (a.isNullOrBlank() || b.isNullOrBlank()) return false
        return try {
            val ba = hexToBytes(a.trim().lowercase())
            val bb = hexToBytes(b.trim().lowercase())
            if (ba == null || bb == null) return false
            if (ba.size != bb.size) return false
            MessageDigest.isEqual(ba, bb)
        } catch (e: Exception) {
            false
        }
    }

    /** Decode a hex string to bytes, or null when it is not valid hex. */
    fun hexToBytes(hex: String): ByteArray? {
        val clean = hex.trim()
        if (clean.length % 2 != 0) return null
        if (!clean.all { it in '0'..'9' || it in 'a'..'f' || it in 'A'..'F' }) return null
        return try {
            ByteArray(clean.length / 2) { i ->
                clean.substring(i * 2, i * 2 + 2).toInt(16).toByte()
            }
        } catch (e: Exception) {
            null
        }
    }

    // ------------------------------------------------------------------
    // L23 — Installer-origin check (standalone; SIGNAL ONLY).
    // ------------------------------------------------------------------

    /** Where this install came from, as far as the installer record says. */
    enum class InstallerOrigin { PLAY_STORE, THIRD_PARTY, UNKNOWN }

    /**
     * Result of the installer-origin check. This is a SIGNAL ONLY:
     * it must NEVER refuse an action on its own — legitimate users
     * sideload, stores vary by country, and the installer record can
     * be absent (null) on a perfectly legitimate install. L103
     * (ReaRepack.classifyInstaller) already records the same signal;
     * this is the standalone check so callers that do not use the
     * full repack gate can still log it for server-side scoring.
     */
    data class InstallerSignal(
        val origin: InstallerOrigin,
        val installerPackage: String?,
        val isPlayStore: Boolean,
        /** Always true: this value is advisory, never a refusal. */
        val signalOnly: Boolean = true
    )

    /**
     * Pure function: (packageName, installerPackageName) -> signal.
     * Only "com.android.vending" is PLAY_STORE. Any other non-blank
     * installer is THIRD_PARTY (sideload / another store). Null or
     * blank is UNKNOWN. [packageName] is accepted for call-site
     * symmetry with the Android wrapper and is not itself checked
     * here (package-name matching is L103's job).
     */
    @Suppress("UNUSED_PARAMETER")
    fun checkInstallerOrigin(packageName: String?, installerPackageName: String?): InstallerSignal {
        // packageName is intentionally unused: this layer classifies
        // the INSTALLER only.
        if (installerPackageName.isNullOrBlank()) {
            return InstallerSignal(InstallerOrigin.UNKNOWN, null, false)
        }
        val installer = installerPackageName.trim()
        return if (installer == "com.android.vending") {
            InstallerSignal(InstallerOrigin.PLAY_STORE, installer, true)
        } else {
            InstallerSignal(InstallerOrigin.THIRD_PARTY, installer, false)
        }
    }

    // ------------------------------------------------------------------
    // L25 — Runtime self-hash (own class bytecode).
    // ------------------------------------------------------------------

    /** Result of a self-hash check. */
    data class SelfHashResult(val passed: Boolean, val actualHex: String?)

    /**
     * SHA-256 hex of a class's own bytecode bytes, read from [stream].
     * Returns null (never throws) when the stream is null or unreadable.
     * Callers pass e.g. `MyClass::class.java.getResourceAsStream(...)`.
     */
    fun hashClassBytes(stream: InputStream?): String? {
        if (stream == null) return null
        return try {
            stream.use {
                val digest = MessageDigest.getInstance("SHA-256")
                val buf = ByteArray(8192)
                var n: Int
                while (it.read(buf).also { r -> n = r } != -1) {
                    digest.update(buf, 0, n)
                }
                digest.digest().joinToString("") { b -> "%02x".format(b) }
            }
        } catch (e: Exception) {
            null
        }
    }

    /** SHA-256 hex of the bytecode of [clazz] itself, or null if unreadable. */
    fun hashOwnClassBytes(clazz: Class<*>): String? {
        val name = "/" + clazz.name.replace('.', '/') + ".class"
        return hashClassBytes(clazz.getResourceAsStream(name))
    }

    /**
     * Compare a class's bytecode hash against a pinned expected hex.
     * [actualHex] is null when the bytes could not be read (fail =
     * refuse, never crash). Hex-to-hex compare only — never hash a
     * hash: the expected value is already a SHA-256 hex.
     */
    fun verifySelfHash(stream: InputStream?, expectedHex: String): SelfHashResult {
        return try {
            val actual = hashClassBytes(stream) ?: return SelfHashResult(false, null)
            SelfHashResult(hexEqualsConstantTime(actual, expectedHex), actual)
        } catch (e: Exception) {
            SelfHashResult(false, null)
        }
    }

    /** Same as [verifySelfHash] but reads [clazz]'s own bytecode. */
    fun verifyOwnClassHash(clazz: Class<*>, expectedHex: String): SelfHashResult {
        val name = "/" + clazz.name.replace('.', '/') + ".class"
        return verifySelfHash(clazz.getResourceAsStream(name), expectedHex)
    }

    // ------------------------------------------------------------------
    // L27 — Config hash pinning (REA-IR / manifest bytes).
    // ------------------------------------------------------------------

    /** Result of a config-hash pin. */
    data class ConfigHashResult(val passed: Boolean, val actualHex: String?)

    /**
     * Compare SHA-256([configBytes]) against a pinned hex value.
     * Hex-to-hex compare only (constant-time-ish via
     * [hexEqualsConstantTime]); the pinned value is NEVER hashed
     * again — hashing a hash could never match and would silently
     * break the check. False (never throws) on null input, empty
     * input, bad hex, or mismatch.
     */
    fun verifyConfigHash(configBytes: ByteArray?, pinnedHex: String): ConfigHashResult {
        if (configBytes == null || configBytes.isEmpty()) return ConfigHashResult(false, null)
        if (pinnedHex.isBlank()) return ConfigHashResult(false, null)
        return try {
            val actual = sha256Hex(configBytes)
            ConfigHashResult(hexEqualsConstantTime(actual, pinnedHex), actual)
        } catch (e: Exception) {
            ConfigHashResult(false, null)
        }
    }

    /** Read a config file and pin-check it; false on any read error. */
    fun verifyConfigFileHash(file: File, pinnedHex: String): ConfigHashResult {
        return try {
            if (!file.canRead()) return ConfigHashResult(false, null)
            verifyConfigHash(file.readBytes(), pinnedHex)
        } catch (e: Exception) {
            ConfigHashResult(false, null)
        }
    }

    // ------------------------------------------------------------------
    // L28 — Resource hash check.
    // ------------------------------------------------------------------

    /** Result of a multi-entry hash check (shared by L28 and L29). */
    data class HashCheckResult(
        val passed: Boolean,
        val failedEntries: List<String>,
        val missingEntries: List<String>,
        val checkedCount: Int
    )

    /**
     * Hash every entry in [entries] (resource entry name -> bytes)
     * and compare each against [expectedHashes] (name -> SHA-256 hex).
     * An entry whose bytes hash differently is FAILED; an expected
     * entry with no supplied bytes is MISSING; an entry with no
     * expected hash is ignored (callers must not treat "unchecked"
     * as "checked"). Never throws; empty inputs fail (nothing
     * checked is not a pass).
     */
    fun verifyResourceHashes(
        entries: Map<String, ByteArray>,
        expectedHashes: Map<String, String>
    ): HashCheckResult {
        return try {
            if (expectedHashes.isEmpty()) {
                return HashCheckResult(false, emptyList(), emptyList(), 0)
            }
            val failed = mutableListOf<String>()
            val missing = mutableListOf<String>()
            var checked = 0
            for ((name, expectedHex) in expectedHashes) {
                val bytes = entries[name]
                if (bytes == null) {
                    missing.add(name)
                    continue
                }
                checked++
                if (!hexEqualsConstantTime(sha256Hex(bytes), expectedHex)) failed.add(name)
            }
            HashCheckResult(failed.isEmpty() && missing.isEmpty(), failed, missing, checked)
        } catch (e: Exception) {
            HashCheckResult(false, emptyList(), emptyList(), 0)
        }
    }

    // ------------------------------------------------------------------
    // L29 — Native lib hash check.
    // ------------------------------------------------------------------

    /**
     * Hash every native library in [libs] (.so name -> bytes) against
     * [expectedHashes] (name -> SHA-256 hex). Same result shape as
     * L28. An entry whose name does not end in ".so" is FAILED (it
     * is not a native library — a renamed or swapped file must not
     * slip through as "checked"). Never throws.
     */
    fun verifyNativeLibHashes(
        libs: Map<String, ByteArray>,
        expectedHashes: Map<String, String>
    ): HashCheckResult {
        return try {
            if (expectedHashes.isEmpty()) {
                return HashCheckResult(false, emptyList(), emptyList(), 0)
            }
            val failed = mutableListOf<String>()
            val missing = mutableListOf<String>()
            var checked = 0
            for ((name, expectedHex) in expectedHashes) {
                val bytes = libs[name]
                if (bytes == null) {
                    missing.add(name)
                    continue
                }
                if (!name.endsWith(".so")) {
                    failed.add(name)
                    continue
                }
                checked++
                if (!hexEqualsConstantTime(sha256Hex(bytes), expectedHex)) failed.add(name)
            }
            HashCheckResult(failed.isEmpty() && missing.isEmpty(), failed, missing, checked)
        } catch (e: Exception) {
            HashCheckResult(false, emptyList(), emptyList(), 0)
        }
    }

    // ------------------------------------------------------------------
    // L54 — Anti-hook re-check inside the decrypt path.
    // ------------------------------------------------------------------

    /**
     * Run [envCheck] (supplied by the caller — typically
     * ReaEnv.checkAll() reduced to "any finding?") BEFORE running
     * [decrypt]. When the env check fires (returns true = threat
     * detected), return null and NEVER call [decrypt] — the plaintext
     * must not even be produced while a hook/debugger is suspected.
     * When the env check is clean, return decrypt()'s value.
     * Either supplier throwing is treated as a refusal (null), never
     * a crash and never a decrypt.
     */
    fun <T> decryptWithEnvCheck(envCheck: () -> Boolean, decrypt: () -> T): T? {
        return try {
            if (envCheck()) return null
            try {
                decrypt()
            } catch (e: Exception) {
                null
            }
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Same gate, but with the standard ReaRuntime blob decrypt wired
     * in: env check first, then ReaRuntime.decrypt(blob, part1,
     * part2). Returns null on env fire, on decrypt refusal, or on
     * any error — never a wrong plaintext.
     */
    fun decryptBlobWithEnvCheck(
        envCheck: () -> Boolean,
        blobBase64: String,
        keyPart1B64: String,
        keyPart2B64: String
    ): String? {
        return decryptWithEnvCheck(envCheck) {
            ReaRuntime.decrypt(blobBase64, keyPart1B64, keyPart2B64)
        }
    }

    // ------------------------------------------------------------------
    // L56 — Reflection-based access (no direct reference at call site).
    // ------------------------------------------------------------------

    /**
     * Invoke a named method on [target] via reflection — the call
     * site holds no direct reference to the method, so a static
     * scan of the call site does not reveal the target method name
     * as a direct call (the NAME string itself is still visible;
     * this is obfuscation, not invisibility — same honest limit as
     * the rest of v1.0). Matches by name + argument count, then by
     * assignable parameter types where possible. Returns null (never
     * throws) when no matching method exists or invocation fails.
     */
    fun invokeReflectively(target: Any, methodName: String, vararg args: Any?): Any? {
        return try {
            val candidates = target.javaClass.methods
                .filter { it.name == methodName && it.parameterCount == args.size } +
                target.javaClass.declaredMethods
                    .filter { it.name == methodName && it.parameterCount == args.size }
            val method = candidates.firstOrNull { m ->
                val params = m.parameterTypes
                params.indices.all { i ->
                    args[i] == null || params[i].isInstance(args[i]) ||
                        params[i].isPrimitive // primitives: trust count match
                }
            } ?: candidates.firstOrNull() ?: return null
            try {
                method.isAccessible = true
            } catch (e: Exception) {
                // isAccessible may fail under a strict SecurityManager;
                // public methods still invoke fine without it.
            }
            method.invoke(target, *args)
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Reflection first, direct fallback second: try
     * [invokeReflectively]; when it returns null AND [direct]
     * supplies a value, return the direct call's value. When
     * [direct] is null there is no fallback — null means "could not
     * call". The [direct] lambda is only evaluated when reflection
     * failed, so the direct reference exists only as a fallback path.
     */
    fun <T> callByReflectionOrDirect(
        target: Any,
        methodName: String,
        args: Array<out Any?> = emptyArray(),
        direct: (() -> T?)? = null
    ): T? {
        @Suppress("UNCHECKED_CAST")
        val reflected = invokeReflectively(target, methodName, *args) as T?
        if (reflected != null) return reflected
        return try {
            direct?.invoke()
        } catch (e: Exception) {
            null
        }
    }

    // ------------------------------------------------------------------
    // L57 — Dynamic class loading.
    // ------------------------------------------------------------------

    /**
     * Load a class from a jar file on the JVM (test path): a
     * URLClassLoader over [jarPath], parented on this class's loader.
     * Returns the Class, or null (never throws) on any error.
     * The loader is NOT closed here — the caller keeps the returned
     * Class alive; closing the loader would unload it.
     */
    fun loadClassFromJar(jarPath: String, className: String): Class<*>? {
        return try {
            val file = File(jarPath)
            if (!file.canRead()) return null
            val loader = URLClassLoader(arrayOf(file.toURI().toURL()), this.javaClass.classLoader)
            Class.forName(className, true, loader)
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Load a class from a jar held in memory ([jarBytes] written to
     * a caller-owned temp file is out of scope — this overload takes
     * a jar FILE; for byte arrays use [loadClassFromJarBytes]).
     * Kept as a thin alias so call sites read the same either way.
     */
    fun loadClassFromJarFile(jarFile: File, className: String): Class<*>? {
        return loadClassFromJar(jarFile.absolutePath, className)
    }

    /**
     * Load a class from jar bytes: writes them to a temp file under
     * [tempDir] (caller-owned, caller deletes), then delegates to
     * [loadClassFromJar]. Returns null (never throws) on any error.
     * On Android this maps to DexClassLoader — see the Android-only
     * section below; the JVM path is the testable equivalent.
     */
    fun loadClassFromJarBytes(jarBytes: ByteArray, className: String, tempDir: File): Class<*>? {
        return try {
            if (!tempDir.isDirectory) return null
            val tmp = File.createTempFile("rea-dyn-", ".jar", tempDir)
            tmp.writeBytes(jarBytes)
            loadClassFromJar(tmp.absolutePath, className)
        } catch (e: Exception) {
            null
        }
    }

    // ------------------------------------------------------------------
    // Android-only section — needs android.jar (and dalvik for L57).
    // Everything above works on the plain JVM; everything below does
    // not, and is NOT exercised by the JVM test.
    // ------------------------------------------------------------------

    /**
     * Android-only: installer-origin signal for the running app, via
     * PackageManager (getInstallSourceInfo on API 30+, the deprecated
     * getInstallerPackageName below that). Pure classification is
     * done by [checkInstallerOrigin]; this only reads the values.
     * Returns an UNKNOWN signal — never throws — when unreadable.
     */
    fun getInstallerOrigin(context: android.content.Context): InstallerSignal {
        return try {
            val pm = context.packageManager
            val pkg = context.packageName
            val installer: String? = if (android.os.Build.VERSION.SDK_INT >= 30) {
                pm.getInstallSourceInfo(pkg).installingPackageName
            } else {
                @Suppress("DEPRECATION")
                pm.getInstallerPackageName(pkg)
            }
            checkInstallerOrigin(pkg, installer)
        } catch (e: Exception) {
            InstallerSignal(InstallerOrigin.UNKNOWN, null, false)
        }
    }

    /**
     * Android-only (L57 device path): load a class from a dex/jar
     * file with DexClassLoader, parented on the app's class loader.
     * On Android the dynamic code ships as a dex file (usually
     * inside assets/, copied to the app's private dir first — never
     * loaded straight from the APK). NOT tested on JVM or device in
     * v1.0: the JVM test covers the equivalent [loadClassFromJar]
     * path, and the DexClassLoader call itself is a one-line mapping
     * documented here. Returns null (never throws) on any error.
     */
    fun loadClassFromDex(
        dexPath: String,
        optimizedDir: String,
        className: String,
        parent: ClassLoader
    ): Class<*>? {
        return try {
            val loader = dalvik.system.DexClassLoader(dexPath, optimizedDir, null, parent)
            Class.forName(className, true, loader)
        } catch (e: Exception) {
            null
        }
    }
}

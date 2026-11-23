package com.antirea.runtime

import android.content.Context
import dalvik.system.DexClassLoader
import java.io.File
import java.lang.reflect.Modifier
import java.util.UUID

/**
 * Anti-REA v1.0 — L60 Android loader for self-changing code.
 *
 * EXPERIMENTAL. ON BY DEFAULT per the user's explicit order
 * (2026-11-23: "Default is on man") — set
 * `experimental.self_changing_code: false` in the config to turn it
 * off. The danger warning still applies in full: read
 * docs/L60-SELF-CHANGING-CODE.md before using this on any real app.
 * The user takes the usage decision; this file is only the mechanism.
 *
 * COMPILE-VERIFIED ONLY. This file CANNOT be JVM-tested here: it
 * needs dalvik.system.DexClassLoader and an Android Context, neither
 * of which exists on a plain JVM. It has NEVER been device-tested.
 * Do not claim it works on a phone until a real device run proves
 * it — that proof is the caller's job, on a non-critical path first.
 *
 * What it does, in plain words
 * -----------------------------
 * 1. Decrypt a sealed dex payload ([ReaMethodDecrypt.SealedMethod])
 *    in memory only — a tampered blob or a wrong key refuses
 *    (null) and nothing is loaded.
 * 2. Write the plaintext dex bytes to ONE file in the app's
 *    PRIVATE storage (filesDir/rea-methods/, a fresh random name
 *    per load, never a fixed name, never external storage).
 * 3. Load the class with a fresh DexClassLoader, parented on the
 *    app's class loader, with the optimised dex in codeCacheDir.
 * 4. Invoke the requested method ([loadAndInvoke]).
 * 5. Delete the plaintext dex file IMMEDIATELY after load, in a
 *    finally block, on every path (success or failure), and wipe
 *    the plaintext byte array in memory. The loaded class stays
 *    usable because ART keeps the optimised code in codeCacheDir;
 *    the plaintext source file is gone.
 *
 * What it does NOT do (honest limits)
 * ------------------------------------
 * - It does NOT sandbox the loaded code. A loaded class runs with
 *   the app's FULL permissions. Only ever load a blob your own
 *   build sealed (tools/make_method_blob.py) — never a blob from
 *   the network, a download, or any untrusted source. Loading an
 *   attacker's dex is remote code execution by another name.
 * - It does NOT unload the code after it runs. Once loaded, the
 *   class stays in memory in plain form until the process dies —
 *   the same limit stated in ReaMethodDecrypt.kt. Deleting the
 *   plaintext FILE does not erase the loaded CLASS.
 * - It does NOT make a crash impossible. A bad dex, a missing
 *   class, or a method that throws all refuse here (null), but a
 *   method that runs and misbehaves is the caller's problem — that
 *   is why this is for non-critical paths only, after device proof.
 * - Play Protect / antivirus engines may flag apps that load code
 *   at runtime. That is a real risk, not a rumour — see the doc.
 *
 * Fail-closed contract: every public function returns null on any
 * error and NEVER throws into app code. A failed load means the
 * app refuses ONE sensitive action; nothing is deleted (except the
 * plaintext dex file this loader itself wrote), killed, or written
 * anywhere else.
 *
 * Kotlin stdlib + Android APIs only (Context, DexClassLoader).
 * Needs android.jar to compile; needs a real device to run.
 */
object ReaMethodLoader {

    /** Subdirectory of filesDir holding plaintext dex files, briefly. */
    private const val PLAINTEXT_DIR = "rea-methods"

    /** Subdirectory fallback for the optimised dex, if codeCacheDir is unavailable. */
    private const val OPT_DIR = "rea-opt"

    /**
     * Load [className] from a sealed dex payload. Returns the Class,
     * or null (never throws) on any failure: tampered blob, wrong
     * key, unreadable payload, missing class, or any I/O error.
     * The plaintext dex file is deleted before this returns, on
     * every path. The caller keeps the returned Class alive; the
     * loader is intentionally not closed (closing it would unload
     * the class) — the same rule as L57's loadClassFromDex.
     */
    fun loadClass(
        context: Context,
        sealed: ReaMethodDecrypt.SealedMethod,
        className: String
    ): Class<*>? {
        if (className.isBlank()) return null
        val plain = ReaMethodDecrypt.open(sealed) ?: return null
        val dexFile = writePlaintextDex(context, plain) ?: run {
            plain.fill(0)
            return null
        }
        return try {
            val optDir = optimizedDir(context) ?: run {
                deleteQuietly(dexFile)
                plain.fill(0)
                return null
            }
            val loader = DexClassLoader(
                dexFile.absolutePath,
                optDir.absolutePath,
                null,
                context.classLoader
            )
            Class.forName(className, true, loader)
        } catch (e: Exception) {
            null
        } finally {
            deleteQuietly(dexFile)
            plain.fill(0)
        }
    }

    /**
     * Load [className] from a sealed dex payload and invoke
     * [methodName] on it, in one fail-closed call. Static methods
     * are invoked without an instance; instance methods are
     * invoked on a fresh no-arg-constructed instance. Returns the
     * method's return value (null when the method itself returns
     * null), or null (never throws) when the load fails, the method
     * does not exist, no usable constructor exists, or the method
     * throws. A null return is ambiguous by design — callers that
     * need to distinguish "method returned null" from "load
     * failed" must call [loadClass] and invoke the method
     * themselves. The plaintext dex file is deleted before this
     * returns, on every path.
     */
    fun loadAndInvoke(
        context: Context,
        sealed: ReaMethodDecrypt.SealedMethod,
        className: String,
        methodName: String,
        vararg args: Any?
    ): Any? {
        if (className.isBlank() || methodName.isBlank()) return null
        val clazz = loadClass(context, sealed, className) ?: return null
        return try {
            val candidates = (clazz.methods + clazz.declaredMethods)
                .filter { it.name == methodName && it.parameterCount == args.size }
            val method = candidates.firstOrNull { m ->
                val params = m.parameterTypes
                params.indices.all { i ->
                    args[i] == null || params[i].isInstance(args[i]) ||
                        params[i].isPrimitive
                }
            } ?: candidates.firstOrNull() ?: return null
            try {
                method.isAccessible = true
            } catch (e: Exception) {
                // Public methods still invoke fine without it.
            }
            if (Modifier.isStatic(method.modifiers)) {
                method.invoke(null, *args)
            } else {
                val instance = try {
                    clazz.getDeclaredConstructor().newInstance()
                } catch (e: Exception) {
                    return null
                }
                method.invoke(instance, *args)
            }
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Rotate a sealed payload under a fresh key — the self-changing
     * step, delegated to [ReaMethodDecrypt.rotate]. Returns the new
     * sealed triple, or null when the old blob is tampered or a key
     * is bad. The caller must persist the returned triple and drop
     * the old one; this function writes nothing to disk itself.
     */
    fun rotateStored(
        sealed: ReaMethodDecrypt.SealedMethod,
        newKey: ByteArray
    ): ReaMethodDecrypt.SealedMethod? {
        return ReaMethodDecrypt.rotate(sealed, newKey)
    }

    // ------------------------------------------------------------------
    // Private helpers — all fail-closed, none throws.
    // ------------------------------------------------------------------

    /**
     * Write [plain] dex bytes to a fresh random-named file under
     * filesDir/rea-methods/. Returns the file, or null on any
     * error. The name is random per load so a stale plaintext file
     * from a crashed earlier load can never be picked up by name.
     */
    private fun writePlaintextDex(context: Context, plain: ByteArray): File? {
        return try {
            val dir = File(context.filesDir, PLAINTEXT_DIR)
            if (!dir.isDirectory && !dir.mkdirs()) return null
            val file = File(dir, "rea-method-" + UUID.randomUUID() + ".dex")
            file.writeBytes(plain)
            if (!file.canRead()) {
                deleteQuietly(file)
                return null
            }
            file
        } catch (e: Exception) {
            null
        }
    }

    /** Optimised-dex directory: codeCacheDir, falling back to filesDir/rea-opt. */
    private fun optimizedDir(context: Context): File? {
        return try {
            val dir = context.codeCacheDir
                ?: File(context.filesDir, OPT_DIR)
            if (!dir.isDirectory && !dir.mkdirs()) return null
            dir
        } catch (e: Exception) {
            null
        }
    }

    /** Best-effort delete; never throws, never reports. */
    private fun deleteQuietly(file: File?) {
        try {
            file?.delete()
        } catch (e: Exception) {
            // Deleting a plaintext file must never crash the app.
        }
    }
}

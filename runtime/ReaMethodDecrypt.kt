package com.appcore.runtime

import java.security.MessageDigest
import java.security.SecureRandom
import java.util.Base64

/**
 * Anti-REA v1.0 — L60 runtime code mutation / self-changing code.
 *
 * EXPERIMENTAL. ON BY DEFAULT per the user's explicit order
 * (2026-11-23: "Default is on man") — set
 * `experimental.self_changing_code: false` in the config to turn it
 * off (see transformer/config.py :: self_changing_code_enabled).
 * The danger warning still applies in full: read
 * docs/L60-SELF-CHANGING-CODE.md before using this on any real app.
 * The user takes the usage decision; this file is only the mechanism.
 *
 * What this is, in plain words
 * -----------------------------
 * A method's code (a dex payload) is stored scrambled, not readable
 * in the APK. At runtime the app unscrambles it, loads it, and runs
 * it. The stored form CHANGES between runs: [rotate] re-encrypts the
 * same payload under a fresh key, so the bytes on disk are different
 * every time the payload is rotated. That changing stored form is
 * the "self-changing" part.
 *
 * What this is NOT (the honest limits, not secrets)
 * -------------------------------------------------
 * - It does NOT patch running code in memory. Kotlin/Java cannot
 *   rewrite a loaded method's bytes, and Android's runtime (ART)
 *   does not keep methods in a fixed, documented layout. Any
 *   design that claimed to patch live code was rejected — see the
 *   old docs/L60-WHY-NOT-SHIPPED.md, whose warnings are carried
 *   over into docs/L60-SELF-CHANGING-CODE.md.
 * - Once code is loaded it STAYS loaded. Decrypted code remains in
 *   RAM in plain form until the process dies. Re-encryption only
 *   changes the STORED form (the bytes on disk / in the blob). A
 *   memory dump after load still reads the code. This is a limit,
 *   not a secret, and no API here pretends otherwise.
 * - It does NOT unload or re-scramble code after it runs. There is
 *   no "re-encrypt after run" step, because the loaded class cannot
 *   be unloaded while it is in use. The rotation happens between
 *   runs (or between loads), never on live code.
 * - It is adjacent to, not a copy of, L57 (dynamic class loading):
 *   L57 loads code; L60 adds the sealed blob + rotation of the
 *   stored form. L57 without rotation is not L60, and L60 without
 *   a loader is only a sealed blob.
 *
 * Blob format (EXACT — the same REA-IR pattern as ReaRuntime)
 * ------------------------------------------------------------
 *   raw        = sha256(payload) || payload        (32-byte hash prefix)
 *   key        = 32 random bytes (fresh per seal / per rotation)
 *   part1      = 32 random bytes
 *   part2      = key XOR part1     (neither part alone is the key)
 *   ciphertext = raw XOR key (repeating)
 *   blob       = base64(ciphertext)
 * The full key is NEVER stored anywhere: only part1/part2 appear,
 * in separate fields of [SealedMethod] / the JSON the tool writes.
 * tools/make_method_blob.py produces exactly this format.
 *
 * Fail-closed contract (the whole point of this file)
 * ---------------------------------------------------
 * Every public function returns null / false on any failure and
 * NEVER throws into app code: bad key length, empty payload,
 * malformed base64, a flipped byte, a wrong key — all refuse with
 * null, never a wrong plaintext. A tampered blob must refuse, not
 * run something half-decrypted.
 *
 * Honest limit (same as the rest of v1.0): XOR + split keys is
 * obfuscation with integrity checking, NOT strong cryptography. A
 * skilled attacker who finds both key parts can reconstruct the
 * key, and Frida / a debugger / a runtime memory dump can read the
 * code after it is loaded. The server-side checks remain the real
 * enforcement. Never put login or payment code behind this.
 *
 * Kotlin stdlib + JDK only, no Android imports, so the JVM test
 * (runtime/tests/MethodDecryptTest.kt) exercises this file directly.
 */
object ReaMethodDecrypt {

    /** Length of every key and key part, in bytes. */
    const val KEY_LEN = 32

    /** Blob format tag, matching tools/make_method_blob.py. */
    const val FORMAT = "anti-rea-method-blob-v1"

    /**
     * One sealed method payload. [blobBase64] is the encrypted
     * payload; [keyPart1B64] / [keyPart2B64] are the split key
     * (neither part alone decrypts anything); [blobSha256Hex] is
     * sha256 of the decoded blob bytes; [plainSha256Hex] is sha256
     * of the plaintext payload. All hashes are lowercase hex.
     */
    data class SealedMethod(
        val blobBase64: String,
        val keyPart1B64: String,
        val keyPart2B64: String,
        val blobSha256Hex: String,
        val plainSha256Hex: String
    )

    /** Fresh random 32-byte key. Never throws. */
    fun generateKey(): ByteArray {
        return ByteArray(KEY_LEN).also { SecureRandom().nextBytes(it) }
    }

    /** SHA-256 hex (lowercase) of raw bytes. Never throws. */
    fun sha256Hex(bytes: ByteArray): String {
        return try {
            MessageDigest.getInstance("SHA-256").digest(bytes)
                .joinToString("") { "%02x".format(it) }
        } catch (e: Exception) {
            ""
        }
    }

    /**
     * Reconstruct the full key from its two split parts. Returns
     * null (never throws) when either part is malformed base64 or
     * the parts have different lengths.
     */
    fun reconstructKey(keyPart1B64: String, keyPart2B64: String): ByteArray? {
        return try {
            val p1 = Base64.getDecoder().decode(keyPart1B64)
            val p2 = Base64.getDecoder().decode(keyPart2B64)
            if (p1.size != p2.size || p1.isEmpty()) return null
            ByteArray(p1.size) { i -> (p1[i].toInt() xor p2[i].toInt()).toByte() }
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Seal [payload] under [key]. Returns null (never throws) when
     * the payload is empty or the key is not exactly [KEY_LEN]
     * bytes. Every call re-randomises the split parts, so two seals
     * of the same payload under the same key still produce a
     * different stored triple (different part1/part2) — only the
     * blob bytes themselves are identical when the key is identical.
     */
    fun seal(payload: ByteArray, key: ByteArray): SealedMethod? {
        return try {
            if (payload.isEmpty() || key.size != KEY_LEN) return null
            val part1 = generateKey()
            val part2 = ByteArray(KEY_LEN) { i ->
                (key[i].toInt() xor part1[i].toInt()).toByte()
            }
            val raw = MessageDigest.getInstance("SHA-256").digest(payload) + payload
            val cipher = ByteArray(raw.size) { i ->
                (raw[i].toInt() xor key[i % KEY_LEN].toInt()).toByte()
            }
            SealedMethod(
                blobBase64 = Base64.getEncoder().encodeToString(cipher),
                keyPart1B64 = Base64.getEncoder().encodeToString(part1),
                keyPart2B64 = Base64.getEncoder().encodeToString(part2),
                blobSha256Hex = sha256Hex(cipher),
                plainSha256Hex = sha256Hex(payload)
            )
        } catch (e: Exception) {
            null
        }
    }

    /** Decrypt [cipher] with [key]; null on any failure, never a wrong value. */
    private fun openCipher(cipher: ByteArray, key: ByteArray): ByteArray? {
        return try {
            if (key.size != KEY_LEN) return null
            val raw = ByteArray(cipher.size) { i ->
                (cipher[i].toInt() xor key[i % KEY_LEN].toInt()).toByte()
            }
            if (raw.size <= 32) return null
            val expectedHash = raw.copyOfRange(0, 32)
            val plain = raw.copyOfRange(32, raw.size)
            val actualHash = MessageDigest.getInstance("SHA-256").digest(plain)
            if (!expectedHash.contentEquals(actualHash)) return null
            plain
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Open a blob with a full key. Returns the plaintext payload
     * bytes, or null (never throws) on tamper, wrong key, or
     * malformed input. Never returns a wrong value.
     */
    fun open(blobBase64: String, key: ByteArray): ByteArray? {
        return try {
            val cipher = Base64.getDecoder().decode(blobBase64)
            openCipher(cipher, key)
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Open a blob with split key parts (the REA-IR form, as
     * produced by [seal] and tools/make_method_blob.py). Returns
     * the plaintext payload bytes, or null (never throws) on
     * tamper, wrong parts, or malformed input.
     */
    fun open(blobBase64: String, keyPart1B64: String, keyPart2B64: String): ByteArray? {
        val key = reconstructKey(keyPart1B64, keyPart2B64) ?: return null
        return open(blobBase64, key)
    }

    /**
     * Open a [SealedMethod]. Null (never throws) on any failure.
     * Verifies the stored hashes, not just the embedded hash
     * prefix: the blob must match its recorded [SealedMethod.blobSha256Hex]
     * and the decrypted payload must match its recorded
     * [SealedMethod.plainSha256Hex] — a blob whose stored hashes
     * were swapped or forged refuses even if its embedded prefix
     * somehow still checks out. Every legitimate producer
     * (seal(), tools/make_method_blob.py, transformer/crypto.py)
     * fills both hashes, so a blank or mismatched hash is a
     * refusal, never a pass.
     */
    fun open(sealed: SealedMethod): ByteArray? {
        return try {
            if (!verifyBlob(sealed.blobBase64, sealed.blobSha256Hex)) return null
            val plain = open(sealed.blobBase64, sealed.keyPart1B64, sealed.keyPart2B64)
                ?: return null
            if (sealed.plainSha256Hex.isBlank() ||
                sha256Hex(plain) != sealed.plainSha256Hex.lowercase()
            ) return null
            plain
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Rotate a sealed payload under a fresh [newKey]: decrypt with
     * the old key, re-seal under the new one. This is the
     * self-changing step — the returned blob's stored bytes differ
     * from the old blob's (a different key encrypts the same
     * payload to different ciphertext), and the split parts are
     * freshly random. Returns null (never throws) when the old blob
     * is tampered (a tampered blob is NEVER re-sealed — rotating it
     * would launder the tamper), when the old key is wrong, or when
     * the new key is not exactly [KEY_LEN] bytes. The old
     * [SealedMethod] is untouched; callers must persist the
     * returned triple and drop the old one.
     */
    fun rotate(blobBase64: String, oldKey: ByteArray, newKey: ByteArray): SealedMethod? {
        return try {
            if (newKey.size != KEY_LEN) return null
            val plain = open(blobBase64, oldKey) ?: return null
            try {
                seal(plain, newKey)
            } finally {
                // The plaintext must not linger in memory after rotation.
                plain.fill(0)
            }
        } catch (e: Exception) {
            null
        }
    }

    /** Rotate a [SealedMethod] under a fresh [newKey]. See [rotate]. */
    fun rotate(sealed: SealedMethod, newKey: ByteArray): SealedMethod? {
        return try {
            if (newKey.size != KEY_LEN) return null
            val plain = open(sealed) ?: return null
            try {
                seal(plain, newKey)
            } finally {
                plain.fill(0)
            }
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Blob-level integrity: true only when sha256(decoded blob
     * bytes) equals [expectedSha256Hex]. False (never throws) on
     * any mismatch or malformed input, so callers can refuse before
     * decrypting.
     */
    fun verifyBlob(blobBase64: String, expectedSha256Hex: String): Boolean {
        return try {
            if (expectedSha256Hex.isBlank()) return false
            val cipher = Base64.getDecoder().decode(blobBase64)
            sha256Hex(cipher) == expectedSha256Hex.lowercase()
        } catch (e: Exception) {
            false
        }
    }
}

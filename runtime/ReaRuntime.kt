package com.antirea.runtime

import java.security.MessageDigest
import java.util.Base64

/**
 * Anti-REA v1.0 runtime — port of the v0.1 ReaRuntime (package changed
 * to com.antirea.runtime; blob format UNCHANGED).
 *
 * Kotlin stdlib + JDK only, no Android imports, so JVM tests can use it
 * directly. Decrypts payloads produced by the v1.0 CLI transformer.
 *
 * Blob format (EXACT, must match the transformer):
 *   raw = sha256(plaintext_utf8) || plaintext_utf8, XORed with a 32-byte key.
 *   key = keyPart1 XOR keyPart2 (neither part alone is the key; the full
 *   key is never stored anywhere).
 *   blob = base64(ciphertext)
 *
 * Decryption happens in memory only; the plaintext is never written to
 * disk or logged. If any integrity check fails, decrypt() throws
 * IllegalStateException and the caller must refuse to use the component —
 * it never returns a wrong value silently.
 *
 * Honest limit: XOR + split keys is obfuscation with integrity checking,
 * NOT strong cryptography. A skilled attacker who finds both key parts
 * can reconstruct the key, and Frida / a debugger / a runtime memory
 * dump can read values after decryption. The server-side checks remain
 * the real enforcement.
 */
object ReaRuntime {

    /** Reconstruct the full key from its two split parts. */
    fun reconstructKey(keyPart1B64: String, keyPart2B64: String): ByteArray {
        val p1 = Base64.getDecoder().decode(keyPart1B64)
        val p2 = Base64.getDecoder().decode(keyPart2B64)
        require(p1.size == p2.size) { "Anti-REA: key parts have different lengths" }
        return ByteArray(p1.size) { i -> (p1[i].toInt() xor p2[i].toInt()).toByte() }
    }

    /**
     * Decrypt a blob. Throws IllegalStateException when the blob is
     * tampered with (embedded plaintext hash mismatch) or malformed.
     * Never returns a wrong plaintext.
     */
    fun decrypt(blobBase64: String, keyPart1B64: String, keyPart2B64: String): String {
        val cipher = try {
            Base64.getDecoder().decode(blobBase64)
        } catch (e: IllegalArgumentException) {
            throw IllegalStateException("Anti-REA: blob is not valid base64", e)
        }
        val key = reconstructKey(keyPart1B64, keyPart2B64)
        val raw = ByteArray(cipher.size) { i ->
            (cipher[i].toInt() xor key[i % key.size].toInt()).toByte()
        }
        if (raw.size <= 32) {
            throw IllegalStateException("Anti-REA: payload too short")
        }
        val expectedHash = raw.copyOfRange(0, 32)
        val plainBytes = raw.copyOfRange(32, raw.size)
        val actualHash = MessageDigest.getInstance("SHA-256").digest(plainBytes)
        if (!expectedHash.contentEquals(actualHash)) {
            throw IllegalStateException("Anti-REA: payload integrity check failed")
        }
        return String(plainBytes, Charsets.UTF_8)
    }

    /**
     * Blob-level integrity: true only when sha256(decoded blob bytes)
     * equals [expectedSha256Hex]. False (never throws) on any mismatch
     * or malformed input, so callers can refuse before decrypting.
     */
    fun verifyIntegrity(blobBase64: String, expectedSha256Hex: String): Boolean {
        return try {
            val cipher = Base64.getDecoder().decode(blobBase64)
            val actual = MessageDigest.getInstance("SHA-256").digest(cipher)
                .joinToString("") { "%02x".format(it) }
            actual == expectedSha256Hex.lowercase()
        } catch (e: Exception) {
            false
        }
    }

    /** Plaintext-level integrity: true only when sha256(text) matches. */
    fun verifyText(text: String, expectedSha256Hex: String): Boolean {
        return try {
            val actual = MessageDigest.getInstance("SHA-256")
                .digest(text.toByteArray(Charsets.UTF_8))
                .joinToString("") { "%02x".format(it) }
            actual == expectedSha256Hex.lowercase()
        } catch (e: Exception) {
            false
        }
    }

    /** sha256 hex of raw bytes; used by ReaIntegrity. Never throws on null input. */
    fun sha256Hex(bytes: ByteArray): String {
        return MessageDigest.getInstance("SHA-256").digest(bytes)
            .joinToString("") { "%02x".format(it) }
    }
}

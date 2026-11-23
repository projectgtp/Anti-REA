package com.appcore.runtime

import java.security.MessageDigest
import java.util.Base64

/**
 * Anti-REA v1.0 — L13 asset decryption.
 *
 * Decrypts asset files encrypted by transformer/native.py
 * encrypt_asset_bytes(). The blob format is the BYTE form of the
 * crypto.py / ReaRuntime format, exactly:
 *   raw = sha256(plaintext) || plaintext, XORed with a 32-byte key.
 *   key = keyPart1 XOR keyPart2 (neither part alone is the key).
 *   stored file = raw cipher bytes (32 bytes longer than plaintext).
 *
 * Kotlin stdlib + JDK only, no Android imports, so JVM tests can use
 * it directly. Decryption happens in memory only; the plaintext is
 * never written to disk or logged. A tampered blob throws
 * IllegalStateException — never a wrong value.
 *
 * The key parts do NOT live in the asset file: the CLI records them
 * in the REA-IR manifest, and the app supplies them (from its own
 * protected config) when it reads the asset. How the app stores the
 * parts is the app's decision; the honest limit is the same as L01 —
 * XOR + split keys is obfuscation with integrity checking, not
 * strong crypto, and a runtime dump can read values after decryption.
 */
object ReaAssets {

    /**
     * Decrypt asset cipher bytes. Throws IllegalStateException on
     * tamper (embedded plaintext hash mismatch) or malformed input.
     * Never returns wrong bytes.
     */
    fun decryptAsset(
        cipher: ByteArray,
        keyPart1B64: String,
        keyPart2B64: String,
    ): ByteArray {
        val key = ReaRuntime.reconstructKey(keyPart1B64, keyPart2B64)
        val raw = ByteArray(cipher.size) { i ->
            (cipher[i].toInt() xor key[i % key.size].toInt()).toByte()
        }
        if (raw.size <= 32) {
            throw IllegalStateException("AppCore: asset payload too short")
        }
        val expectedHash = raw.copyOfRange(0, 32)
        val plain = raw.copyOfRange(32, raw.size)
        val actualHash = MessageDigest.getInstance("SHA-256").digest(plain)
        if (!expectedHash.contentEquals(actualHash)) {
            throw IllegalStateException(
                "AppCore: asset payload integrity check failed"
            )
        }
        return plain
    }

    /** Base64-blob convenience wrapper around [decryptAsset]. */
    fun decryptAssetBase64(
        blobB64: String,
        keyPart1B64: String,
        keyPart2B64: String,
    ): ByteArray {
        val cipher = try {
            Base64.getDecoder().decode(blobB64)
        } catch (e: IllegalArgumentException) {
            throw IllegalStateException("AppCore: asset blob is not valid base64", e)
        }
        return decryptAsset(cipher, keyPart1B64, keyPart2B64)
    }

    /** Decrypt an asset that holds UTF-8 text. */
    fun decryptAssetText(
        cipher: ByteArray,
        keyPart1B64: String,
        keyPart2B64: String,
    ): String {
        return String(decryptAsset(cipher, keyPart1B64, keyPart2B64), Charsets.UTF_8)
    }
}

package com.antirea.runtime

/**
 * JVM test for L60 ReaMethodDecrypt (runtime/ReaMethodDecrypt.kt).
 * Pure core only — no Android imports, no device.
 *
 * Compile + run (pattern from tools/run_all.py — kotlinc with
 * android.jar on the classpath, plain JVM to run):
 *   kotlinc -cp $ANDROID_JAR -d method-test.jar \
 *     ReaMethodDecrypt.kt tests/MethodDecryptTest.kt
 *   java -cp method-test.jar:$STDLIB \
 *     com.antirea.runtime.MethodDecryptTestKt
 *
 * Checks:
 *  (a) seal/open round-trip on binary (non-UTF-8) payload bytes;
 *  (b) double-open works — opening the same sealed blob twice
 *      gives the same plaintext both times;
 *  (c) tamper: flipping 1 byte of the blob refuses (null), never
 *      a wrong value;
 *  (d) wrong key refuses, in both the full-key and split-parts
 *      forms; malformed base64 refuses;
 *  (e) rotate changes the stored bytes AND the rotated blob still
 *      opens to the same payload; rotating a tampered blob refuses;
 *      rotating with a bad-length new key refuses;
 *  (f) bad inputs refuse: empty payload, wrong-length key;
 *  (g) verifyBlob: true for the good blob + hash, false for a
 *      wrong hash.
 * Any failure exits non-zero. Prints TEST-PASS on success.
 */
fun main() {
    fun fail(msg: String): Nothing {
        println("FAIL: $msg")
        kotlin.system.exitProcess(1)
    }

    // Deterministic binary payload: dex magic + text + every byte
    // value 0..255, so the test covers non-UTF-8 bytes too.
    val payload = byteArrayOf(0x64, 0x65, 0x78, 0x0a, 0x30, 0x33, 0x35, 0x00) +
        "test-method-payload".toByteArray(Charsets.UTF_8) +
        ByteArray(256) { it.toByte() }

    val key = ReaMethodDecrypt.generateKey()
    if (key.size != ReaMethodDecrypt.KEY_LEN) fail("generateKey length ${key.size}")

    // (a) round-trip, full-key and split-parts forms.
    val sealed = ReaMethodDecrypt.seal(payload, key) ?: fail("seal returned null")
    val opened = ReaMethodDecrypt.open(sealed) ?: fail("open(sealed) returned null")
    if (!opened.contentEquals(payload)) fail("round-trip payload mismatch")
    val openedByKey = ReaMethodDecrypt.open(sealed.blobBase64, key)
        ?: fail("open(blob, key) returned null")
    if (!openedByKey.contentEquals(payload)) fail("open(blob, key) mismatch")
    val openedByParts = ReaMethodDecrypt.open(
        sealed.blobBase64, sealed.keyPart1B64, sealed.keyPart2B64
    ) ?: fail("open(blob, parts) returned null")
    if (!openedByParts.contentEquals(payload)) fail("open(blob, parts) mismatch")
    if (sealed.plainSha256Hex != ReaMethodDecrypt.sha256Hex(payload)) {
        fail("plainSha256Hex mismatch")
    }
    println("ROUNDTRIP-OK: seal/open in all three forms, ${payload.size} bytes")

    // (b) double-open works.
    val openedAgain = ReaMethodDecrypt.open(sealed) ?: fail("second open returned null")
    if (!openedAgain.contentEquals(payload)) fail("second open mismatch")
    println("DOUBLE-OPEN-OK: same blob opens twice to the same payload")

    // (c) tamper: flip 1 byte of the decoded blob, re-encode, open must refuse.
    val cipher = java.util.Base64.getDecoder().decode(sealed.blobBase64)
    val tamperedCipher = cipher.copyOf().also { it[10] = (it[10].toInt() xor 0x01).toByte() }
    val tamperedBlob = java.util.Base64.getEncoder().encodeToString(tamperedCipher)
    if (ReaMethodDecrypt.open(tamperedBlob, key) != null) {
        fail("tampered blob opened with full key")
    }
    val tamperedSealed = sealed.copy(blobBase64 = tamperedBlob)
    if (ReaMethodDecrypt.open(tamperedSealed) != null) {
        fail("tampered blob opened in split-parts form")
    }
    println("TAMPER-OK: 1-byte flip refuses in both open forms")

    // (d) wrong key refuses; malformed base64 refuses.
    val wrongKey = ReaMethodDecrypt.generateKey()
    if (ReaMethodDecrypt.open(sealed.blobBase64, wrongKey) != null) {
        fail("wrong full key opened the blob")
    }
    val wrongPart2 = java.util.Base64.getEncoder().encodeToString(
        ReaMethodDecrypt.generateKey()
    )
    if (ReaMethodDecrypt.open(sealed.blobBase64, sealed.keyPart1B64, wrongPart2) != null) {
        fail("wrong key part2 opened the blob")
    }
    if (ReaMethodDecrypt.open("!!!not-base64!!!", key) != null) {
        fail("malformed base64 opened")
    }
    if (ReaMethodDecrypt.open(sealed.blobBase64, "!!!", "???") != null) {
        fail("malformed key parts opened the blob")
    }
    println("WRONG-KEY-OK: wrong key / wrong part / malformed input all refuse")

    // (e) rotate changes the stored bytes; rotated blob still opens.
    val newKey = ReaMethodDecrypt.generateKey()
    val rotated = ReaMethodDecrypt.rotate(sealed, newKey)
        ?: fail("rotate(sealed, newKey) returned null")
    if (rotated.blobBase64 == sealed.blobBase64) {
        fail("rotation did not change the stored blob bytes")
    }
    if (rotated.keyPart1B64 == sealed.keyPart1B64 &&
        rotated.keyPart2B64 == sealed.keyPart2B64
    ) {
        fail("rotation did not re-randomise the split key parts")
    }
    val rotatedOpen = ReaMethodDecrypt.open(rotated)
        ?: fail("rotated blob refused to open")
    if (!rotatedOpen.contentEquals(payload)) fail("rotated blob wrong payload")
    val rotated2 = ReaMethodDecrypt.rotate(sealed.blobBase64, key, newKey)
        ?: fail("rotate(blob, oldKey, newKey) returned null")
    val rotated2Open = ReaMethodDecrypt.open(rotated2)
        ?: fail("full-key-form rotated blob refused to open")
    if (!rotated2Open.contentEquals(payload)) fail("full-key rotated blob wrong payload")
    // Rotating a tampered blob must refuse, never launder the tamper.
    if (ReaMethodDecrypt.rotate(tamperedSealed, newKey) != null) {
        fail("tampered blob was rotated (must refuse)")
    }
    if (ReaMethodDecrypt.rotate(tamperedBlob, key, newKey) != null) {
        fail("tampered blob was rotated in full-key form (must refuse)")
    }
    // Bad-length new key refuses.
    if (ReaMethodDecrypt.rotate(sealed, ByteArray(16)) != null) {
        fail("rotate with 16-byte new key succeeded (must refuse)")
    }
    println("ROTATE-OK: stored bytes change, rotated blob opens, tamper/bad-key refuse")

    // (f) bad inputs refuse.
    if (ReaMethodDecrypt.seal(ByteArray(0), key) != null) {
        fail("seal of empty payload succeeded (must refuse)")
    }
    if (ReaMethodDecrypt.seal(payload, ByteArray(16)) != null) {
        fail("seal with 16-byte key succeeded (must refuse)")
    }
    println("BAD-INPUT-OK: empty payload / short key refuse")

    // (g) verifyBlob.
    if (!ReaMethodDecrypt.verifyBlob(sealed.blobBase64, sealed.blobSha256Hex)) {
        fail("verifyBlob failed on the good blob")
    }
    if (ReaMethodDecrypt.verifyBlob(
            sealed.blobBase64,
            "0000000000000000000000000000000000000000000000000000000000000000"
        )
    ) {
        fail("verifyBlob passed on a wrong hash")
    }
    if (ReaMethodDecrypt.verifyBlob("!!!not-base64!!!", sealed.blobSha256Hex)) {
        fail("verifyBlob passed on malformed base64")
    }
    println("VERIFY-OK: good hash passes, wrong hash / malformed input refuse")

    println("TEST-PASS")
}

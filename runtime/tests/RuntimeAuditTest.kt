package com.appcore.runtime

import java.io.File
import java.nio.file.Files
import java.nio.file.LinkOption
import java.security.MessageDigest
import java.util.Base64

/**
 * JVM test for the runtime audit fixes (2026-11-23, Agent C).
 *
 * Pure core only — no device. Compile with android.jar on the
 * kotlinc classpath (ReaMethodLoader.kt imports android.* /
 * dalvik.*, which this test never calls at runtime beyond the
 * internal writePlaintextFile helper), then run on a plain JVM:
 *   kotlinc -cp $ANDROID_JAR -d audit-test.jar \
 *     ReaRuntime.kt ReaIntegrity.kt ReaIntegrity2.kt \
 *     ReaMethodDecrypt.kt ReaMethodLoader.kt ReaNative.kt \
 *     ReaTraps.kt ReaAssets.kt tests/RuntimeAuditTest.kt
 *   java -cp audit-test.jar:$ANDROID_JAR:$STDLIB \
 *     com.appcore.runtime.RuntimeAuditTestKt <work-dir>
 * <work-dir> holds the test files (created under /home/hatch/tmp
 * by the runner, never /tmp).
 *
 * Checks:
 *  (a) F1 key-part errors: empty / mismatched / malformed key parts
 *      throw IllegalStateException from ReaRuntime.decrypt (never
 *      ArithmeticException from an empty key, never
 *      IllegalArgumentException from require()); ReaAssets agrees.
 *  (b) F2 streaming file hash: a 5 MB file hashes correctly via
 *      verifyFileSha256 / verifyConfigFileHash, a 1-byte flip fails,
 *      an empty file is rejected by verifyConfigFileHash.
 *  (c) F3 reflection fallback: a null-returning or void method is
 *      invoked EXACTLY ONCE through callByReflectionOrDirect (no
 *      double-invoke via the direct fallback); a missing method
 *      still falls back to direct exactly once.
 *  (d) F5 plaintext dex write: success writes the bytes; a write
 *      failure (symlink to /dev/full) returns false AND leaves no
 *      file behind.
 *  (e) F7 Java gate: correct hash passes (any case), wrong hash fails.
 *  (f) F9 sealed hashes: open(sealed) refuses when the stored
 *      blobSha256Hex or plainSha256Hex is tampered with or blank.
 *  (g) F10 thread safety: concurrent recordIntegrityFailure /
 *      useTripwire calls lose no counts and throw nothing.
 * Any failure exits non-zero. Prints TEST-PASS on success.
 */
fun main(args: Array<String>) {
    fun fail(msg: String): Nothing {
        println("FAIL: $msg")
        kotlin.system.exitProcess(1)
    }
    val workDir = File(if (args.isNotEmpty()) args[0] else "audit-work")
    if (!workDir.isDirectory && !workDir.mkdirs()) fail("cannot create work dir $workDir")

    // -- (a) F1: key-part errors are IllegalStateException. ----------
    val plain = "audit-test-value"
    val key = ByteArray(32) { (it * 7 + 3).toByte() }
    val part1 = ByteArray(32) { (it * 11 + 1).toByte() }
    val part2 = ByteArray(32) { i -> (key[i].toInt() xor part1[i].toInt()).toByte() }
    val raw = MessageDigest.getInstance("SHA-256").digest(plain.toByteArray(Charsets.UTF_8)) +
        plain.toByteArray(Charsets.UTF_8)
    val cipher = ByteArray(raw.size) { i -> (raw[i].toInt() xor key[i % 32].toInt()).toByte() }
    val blob = Base64.getEncoder().encodeToString(cipher)
    val p1b64 = Base64.getEncoder().encodeToString(part1)
    val p2b64 = Base64.getEncoder().encodeToString(part2)
    if (ReaRuntime.decrypt(blob, p1b64, p2b64) != plain) fail("control decrypt failed")
    fun expectIllegalState(name: String, block: () -> Any?) {
        try {
            block()
            fail("$name: expected IllegalStateException, got a value")
        } catch (e: IllegalStateException) {
            // Expected.
        } catch (e: Exception) {
            fail("$name: expected IllegalStateException, got ${e.javaClass.name}: ${e.message}")
        }
    }
    // Empty key parts: old code divided by zero (ArithmeticException).
    expectIllegalState("decrypt empty key parts") { ReaRuntime.decrypt(blob, "", "") }
    expectIllegalState("decrypt empty part1") { ReaRuntime.decrypt(blob, "", p2b64) }
    // Mismatched lengths: old code threw IllegalArgumentException via require().
    val shortPart = Base64.getEncoder().encodeToString(ByteArray(16) { 1 })
    expectIllegalState("decrypt mismatched key parts") { ReaRuntime.decrypt(blob, p1b64, shortPart) }
    // Malformed base64 key part: old code threw raw IllegalArgumentException.
    expectIllegalState("decrypt malformed key part") { ReaRuntime.decrypt(blob, "!!!", p2b64) }
    expectIllegalState("decrypt malformed blob") { ReaRuntime.decrypt("!!!", p1b64, p2b64) }
    // Same contract through ReaAssets (old code: ArithmeticException on empty key).
    expectIllegalState("decryptAsset empty key parts") { ReaAssets.decryptAsset(cipher, "", "") }
    expectIllegalState("decryptAsset mismatched parts") { ReaAssets.decryptAsset(cipher, p1b64, shortPart) }
    println("KEYPARTS-OK: empty/mismatched/malformed parts -> IllegalStateException, control decrypts")

    // -- (b) F2: streaming file hash. -------------------------------
    val big = File(workDir, "five-mb.bin")
    val rng = java.util.Random(1234L)
    val fiveMb = ByteArray(5 * 1024 * 1024).also { rng.nextBytes(it) }
    big.writeBytes(fiveMb)
    val wantHash = MessageDigest.getInstance("SHA-256").digest(fiveMb)
        .joinToString("") { "%02x".format(it) }
    if (!ReaIntegrity.verifyFileSha256(big, wantHash)) fail("verifyFileSha256 failed on 5 MB file")
    if (!ReaIntegrity.verifyFileSha256(big, wantHash.uppercase())) {
        fail("verifyFileSha256 must be case-insensitive")
    }
    val flipped = fiveMb.copyOf().also { it[1_000_000] = (it[1_000_000].toInt() xor 1).toByte() }
    val flippedFile = File(workDir, "five-mb-flipped.bin").also { it.writeBytes(flipped) }
    if (ReaIntegrity.verifyFileSha256(flippedFile, wantHash)) {
        fail("verifyFileSha256 passed a 1-byte-flipped file")
    }
    val cfg = ReaIntegrity2.verifyConfigFileHash(big, wantHash)
    if (!cfg.passed || cfg.actualHex != wantHash) fail("verifyConfigFileHash failed on 5 MB file: $cfg")
    if (ReaIntegrity2.verifyConfigFileHash(flippedFile, wantHash).passed) {
        fail("verifyConfigFileHash passed a flipped file")
    }
    val empty = File(workDir, "empty.bin").also { it.writeBytes(ByteArray(0)) }
    if (ReaIntegrity2.verifyConfigFileHash(empty, wantHash).passed) {
        fail("verifyConfigFileHash passed an empty file")
    }
    if (!ReaIntegrity.verifyFileSha256(File(workDir, "no-such-file.bin"), wantHash).let { !it }) {
        fail("verifyFileSha256 passed a missing file")
    }
    println("STREAM-HASH-OK: 5 MB file hashes, flip fails, empty config rejected")

    // -- (c) F3: no double-invoke through the reflection fallback. ---
    val target = CountingTarget()
    var directCalls = 0
    val nullResult: String? = ReaIntegrity2.callByReflectionOrDirect(
        target, "returnsNull", direct = { directCalls++; "fallback" }
    )
    if (nullResult != null) fail("null-returning method came back as '$nullResult' (direct fallback ran)")
    if (target.nullCalls != 1) fail("returnsNull invoked ${target.nullCalls}x, want exactly 1")
    if (directCalls != 0) fail("direct fallback ran $directCalls times for a null-returning method")
    val voidResult: String? = ReaIntegrity2.callByReflectionOrDirect(
        target, "returnsVoid", direct = { directCalls++; "fallback" }
    )
    if (voidResult != null) fail("void method came back as '$voidResult'")
    if (target.voidCalls != 1) fail("returnsVoid invoked ${target.voidCalls}x, want exactly 1")
    if (directCalls != 0) fail("direct fallback ran for a void method")
    val valueResult: String? = ReaIntegrity2.callByReflectionOrDirect(target, "returnsValue")
    if (valueResult != "v" || target.valueCalls != 1) {
        fail("returnsValue -> '$valueResult' after ${target.valueCalls} calls")
    }
    // Missing method: direct fallback runs exactly once.
    val missingResult: String? = ReaIntegrity2.callByReflectionOrDirect(
        target, "noSuchMethod", direct = { directCalls++; "fallback" }
    )
    if (missingResult != "fallback" || directCalls != 1) {
        fail("missing method fallback -> '$missingResult', directCalls=$directCalls")
    }
    // invokeReflectively itself still returns null for a null-returning method.
    if (ReaIntegrity2.invokeReflectively(target, "returnsNull") != null) {
        fail("invokeReflectively on null-returning method did not return null")
    }
    println("REFLECT-OK: null/void methods invoked once, missing method falls back once")

    // -- (d) F5: plaintext dex write, success + failure cleanup. ----
    val dexDir = File(workDir, "dexwrite").also { it.mkdirs() }
    val goodFile = File(dexDir, "good.dex")
    val dexBytes = "dex\n035\u0000fake-dex-bytes".toByteArray(Charsets.UTF_8)
    if (!ReaMethodLoader.writePlaintextFile(goodFile, dexBytes)) {
        fail("writePlaintextFile failed on a normal file")
    }
    if (!goodFile.readBytes().contentEquals(dexBytes)) fail("written dex bytes differ")
    // Forced write failure: a symlink to /dev/full — open succeeds,
    // the write itself fails with ENOSPC. The link must be gone after.
    val fullLink = File(dexDir, "full.dex")
    try {
        Files.createSymbolicLink(fullLink.toPath(), File("/dev/full").toPath())
    } catch (e: Exception) {
        fail("cannot create /dev/full symlink for the test: $e")
    }
    if (ReaMethodLoader.writePlaintextFile(fullLink, dexBytes)) {
        fail("writePlaintextFile claimed success writing to /dev/full")
    }
    if (Files.exists(fullLink.toPath(), LinkOption.NOFOLLOW_LINKS)) {
        fail("failed plaintext write left the file behind (must be deleted)")
    }
    // Open failure (parent is a file, not a dir): false, nothing left.
    val notADir = File(dexDir, "not-a-dir").also { it.writeText("x") }
    if (ReaMethodLoader.writePlaintextFile(File(notADir, "f.dex"), dexBytes)) {
        fail("writePlaintextFile claimed success under a non-directory")
    }
    println("DEXWRITE-OK: success writes bytes, /dev/full failure deletes the file")

    // -- (e) F7: Java gate (constant-time compare, same verdicts). ---
    val data = "gate-input-bytes".toByteArray(Charsets.UTF_8)
    val dataHash = ReaRuntime.sha256Hex(data)
    if (!ReaNative.javaGate(dataHash, data)) fail("javaGate rejected the correct hash")
    if (!ReaNative.javaGate(dataHash.uppercase(), data)) {
        fail("javaGate must be case-insensitive")
    }
    val wrongHash = "00" + dataHash.substring(2)
    if (ReaNative.javaGate(wrongHash, data)) fail("javaGate accepted a wrong hash")
    if (ReaNative.javaGate("", data)) fail("javaGate accepted a blank hash")
    if (ReaNative.javaGate("not-hex", data)) fail("javaGate accepted malformed hex")
    // On the JVM the .so is absent, so integrityGate() runs the Java fallback.
    if (ReaNative.nativeLoaded) fail("nativeLoaded true on a plain JVM (unexpected)")
    if (!ReaNative.integrityGate(dataHash, data)) fail("integrityGate rejected the correct hash")
    if (ReaNative.integrityGate(wrongHash, data)) fail("integrityGate accepted a wrong hash")
    println("JAVAGATE-OK: correct hash passes, wrong/blank/malformed refuse")

    // -- (f) F9: stored sealed hashes are verified on open. ----------
    val payload = byteArrayOf(0x64, 0x65, 0x78, 0x0a) + "audit-payload".toByteArray(Charsets.UTF_8)
    val sealed = ReaMethodDecrypt.seal(payload, ReaMethodDecrypt.generateKey())
        ?: fail("seal returned null")
    if (!ReaMethodDecrypt.open(sealed)!!.contentEquals(payload)) fail("control open(sealed) failed")
    val badBlobHash = sealed.copy(
        blobSha256Hex = "00" + sealed.blobSha256Hex.substring(2)
    )
    if (ReaMethodDecrypt.open(badBlobHash) != null) {
        fail("open(sealed) accepted a tampered blobSha256Hex")
    }
    val badPlainHash = sealed.copy(
        plainSha256Hex = "00" + sealed.plainSha256Hex.substring(2)
    )
    if (ReaMethodDecrypt.open(badPlainHash) != null) {
        fail("open(sealed) accepted a tampered plainSha256Hex")
    }
    val blankHashes = sealed.copy(blobSha256Hex = "", plainSha256Hex = "")
    if (ReaMethodDecrypt.open(blankHashes) != null) {
        fail("open(sealed) accepted blank stored hashes")
    }
    // Rotation still works and the rotated blob still opens.
    val rotated = ReaMethodDecrypt.rotate(sealed, ReaMethodDecrypt.generateKey())
        ?: fail("rotate(sealed) returned null after the hash check")
    if (!ReaMethodDecrypt.open(rotated)!!.contentEquals(payload)) {
        fail("rotated blob failed to open")
    }
    println("SEALED-HASH-OK: tampered/blank stored hashes refuse, good seal + rotate open")

    // -- (g) F10: thread safety (hammer test). -----------------------
    val delayed = DelayedFailure(8000)
    val threads = (1..8).map {
        Thread {
            repeat(1000) { delayed.recordIntegrityFailure() }
        }
    }
    threads.forEach { it.start() }
    threads.forEach { it.join() }
    if (delayed.failureCount() != 8000) {
        fail("DelayedFailure lost failures under threads: ${delayed.failureCount()}, want 8000")
    }
    if (delayed.allowSensitiveAction()) fail("DelayedFailure should refuse at 8000 failures")
    val tripwire = Tripwire()
    tripwire.registerTripwire("k", "fake")
    val honeyThreads = (1..8).map {
        Thread {
            repeat(500) { tripwire.useTripwire("k") }
        }
    }
    honeyThreads.forEach { it.start() }
    honeyThreads.forEach { it.join() }
    if (tripwire.tripCount() != 4000) {
        fail("Tripwire lost trips under threads: ${tripwire.tripCount()}, want 4000")
    }
    if (tripwire.trips().size != 4000) fail("Tripwire.trips() size mismatch")
    println("THREADSAFE-OK: 8000 failures counted, 4000 tripwire trips counted")

    println("TEST-PASS")
}

/** Counting target for the reflection double-invoke check (F3). */
class CountingTarget {
    var nullCalls: Int = 0
    var voidCalls: Int = 0
    var valueCalls: Int = 0

    fun returnsNull(): String? {
        nullCalls++
        return null
    }

    fun returnsVoid() {
        voidCalls++
    }

    fun returnsValue(): String {
        valueCalls++
        return "v"
    }
}

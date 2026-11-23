package com.appcore.runtime

/**
 * JVM test Main for ReaRuntime (v1.0). No Android imports.
 * Usage: java -cp test.jar com.appcore.runtime.MainKt <blob> <part1> <part2> <expectedPlain> <tamperedBlob>
 *   1. decrypt(blob) must equal expectedPlain  -> prints DECRYPT-OK
 *   2. decrypt(tamperedBlob) must throw IllegalStateException -> prints TAMPER-REFUSED
 * Any other outcome exits non-zero.
 */
fun main(args: Array<String>) {
    require(args.size == 5) { "usage: MainKt <blob> <part1> <part2> <expectedPlain> <tamperedBlob>" }
    val (blob, p1, p2, expected, tampered) = args

    val plain = ReaRuntime.decrypt(blob, p1, p2)
    if (plain != expected) {
        println("DECRYPT-MISMATCH: got [$plain] expected [$expected]")
        kotlin.system.exitProcess(2)
    }
    println("DECRYPT-OK: $plain")

    // Blob-level + plaintext-level integrity on the good blob.
    val blobSha = ReaRuntime.sha256Hex(java.util.Base64.getDecoder().decode(blob))
    if (!ReaRuntime.verifyIntegrity(blob, blobSha)) {
        println("VERIFY-INTEGRITY-FAIL on good blob")
        kotlin.system.exitProcess(3)
    }
    if (!ReaRuntime.verifyText(plain, ReaRuntime.sha256Hex(plain.toByteArray(Charsets.UTF_8)))) {
        println("VERIFY-TEXT-FAIL on good plaintext")
        kotlin.system.exitProcess(4)
    }
    println("VERIFY-OK")

    // Tampered blob must refuse with IllegalStateException, never a wrong value.
    try {
        val bad = ReaRuntime.decrypt(tampered, p1, p2)
        println("TAMPER-NOT-REFUSED: decrypt returned [$bad]")
        kotlin.system.exitProcess(5)
    } catch (e: IllegalStateException) {
        println("TAMPER-REFUSED: ${e.message}")
    }
    println("TEST-PASS")
}

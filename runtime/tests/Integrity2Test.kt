package com.antirea.runtime

/**
 * JVM test Main for Batch B integrity layers (L23, L25, L27, L28, L29,
 * L30, L54, L56, L57) in ReaIntegrity2.kt + ReaTimer.kt.
 *
 * Pure core only — no Context, no device. Compile with android.jar on
 * the kotlinc classpath (ReaIntegrity2.kt imports android.* / dalvik.*
 * for adapter functions this test never calls), then run on a plain JVM:
 *   kotlinc -cp $ANDROID_JAR -d tests/dynamic-test.jar tests/DynamicHello.kt
 *   kotlinc -cp $ANDROID_JAR -d tests/integrity2-test.jar \
 *     ReaRuntime.kt ReaIntegrity.kt ReaIntegrity2.kt ReaTimer.kt tests/Integrity2Test.kt
 *   cd runtime && java -cp tests/integrity2-test.jar:$STDLIB:$ANDROID_JAR \
 *     com.antirea.runtime.Integrity2TestKt [path-to-dynamic-test.jar]
 * (default jar path: tests/dynamic-test.jar, relative to the runtime dir.)
 *
 * Checks:
 *  (a) L23 installer origin: Play / third-party / unknown / blank; signalOnly.
 *  (b) L25 self-hash: known "hello" SHA-256, own-class hash, mismatch refuses.
 *  (c) L27 config pin: match / mismatch / empty / uppercase hex / file.
 *  (d) L28 resource hashes: pass / flipped byte / missing / empty expected.
 *  (e) L29 native lib hashes: pass / flipped / non-.so name / missing.
 *  (f) L30 timer: fires N times on a fake clock, stops on refusal, stops on throw.
 *  (g) L54 env-gated decrypt: env fires -> decrypt NEVER called; clean -> called.
 *  (h) L56 reflection: named-method call, missing method -> null, direct fallback.
 *  (i) L57 dynamic loading: load DynamicHello from a jar file + from jar bytes.
 * Any failure exits non-zero. Prints TEST-PASS on success.
 */
fun main(args: Array<String>) {
    fun fail(msg: String): Nothing {
        println("FAIL: $msg")
        kotlin.system.exitProcess(1)
    }

    fun sha256(bytes: ByteArray): String = ReaIntegrity2.sha256Hex(bytes)

    // (a) L23 installer origin.
    val play = ReaIntegrity2.checkInstallerOrigin("com.example.app", "com.android.vending")
    if (play.origin != ReaIntegrity2.InstallerOrigin.PLAY_STORE || !play.isPlayStore) {
        fail("L23 Play Store not classified: $play")
    }
    if (!play.signalOnly) fail("L23 signalOnly must be true")
    val side = ReaIntegrity2.checkInstallerOrigin("com.example.app", "com.amazon.venezia")
    if (side.origin != ReaIntegrity2.InstallerOrigin.THIRD_PARTY || side.isPlayStore) {
        fail("L23 third-party not classified: $side")
    }
    val unk = ReaIntegrity2.checkInstallerOrigin("com.example.app", null)
    if (unk.origin != ReaIntegrity2.InstallerOrigin.UNKNOWN || unk.installerPackage != null) {
        fail("L23 null installer not UNKNOWN: $unk")
    }
    val blank = ReaIntegrity2.checkInstallerOrigin("com.example.app", "   ")
    if (blank.origin != ReaIntegrity2.InstallerOrigin.UNKNOWN) fail("L23 blank installer not UNKNOWN")
    println("L23-OK: play-store / third-party / unknown / blank, signalOnly=true")

    // (b) L25 self-hash.
    val helloHash = ReaIntegrity2.hashClassBytes("hello".toByteArray(Charsets.UTF_8).inputStream())
    if (helloHash != "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824") {
        fail("L25 sha256(hello) = $helloHash")
    }
    val ownHash = ReaIntegrity2.hashOwnClassBytes(ReaIntegrity2::class.java)
    if (ownHash == null || ownHash.length != 64) fail("L25 own-class hash missing: $ownHash")
    val selfOk = ReaIntegrity2.verifySelfHash(
        "hello".toByteArray(Charsets.UTF_8).inputStream(), helloHash!!
    )
    if (!selfOk.passed || selfOk.actualHex != helloHash) fail("L25 verifySelfHash good != pass: $selfOk")
    val selfBad = ReaIntegrity2.verifySelfHash(
        "hello".toByteArray(Charsets.UTF_8).inputStream(),
        "0000000000000000000000000000000000000000000000000000000000000000"
    )
    if (selfBad.passed) fail("L25 verifySelfHash mismatch passed")
    val selfNull = ReaIntegrity2.verifySelfHash(null, helloHash)
    if (selfNull.passed || selfNull.actualHex != null) fail("L25 null stream must fail with null hash")
    val ownCheck = ReaIntegrity2.verifyOwnClassHash(ReaIntegrity2::class.java, ownHash)
    if (!ownCheck.passed) fail("L25 verifyOwnClassHash with its own hash failed")
    println("L25-OK: known hello hash, own-class hash, mismatch/null refuse")

    // (c) L27 config hash pinning.
    val config = "rea-ir-test-config".toByteArray(Charsets.UTF_8)
    val pinned = sha256(config)
    if (!ReaIntegrity2.verifyConfigHash(config, pinned).passed) fail("L27 matching pin failed")
    if (!ReaIntegrity2.verifyConfigHash(config, pinned.uppercase()).passed) {
        fail("L27 uppercase pinned hex must match (case-insensitive)")
    }
    if (ReaIntegrity2.verifyConfigHash(config, "00".repeat(32)).passed) {
        fail("L27 wrong pin passed")
    }
    if (ReaIntegrity2.verifyConfigHash(ByteArray(0), pinned).passed) fail("L27 empty config passed")
    if (ReaIntegrity2.verifyConfigHash(null, pinned).passed) fail("L27 null config passed")
    if (ReaIntegrity2.verifyConfigHash(config, "not-hex").passed) fail("L27 bad hex passed")
    // Hex-to-hex, never hash-a-hash: pinning sha256(pinned) must NOT pass.
    if (ReaIntegrity2.verifyConfigHash(config, sha256(pinned.toByteArray(Charsets.UTF_8))).passed) {
        fail("L27 hash-of-hash pin passed — must never match")
    }
    val tmpConfig = java.io.File("tests/rea-cfg-test.json")
    tmpConfig.writeBytes(config)
    if (!ReaIntegrity2.verifyConfigFileHash(tmpConfig, pinned).passed) {
        fail("L27 config file pin failed")
    }
    if (ReaIntegrity2.verifyConfigFileHash(java.io.File("/nonexistent/rea-cfg.json"), pinned).passed) {
        fail("L27 missing config file passed")
    }
    tmpConfig.delete()
    // Constant-time hex compare sanity.
    if (!ReaIntegrity2.hexEqualsConstantTime("aabb", "AABB")) fail("hexEquals case-insensitive")
    if (ReaIntegrity2.hexEqualsConstantTime("aabb", "aabc")) fail("hexEquals mismatch passed")
    if (ReaIntegrity2.hexEqualsConstantTime("aab", "aabb")) fail("hexEquals odd-length passed")
    if (ReaIntegrity2.hexEqualsConstantTime(null, "aabb")) fail("hexEquals null passed")
    println("L27-OK: match / mismatch / empty / bad-hex / hash-of-hash refuses, file pin works")

    // (d) L28 resource hashes.
    val resEntries = mapOf(
        "res/values/strings.xml" to "strings-content".toByteArray(Charsets.UTF_8),
        "assets/antirea/manifest.json" to "{\"v\":1}".toByteArray(Charsets.UTF_8)
    )
    val resExpected = resEntries.mapValues { sha256(it.value) }
    val resOk = ReaIntegrity2.verifyResourceHashes(resEntries, resExpected)
    if (!resOk.passed || resOk.checkedCount != 2) fail("L28 good resources failed: $resOk")
    val resFlipped = resEntries.toMutableMap()
    resFlipped["res/values/strings.xml"] = "strings-contenT".toByteArray(Charsets.UTF_8)
    val resBad = ReaIntegrity2.verifyResourceHashes(resFlipped, resExpected)
    if (resBad.passed || resBad.failedEntries != listOf("res/values/strings.xml")) {
        fail("L28 flipped resource not flagged: $resBad")
    }
    val resMissing = ReaIntegrity2.verifyResourceHashes(
        mapOf("res/values/strings.xml" to resEntries["res/values/strings.xml"]!!), resExpected
    )
    if (resMissing.passed || resMissing.missingEntries != listOf("assets/antirea/manifest.json")) {
        fail("L28 missing resource not flagged: $resMissing")
    }
    if (ReaIntegrity2.verifyResourceHashes(resEntries, emptyMap()).passed) {
        fail("L28 empty expected map passed (nothing checked is not a pass)")
    }
    println("L28-OK: pass / flipped / missing / empty-expected refuses")

    // (e) L29 native lib hashes.
    val soEntries = mapOf(
        "lib/arm64-v8a/librea.so" to byteArrayOf(0x7F, 0x45, 0x4C, 0x46, 0x01, 0x02),
        "lib/armeabi-v7a/librea.so" to byteArrayOf(0x7F, 0x45, 0x4C, 0x46, 0x03, 0x04)
    )
    val soExpected = soEntries.mapValues { sha256(it.value) }
    if (!ReaIntegrity2.verifyNativeLibHashes(soEntries, soExpected).passed) {
        fail("L29 good .so set failed")
    }
    val soFlipped = soEntries.toMutableMap()
    soFlipped["lib/arm64-v8a/librea.so"] = byteArrayOf(0x7F, 0x45, 0x4C, 0x46, 0x01, 0x03)
    val soBad = ReaIntegrity2.verifyNativeLibHashes(soFlipped, soExpected)
    if (soBad.passed || soBad.failedEntries != listOf("lib/arm64-v8a/librea.so")) {
        fail("L29 flipped .so not flagged: $soBad")
    }
    val notSo = ReaIntegrity2.verifyNativeLibHashes(
        mapOf("lib/arm64-v8a/librea.txt" to byteArrayOf(1, 2, 3)),
        mapOf("lib/arm64-v8a/librea.txt" to sha256(byteArrayOf(1, 2, 3)))
    )
    if (notSo.passed || notSo.failedEntries != listOf("lib/arm64-v8a/librea.txt")) {
        fail("L29 non-.so entry not flagged: $notSo")
    }
    if (ReaIntegrity2.verifyNativeLibHashes(soEntries, emptyMap()).passed) {
        fail("L29 empty expected map passed")
    }
    println("L29-OK: pass / flipped / non-.so / empty-expected refuses")

    // (f) L30 timer on a fake clock.
    var fakeNow = 0L
    var checkCalls = 0
    var checkClean = true
    val timer = ReaTimer(1000L, { checkCalls++; checkClean }, { fakeNow })
    timer.arm() // first fire due at t=1000
    if (timer.tick(500L) != 0 || checkCalls != 0) fail("L30 fired before interval")
    if (timer.tick(1000L) != 1 || checkCalls != 1) fail("L30 did not fire at t=1000")
    if (timer.tick(3500L) != 2 || checkCalls != 3) fail("L30 did not catch up 2 fires by t=3500")
    checkClean = false
    if (timer.tick(4000L) != 1 || !timer.stopped) fail("L30 did not stop on refusal at t=4000")
    if (timer.fireCount != 4 || timer.passCount != 3) {
        fail("L30 counts wrong: fire=${timer.fireCount} pass=${timer.passCount}, want 4/3")
    }
    if (timer.tick(10000L) != 0 || checkCalls != 4) fail("L30 fired after stop")
    // A check that throws also stops the timer (treated as failure).
    val throwing = ReaTimer(100L, { throw RuntimeException("boom") }, { fakeNow })
    throwing.arm()
    throwing.tick(200L)
    if (!throwing.stopped || throwing.fireCount != 1) fail("L30 throwing check did not stop")
    // Bad interval is rejected at construction.
    try {
        ReaTimer(0L, { true })
        fail("L30 interval 0 accepted")
    } catch (e: IllegalArgumentException) {
        // Expected.
    }
    println("L30-OK: 3 passes by t=3500, refusal stops at t=4000, throw stops, interval validated")

    // (g) L54 env-gated decrypt.
    var decryptCalls = 0
    val secret = ReaIntegrity2.decryptWithEnvCheck({ true }, { decryptCalls++; "plaintext" })
    if (secret != null || decryptCalls != 0) {
        fail("L54 env-fire still called decrypt (calls=$decryptCalls)")
    }
    val clean = ReaIntegrity2.decryptWithEnvCheck({ false }, { decryptCalls++; "plaintext" })
    if (clean != "plaintext" || decryptCalls != 1) fail("L54 clean env did not decrypt: $clean")
    val envThrows = ReaIntegrity2.decryptWithEnvCheck(
        { throw RuntimeException("env boom") }, { decryptCalls++; "plaintext" }
    )
    if (envThrows != null || decryptCalls != 1) fail("L54 throwing env check called decrypt")
    val decryptThrows: String? = ReaIntegrity2.decryptWithEnvCheck<String>({ false }, { throw IllegalStateException("bad blob") })
    if (decryptThrows != null) fail("L54 throwing decrypt returned a value")
    println("L54-OK: env-fire never decrypts, clean decrypts, throws refuse")

    // (h) L56 reflection.
    val greeter = object {
        fun greet(name: String): String = "hello $name"
        fun secret(): String = "never-direct"
    }
    val reflected = ReaIntegrity2.invokeReflectively(greeter, "greet", "Ada")
    if (reflected != "hello Ada") fail("L56 reflective greet = $reflected")
    if (ReaIntegrity2.invokeReflectively(greeter, "noSuchMethod") != null) {
        fail("L56 missing method returned non-null")
    }
    var directCalls = 0
    val fallback = ReaIntegrity2.callByReflectionOrDirect<String>(
        greeter, "noSuchMethod", emptyArray(), { directCalls++; "direct-fallback" }
    )
    if (fallback != "direct-fallback" || directCalls != 1) fail("L56 direct fallback failed: $fallback")
    val noFallbackNeeded = ReaIntegrity2.callByReflectionOrDirect<String>(
        greeter, "greet", arrayOf("Bo"), { directCalls++; "should-not-run" }
    )
    if (noFallbackNeeded != "hello Bo" || directCalls != 1) {
        fail("L56 reflection success still ran direct fallback: $noFallbackNeeded")
    }
    println("L56-OK: reflective call, missing->null, fallback only when reflection fails")

    // (i) L57 dynamic loading from a jar.
    val jarPath = if (args.isNotEmpty()) args[0] else "tests/dynamic-test.jar"
    val dynClass = ReaIntegrity2.loadClassFromJar(jarPath, "com.antirea.runtime.DynamicHello")
    if (dynClass == null) fail("L57 loadClassFromJar returned null for $jarPath")
    val dynInstance = dynClass.getDeclaredConstructor().newInstance()
    val dynHello = ReaIntegrity2.invokeReflectively(dynInstance, "hello")
    if (dynHello != "dynamic-hello") fail("L57 dynamic hello = $dynHello")
    val dynAdd = ReaIntegrity2.invokeReflectively(dynInstance, "add", 2, 3)
    if (dynAdd != 5) fail("L57 dynamic add(2,3) = $dynAdd")
    if (ReaIntegrity2.loadClassFromJar(jarPath, "com.antirea.runtime.NoSuchClass") != null) {
        fail("L57 missing class returned non-null")
    }
    if (ReaIntegrity2.loadClassFromJar("tests/no-such.jar", "com.antirea.runtime.DynamicHello") != null) {
        fail("L57 missing jar returned non-null")
    }
    val dynTmpDir = java.io.File("tests/dyn-tmp").apply { mkdirs() }
    val jarBytes = java.io.File(jarPath).readBytes()
    val fromBytes = ReaIntegrity2.loadClassFromJarBytes(jarBytes, "com.antirea.runtime.DynamicHello", dynTmpDir)
    if (fromBytes == null) fail("L57 loadClassFromJarBytes returned null")
    dynTmpDir.listFiles()?.forEach { it.delete() }
    dynTmpDir.delete()
    println("L57-OK: jar + jar-bytes load, instantiate, reflective call; missing class/jar null")

    println("TEST-PASS")
}

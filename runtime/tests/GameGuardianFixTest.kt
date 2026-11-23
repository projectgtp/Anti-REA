package com.appcore.runtime

import java.security.MessageDigest

/**
 * JVM test for the GameGuardian + renamed-APK fixes (L102, L103).
 *
 * Pure core only — no Context, no device. Compile with android.jar on
 * the kotlinc classpath (ReaEnv.kt / ReaRepack.kt import android.* for
 * adapter functions this test never calls), then run on a plain JVM:
 *   kotlinc -cp $ANDROID_JAR -d ggfix-test.jar \
 *     ReaRuntime.kt ReaIntegrity.kt ReaTrace.kt ReaEnv.kt \
 *     ReaMemory.kt ReaRepack.kt GameGuardianFixTest.kt
 *   java -cp ggfix-test.jar:$STDLIB com.appcore.runtime.GameGuardianFixTestKt
 *
 * Checks:
 *  (a) TracerPid parsing (0, 1234, missing, malformed).
 *  (b) /proc/self/stat state parsing, incl. a comm with spaces/parens.
 *  (c) isBeingTraced logic (pid, state, clean, unreadable).
 *  (d) Maps scan with GG markers present/absent; bare "gg" must NOT hit.
 *  (e) GG data-dir check with a fake exists() function.
 *  (f) ObfuscatedLong + ObfuscatedInt round-trip + tamper refusal.
 *  (g) Package-name match/mismatch/null; cert-hash match/mismatch;
 *      encrypted-hash-blob round-trip; installer classification.
 *  (h) memoryEditorRisk levels (high on trace/maps/files, root noted,
 *      root alone stays "none").
 * Any failure exits non-zero. Prints TEST-PASS on success.
 */
fun main() {
    fun fail(msg: String): Nothing {
        println("FAIL: $msg")
        kotlin.system.exitProcess(1)
    }

    // (a) TracerPid parsing.
    val statusClean = "Name:\tmyapp\nState:\tS (sleeping)\nTracerPid:\t0\nUid:\t10123\n"
    val statusTraced = "Name:\tmyapp\nTracerPid:\t1234\n"
    val statusNoLine = "Name:\tmyapp\nState:\tR (running)\n"
    val statusBad = "Name:\tmyapp\nTracerPid:\tabc\n"
    if (ReaTrace.parseTracerPid(statusClean) != 0) fail("TracerPid clean != 0")
    if (ReaTrace.parseTracerPid(statusTraced) != 1234) fail("TracerPid traced != 1234")
    if (ReaTrace.parseTracerPid(statusNoLine) != null) fail("TracerPid missing != null")
    if (ReaTrace.parseTracerPid(statusBad) != null) fail("TracerPid malformed != null")
    println("TRACERPID-OK: 0 / 1234 / missing / malformed")

    // (b) /proc/self/stat state parsing.
    if (ReaTrace.parseProcStatState("12345 (myapp) S 123 0 0") != 'S') fail("stat state S")
    if (ReaTrace.parseProcStatState("12345 (my app (2)) t 123 0 0") != 't') {
        fail("stat state 't' with spaces/parens in comm")
    }
    if (ReaTrace.parseProcStatState("12345 (myapp) R 123 0 0") != 'R') fail("stat state R")
    if (ReaTrace.parseProcStatState("garbage-no-parens") != null) fail("stat garbage != null")
    if (ReaTrace.parseProcStatState("") != null) fail("stat empty != null")
    println("STAT-OK: S / t (spaces in comm) / R / garbage")

    // (c) isBeingTraced logic.
    if (ReaTrace.isBeingTraced(statusClean, "1 (a) S 0")) fail("clean process flagged traced")
    if (!ReaTrace.isBeingTraced(statusTraced, "1 (a) S 0")) fail("TracerPid 1234 not flagged")
    if (!ReaTrace.isBeingTraced(statusClean, "1 (a) t 0")) fail("state 't' not flagged")
    if (!ReaTrace.isBeingTraced(null, "1 (a) t 0")) fail("state 't' with null status not flagged")
    if (ReaTrace.isBeingTraced(null, null)) fail("null inputs flagged traced")
    if (ReaTrace.isBeingTraced(statusNoLine, "1 (a) R 0")) fail("no TracerPid + R flagged")
    println("TRACED-OK: pid + state + null-safe")

    // (d) Maps scan.
    val mapsClean = "7f00000000-7f00100000 r-xp 00000000 fd:00 123 /system/lib64/libc.so\n" +
        "7f00200000-7f00300000 rw-p 00000000 00:00 0 [heap]\n"
    val mapsGg = mapsClean +
        "7f00400000-7f00500000 r-xp 00000000 fd:00 456 /data/app/libgameguardian.so\n" +
        "7f00600000-7f00700000 rw-p 00000000 00:00 0 /dev/ashmem/libgg\n"
    val hitsClean = ReaTrace.scanMapsForMarkers(mapsClean)
    if (hitsClean.isNotEmpty()) fail("clean maps flagged: $hitsClean")
    val hitsGg = ReaTrace.scanMapsForMarkers(mapsGg)
    if (hitsGg != listOf("gameguardian", "libgg")) fail("GG maps hits=$hitsGg")
    // Bare "gg" must NOT be a marker: "logged"/"suggest" contain "gg".
    val mapsGgWord = "7f00000000-7f00100000 r-xp 00000000 fd:00 123 /system/lib64/liblogged.so\n"
    if (ReaTrace.scanMapsForMarkers(mapsGgWord).isNotEmpty()) {
        fail("bare 'gg' in 'logged' flagged — marker list must not contain bare gg")
    }
    println("MAPS-OK: clean 0, GG markers found, bare 'gg' not a marker")

    // (e) GG data-dir check with a fake exists().
    val present = setOf("/data/data/com.catch_.me_.if_.you_.can_")
    val foundDirs = ReaTrace.findExistingDirs(ReaTrace.GG_DATA_DIRS) { it in present }
    if (foundDirs != listOf("/data/data/com.catch_.me_.if_.you_.can_")) {
        fail("GG dirs found=$foundDirs")
    }
    if (ReaTrace.findExistingDirs(ReaTrace.GG_DATA_DIRS) { false }.isNotEmpty()) {
        fail("GG dirs found with nothing present")
    }
    if (ReaTrace.GG_DATA_DIRS.size != 2) fail("GG_DATA_DIRS size != 2")
    println("DIRS-OK: base path found when present, clean when absent")

    // (f) ObfuscatedLong / ObfuscatedInt round-trip + tamper.
    for (v in listOf(0L, 1L, 100L, 99999L, -1L, Long.MAX_VALUE, Long.MIN_VALUE)) {
        val o = ReaMemory.ObfuscatedLong(v)
        if (o.get() != v) fail("ObfuscatedLong($v) get()=${o.get()}")
        if (!o.isIntact()) fail("ObfuscatedLong($v) not intact")
        o.set(v + 1)
        if (o.get() != v + 1) fail("ObfuscatedLong set() failed for $v")
        o.corruptForTest()
        if (o.get() != null) fail("ObfuscatedLong tamper NOT detected for $v")
        if (o.isIntact()) fail("ObfuscatedLong isIntact true after tamper")
        o.set(v) // recoverable by re-setting a fresh value
        if (o.get() != v) fail("ObfuscatedLong did not recover after set()")
    }
    for (v in listOf(0, 1, 100, 99999, -1, Int.MAX_VALUE, Int.MIN_VALUE)) {
        val o = ReaMemory.ObfuscatedInt(v)
        if (o.get() != v) fail("ObfuscatedInt($v) get()=${o.get()}")
        o.corruptForTest()
        if (o.get() != null) fail("ObfuscatedInt tamper NOT detected for $v")
        o.set(v)
        if (o.get() != v) fail("ObfuscatedInt did not recover after set()")
    }
    println("MEMORY-OK: Long/Int round-trip, tamper refuses (null), set() recovers")

    // (g) Repack: package, cert hash, blob, installer.
    if (!ReaRepack.verifyPackageName("com.bridge.mvp", "com.bridge.mvp")) {
        fail("package exact match failed")
    }
    if (ReaRepack.verifyPackageName("com.bridge.mvp.clone", "com.bridge.mvp")) {
        fail("renamed package passed")
    }
    if (ReaRepack.verifyPackageName("COM.BRIDGE.MVP", "com.bridge.mvp")) {
        fail("wrong-case package passed")
    }
    if (ReaRepack.verifyPackageName(null, "com.bridge.mvp")) fail("null package passed")
    val fakeCert = "fake-certificate-bytes-for-test".toByteArray(Charsets.UTF_8)
    val certHex = MessageDigest.getInstance("SHA-256").digest(fakeCert)
        .joinToString("") { "%02x".format(it) }
    if (!ReaRepack.verifySigningCertSha256(fakeCert, certHex)) fail("cert hash match failed")
    if (!ReaRepack.verifySigningCertSha256(fakeCert, certHex.uppercase())) {
        fail("cert hash match must be case-insensitive")
    }
    if (ReaRepack.verifySigningCertSha256(fakeCert, "00".repeat(32))) {
        fail("wrong cert hash passed")
    }
    if (ReaRepack.verifySigningCertSha256(ByteArray(0), certHex)) fail("empty cert passed")
    if (!ReaRepack.verifySigningCertHex(certHex, certHex.uppercase())) {
        fail("cert hex-to-hex match failed")
    }
    if (ReaRepack.verifySigningCertHex(certHex, "00".repeat(32))) {
        fail("cert hex mismatch passed")
    }
    // Encrypted-hash-blob round-trip (same blob format as ReaRuntime):
    // raw = sha256(plain) || plain, XOR with a fixed test key, base64.
    val testKey = ByteArray(32) { (it * 7 + 3).toByte() }
    fun makeBlob(plain: String): Triple<String, String, String> {
        val plainBytes = plain.toByteArray(Charsets.UTF_8)
        val hash = MessageDigest.getInstance("SHA-256").digest(plainBytes)
        val raw = hash + plainBytes
        val cipher = ByteArray(raw.size) { i ->
            (raw[i].toInt() xor testKey[i % 32].toInt()).toByte()
        }
        val part1 = ByteArray(32) { (it * 11 + 5).toByte() }
        val part2 = ByteArray(32) { i -> (testKey[i].toInt() xor part1[i].toInt()).toByte() }
        val enc = java.util.Base64.getEncoder()
        return Triple(
            enc.encodeToString(cipher),
            enc.encodeToString(part1),
            enc.encodeToString(part2)
        )
    }
    val blob = makeBlob(certHex)
    if (!ReaRepack.verifyExpectedHashBlob(blob.first, blob.second, blob.third, fakeCert)) {
        fail("encrypted cert-hash blob did not verify")
    }
    val wrongBlob = makeBlob("00".repeat(32))
    if (ReaRepack.verifyExpectedHashBlob(wrongBlob.first, wrongBlob.second, wrongBlob.third, fakeCert)) {
        fail("wrong-hash blob passed")
    }
    val tamperedBlob = Triple(
        blob.first.replaceRange(0, 1, if (blob.first[0] == 'A') "B" else "A"),
        blob.second, blob.third
    )
    if (ReaRepack.verifyExpectedHashBlob(tamperedBlob.first, tamperedBlob.second, tamperedBlob.third, fakeCert)) {
        fail("tampered blob passed")
    }
    if (ReaRepack.classifyInstaller("com.android.vending") != "play-store") {
        fail("Play installer misclassified")
    }
    if (ReaRepack.classifyInstaller(null) != "unknown") fail("null installer misclassified")
    if (ReaRepack.classifyInstaller("") != "unknown") fail("blank installer misclassified")
    if (ReaRepack.classifyInstaller("com.some.other.store") != "third-party-or-sideload") {
        fail("other installer misclassified")
    }
    println("REPACK-OK: package / cert hash / blob / installer")

    // (h) memoryEditorRisk levels.
    val (levelClean, sigClean) = ReaTrace.memoryEditorRisk(false, false, emptyList(), emptyList())
    if (levelClean != "none" || sigClean.isNotEmpty()) fail("clean risk=$levelClean $sigClean")
    val (levelRootOnly, _) = ReaTrace.memoryEditorRisk(true, false, emptyList(), emptyList())
    if (levelRootOnly != "none") fail("root alone raised risk to $levelRootOnly (must stay none)")
    val (levelTraced, sigTraced) = ReaTrace.memoryEditorRisk(false, true, emptyList(), emptyList())
    if (levelTraced != "high" || sigTraced != listOf("traced")) fail("traced risk=$levelTraced $sigTraced")
    val (levelCombo, sigCombo) = ReaTrace.memoryEditorRisk(true, true, listOf("gameguardian"), emptyList())
    if (levelCombo != "high" || sigCombo != listOf("root+traced", "root+maps:gameguardian")) {
        fail("root+trace+maps risk=$levelCombo $sigCombo")
    }
    val (levelFiles, sigFiles) = ReaTrace.memoryEditorRisk(false, false, emptyList(), listOf("/data/data/x"))
    if (levelFiles != "high") fail("files-only risk=$levelFiles")
    println("RISK-OK: clean none, root alone none, traced/maps/files high, root combo noted")

    println("TEST-PASS")
}

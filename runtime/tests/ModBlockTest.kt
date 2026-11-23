package com.antirea.runtime

/**
 * JVM test Main for ReaModBlock L101 (pure core only — no Context).
 *
 * Compile with android.jar on the kotlinc classpath (ReaModBlock.kt
 * imports android.* for its adapter functions, which this test never
 * calls), then run on a plain JVM:
 *   kotlinc -cp $ANDROID_JAR -d modblock-test.jar \
 *     ReaRuntime.kt ReaModBlock.kt ModBlockData.kt ModBlockTest.kt
 *   java -cp modblock-test.jar:$STDLIB com.antirea.runtime.ModBlockTestKt
 *
 * Checks:
 *   1. blockedPackages() decrypts all 13 entries, including
 *      bin.mt.plus, ru.maximoff.apktool, com.chelpus.lackypatch.
 *   2. findBlocked() flags listed packages in a fake installed set
 *      and does NOT flag benign apps (Chrome, Gmail).
 *   3. Empty set -> empty. Case differs -> not flagged (exact match).
 *   4. A renamed clone (bin.mt.plus.clone) is NOT flagged — the
 *      documented clone-evasion limit of a package-name check.
 * Any failure exits non-zero. Prints TEST-PASS on success.
 */
fun main() {
    fun fail(msg: String): Nothing {
        println("FAIL: $msg")
        kotlin.system.exitProcess(1)
    }

    // 1. All 13 blobs decrypt.
    val blocked = ReaModBlock.blockedPackages()
    if (blocked.size != 13) fail("blockedPackages() size=${blocked.size}, want 13")
    for (want in listOf("bin.mt.plus", "ru.maximoff.apktool", "com.chelpus.lackypatch")) {
        if (want !in blocked) fail("blockedPackages() missing $want")
    }
    println("DECRYPT-OK: 13 entries, incl. bin.mt.plus / ru.maximoff.apktool / com.chelpus.lackypatch")

    // 2. Listed packages flagged, benign apps not flagged.
    val found = ReaModBlock.findBlocked(
        setOf("bin.mt.plus", "com.android.chrome", "ru.maximoff.apktool", "com.google.android.gm")
    )
    if (found != listOf("bin.mt.plus", "ru.maximoff.apktool")) {
        fail("findBlocked() = $found, want [bin.mt.plus, ru.maximoff.apktool]")
    }
    println("BLOCK-OK: listed flagged, Chrome/Gmail not flagged")

    // 3. Empty set, case sensitivity.
    if (ReaModBlock.findBlocked(emptySet()).isNotEmpty()) fail("empty set flagged something")
    if (ReaModBlock.isPackageBlocked("BIN.MT.PLUS")) fail("uppercase name flagged (must be exact)")
    if (!ReaModBlock.isPackageBlocked("bin.mt.plus")) fail("bin.mt.plus not flagged")
    if (ReaModBlock.isPackageBlocked("com.android.chrome")) fail("Chrome flagged")
    println("EDGE-OK: empty set clean, exact-match only")

    // 4. Clone evasion (documented limit, not a bug in this test).
    if (ReaModBlock.isPackageBlocked("bin.mt.plus.clone")) {
        fail("clone name flagged — unexpected (list has no such entry)")
    }
    println("CLONE-LIMIT-OK: bin.mt.plus.clone NOT flagged (known L101 limit, see blocklist doc)")

    println("TEST-PASS")
}

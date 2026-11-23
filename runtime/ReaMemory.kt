package com.appcore.runtime

import java.security.MessageDigest
import java.security.SecureRandom

/**
 * Anti-REA L102 — in-memory value protection (ReaMemory).
 *
 * THE PROBLEM IT SOLVES (simple words, see docs/GAMEGUARDIAN.md):
 * GameGuardian finds a value by scanning RAM. It looks for the
 * number 100 (your points), finds every place in memory holding
 * 100, you spend 10 points, it looks again for 90, and after a few
 * rounds it knows exactly where your points live — then it WRITES
 * 99999 there. A plain `var points: Long = 100` in memory is a
 * sitting target: the number 100 is right there in RAM to find.
 *
 * WHAT THIS DOES: the value is NEVER stored as itself. It is stored
 * split into two random-looking parts (partA, partB) where
 * value = partA XOR partB, plus a checksum that only matches the
 * true value. In RAM, a memory scan for "100" finds NOTHING — there
 * is no 100 anywhere, only two random numbers and a checksum. Every
 * read recomputes the value and re-checks the checksum; on mismatch
 * (someone wrote into the memory) the read returns null instead of
 * a wrong number — it refuses, it never returns tampered data, and
 * it never crashes the app.
 *
 * HOW TO USE IT (example — a points balance):
 *   val points = ObfuscatedLong(100L)
 *   val current = points.get() ?: return // tampered — refuse the action
 *   points.set(current - 10)             // re-splits with fresh randomness
 *   if (!points.isIntact()) refuse()
 *
 * Pure Kotlin stdlib + JDK only, no Android imports, JVM-testable.
 * NOT a cure-all — honest limits, also in docs/GAMEGUARDIAN.md:
 *  - The plain value exists for a moment in a local variable during
 *    get()/set() — a determined root attacker watching that exact
 *    function (Frida hook on get, or a breakpoint) can still read
 *    it. What this stops is the plain memory SCAN and the blind
 *    WRITE: the attacker can no longer find the value by searching
 *    for the number, and writing garbage into the parts is detected
 *    by the checksum instead of silently working.
 *  - The split parts and the salt live in this object's fields. A
 *    full memory dump still contains them — but without knowing the
 *    scheme they are just random numbers, and the checksum means a
 *    changed value is caught, not accepted.
 *  - Fuzzy search still works against it in theory: GameGuardian
 *    can search for "unknown, then changed" values. If the attacker
 *    watches the value change across two reads, they can narrow
 *    down the parts. Re-splitting on every set() (fresh randomness
 *    each time) makes the parts move, so yesterday's address is
 *    useless today — but it is still not proof against a patient
 *    root attacker. The SERVER is the real defence: it must never
 *    trust a number the client reports (see docs/SERVER.md; Bridge
 *    already recomputes balances from its own ledger).
 */
object ReaMemory {

    private val random = SecureRandom()

    private fun randomLong(): Long {
        val b = ByteArray(8)
        random.nextBytes(b)
        var v = 0L
        for (x in b) v = (v shl 8) or (x.toLong() and 0xFF)
        return v
    }

    private fun randomInt(): Int {
        val b = ByteArray(4)
        random.nextBytes(b)
        var v = 0
        for (x in b) v = (v shl 8) or (x.toInt() and 0xFF)
        return v
    }

    private fun longToBytes(v: Long): ByteArray {
        val out = ByteArray(8)
        for (i in 0..7) out[i] = ((v ushr (56 - 8 * i)) and 0xFF).toByte()
        return out
    }

    private fun intToBytes(v: Int): ByteArray {
        val out = ByteArray(4)
        for (i in 0..3) out[i] = ((v ushr (24 - 8 * i)) and 0xFF).toByte()
        return out
    }

    /** First 8 bytes of SHA-256(salt || value), as a Long. */
    private fun checksumLong(value: Long, salt: Long): Long {
        val digest = MessageDigest.getInstance("SHA-256")
        digest.update(longToBytes(salt))
        digest.update(longToBytes(value))
        val hash = digest.digest()
        var v = 0L
        for (i in 0..7) v = (v shl 8) or (hash[i].toLong() and 0xFF)
        return v
    }

    /** First 8 bytes of SHA-256(salt || value), as a Long. */
    private fun checksumInt(value: Int, salt: Long): Long {
        val digest = MessageDigest.getInstance("SHA-256")
        digest.update(longToBytes(salt))
        digest.update(intToBytes(value))
        val hash = digest.digest()
        var v = 0L
        for (i in 0..7) v = (v shl 8) or (hash[i].toLong() and 0xFF)
        return v
    }

    /**
     * A Long that is never stored as itself in memory.
     * Stored: partA (random), partB = value XOR partA, salt (random),
     * check = checksum(value, salt). get() returns null on tamper.
     */
    class ObfuscatedLong(initial: Long) {
        private var partA: Long = 0L
        private var partB: Long = 0L
        private var salt: Long = 0L
        private var check: Long = 0L

        init {
            set(initial)
        }

        /** Store [value] with fresh randomness (parts move every time). */
        fun set(value: Long) {
            salt = randomLong()
            partA = randomLong()
            partB = value xor partA
            check = checksumLong(value, salt)
        }

        /** The value, or null when the stored parts were tampered with.
         *  Never returns a wrong value. Never throws on tamper. */
        fun get(): Long? {
            val value = partA xor partB
            return if (checksumLong(value, salt) == check) value else null
        }

        /** True only when get() would return a value. */
        fun isIntact(): Boolean = get() != null

        /**
         * TEST-ONLY: flip one bit of partA, simulating an attacker
         * writing into the app's memory. Production code must never
         * call this. It exists so the JVM test can prove a memory
         * write is detected instead of silently accepted.
         */
        fun corruptForTest() {
            partA = partA xor 1L
        }
    }

    /**
     * An Int that is never stored as itself in memory. Same scheme
     * as [ObfuscatedLong]: value = partA XOR partB, plus checksum.
     */
    class ObfuscatedInt(initial: Int) {
        private var partA: Int = 0
        private var partB: Int = 0
        private var salt: Long = 0L
        private var check: Long = 0L

        init {
            set(initial)
        }

        /** Store [value] with fresh randomness (parts move every time). */
        fun set(value: Int) {
            salt = randomLong()
            partA = randomInt()
            partB = value xor partA
            check = checksumInt(value, salt)
        }

        /** The value, or null when the stored parts were tampered with. */
        fun get(): Int? {
            val value = partA xor partB
            return if (checksumInt(value, salt) == check) value else null
        }

        /** True only when get() would return a value. */
        fun isIntact(): Boolean = get() != null

        /** TEST-ONLY: flip one bit of partA (simulated memory write). */
        fun corruptForTest() {
            partA = partA xor 1
        }
    }
}

package com.appcore.runtime

import java.io.File

/**
 * Anti-REA L102 — GameGuardian / runtime-memory-editor detection.
 *
 * WHAT GAMEGUARDIAN DOES (simple words, see docs/GAMEGUARDIAN.md):
 * it is a ROOT memory editor, not a decompiler. It does NOT read the
 * APK file. While the app RUNS, it scans the app's live memory (RAM)
 * for a value — for example points = 100 — then WRITES a new value
 * (points = 99999) into that memory, and it can DUMP the memory to a
 * file. Dump, run, write. That is exactly what the user asked about.
 * It works only through `ptrace` (the Linux call that lets one
 * process read and write another process's memory) — GameGuardian's
 * own author says so: "No other way. Only ptrace."
 * It NEEDS root (or a virtual-space app that runs the target inside
 * its own sandbox — see the docs for that gap).
 *
 * WHY A NAME BLOCKLIST CAN NEVER CATCH IT (L101 left it UNVERIFIED):
 * GameGuardian reinstalls itself with a RANDOM package name on every
 * install, on purpose, "to prevent detection by anti-cheats by
 * package name" (its own FAQ, docs.gameguardian.net/faq.html,
 * questions 9, 15, 16, 17). Its base name is
 * `catch_.me_.if_.you_.can_`, but the installed name is almost never
 * that. So this file detects GameGuardian by BEHAVIOUR, never by
 * package name:
 *   1. TracerPid — if another process is attached to us with ptrace,
 *      /proc/self/status says TracerPid != 0. GameGuardian MUST
 *      attach to search and write, so while it works on us this
 *      fires. (It attaches, searches, then detaches — between
 *      searches TracerPid is 0 again, so this is checked before
 *      every sensitive action, not once at startup.)
 *   2. /proc/self/stat state 't' — a traced process is stopped in
 *      state 't'. Second signal for the same fact.
 *   3. /proc/self/maps markers — named GameGuardian pieces
 *      ("gameguardian", "libgg", "bulldog-daemon", the base data
 *      name). A bare "gg" is DELIBERATELY not a marker: it matches
 *      innocent words ("logged", "suggest") and would false-positive
 *      constantly.
 *   4. Known GameGuardian data dirs (read-only File.exists) — only
 *      the two paths verified from GameGuardian's own site (see
 *      below). Weak on their own, because the random install renames
 *      them; strong only together with 1–3.
 *   5. Root — GameGuardian needs root. ReaEnv.isRooted() already
 *      checks that; the combined finding below says so explicitly.
 *
 * REFUSE-ONLY. Everything here returns findings (signals). Nothing
 * kills, deletes, executes `su`, or writes. Every file read catches
 * all exceptions and returns "not found" on error — a failed check
 * must never crash the app. A finding means the app refuses ONE
 * sensitive action while it is present.
 *
 * Honest limit (also in docs/GAMEGUARDIAN.md): a root memory editor
 * can NEVER be fully stopped from inside the app it is editing.
 * These checks catch it while it is attached and make plain-value
 * memory scans fail (see ReaMemory.kt), but a determined root
 * attacker who watches the decrypt/read function can still win.
 * The only real defence for money/points is the SERVER: it must
 * never trust a number the client reports — it recomputes from its
 * own ledger. Bridge already does this (ledger-based balances).
 */
object ReaTrace {

    // -- Markers -------------------------------------------------------

    /** Maps needles for GameGuardian pieces. Lowercase, substring
     *  match on the lowercased maps line. "gg" alone is NOT here. */
    val GG_MAPS_MARKERS: List<String> = listOf(
        "gameguardian",
        "libgg",
        "bulldog-daemon",
        "catch_.me_.if_.you_.can_"
    )

    /**
     * GameGuardian data directories, VERIFIED from GameGuardian's own
     * site — but WEAK, because the random reinstall renames them:
     *  - /data/data/com.catch_.me_.if_.you_.can_ — the BASE package
     *    name (official FAQ Q16: "This is the base name of the
     *    GameGuardian package").
     *  - /storage/emulated/0/Android/data/com.catch_.me_.if_.you_.can_
     *    — the install guide's path (Android > data >
     *    com.catch_.me_.if_.you_.can_ > cache > tmpe.apk is where the
     *    re-randomised installer lives).
     * A hit here is a signal, never proof. A miss proves nothing —
     * the random name is almost always different.
     * UNVERIFIED (listed in docs only, NOT checked here): any
     * "GG-xxxx" folder name — seen in GG daemon logs
     * (files/GG-bZcF, files/GG-ZwHX) but the suffix is random per
     * install, so no fixed path exists to check.
     */
    val GG_DATA_DIRS: List<String> = listOf(
        "/data/data/com.catch_.me_.if_.you_.can_",
        "/storage/emulated/0/Android/data/com.catch_.me_.if_.you_.can_"
    )

    // -- Pure parsers (JVM-testable, no file reads) --------------------

    /**
     * Parse TracerPid from /proc/self/status content.
     * Returns the pid (0 = not traced), or null when the line is
     * missing or malformed. Example line: "TracerPid:\t1234".
     */
    fun parseTracerPid(statusContent: String): Int? {
        for (rawLine in statusContent.lines()) {
            val line = rawLine.trim()
            if (!line.startsWith("TracerPid:")) continue
            val value = line.removePrefix("TracerPid:").trim()
            return value.toIntOrNull()
        }
        return null
    }

    /**
     * Parse the process state from /proc/self/stat content.
     * Format: "pid (comm) state ppid ..." — comm is in parentheses
     * and may itself contain spaces or parens, so the state is the
     * first field AFTER the last ')'. Returns e.g. 'R', 'S', 't',
     * or null when unparseable. State 't' = traced/stopped.
     */
    fun parseProcStatState(statContent: String): Char? {
        val close = statContent.lastIndexOf(')')
        if (close < 0) return null
        val rest = statContent.substring(close + 1).trim()
        if (rest.isEmpty()) return null
        return rest[0]
    }

    /** True when the process is being traced: TracerPid != 0, or
     *  /proc/self/stat state is 't'. Both inputs may be null
     *  (unreadable) — then this returns false, never throws. */
    fun isBeingTraced(statusContent: String?, statContent: String?): Boolean {
        val tracerPid = try {
            if (statusContent == null) null else parseTracerPid(statusContent)
        } catch (e: Exception) {
            null
        }
        if (tracerPid != null && tracerPid != 0) return true
        val state = try {
            if (statContent == null) null else parseProcStatState(statContent)
        } catch (e: Exception) {
            null
        }
        return state == 't'
    }

    /** Pure maps scan: which markers appear in the maps content
     *  (lowercase substring match, duplicates removed). */
    fun scanMapsForMarkers(mapsContent: String, markers: List<String> = GG_MAPS_MARKERS): List<String> {
        val hits = mutableListOf<String>()
        val lower = mapsContent.lowercase()
        for (m in markers) {
            if (lower.contains(m) && !hits.contains(m)) hits.add(m)
        }
        return hits
    }

    /** Pure directory check: which of [dirs] exist, using the
     *  caller-supplied [exists] function (so tests can fake it). */
    fun findExistingDirs(dirs: List<String>, exists: (String) -> Boolean): List<String> {
        val out = mutableListOf<String>()
        for (d in dirs) {
            try {
                if (exists(d)) out.add(d)
            } catch (e: Exception) {
                continue
            }
        }
        return out
    }

    // -- Live readers (read-only files, never throw) -------------------

    private fun readFileOrNull(path: String): String? {
        return try {
            val f = File(path)
            if (!f.canRead()) null else f.readText()
        } catch (e: Exception) {
            null
        }
    }

    /** Live TracerPid from /proc/self/status, or null when unreadable. */
    fun readTracerPid(): Int? {
        return try {
            val content = readFileOrNull("/proc/self/status") ?: return null
            parseTracerPid(content)
        } catch (e: Exception) {
            null
        }
    }

    /** Live traced check: TracerPid != 0 or stat state 't'. */
    fun isTraced(): Boolean = try {
        isBeingTraced(readFileOrNull("/proc/self/status"), readFileOrNull("/proc/self/stat"))
    } catch (e: Exception) {
        false
    }

    /** Live GameGuardian markers in this process's maps. */
    fun gameGuardianMapsHits(): List<String> = try {
        val maps = readFileOrNull("/proc/self/maps") ?: return emptyList()
        scanMapsForMarkers(maps)
    } catch (e: Exception) {
        emptyList()
    }

    /** Live GameGuardian data-dir hits (the two VERIFIED base paths). */
    fun gameGuardianFilesHits(): List<String> = try {
        findExistingDirs(GG_DATA_DIRS) { p ->
            try {
                File(p).exists()
            } catch (e: Exception) {
                false
            }
        }
    } catch (e: Exception) {
        emptyList()
    }

    /**
     * Combined memory-editor verdict for the app to gate on.
     * [rooted] should come from ReaEnv.isRooted().detected.
     * Returns a short level plus the signals that fired:
     *  - "high": traced right now, or a GG maps/files marker fired.
     *    When root is ALSO present, the evidence says so explicitly
     *    ("root+traced", "root+maps:…") — root + a memory-editor
     *    signal together is the strong combination, because
     *    GameGuardian NEEDS root to attach with ptrace.
     *  - "none": no memory-editor signal fired. Root ALONE does not
     *    raise this above "none": many legitimate devices are
     *    rooted, and ReaEnv already reports root separately. And
     *    "none" proves nothing — GG detaches between searches, so
     *    re-check before every sensitive action.
     */
    fun memoryEditorRisk(
        rooted: Boolean,
        traced: Boolean,
        mapsHits: List<String>,
        filesHits: List<String>
    ): Pair<String, List<String>> {
        val signals = mutableListOf<String>()
        if (traced) signals.add(if (rooted) "root+traced" else "traced")
        if (mapsHits.isNotEmpty()) {
            signals.add(if (rooted) "root+maps:${mapsHits.joinToString(",")}"
                        else "maps:${mapsHits.joinToString(",")}")
        }
        if (filesHits.isNotEmpty()) {
            signals.add(if (rooted) "root+files:${filesHits.joinToString(",")}"
                        else "files:${filesHits.joinToString(",")}")
        }
        val level = if (signals.isNotEmpty()) "high" else "none"
        return level to signals
    }
}

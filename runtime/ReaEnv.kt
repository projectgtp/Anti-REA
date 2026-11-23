package com.antirea.runtime

import android.os.Build
import android.os.Debug
import java.io.File

/**
 * Anti-REA v1.0 environment checks — Android-only.
 *
 * Every check is a pure function returning a [Finding]: a signal, not a
 * verdict. NOTHING here has side effects: no killing the app, no deleting
 * files, no network, no executing `su` or any other binary, no writing.
 * All file reads catch exceptions and return detected=false on error —
 * these checks must never crash the app.
 *
 * Honest limit: env checks are SIGNALS, not proof. An emulator marker
 * can appear on a real device (e.g. a test-keys build), root binaries can
 * exist without root being active, and a clean result does NOT prove the
 * device is uncompromised — Frida can hide itself. The app decides what
 * a finding means (refuse, degrade, report to the server); this file
 * only reports.
 */
object ReaEnv {

    /** One environment finding. `evidence` never contains secrets. */
    data class Finding(val name: String, val detected: Boolean, val evidence: String)

    /** Debugger attached (or waiting for one). */
    fun isDebuggerConnected(): Finding {
        val detected = try {
            Debug.isDebuggerConnected() || Debug.waitingForDebugger()
        } catch (e: Exception) {
            false
        }
        return Finding(
            name = "debugger",
            detected = detected,
            evidence = if (detected) "android.os.Debug reports a debugger" else "no debugger reported"
        )
    }

    /** Known emulator markers in Build fields. */
    fun isEmulator(): Finding {
        val markers = mutableListOf<String>()
        try {
            val fingerprint = Build.FINGERPRINT ?: ""
            val model = Build.MODEL ?: ""
            val hardware = Build.HARDWARE ?: ""
            val product = Build.PRODUCT ?: ""
            val brand = Build.BRAND ?: ""
            val device = Build.DEVICE ?: ""
            val combined = "$fingerprint $model $hardware $product $brand $device".lowercase()
            // Known emulator / SDK markers (substring match on the combined string).
            val known = listOf(
                "generic", "sdk", "emulator", "goldfish", "ranchu",
                "vbox86", "genymotion", "test-keys"
            )
            for (m in known) {
                if (combined.contains(m)) markers.add(m)
            }
            // google_sdk / sdk_gphone fingerprints are the classic emulator tell.
            if (fingerprint.startsWith("generic/") || fingerprint.contains("sdk_gphone")) {
                if (!markers.contains("generic")) markers.add("generic-fingerprint")
            }
        } catch (e: Exception) {
            return Finding("emulator", false, "check failed: ${e.javaClass.simpleName}")
        }
        return Finding(
            name = "emulator",
            detected = markers.isNotEmpty(),
            evidence = if (markers.isEmpty()) "no emulator markers in Build fields"
            else "emulator markers: ${markers.joinToString(",")}"
        )
    }

    /**
     * Root indicators: presence of `su` binaries in well-known paths and
     * test-keys in the build tags. This only READS (File.exists) — it
     * never executes `su`, never runs a shell command, never remounts.
     */
    fun isRooted(): Finding {
        val hits = mutableListOf<String>()
        try {
            if ((Build.TAGS ?: "").contains("test-keys")) hits.add("test-keys")
            val suPaths = listOf(
                "/system/bin/su", "/system/xbin/su", "/sbin/su",
                "/system/sd/xbin/su", "/system/bin/failsafe/su",
                "/data/local/xbin/su", "/data/local/bin/su",
                "/data/local/su", "/su/bin/su", "/system/app/Superuser.apk"
            )
            for (p in suPaths) {
                if (File(p).exists()) hits.add(p)
            }
        } catch (e: Exception) {
            return Finding("root", false, "check failed: ${e.javaClass.simpleName}")
        }
        return Finding(
            name = "root",
            detected = hits.isNotEmpty(),
            evidence = if (hits.isEmpty()) "no su binary or test-keys found"
            else "root indicators: ${hits.joinToString(",")}"
        )
    }

    /** Frida agent/gadget strings in this process's memory maps (read-only). */
    fun fridaMapsDetected(): Finding {
        val hits = readMapsHits(listOf("frida-agent", "frida-gadget", "linjector"))
        return Finding(
            name = "frida-maps",
            detected = hits.isNotEmpty(),
            evidence = if (hits.isEmpty()) "no frida strings in /proc/self/maps"
            else "frida strings in maps: ${hits.joinToString(",")}"
        )
    }

    /**
     * Frida default TCP ports 27042 / 27043 in LISTEN state, parsed from
     * /proc/net/tcp (and /proc/net/tcp6) — read-only file parsing, no
     * sockets opened, no connections attempted. Port numbers in
     * /proc/net/tcp are hex; 27042 = 0x699A, 27043 = 0x699B; state 0A = LISTEN.
     */
    fun fridaPortsDetected(): Finding {
        val ports = mutableListOf<String>()
        try {
            for (path in listOf("/proc/net/tcp", "/proc/net/tcp6")) {
                val file = File(path)
                if (!file.canRead()) continue
                for (line in file.readLines()) {
                    val parts = line.trim().split(Regex("\\s+"))
                    if (parts.size < 4) continue
                    val local = parts[1] // e.g. 0100007F:699A
                    val state = parts[3] // 0A = LISTEN
                    if (state != "0A") continue
                    val hexPort = local.substringAfter(":", "").uppercase()
                    if (hexPort == "699A") ports.add("27042")
                    if (hexPort == "699B") ports.add("27043")
                }
            }
        } catch (e: Exception) {
            return Finding("frida-ports", false, "check failed: ${e.javaClass.simpleName}")
        }
        return Finding(
            name = "frida-ports",
            detected = ports.isNotEmpty(),
            evidence = if (ports.isEmpty()) "frida ports 27042/27043 not listening"
            else "listening frida ports: ${ports.distinct().joinToString(",")}"
        )
    }

    /** Hook-framework libraries (Xposed / Substrate / EdXposed / LSPosed) in maps. */
    fun hookLibsDetected(): Finding {
        val hits = readMapsHits(listOf("xposed", "substrate", "edxposed", "lsposed", "riru"))
        return Finding(
            name = "hook-libs",
            detected = hits.isNotEmpty(),
            evidence = if (hits.isEmpty()) "no hook-framework libs in /proc/self/maps"
            else "hook libs in maps: ${hits.joinToString(",")}"
        )
    }

    // -- L102: GameGuardian / runtime-memory-editor signals -----------
    // Behaviour only — GameGuardian randomises its package name, so
    // no name check exists here. See ReaTrace.kt + docs/GAMEGUARDIAN.md.

    /** Traced right now (TracerPid != 0 or /proc/self/stat state 't').
     *  GameGuardian MUST attach with ptrace to search and write, so
     *  while it works on us this fires. Between searches it detaches
     *  and this goes quiet again — re-check before every sensitive
     *  action, not once at startup. */
    fun isBeingTraced(): Finding {
        val detected = try {
            ReaTrace.isTraced()
        } catch (e: Exception) {
            false
        }
        return Finding(
            name = "traced",
            detected = detected,
            evidence = if (detected) "TracerPid != 0 or proc state 't' — a tracer is attached"
            else "not traced (TracerPid 0, state not 't')"
        )
    }

    /** Named GameGuardian pieces in this process's maps. */
    fun gameGuardianMapsDetected(): Finding {
        val hits = try {
            ReaTrace.gameGuardianMapsHits()
        } catch (e: Exception) {
            emptyList()
        }
        return Finding(
            name = "gameguardian-maps",
            detected = hits.isNotEmpty(),
            evidence = if (hits.isEmpty()) "no gameguardian markers in /proc/self/maps"
            else "gameguardian markers in maps: ${hits.joinToString(",")}"
        )
    }

    /** GameGuardian data dirs (the two VERIFIED base paths only). */
    fun gameGuardianFilesDetected(): Finding {
        val hits = try {
            ReaTrace.gameGuardianFilesHits()
        } catch (e: Exception) {
            emptyList()
        }
        return Finding(
            name = "gameguardian-files",
            detected = hits.isNotEmpty(),
            evidence = if (hits.isEmpty()) "no gameguardian base data dirs present"
            else "gameguardian base data dirs: ${hits.joinToString(",")}"
        )
    }

    /**
     * Combined memory-editor verdict (L102): "high" when traced or a
     * GameGuardian maps/files marker fired (root noted explicitly
     * when also present); "none" otherwise. A "none" proves nothing
     * — GameGuardian detaches between searches.
     */
    fun memoryEditorDetected(): Finding {
        val (level, signals) = try {
            val rooted = isRooted().detected
            val traced = ReaTrace.isTraced()
            val maps = ReaTrace.gameGuardianMapsHits()
            val files = ReaTrace.gameGuardianFilesHits()
            ReaTrace.memoryEditorRisk(rooted, traced, maps, files)
        } catch (e: Exception) {
            return Finding("memory-editor", false, "check failed: ${e.javaClass.simpleName}")
        }
        return Finding(
            name = "memory-editor",
            detected = level == "high",
            evidence = if (signals.isEmpty()) "no memory-editor signals"
            else "memory-editor risk=$level: ${signals.joinToString("; ")}"
        )
    }

    /** Run every check. Order is fixed so output is stable. L102
     *  findings are appended after the original six, so existing
     *  output order is unchanged. */
    fun checkAll(): List<Finding> = listOf(
        isDebuggerConnected(),
        isEmulator(),
        isRooted(),
        fridaMapsDetected(),
        fridaPortsDetected(),
        hookLibsDetected(),
        isBeingTraced(),
        gameGuardianMapsDetected(),
        gameGuardianFilesDetected(),
        memoryEditorDetected()
    )

    /** Number of checks that fired. 0 does NOT prove a clean device. */
    fun suspiciousCount(): Int = checkAll().count { it.detected }

    /** Shared read-only /proc/self/maps scanner. Returns matched needles. */
    private fun readMapsHits(needles: List<String>): List<String> {
        val hits = mutableListOf<String>()
        try {
            val file = File("/proc/self/maps")
            if (!file.canRead()) return emptyList()
            for (line in file.readLines()) {
                val lower = line.lowercase()
                for (n in needles) {
                    if (lower.contains(n) && !hits.contains(n)) hits.add(n)
                }
            }
        } catch (e: Exception) {
            return emptyList()
        }
        return hits
    }
}

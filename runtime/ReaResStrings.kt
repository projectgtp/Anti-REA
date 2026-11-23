package com.antirea.runtime

/**
 * Anti-REA v1.0 — L06 resource-string runtime helper (finishes the
 * PARTIAL in v1.0: the CLI now encrypts sensitive res/values strings
 * into assets/antirea/res_strings.json and replaces the XML value
 * with the placeholder "antirea-encrypted:<name>").
 *
 * Same blob format as ReaRuntime (sha256(plain) || plain, XOR with
 * the 32-byte key reconstructed from two split parts; see
 * ReaRuntime.kt). Decryption happens in memory only; a tampered blob
 * throws IllegalStateException and decryptResource() never returns a
 * wrong value.
 *
 * HONEST LIMIT — Android loads res/values itself: getString(R.string.x)
 * returns the PLACEHOLDER, not the real value. There is no way for a
 * library to transparently intercept that. The app MUST call
 * ReaResStrings.decryptResource("x") explicitly wherever it needs a
 * sensitive resource string, and must load the JSON once at startup:
 *
 *     val json = assets.open("antirea/res_strings.json")
 *         .bufferedReader().readText()
 *     ReaResStrings.loadFromJson(json)
 *     val apiBase = ReaResStrings.decryptResource("api_base")
 *
 * Non-sensitive strings are untouched by the CLI and keep working
 * through getString() as normal. Pure Kotlin + JDK, no Android
 * imports, so JVM tests can use it directly.
 */
object ReaResStrings {

    /** One encrypted resource string, as written by the CLI. */
    data class Entry(
        val name: String,
        val blobB64: String,
        val keyPart1B64: String,
        val keyPart2B64: String,
        val plainSha256: String,
    )

    private val entries = LinkedHashMap<String, Entry>()

    /** Placeholder the CLI writes into res/values XML. */
    fun placeholder(name: String): String = "antirea-encrypted:$name"

    /** True when a value is an Anti-REA resource placeholder. */
    fun isPlaceholder(value: String): Boolean =
        value.startsWith("antirea-encrypted:")

    /** Register one entry (used by loadFromJson and by tests). */
    fun register(entry: Entry) {
        entries[entry.name] = entry
    }

    /** Names currently registered. */
    fun registeredNames(): List<String> = entries.keys.toList()

    /** Forget all registered entries (tests / re-load). */
    fun clear() {
        entries.clear()
    }

    /**
     * Decrypt one registered resource string by name. Throws
     * IllegalStateException when the name is unknown or the blob is
     * tampered with (hash mismatch inside ReaRuntime.decrypt, or the
     * stored plain_sha256 does not match the decrypted text).
     * Never returns a wrong value.
     */
    fun decryptResource(name: String): String {
        val entry = entries[name]
            ?: throw IllegalStateException(
                "Anti-REA: no encrypted resource registered for '$name'"
            )
        val plain = ReaRuntime.decrypt(
            entry.blobB64, entry.keyPart1B64, entry.keyPart2B64
        )
        if (!ReaRuntime.verifyText(plain, entry.plainSha256)) {
            throw IllegalStateException(
                "Anti-REA: resource '$name' failed plain_sha256 check"
            )
        }
        return plain
    }

    /**
     * Load entries from the JSON the CLI writes to
     * assets/antirea/res_strings.json:
     *   {"version": 1, "entries": [{"name": ..., "blob_b64": ...,
     *     "key_part1_b64": ..., "key_part2_b64": ...,
     *     "plain_sha256": ...}, ...]}
     * Minimal parser for exactly this shape (stdlib only, no JSON
     * library on the JVM path). Malformed input throws
     * IllegalArgumentException; a single bad entry is skipped, never
     * silently treated as a good one. Returns the number loaded.
     */
    fun loadFromJson(json: String): Int {
        val objectRe = Regex("""\{[^{}]*\}""")
        val fieldRe = Regex(""""([A-Za-z0-9_]+)"\s*:\s*"((?:[^"\\]|\\.)*)"""")
        var loaded = 0
        for (m in objectRe.findAll(json)) {
            val fields = mutableMapOf<String, String>()
            for (f in fieldRe.findAll(m.value)) {
                fields[f.groupValues[1]] = f.groupValues[2]
                    .replace("\\\"", "\"").replace("\\\\", "\\")
            }
            val name = fields["name"] ?: continue
            val blob = fields["blob_b64"] ?: continue
            val p1 = fields["key_part1_b64"] ?: continue
            val p2 = fields["key_part2_b64"] ?: continue
            val sha = fields["plain_sha256"] ?: continue
            register(Entry(name, blob, p1, p2, sha))
            loaded++
        }
        if (loaded == 0) {
            throw IllegalArgumentException(
                "Anti-REA: res_strings.json has no usable entries"
            )
        }
        return loaded
    }
}

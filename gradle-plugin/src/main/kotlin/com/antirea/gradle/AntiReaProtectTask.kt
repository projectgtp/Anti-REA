package com.antirea.gradle

import org.gradle.api.DefaultTask
import org.gradle.api.GradleException
import org.gradle.api.file.RegularFileProperty
import org.gradle.api.provider.Property
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.InputFile
import org.gradle.api.tasks.Optional
import org.gradle.api.tasks.OutputFile
import org.gradle.api.tasks.TaskAction

/**
 * Anti-REA Gradle plugin — layer L98. The task that runs the CLI.
 *
 * Runs `python3 anti-rea.py protect --apk <apk> --config <yaml>
 * --out <protected.apk> [...]` as a subprocess and FAILS THE BUILD
 * (GradleException) if anything goes wrong: missing CLI/config/APK, the
 * CLI exiting non-zero, or the CLI failing to start. There is no
 * "protect anyway / continue unprotected" path — fail-closed by design.
 *
 * The task does NOT modify the assembled APK in place; the protected APK
 * is a separate output file (default: app-release-protected.apk).
 */
abstract class AntiReaProtectTask : DefaultTask() {

    @get:InputFile
    abstract val cliScript: RegularFileProperty

    @get:InputFile
    abstract val config: RegularFileProperty

    @get:InputFile
    abstract val apk: RegularFileProperty

    @get:OutputFile
    abstract val outputApk: RegularFileProperty

    @get:Input
    abstract val profile: Property<String>

    @get:Input
    abstract val python: Property<String>

    @get:Input
    @get:Optional
    abstract val keystore: RegularFileProperty

    @get:Input
    @get:Optional
    abstract val keyAlias: Property<String>

    @get:Input
    abstract val enabled: Property<Boolean>

    @TaskAction
    fun protect() {
        if (!enabled.get()) {
            logger.lifecycle("[anti-rea] disabled (antiRea.enabled = false); skipping protection.")
            return
        }

        val cli = cliScript.get().asFile
        val cfg = config.get().asFile
        val input = apk.get().asFile
        val out = outputApk.get().asFile

        // Fail-closed: missing inputs fail the build before the CLI runs.
        try {
            AntiReaCommand.validateInputs(cli.isFile, cli.path, cfg.isFile, cfg.path, input.isFile, input.path)
        } catch (e: IllegalStateException) {
            throw GradleException(e.message, e)
        }

        val command = AntiReaCommand.buildCommand(
            python = python.get(),
            cliScript = cli.path,
            apk = input.path,
            config = cfg.path,
            out = out.path,
            profile = profile.get().ifBlank { null },
            keystore = if (keystore.isPresent) keystore.get().asFile.path else null,
            keyAlias = keyAlias.getOrElse("").ifBlank { null }
        )

        logger.lifecycle("[anti-rea] running: " + command.joinToString(" "))
        val exitCode = try {
            ProcessBuilder(command).inheritIO().start().waitFor()
        } catch (e: Exception) {
            throw GradleException("[anti-rea] could not start the CLI (${e.message}); build FAILED (fail-closed).", e)
        }

        // Fail-closed: a non-zero CLI exit fails the build. The
        // unprotected APK must never be mistaken for a protected one.
        try {
            AntiReaCommand.checkExitCode(exitCode, command)
        } catch (e: IllegalStateException) {
            throw GradleException(e.message + " Build FAILED (fail-closed).", e)
        }

        logger.lifecycle("[anti-rea] protected APK written to ${out.path}")
    }
}

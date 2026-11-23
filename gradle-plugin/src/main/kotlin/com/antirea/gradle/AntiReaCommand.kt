package com.antirea.gradle

/**
 * Anti-REA Gradle plugin — layer L98.
 *
 * Pure logic only: no Gradle API imports in this file, so it can be
 * unit-tested without a Gradle daemon (see gradle-plugin/tests/).
 * The Gradle-facing classes (AntiReaPlugin, AntiReaProtectTask) are thin
 * wrappers around these functions.
 *
 * Gradle APIs used by the wrappers (not here) come from the official
 * "Writing Plugins" guide:
 * https://docs.gradle.org/8.11-rc-2/userguide/writing_plugins.html
 * (Plugin<Project>, apply(), tasks.register(), lazy Property API).
 */
object AntiReaCommand {

    /** Default file names, resolved relative to the project directory. */
    const val DEFAULT_CONFIG_FILE_NAME = "anti-rea.yaml"
    const val DEFAULT_CLI_FILE_NAME = "anti-rea.py"

    /** The CLI is a Python script; the interpreter to run it with. */
    const val DEFAULT_PYTHON = "python3"

    /**
     * Conventional Android Gradle Plugin release-APK location.
     * This is only a default — set antiRea.apk explicitly if your build
     * puts the APK anywhere else (flavours, custom output dirs).
     */
    const val DEFAULT_APK_RELATIVE_PATH = "build/outputs/apk/release/app-release.apk"

    /** Name of the Gradle task this plugin registers. */
    const val TASK_NAME = "protectApk"

    /** Name of the assemble task the plugin hooks after (when it exists). */
    const val ASSEMBLE_TASK_NAME = "assembleRelease"

    /** Resolve the config path: explicit value wins, else <projectDir>/anti-rea.yaml. */
    fun resolveConfigPath(projectDir: String, configured: String?): String =
        configured?.takeIf { it.isNotBlank() } ?: "$projectDir/$DEFAULT_CONFIG_FILE_NAME"

    /** Resolve the CLI script path: explicit value wins, else <projectDir>/anti-rea.py. */
    fun resolveCliScriptPath(projectDir: String, configured: String?): String =
        configured?.takeIf { it.isNotBlank() } ?: "$projectDir/$DEFAULT_CLI_FILE_NAME"

    /** Resolve the input APK path: explicit value wins, else the AGP default. */
    fun resolveApkPath(projectDir: String, configured: String?): String =
        configured?.takeIf { it.isNotBlank() } ?: "$projectDir/$DEFAULT_APK_RELATIVE_PATH"

    /**
     * Default output path: the input name with "-protected" before ".apk",
     * e.g. app-release.apk -> app-release-protected.apk.
     * The original assembled APK is never overwritten in place.
     */
    fun defaultOutputPath(apkPath: String): String =
        if (apkPath.endsWith(".apk")) apkPath.removeSuffix(".apk") + "-protected.apk"
        else "$apkPath-protected.apk"

    /**
     * Build the exact command line for the Anti-REA CLI (v1.0).
     * Mirrors anti-rea.py's `protect` subcommand:
     *   python3 anti-rea.py protect --apk <apk> --config <yaml> --out <out>
     *       [--profile <name>] [--keystore <file> --key-alias <alias>]
     * Optional flags are appended only when a value is set.
     */
    fun buildCommand(
        python: String,
        cliScript: String,
        apk: String,
        config: String,
        out: String,
        profile: String?,
        keystore: String?,
        keyAlias: String?
    ): List<String> {
        val command = mutableListOf(
            python, cliScript, "protect",
            "--apk", apk,
            "--config", config,
            "--out", out
        )
        if (!profile.isNullOrBlank()) {
            command += "--profile"
            command += profile
        }
        if (!keystore.isNullOrBlank()) {
            command += "--keystore"
            command += keystore
        }
        if (!keyAlias.isNullOrBlank()) {
            command += "--key-alias"
            command += keyAlias
        }
        return command
    }

    /**
     * Fail-closed check on the paths the CLI needs. Returns nothing on
     * success; throws IllegalStateException naming every missing file.
     * The Gradle task converts this into a GradleException (build failure).
     */
    fun validateInputs(cliExists: Boolean, cliPath: String, configExists: Boolean, configPath: String, apkExists: Boolean, apkPath: String) {
        val missing = mutableListOf<String>()
        if (!cliExists) missing += "CLI script not found: $cliPath (copy anti-rea.py into the project or set antiRea.cliScript)"
        if (!configExists) missing += "config not found: $configPath (copy anti-rea.yaml into the project or set antiRea.config)"
        if (!apkExists) missing += "input APK not found: $apkPath (run the assemble task first, or set antiRea.apk)"
        if (missing.isNotEmpty()) {
            throw IllegalStateException("[anti-rea] cannot protect: " + missing.joinToString("; "))
        }
    }

    /**
     * Fail-closed check on the CLI exit code. Exit 0 passes; anything else
     * throws, so a failed protection can never silently pass the build.
     */
    fun checkExitCode(exitCode: Int, command: List<String>) {
        if (exitCode != 0) {
            throw IllegalStateException(
                "[anti-rea] protect failed with exit code $exitCode: " + command.joinToString(" ")
            )
        }
    }
}

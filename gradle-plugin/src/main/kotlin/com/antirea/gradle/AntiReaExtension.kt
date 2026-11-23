package com.antirea.gradle

import org.gradle.api.file.RegularFileProperty
import org.gradle.api.provider.Property

/**
 * Anti-REA Gradle plugin — layer L98. Extension (the `antiRea { }` block).
 *
 * Every property is a lazy Gradle Property / RegularFileProperty (see the
 * "lazy configuration" section of the official Writing Plugins guide:
 * https://docs.gradle.org/8.11-rc-2/userguide/writing_plugins.html).
 * Defaults are set by AntiReaPlugin from the project directory; anything
 * here can be overridden in the build script.
 */
abstract class AntiReaExtension {

    /** Path to the anti-rea.py CLI script. Default: <projectDir>/anti-rea.py */
    abstract val cliScript: RegularFileProperty

    /** Path to the anti-rea.yaml config. Default: <projectDir>/anti-rea.yaml */
    abstract val config: RegularFileProperty

    /**
     * Assembled APK to protect.
     * Default: <projectDir>/build/outputs/apk/release/app-release.apk
     * (the conventional AGP release output). Override for flavours or
     * custom output directories.
     */
    abstract val apk: RegularFileProperty

    /**
     * Where the protected APK is written.
     * Default: the input name with "-protected" before ".apk".
     * The input APK is never overwritten in place.
     */
    abstract val outputApk: RegularFileProperty

    /**
     * Layer profile (L96): "strict", "standard", "light", or a custom
     * profile name. Empty/absent = every IMPLEMENTED layer from the config.
     */
    abstract val profile: Property<String>

    /** Python interpreter used to run anti-rea.py. Default: "python3". */
    abstract val python: Property<String>

    /** Keystore for re-signing the protected APK (CLI --keystore). Optional. */
    abstract val keystore: RegularFileProperty

    /** Key alias for re-signing (CLI --key-alias). Optional. */
    abstract val keyAlias: Property<String>

    /**
     * Master switch. When false, protectApk logs a skip and succeeds.
     * Default: true. Fail-closed is the default; disabling is explicit.
     */
    abstract val enabled: Property<Boolean>
}

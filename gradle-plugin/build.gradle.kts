// Anti-REA Gradle plugin (L98) — the plugin project's own build file.
// NOT RUN in this VM: the Gradle daemon is broken here, so this file is
// written from the official Gradle docs and has never been executed.
// Verify on a working Gradle host with: ./gradlew build
// Docs: https://docs.gradle.org/8.11-rc-2/userguide/writing_plugins.html
//       https://docs.gradle.org/current/userguide/part1_gradle_init_plugin.html
plugins {
    `java-gradle-plugin`
    kotlin("jvm") version "1.9.24"
    `maven-publish`
}

repositories {
    gradlePluginPortal()
}

gradlePlugin {
    plugins {
        create("antiRea") {
            id = "com.antirea.gradle"
            implementationClass = "com.antirea.gradle.AntiReaPlugin"
            displayName = "Anti-REA Gradle plugin"
            description = "Runs the Anti-REA CLI (anti-rea.py protect) on the assembled release APK; fails the build if protection fails (L98)."
        }
    }
}

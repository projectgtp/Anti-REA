package com.antirea.gradle

import org.gradle.api.Plugin
import org.gradle.api.Project

/**
 * Anti-REA Gradle plugin — layer L98.
 *
 * Applies as `id("com.antirea.gradle")` and registers one task,
 * `protectApk`, which runs the Anti-REA CLI on the assembled release APK.
 *
 * How it hooks the Android build (deliberately conservative):
 * - The plugin does NOT depend on the Android Gradle Plugin API and does
 *   NOT guess variant/task internals. It only looks up the standard
 *   `assembleRelease` task by name after the project is evaluated
 *   (Project.afterEvaluate — see the official Writing Plugins guide:
 *   https://docs.gradle.org/8.11-rc-2/userguide/writing_plugins.html).
 * - If `assembleRelease` exists, it is wired with finalizedBy so
 *   `protectApk` runs after every release assemble. If it does not exist
 *   (non-Android project, or AGP applied later / different variant
 *   naming), the plugin only warns and leaves `protectApk` runnable by
 *   hand: `./gradlew protectApk`. It never fails configuration over this.
 * - The task itself is fail-closed: a failed protection fails the build.
 *
 * Plugin structure follows the official guide above: a class implementing
 * Plugin<Project>, apply() creating the extension and registering the task
 * with tasks.register() (configuration avoidance), and the `gradlePlugin {}`
 * block in build.gradle.kts giving the plugin its id.
 */
class AntiReaPlugin : Plugin<Project> {

    override fun apply(project: Project) {
        val extension = project.extensions.create("antiRea", AntiReaExtension::class.java)

        // Defaults, all overridable in the `antiRea { }` block.
        val projectDir = project.layout.projectDirectory
        extension.cliScript.convention(projectDir.file(AntiReaCommand.DEFAULT_CLI_FILE_NAME))
        extension.config.convention(projectDir.file(AntiReaCommand.DEFAULT_CONFIG_FILE_NAME))
        extension.apk.convention(projectDir.file(AntiReaCommand.DEFAULT_APK_RELATIVE_PATH))
        extension.outputApk.convention(
            extension.apk.map { apkFile ->
                projectDir.file(AntiReaCommand.defaultOutputPath(apkFile.asFile.path))
            }
        )
        extension.profile.convention("")
        extension.python.convention(AntiReaCommand.DEFAULT_PYTHON)
        extension.keyAlias.convention("")
        extension.enabled.convention(true)

        project.tasks.register(AntiReaCommand.TASK_NAME, AntiReaProtectTask::class.java) { task ->
            task.group = "anti-rea"
            task.description = "Protect the assembled release APK with Anti-REA (runs anti-rea.py protect; fails the build if protection fails)."
            task.cliScript.set(extension.cliScript)
            task.config.set(extension.config)
            task.apk.set(extension.apk)
            task.outputApk.set(extension.outputApk)
            task.profile.set(extension.profile)
            task.python.set(extension.python)
            task.keystore.set(extension.keystore)
            task.keyAlias.set(extension.keyAlias)
            task.enabled.set(extension.enabled)
        }

        project.afterEvaluate {
            val assemble = project.tasks.findByName(AntiReaCommand.ASSEMBLE_TASK_NAME)
            if (assemble != null) {
                assemble.finalizedBy(AntiReaCommand.TASK_NAME)
            } else {
                project.logger.warn(
                    "[anti-rea] task '${AntiReaCommand.ASSEMBLE_TASK_NAME}' not found; " +
                        "run './gradlew ${AntiReaCommand.TASK_NAME}' manually after assembling, " +
                        "or set antiRea.apk to your APK."
                )
            }
        }
    }
}

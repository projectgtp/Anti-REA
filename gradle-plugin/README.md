# Anti-REA Gradle plugin — layer L98

A Gradle plugin that runs the Anti-REA CLI on your assembled release APK
as part of the build, and **fails the build if protection fails**
(fail-closed). The unprotected APK is never passed off as protected.

## What it does

1. You run `./gradlew assembleRelease` (or any release assemble).
2. The plugin's `protectApk` task runs automatically right after it
   (`assembleRelease.finalizedBy("protectApk")`).
3. `protectApk` runs:
   `python3 anti-rea.py protect --apk <your APK> --config anti-rea.yaml --out <your APK>-protected.apk`
   (plus `--profile`, `--keystore`, `--key-alias` only when you set them).
4. If the CLI is missing, the config is missing, the APK is missing, the
   CLI cannot start, or the CLI exits non-zero, the task throws a
   `GradleException` and the build FAILS. There is no "continue
   unprotected" path.
5. The protected APK is a separate file (`app-release-protected.apk` by
   default). The assembled APK is never overwritten in place.

## How a developer adds it to their app

**Step 1 — copy the Anti-REA files into your app project:**

```
your-app/
  anti-rea.py        <- copy from the anti-rea v1.0 tree
  anti-rea.yaml      <- copy, then replace the example strings/patterns
                       with your app's real secrets (see anti-rea.yaml)
  build.gradle.kts   <- your app module build file
```

**Step 2 — apply the plugin.** The plugin is not published to the Gradle
Plugin Portal yet, so use it from source. The simplest route is
`buildSrc`: copy this whole `gradle-plugin/src/main/kotlin/` tree into
`your-app/buildSrc/src/main/kotlin/`, then in your app module's
`build.gradle.kts`:

```kotlin
plugins {
    id("com.android.application")
    id("com.antirea.gradle")
}

antiRea {
    // All of these are optional — the defaults are shown here.
    // cliScript = file("anti-rea.py")                 // default
    // config    = file("anti-rea.yaml")               // default
    // apk       = file("build/outputs/apk/release/app-release.apk") // default
    // outputApk = file("build/outputs/apk/release/app-release-protected.apk") // default
    // profile   = "standard"   // L96 profile; empty = every IMPLEMENTED layer
    // python    = "python3"
    // keystore  = file("release.jks")  // only if the CLI should re-sign
    // keyAlias  = "release"
    // enabled   = true         // false = skip protection (explicit only)
}
```

Then build as normal:

```
./gradlew assembleRelease
# ... assemble runs, then protectApk runs, then:
# build/outputs/apk/release/app-release-protected.apk
```

You can also run the task by hand after any assemble:

```
./gradlew protectApk
```

**Step 3 (standalone plugin project, optional)** — to build the plugin
as its own JAR instead of via `buildSrc`, use the `build.gradle.kts` and
`settings.gradle.kts` in this directory on a working Gradle host:

```
./gradlew build
```

## How the hook works (and what it deliberately does NOT do)

- The plugin does **not** depend on the Android Gradle Plugin API and
  does not guess variant internals. It only looks up the standard
  `assembleRelease` task by name after the project is evaluated
  (`Project.afterEvaluate`). If that task does not exist (non-Android
  project, different variant naming), the plugin warns and leaves
  `protectApk` runnable by hand — it never fails configuration over this.
- The task is a plain `DefaultTask` that runs the CLI as a subprocess
  with `ProcessBuilder`; the CLI does the protection, exactly as if you
  ran `python3 anti-rea.py protect ...` yourself.
- Flavours / custom output dirs: set `antiRea.apk` explicitly. The
  default input path is the conventional AGP release output,
  `build/outputs/apk/release/app-release.apk`.

## Files

| File | What it is |
|---|---|
| `src/main/kotlin/com/antirea/gradle/AntiReaPlugin.kt` | `Plugin<Project>`: creates the `antiRea` extension, registers `protectApk`, wires `assembleRelease.finalizedBy("protectApk")` |
| `src/main/kotlin/com/antirea/gradle/AntiReaExtension.kt` | The `antiRea { }` extension (all options, lazy `Property` API) |
| `src/main/kotlin/com/antirea/gradle/AntiReaProtectTask.kt` | The `protectApk` task: runs the CLI, throws `GradleException` on any failure |
| `src/main/kotlin/com/antirea/gradle/AntiReaCommand.kt` | Pure logic (no Gradle imports): path resolution, CLI command construction, fail-closed checks — the unit-testable core |
| `build.gradle.kts`, `settings.gradle.kts` | The plugin project's own build (standalone JAR route) |
| `tests/test_antirea_command.py` | Unit tests (stdlib only, no Gradle needed) |

## Tests

```bash
python3 tests/test_antirea_command.py
```

26 tests, stdlib `unittest` only: config resolution (defaults, overrides,
blank overrides), output-path rules, exact CLI command construction
(minimal, `--profile`, `--keystore`/`--key-alias`, and their absence),
failure handling (exit 1 / 127 → error, missing CLI/config/APK → error
naming every missing file), plus drift guards that read the Kotlin
sources and assert the constants and CLI argument words match the tested
Python mirror. Result here: **26 passed, 0 failed.**

## Honest status — read this before relying on it

- **Code written, NEVER RUN under Gradle in this VM.** The Gradle daemon
  is broken in this VM (verified earlier — the daemon was not retried and
  Gradle was not run at all for this layer, per the task rules).
- `kotlinc` is not installed in this VM either, so the Kotlin sources
  have **never been compiled**. They were written from the official Gradle
  docs cited below, and the pure logic is covered by the Python mirror
  tests — but the mirror tests prove the *logic*, not that the Kotlin
  compiles or that Gradle accepts the plugin.
- **Needs a working Gradle host to verify.** First verification steps
  there: `./gradlew build` in this directory, then apply the plugin to a
  real Android app, run `./gradlew assembleRelease`, and confirm (a) the
  protected APK appears, (b) a deliberately broken config fails the
  build, and (c) the unprotected APK is never shipped as protected.
- Until that verification passes, treat L98 as **code written, not
  proven**. The registry row stays PLANNED until the parent merges it
  after a real Gradle run.

## Sources (Gradle API — nothing guessed)

- Writing Plugins (plugin interface, `apply()`, `tasks.register()`,
  lazy `Property` API, `gradlePlugin {}` block):
  https://docs.gradle.org/8.11-rc-2/userguide/writing_plugins.html
- Developing Gradle Plugins tutorial (`java-gradle-plugin`,
  plugin id + implementation class):
  https://docs.gradle.org/current/userguide/part1_gradle_init_plugin.html
- Using Plugins (how a plugin is applied via the `plugins {}` block):
  https://docs.gradle.org/8.12-rc-1/userguide/plugins.html
- The CLI command this plugin shells out to is Anti-REA v1.0's own
  `protect` subcommand (`anti-rea.py`, same tree):
  `python3 anti-rea.py protect --apk <apk> --config <yaml> --out <out>
  [--profile <name>] [--keystore <file> --key-alias <alias>]`

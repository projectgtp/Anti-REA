#!/bin/bash
# Anti-REA v1.0 runtime — compile Kotlin -> jar -> dex -> smali.
#
# Usage:  bash build_smali.sh
#   (run heavy compiles through the big-tmp wrapper, never /tmp:
#    bash /home/hatch/tmp/_config/run-with-big-tmp.sh \
#      --job-name appcore-v10-runtime --kind general -- bash build_smali.sh)
#
# Toolchain (fixed paths, no new dependencies):
#   kotlinc  ~/workspace/tools/kotlin-2.0.21/bin/kotlinc
#   JDK 17   ~/workspace/tools/jdk17          (JAVA_HOME)
#   android.jar  ~/workspace/tools/android-sdk/platforms/android-36/android.jar
#   d8       ~/workspace/tools/bin/d8-36
#   baksmali ~/workspace/tools/bin/baksmali   (2.5.2)
#
# Outputs (all under this script's directory, ~/workspace/anti-rea/v1.0/runtime/):
#   build/runtime.jar   compiled runtime classes (jar)
#   build/classes.dex   d8 output (intermediate, kept for inspection)
#   smali/              baksmali output, package path com/appcore/runtime/
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="$SCRIPT_DIR"
TOOLS="$HOME/workspace/tools"

export JAVA_HOME="$TOOLS/jdk17"
export PATH="$JAVA_HOME/bin:$PATH"
KOTLINC="$TOOLS/kotlin-2.0.21/bin/kotlinc"
ANDROID_JAR="$TOOLS/android-sdk/platforms/android-36/android.jar"
D8="$TOOLS/bin/d8-36"
BAKSMALI="$TOOLS/bin/baksmali"

for f in "$KOTLINC" "$JAVA_HOME/bin/java" "$ANDROID_JAR" "$D8" "$BAKSMALI"; do
    [ -e "$f" ] || { echo "MISSING: $f" >&2; exit 1; }
done

BUILD_DIR="$RUNTIME_DIR/build"
SMALI_DIR="$RUNTIME_DIR/smali"
mkdir -p "$BUILD_DIR" "$SMALI_DIR"
rm -rf "$SMALI_DIR"
mkdir -p "$SMALI_DIR"

echo "== kotlinc: runtime sources -> build/runtime.jar =="
"$KOTLINC" -cp "$ANDROID_JAR" -d "$BUILD_DIR/runtime.jar" \
    "$RUNTIME_DIR/ReaRuntime.kt" \
    "$RUNTIME_DIR/ReaEnv.kt" \
    "$RUNTIME_DIR/ReaIntegrity.kt" \
    "$RUNTIME_DIR/ReaTraps.kt" \
    "$RUNTIME_DIR/ReaGuardProvider.kt" \
    "$RUNTIME_DIR/ReaModBlock.kt" \
    "$RUNTIME_DIR/ModBlockData.kt" \
    "$RUNTIME_DIR/ReaTrace.kt" \
    "$RUNTIME_DIR/ReaMemory.kt" \
    "$RUNTIME_DIR/ReaRepack.kt" \
    "$RUNTIME_DIR/ReaResStrings.kt" \
    "$RUNTIME_DIR/ReaIntegrity2.kt" \
    "$RUNTIME_DIR/ReaMethodDecrypt.kt" \
    "$RUNTIME_DIR/ReaMethodLoader.kt" \
    "$RUNTIME_DIR/ReaTimer.kt" \
    "$RUNTIME_DIR/ReaEnv2.kt" \
    "$RUNTIME_DIR/ReaNative.kt" \
    "$RUNTIME_DIR/ReaAssets.kt"
echo "jar: $(du -h "$BUILD_DIR/runtime.jar" | cut -f1)  sha256: $(sha256sum "$BUILD_DIR/runtime.jar" | cut -d' ' -f1)"

echo "== d8: runtime.jar -> build/classes.dex =="
"$D8" --lib "$ANDROID_JAR" --min-api 26 \
    --output "$BUILD_DIR" "$BUILD_DIR/runtime.jar"
[ -f "$BUILD_DIR/classes.dex" ] || { echo "d8 produced no classes.dex" >&2; exit 1; }
echo "dex: $(du -h "$BUILD_DIR/classes.dex" | cut -f1)"

echo "== baksmali: classes.dex -> smali/ =="
"$BAKSMALI" d "$BUILD_DIR/classes.dex" -o "$SMALI_DIR"
echo "smali files:"
find "$SMALI_DIR" -name '*.smali' | sort
echo "BUILD-OK: smali in $SMALI_DIR"

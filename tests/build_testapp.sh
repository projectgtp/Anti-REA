#!/usr/bin/env bash
# Anti-REA v1.0 — build the generic test app (NOT Bridge) with the
# Gradle-free chain: aapt2 + kotlinc + d8 + zipalign + apksigner.
# Gradle is known-broken in this VM (daemon failure), so it is not used.
# Signing uses a FRESH ephemeral test keystore in the job dir — never
# the Bridge stable key, never any production key.
# Usage:
#   bash /home/hatch/tmp/_config/run-with-big-tmp.sh \
#     --job-name antirea-v10-testapp --kind general -- \
#     bash tests/build_testapp.sh
# Output: tests/testapp/testapp-control.apk
# Exit 0 = APK produced and apksigner-verified. Anything else = failure.
set -euo pipefail

export JAVA_HOME="${JAVA_HOME:-$HOME/workspace/tools/jdk17}"
export PATH="$JAVA_HOME/bin:$HOME/workspace/tools/kotlin-2.0.21/bin:$HOME/workspace/tools/android-sdk/build-tools/36.0.0:$PATH"

TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$TESTS_DIR/testapp"
SDK="$HOME/workspace/tools/android-sdk"
ANDROID_JAR="$SDK/platforms/android-36/android.jar"
AAPT2="$SDK/build-tools/36.0.0/aapt2"
D8="$SDK/build-tools/36.0.0/d8"
ZIPALIGN="$SDK/build-tools/36.0.0/zipalign"
APKSIGNER="$SDK/build-tools/36.0.0/apksigner"
KOTLINC="$HOME/workspace/tools/kotlin-2.0.21/bin/kotlinc"
STDLIB="$HOME/workspace/tools/kotlin-2.0.21/lib/kotlin-stdlib.jar"

# JOBDIR is set by run-with-big-tmp.sh; fall back to a dir under
# /home/hatch/tmp (never /tmp, which is a 512 MB tmpfs).
JOBDIR="${JOBDIR:-$(mktemp -d /home/hatch/tmp/antirea-testapp-XXXXXX)}"
OUT_APK="$APP_DIR/testapp-control.apk"
mkdir -p "$JOBDIR"
echo "JOBDIR=$JOBDIR"
echo "OUT_APK=$OUT_APK"

for f in "$ANDROID_JAR" "$AAPT2" "$D8" "$ZIPALIGN" "$APKSIGNER" "$KOTLINC" "$STDLIB"; do
  [ -e "$f" ] || { echo "MISSING tool/lib: $f" >&2; exit 1; }
done
[ -f "$APP_DIR/AndroidManifest.xml" ] || { echo "MISSING manifest: $APP_DIR/AndroidManifest.xml" >&2; exit 1; }

cd "$APP_DIR"
rm -rf "$JOBDIR/compiled-res.zip" "$JOBDIR/gen" "$JOBDIR/classes" "$JOBDIR/dex" "$JOBDIR/app-unsigned.apk" "$JOBDIR/app-aligned.apk"
mkdir -p "$JOBDIR/gen" "$JOBDIR/classes" "$JOBDIR/dex"

echo "== aapt2 compile =="
"$AAPT2" compile --dir res -o "$JOBDIR/compiled-res.zip"

echo "== aapt2 link (generates R.java) =="
"$AAPT2" link -o "$JOBDIR/app-unsigned.apk" \
  --manifest AndroidManifest.xml \
  -I "$ANDROID_JAR" \
  --java "$JOBDIR/gen" \
  --auto-add-overlay \
  --min-sdk-version 26 --target-sdk-version 34 \
  "$JOBDIR/compiled-res.zip"

echo "== kotlinc (MainActivity.kt + R.java, Kotlin stdlib only) =="
find src/main/java -name '*.kt' > "$JOBDIR/sources.txt"
find "$JOBDIR/gen" -name '*.java' >> "$JOBDIR/sources.txt"
wc -l "$JOBDIR/sources.txt"
"$KOTLINC" -cp "$ANDROID_JAR" -d "$JOBDIR/classes" @"$JOBDIR/sources.txt"

echo "== jar classes (d8 rejects kotlinc's .kotlin_module files in a raw dir) =="
jar --create --file "$JOBDIR/classes.jar" -C "$JOBDIR/classes" .

echo "== d8 =="
"$D8" --lib "$ANDROID_JAR" --release --output "$JOBDIR/dex" \
  "$JOBDIR/classes.jar" "$STDLIB"

echo "== add classes.dex to apk =="
python3 - "$JOBDIR/app-unsigned.apk" "$JOBDIR/dex/classes.dex" <<'PYEOF'
import sys, zipfile
apk, dex = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(apk, 'a', zipfile.ZIP_DEFLATED) as z:
    z.write(dex, 'classes.dex')
print("classes.dex added")
PYEOF

echo "== zipalign =="
"$ZIPALIGN" -f 4 "$JOBDIR/app-unsigned.apk" "$JOBDIR/app-aligned.apk"

echo "== ephemeral test keystore + apksigner =="
keytool -genkeypair -keystore "$JOBDIR/test.keystore" -storepass android \
  -keypass android -alias antirea-test -keyalg RSA -keysize 2048 -validity 365 \
  -dname "CN=Anti-REA Test, OU=Test, O=Test, C=BD" -noprompt
"$APKSIGNER" sign --ks "$JOBDIR/test.keystore" --ks-pass pass:android \
  --key-pass pass:android --ks-key-alias antirea-test \
  --out "$OUT_APK" "$JOBDIR/app-aligned.apk"

echo "== apksigner verify =="
"$APKSIGNER" verify --verbose "$OUT_APK"
echo "== aapt dump badging =="
"$AAPT2" dump badging "$OUT_APK" | head -n 10
ls -l "$OUT_APK"
sha256sum "$OUT_APK"
echo "BUILD_OK"

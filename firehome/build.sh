#!/usr/bin/env bash
# Build the YouTube home without Gradle: aapt2, javac, d8, zipalign and apksigner from the Android SDK,
# nothing downloaded. Needs a JDK (17 works) and any build-tools and platform. Output: firehome/build/firehome.apk
set -euo pipefail
cd "$(dirname "$0")"
SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
[ -d "$SDK" ] || SDK="$HOME/Android/Sdk"
[ -d "$SDK" ] || SDK="${LOCALAPPDATA:-}/Android/Sdk"   # Android Studio's default on Windows (Git Bash)
[ -n "${JAVA_HOME:-}" ] && PATH="$JAVA_HOME/bin:$PATH"
BT="$(ls -d "$SDK"/build-tools/* | sort -V | tail -1)"
JAR="$(ls -d "$SDK"/platforms/android-* | sort -V | tail -1)/android.jar"
[ -x "$BT/aapt2" ] && [ -f "$JAR" ] || { echo "no Android SDK build-tools/platform under $SDK"; exit 1; }
# d8 and apksigner are .bat scripts in the Windows build-tools
D8="$BT/d8"; [ -f "$D8" ] || D8="$BT/d8.bat"
SIGN="$BT/apksigner"; [ -f "$SIGN" ] || SIGN="$BT/apksigner.bat"

rm -rf build && mkdir -p build/gen build/classes build/dex
"$BT/aapt2" compile --dir res -o build/res.zip
# minSdk 22 is Fire OS 5 (Android 5.1), the oldest Fire TV that still takes ADB from a computer
"$BT/aapt2" link -o build/unsigned.apk -I "$JAR" --manifest AndroidManifest.xml --java build/gen \
  --min-sdk-version 22 --target-sdk-version 22 --version-code 1 --version-name 1.0 build/res.zip
javac -nowarn --release 8 -classpath "$JAR" -d build/classes $(find src build/gen -name '*.java')
"$D8" --min-api 22 --lib "$JAR" --output build/dex $(find build/classes -name '*.class')
# jar comes with the JDK; Git Bash on Windows has no zip
jar uMf build/unsigned.apk -C build/dex classes.dex
"$BT/zipalign" -f 4 build/unsigned.apk build/aligned.apk

KS="$HOME/.android/debug.keystore"
[ -f "$KS" ] || keytool -genkeypair -keystore "$KS" -storepass android -alias androiddebugkey -keypass android \
  -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
"$SIGN" sign --ks "$KS" --ks-pass pass:android --key-pass pass:android --out build/firehome.apk build/aligned.apk
echo "built $(pwd)/build/firehome.apk ($(wc -c < build/firehome.apk | tr -d ' ') bytes)"

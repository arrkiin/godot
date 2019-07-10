#!/usr/bin/env bash
#
# This build script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/

set -euo pipefail
IFS=$'\n\t'

export ANDROID_NDK_ROOT=$ANDROID_HOME/ndk-bundle
export GODOT_DIR=$PWD

if [[ "$BUILD_TARGET" == "debug" ]]; then
  scons_target="release_debug"
else
  scons_target="release"
fi

# Build Android export template
for arch in "armv7" "arm64v8" "x86"; do
    scons platform=android tools=no target="$scons_target" android_arch="$arch" \
        "${SCONS_FLAGS[@]}" "${SCONS_TMPL_FLAGS[@]}"
done

# Create an APK and move it to the artifacts directory
cd "$GODOT_DIR/platform/android/java/"
./gradlew build
mv "$GODOT_DIR/bin/android_$BUILD_TARGET.apk" \
    "$BUILD_ARTIFACTSTAGINGDIRECTORY/templates/"
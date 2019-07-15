#!/usr/bin/env bash
#
# This build script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/

set -euo pipefail
IFS=$'\n\t'

# Build iOS export templates
# Compile only 64-bit ARM binaries, as all Apple devices supporting
# OpenGL ES 3.0 have 64-bit ARM processors anyway
# An empty `data.pck` file must be included in the export template ZIP as well
for target in "release_debug" "release"; do
  scons platform=iphone arch=arm64 tools=no target=$target \
        "${SCONS_FLAGS[@]}" "${SCONS_TMPL_FLAGS[@]}"
done

# Create iOS export templates ZIP archive
mv "bin/libgodot.iphone.opt.debug.arm64.a" "misc/dist/ios_xcode/libgodot.iphone.debug.fat.a"
mv "bin/libgodot.iphone.opt.arm64.a" "misc/dist/ios_xcode/libgodot.iphone.release.fat.a"
cd "misc/dist/ios_xcode"
zip -r9 "$BUILD_ARTIFACTSTAGINGDIRECTORY/templates/iphone.zip" *
#!/usr/bin/env bash
#
# This build script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/

set -euo pipefail
IFS=$'\n\t'

for target in "release_debug" "release"; do
  scons platform=iphone arch=x86_64 tools=no target=$target \
        "${SCONS_FLAGS[@]}" "${SCONS_TMPL_FLAGS[@]}"
done

# Create export templates ZIP archive
mv "bin/libgodot.iphone.opt.debug.x86_64.a" "libgodot.iphone.debug.fat.a"
mv "bin/libgodot.iphone.opt.x86_64.a" "libgodot.iphone.release.fat.a"
touch "data.pck"
zip -r9 \
    "$BUILD_ARTIFACTSTAGINGDIRECTORY/templates/simulator.zip" \
    "libgodot.iphone.debug.fat.a" \
    "libgodot.iphone.release.fat.a" \
    "data.pck"

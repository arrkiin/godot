#!/usr/bin/env bash
#
# This build script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/

set -euo pipefail
IFS=$'\n\t'

scons p=iphone tools=no target=release arch=arm "${SCONS_FLAGS[@]}" "${SCONS_TMPL_FLAGS[@]}"
scons p=iphone tools=no target=release arch=arm64 "${SCONS_FLAGS[@]}" "${SCONS_TMPL_FLAGS[@]}"
scons p=iphone tools=no target=release arch=x86_64 "${SCONS_FLAGS[@]}" "${SCONS_TMPL_FLAGS[@]}"
lipo -create bin/libgodot.iphone.opt.arm.a bin/libgodot.iphone.opt.arm64.a bin/libgodot.iphone.opt.x86_64.a -output bin/godot.iphone.opt.universal.simulator.a

# Create export templates ZIP archive
mv "bin/godot.iphone.opt.universal.simulator.a" "libgodot.iphone.universal.simulator.a"
touch "data.pck"
zip -r9 \
    "$BUILD_ARTIFACTSTAGINGDIRECTORY/templates/simulator.zip" \
    "libgodot.iphone.universal.simulator.a" \
    "data.pck"

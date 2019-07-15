#!/usr/bin/env bash
#
# This build script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/

set -euo pipefail
IFS=$'\n\t'

# Build Windows editor
scons platform=windows tools=yes target=release_debug \
      "${SCONS_FLAGS[@]}"

cd "bin/"
mv "godot.windows.opt.tools.64.exe" "godot.exe"
7z a -mx9 "godot-windows-nightly-64.zip" "godot.exe"

mv \
    "godot-windows-nightly-64.zip" \
    "$BUILD_ARTIFACTSTAGINGDIRECTORY/editor/godot-windows-nightly-64.zip" \

#!/usr/bin/env bash
#
# This build script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/

set -euo pipefail
IFS=$'\n\t'

choco install 7zip

pip install scons

mkdir -p \
    "$BUILD_ARTIFACTSTAGINGDIRECTORY/editor" \
    "$BUILD_ARTIFACTSTAGINGDIRECTORY/templates"

# Prepare submodules for integration
git submodule update --init --recursive
for module_dir in $(ls staging)
do
    cp -rv staging/$module_dir/$module_dir modules
done
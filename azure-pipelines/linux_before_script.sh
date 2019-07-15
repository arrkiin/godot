#!/usr/bin/env bash
#
# This build script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/

set -euo pipefail
IFS=$'\n\t'

# Install dependencies
sudo apt-get update -qq
sudo apt-get install -qqq software-properties-common
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt-get update -qq

sudo apt-get install -qqq git cmake zip unzip build-essential scons pkg-config \
    libx11-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev libcairo2 \
    libglu-dev libasound2-dev libpulse-dev libfreetype6-dev \
    libssl-dev libudev-dev libxrandr-dev libxi-dev curl yasm expect \
    gcc-8 g++-8

mkdir -p \
    "$BUILD_ARTIFACTSTAGINGDIRECTORY/editor" \
    "$BUILD_ARTIFACTSTAGINGDIRECTORY/templates" \
    "$BUILD_ARTIFACTSTAGINGDIRECTORY/server"

# Prepare submodules for integration
git submodule update --init --recursive
for module_dir in $(ls staging)
do
    cp -rv staging/$module_dir/$module_dir modules
done
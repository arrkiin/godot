#!/usr/bin/env bash
#
# This build script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/

set -euo pipefail
IFS=$'\n\t'

# Install dependencies and upgrade to Bash 4
brew update
brew install bash scons yasm
echo "$(brew --prefix)/bin/bash" | sudo tee -a /etc/shells
sudo chsh -s "$(brew --prefix)/bin/bash"
"$(brew --prefix)/bin/bash" -c "cd $PWD"

mkdir -p \
    "$BUILD_ARTIFACTSTAGINGDIRECTORY/editor" \
    "$BUILD_ARTIFACTSTAGINGDIRECTORY/templates"

# Prepare submodules for integration
git submodule update --init --recursive
for module_dir in $(ls staging)
do
    cp -rv staging/$module_dir/$module_dir modules
done

if [[ "$PLATFORM" == "iphone" ]] || [[ "$PLATFORM" == "simulator" ]]; then

    # Provide Admob iOS sdk
    mkdir -p tmp
    cd tmp
    curl -LO http://dl.google.com/googleadmobadssdk/googlemobileadssdkios.zip
    unzip googlemobileadssdkios.zip
    for sdk_dir in GoogleMobileAdsSdkiOS*/ ; do
        for lib_dir in ./$sdk_dir/*.framework; do
            cp -rv $lib_dir ../modules/admob/ios/lib
        done
    done
    cd ..

fi
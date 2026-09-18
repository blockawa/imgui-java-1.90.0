#!/bin/bash
set -e

echo "Setting base directory and navigating to project root..."
BASEDIR=$(dirname "$0")
cd "$BASEDIR"/../.. || exit 1
echo "Navigated to $(pwd)"

if [ -z "$1" ]; then
    echo "Vendor type is required"
    exit 1
fi

VTYPE=$1
echo "Vendor type set to '$VTYPE'"

export BUILD_FREETYPE_VERSION=2.13.3
LIBDIR=build/vendor/freetype

case "$VTYPE" in
    android-arm64)
        if [ -z "$ANDROID_NDK_HOME" ]; then
            echo "ANDROID_NDK_HOME is not set"
            exit 1
        fi

        TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64
        API=21
        TARGET=aarch64-linux-android
        CC=$TOOLCHAIN/bin/${TARGET}${API}-clang
        CXX=$TOOLCHAIN/bin/${TARGET}${API}-clang++

        echo "Cleaning and extracting FreeType source..."
        rm -rf $LIBDIR
        mkdir -p $LIBDIR
        tar -xzf ./vendor/freetype-$BUILD_FREETYPE_VERSION.tar.gz -C $LIBDIR --strip-components=1

        cd $LIBDIR

        echo "Cleaning previous CMake builds..."
        rm -rf build_android

        echo "Configuring FreeType with CMake..."
        cmake -B build_android \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_SYSTEM_NAME=Android \
            -DCMAKE_SYSTEM_VERSION=$API \
            -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a \
            -DCMAKE_C_COMPILER=$CC \
            -DCMAKE_CXX_COMPILER=$CXX \
            -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
            -DFT_DISABLE_BZIP2=ON \
            -DFT_DISABLE_BROTLI=ON \
            -DFT_DISABLE_HARFBUZZ=ON \
            -DFT_DISABLE_PNG=ON \
            -DFT_DISABLE_ZLIB=ON \
            .
        if [ $? -ne 0 ]; then
            echo "Failed to configure FreeType with CMake"
            exit 1
        fi

        echo "Building FreeType..."
        cmake --build build_android --config Release
        if [ $? -ne 0 ]; then
            echo "Failed to build FreeType"
            exit 1
        fi

        if [ ! -f build_android/libfreetype.a ]; then
            echo "File build_android/libfreetype.a not found!"
            exit 1
        fi

        mkdir -p lib
        cp build_android/libfreetype.a lib/
        echo "FreeType built successfully"

        ;;

    *)
        echo "Unknown vendor type: $VTYPE"
        exit 1
        ;;
esac

echo "Script completed successfully."

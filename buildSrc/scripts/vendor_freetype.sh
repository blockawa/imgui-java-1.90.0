#!/bin/bash

# Set base directory and navigate to project root
echo "Setting base directory and navigating to project root..."
BASEDIR=$(dirname "$0")
cd "$BASEDIR"/../.. || exit 1
echo "Navigated to $(pwd)"

# Check if vendor type argument is provided
if [ -z "$1" ]; then
    echo "Vendor type is required"
    exit 1
fi

VTYPE=$1
echo "Vendor type set to '$VTYPE'"

# Define library directory and version
LIBDIR=build/vendor/freetype
VERSION=2.13.3

# Clean and create library directory, then extract FreeType source
echo "Cleaning and creating library directory, then extracting FreeType source..."
rm -rf $LIBDIR
mkdir -p $LIBDIR
tar -xzf ./vendor/freetype-$VERSION.tar.gz -C $LIBDIR --strip-components=1
if [ $? -ne 0 ]; then
    echo "Failed to extract FreeType source"
    exit 1
fi
cd $LIBDIR || exit 1
echo "FreeType unzipped to $LIBDIR"

# Function to build FreeType using CMake (for cross-compilation targets like Android)
build_freetype_cmake() {
    cmake_flags=$1
    output_path=$2

    echo "Cleaning previous CMake builds..."
    rm -rf build_android

    echo "Configuring FreeType with CMake..."
    cmake -B build_android \
        -DCMAKE_BUILD_TYPE=Release \
        $cmake_flags \
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

    echo "Checking if the generated library exists..."
    if [ ! -f build_android/libfreetype.a ]; then
        echo "File build_android/libfreetype.a not found!"
        exit 1
    fi

    echo "Copying the generated library to $output_path..."
    cp build_android/libfreetype.a "$output_path"
    if [ $? -ne 0 ]; then
        echo "Failed to copy library to $output_path"
        exit 1
    fi
    echo "Library copied to $output_path"
}

# Ensure necessary directories exist
echo "Ensuring necessary directories exist..."
mkdir -p lib tmp

# Determine build process based on vendor type
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

        build_freetype_cmake "-DCMAKE_SYSTEM_NAME=Android \
            -DCMAKE_SYSTEM_VERSION=$API \
            -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a \
            -DCMAKE_C_COMPILER=$CC \
            -DCMAKE_CXX_COMPILER=$CXX \
            -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
            -DFT_DISABLE_BZIP2=ON \
            -DFT_DISABLE_BROTLI=ON \
            -DFT_DISABLE_HARFBUZZ=ON \
            -DFT_DISABLE_PNG=ON \
            -DFT_DISABLE_ZLIB=ON" "lib/libfreetype.a"
        ;;
    *)
        echo "Unknown vendor type: $VTYPE"
        exit 1
        ;;
esac

echo "Script completed successfully."

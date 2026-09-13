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

# Common configuration flags
COMMON_FLAGS="--enable-static --disable-shared --without-zlib --without-bzip2 --without-png --without-harfbuzz --without-brotli"

# Function to configure and build FreeType
build_freetype() {
    cflags=$1
    prefix=$2
    output_dir=$3

    echo "Cleaning previous builds..."
    make clean

    echo "Configuring FreeType with CFLAGS='$cflags' and PREFIX='$prefix'..."
    ./configure CFLAGS="$cflags" $COMMON_FLAGS $prefix
    if [ $? -ne 0 ]; then
        echo "Failed to configure FreeType"
        exit 1
    fi

    echo "Building FreeType..."
    make
    if [ $? -ne 0 ]; then
        echo "Failed to build FreeType"
        exit 1
    fi

    echo "Checking if the generated library exists..."
    if [ ! -f objs/.libs/libfreetype.a ]; then
        echo "File objs/.libs/libfreetype.a not found!"
        exit 1
    fi

    echo "Copying the generated library to $output_dir..."
    cp objs/.libs/libfreetype.a "$output_dir"
    if [ $? -ne 0 ]; then
        echo "Failed to copy library to $output_dir"
        exit 1
    fi
    echo "Library copied to $output_dir"
}

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
    windows)
        build_freetype "" "--host=x86_64-w64-mingw32 --prefix=/usr/x86_64-w64-mingw32" "lib/libfreetype.a"
        ;;
    linux)
        build_freetype "-fPIC" "" "lib/libfreetype.a"
        ;;
    macos)
        MACOS_VERSION=10.15

        build_freetype "-arch x86_64 -mmacosx-version-min=$MACOS_VERSION" "" "tmp/libfreetype-x86_64.a"
        build_freetype "-arch arm64 -mmacosx-version-min=$MACOS_VERSION" "" "tmp/libfreetype-arm64.a"

        echo "Creating universal library using lipo..."
        lipo -create -output lib/libfreetype.a tmp/libfreetype-x86_64.a tmp/libfreetype-arm64.a
        if [ $? -ne 0 ]; then
            echo "Failed to create universal library with lipo"
            exit 1
        fi
        echo "Universal library created at lib/libfreetype.a"
        ;;
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

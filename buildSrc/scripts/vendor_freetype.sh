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

        echo "Cleaning and extracting FreeType source..."
        rm -rf $LIBDIR
        mkdir -p $LIBDIR
        tar -xzf ./vendor/freetype-$BUILD_FREETYPE_VERSION.tar.gz -C $LIBDIR --strip-components=1
        cd $LIBDIR

        export CC
        ./configure \
            --host=$TARGET \
            --prefix=$(pwd)/install \
            --without-zlib \
            --with-brotli=no \
            --with-bzip2=no \
            --with-png=no \
            --with-harfbuzz=no \
            --enable-static=yes \
            --enable-shared=no

        make -j$(nproc)
        make install

        $TOOLCHAIN/bin/llvm-strip $(pwd)/install/lib/libfreetype.a

        mkdir -p ../../lib
        cp $(pwd)/install/lib/libfreetype.a ../../lib/
        echo "FreeType built successfully"
        ;;

    *)
        echo "Unknown vendor type: $VTYPE"
        exit 1
        ;;
esac

echo "Script completed successfully."

#!/bin/bash

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

# Make the vendor FreeType script executable and run it
echo "Making vendor FreeType script executable and running it..."
chmod +x buildSrc/scripts/vendor_freetype.sh
buildSrc/scripts/vendor_freetype.sh "$VTYPE"
if [ $? -ne 0 ]; then
    echo "Vendor FreeType script failed"
    exit 1
fi
echo "Vendor FreeType script completed successfully"

# Create the destination directory for imgui libraries
echo "Creating destination directory for imgui libraries..."
mkdir -p /tmp/imgui/dst
echo "Directory /tmp/imgui/dst created successfully"

# Function to check if a file exists
check_file_exists() {
    if [ ! -f "$1" ]; then
        echo "File $1 not found!"
        exit 1
    fi
}

# Determine build process based on vendor type
case "$VTYPE" in
    windows)
        echo "Running Gradle task for Windows..."
        ./gradlew imgui-binding:generateLibs -Denvs=windows -Dfreetype=true
        if [ $? -ne 0 ]; then
            echo "Gradle task for Windows failed"
            exit 1
        fi

        echo "Checking if the generated DLL exists..."
        check_file_exists /tmp/imgui/libsNative/windows64/imgui-java64.dll

        echo "Copying the generated DLL to the destination directory..."
        cp /tmp/imgui/libsNative/windows64/imgui-java64.dll /tmp/imgui/dst/imgui-java64.dll
        if [ $? -ne 0 ]; then
            echo "Failed to copy DLL to /tmp/imgui/dst/imgui-java64.dll"
            exit 1
        fi
        echo "DLL copied to /tmp/imgui/dst/imgui-java64.dll successfully"
        ;;
    linux)
        echo "Running Gradle task for Linux..."
        ./gradlew imgui-binding:generateLibs -Denvs=linux -Dfreetype=true
        if [ $? -ne 0 ]; then
            echo "Gradle task for Linux failed"
            exit 1
        fi

        echo "Checking if the generated SO file exists..."
        check_file_exists /tmp/imgui/libsNative/linux64/libimgui-java64.so

        echo "Copying the generated SO file to the destination directory..."
        cp /tmp/imgui/libsNative/linux64/libimgui-java64.so /tmp/imgui/dst/libimgui-java64.so
        if [ $? -ne 0 ]; then
            echo "Failed to copy SO file to /tmp/imgui/dst/libimgui-java64.so"
            exit 1
        fi
        echo "SO file copied to /tmp/imgui/dst/libimgui-java64.so successfully"
        ;;
    macos)
        echo "Running Gradle task for macOS and macOS ARM..."
        ./gradlew imgui-binding:generateLibs -Denvs=macos,macosarm64 -Dfreetype=true
        if [ $? -ne 0 ]; then
            echo "Gradle task for macOS failed"
            exit 1
        fi

        echo "Checking if the generated DYLIB files exist..."
        check_file_exists /tmp/imgui/libsNative/macosx64/libimgui-java64.dylib
        check_file_exists /tmp/imgui/libsNative/macosxarm64/libimgui-java64.dylib

        echo "Creating a universal library using lipo..."
        lipo -create -output /tmp/imgui/dst/libimgui-java64.dylib /tmp/imgui/libsNative/macosx64/libimgui-java64.dylib /tmp/imgui/libsNative/macosxarm64/libimgui-java64.dylib
        if [ $? -ne 0 ]; then
            echo "Failed to create universal library with lipo"
            exit 1
        fi
        echo "Universal library created at /tmp/imgui/dst/libimgui-java64.dylib successfully"
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

        CFLAGS="-fPIC -DIMGUI_ENABLE_FREETYPE -Ibuild/vendor/freetype/include"
        CXXFLAGS="$CFLAGS -std=c++17 -fno-exceptions -fno-rtti"
        LDFLAGS="-Wl,--gc-sections -shared -s -Lbuild/vendor/freetype/lib -lfreetype"

        JNI_DIR=/tmp/imgui/android-arm64-build/jni
        rm -rf /tmp/imgui/android-arm64-build
        mkdir -p $JNI_DIR

        echo "Generating JNI headers..."
        ./gradlew :imgui-binding:classes 2>/dev/null || true
        find imgui-binding/src/generated/java -name '*.java' > /tmp/java_sources.txt
        javac -h $JNI_DIR -sourcepath imgui-binding/src/generated/java:imgui-binding/src/main/java @/tmp/java_sources.txt 2>/dev/null || true

        echo "Copying ImGui source files..."
        cp include/imgui/*.h include/imgui/*.cpp $JNI_DIR/
        cp include/imnodes/*.h include/imnodes/*.cpp $JNI_DIR/
        cp include/imgui-node-editor/*.h include/imgui-node-editor/*.cpp include/imgui-node-editor/*.inl $JNI_DIR/
        cp include/imguizmo/*.h include/imguizmo/*.cpp $JNI_DIR/
        cp include/implot/*.h include/implot/*.cpp $JNI_DIR/
        cp include/ImGuiColorTextEdit/*.h include/ImGuiColorTextEdit/*.cpp $JNI_DIR/
        cp include/imgui_club/imgui_memory_editor/*.h $JNI_DIR/
        cp include/imgui-knobs/*.h include/imgui-knobs/*.cpp $JNI_DIR/
        cp imgui-binding/src/main/native/*.h imgui-binding/src/main/native/*.cpp $JNI_DIR/

        # Fix JNI includes: ensure JNI_VERSION_1_8 is always defined
        sed -i 's/#include "jni.h"/#include <jni.h>\n\n#ifndef JNI_VERSION_1_8\n#define JNI_VERSION_1_8 0x00010008\n#endif/g' $JNI_DIR/jni_jvm.h $JNI_DIR/jni_common.h

        mkdir -p $JNI_DIR/misc/freetype
        cp include/imgui/misc/freetype/*.h include/imgui/misc/freetype/*.cpp $JNI_DIR/misc/freetype/

        # Patch imgui_draw.cpp to use stb_truetype as default when freetype is enabled
        sed -i 's/ImGuiFreeType::GetFontLoader()/ImFontAtlasGetFontLoaderForStbTruetype()/g' $JNI_DIR/imgui_draw.cpp

        echo "Compiling JNI sources for Android arm64..."
        SRCS=$(find $JNI_DIR -maxdepth 1 \( -name '*.cpp' -o -name '*.c' \))
        FREETYPE_SRCS=$(find $JNI_DIR/misc/freetype -name '*.cpp' 2>/dev/null || true)

        for src in $SRCS $FREETYPE_SRCS; do
            $CXX $CXXFLAGS \
                -I$JNI_DIR \
                -Iimgui-binding/src/main/native \
                -c "$src" -o "${src%.cpp}.o" || {
                echo "Compilation failed: $src"
                exit 1
            }
        done

        echo "Linking shared library..."
        OBJS=$(find $JNI_DIR -name '*.o')
        mkdir -p /tmp/imgui/libsNative/android-arm64
        $CXX $LDFLAGS \
            $OBJS \
            -o /tmp/imgui/libsNative/android-arm64/libimgui-java64.so \
            -lm -llog -landroid || {
            echo "Linking failed"
            exit 1
        }

        if [ ! -f /tmp/imgui/libsNative/android-arm64/libimgui-java64.so ]; then
            echo "Android arm64 library not found!"
            exit 1
        fi

        echo "Copying Android arm64 library to destination..."
        cp /tmp/imgui/libsNative/android-arm64/libimgui-java64.so /tmp/imgui/dst/libimgui-java64.so
        echo "Android arm64 library built successfully"
        ;;
    *)
        echo "Unknown vendor type: $VTYPE"
        exit 1
        ;;
esac

echo "Script completed successfully."

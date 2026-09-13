#!/bin/bash

echo "Setting base directory and navigating to project root..."
BASEDIR=$(dirname "$0")
cd "$BASEDIR"/../.. || exit 1
echo "Navigated to $(pwd)"

chmod +x gradlew

if [ -z "$1" ]; then
    echo "Vendor type is required"
    exit 1
fi

VTYPE=$1
echo "Vendor type set to '$VTYPE'"

echo "Making vendor FreeType script executable and running it..."
chmod +x buildSrc/scripts/vendor_freetype.sh
buildSrc/scripts/vendor_freetype.sh "$VTYPE"
if [ $? -ne 0 ]; then
    echo "Vendor FreeType script failed"
    exit 1
fi
echo "Vendor FreeType script completed successfully"

echo "Creating destination directory for imgui libraries..."
mkdir -p /tmp/imgui/dst

check_file_exists() {
    if [ ! -f "$1" ]; then
        echo "File $1 not found!"
        exit 1
    fi
}

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

        CFLAGS="-fPIC -DIMGUI_ENABLE_FREETYPE -Ibuild/vendor/freetype/include"
        CXXFLAGS="$CFLAGS -std=c++17 -fno-exceptions -fno-rtti"
        LDFLAGS="-Wl,--gc-sections -shared -Lbuild/vendor/freetype/lib -lfreetype"

        JNI_DIR=/tmp/imgui/android-arm64-build/jni
        rm -rf /tmp/imgui/android-arm64-build
        mkdir -p $JNI_DIR

        echo "Generating JNI headers..."
        ./gradlew :imgui-binding:classes 2>/dev/null || true
        find imgui-binding/src/generated/java -name '*.java' > /tmp/java_sources.txt
        javac -h $JNI_DIR -sourcepath imgui-binding/src/generated/java:imgui-binding/src/main/java @/tmp/java_sources.txt 2>/dev/null || true

        echo "Applying vendor patches..."
        patch -p1 -d include/imgui-node-editor < patches/imgui-node-editor-imgui-1.92-operator-star.patch || true

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

        sed -i 's/#include "jni.h"/#include <jni.h>\n\n#ifndef JNI_VERSION_1_8\n#define JNI_VERSION_1_8 0x00010008\n#endif/g' $JNI_DIR/jni_jvm.h $JNI_DIR/jni_common.h

        mkdir -p $JNI_DIR/misc/freetype
        cp include/imgui/misc/freetype/*.h include/imgui/misc/freetype/*.cpp $JNI_DIR/misc/freetype/

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
            -o /tmp/imgui/libsNative/android-arm64/libimgui-moulberry90-java64.so \
            -lm -llog -landroid || {
            echo "Linking failed"
            exit 1
        }

        $TOOLCHAIN/bin/llvm-strip /tmp/imgui/libsNative/android-arm64/libimgui-moulberry90-java64.so

        if [ ! -f /tmp/imgui/libsNative/android-arm64/libimgui-moulberry90-java64.so ]; then
            echo "Android arm64 library not found!"
            exit 1
        fi

        echo "Copying Android arm64 library to destination..."
        cp /tmp/imgui/libsNative/android-arm64/libimgui-moulberry90-java64.so /tmp/imgui/dst/

        echo "Copying libc++_shared.so from NDK..."
        cp $TOOLCHAIN/aarch64-linux-android/lib/libc++_shared.so /tmp/imgui/dst/ 2>/dev/null || \
        cp $TOOLCHAIN/sysroot/usr/lib/aarch64-linux-android/libc++_shared.so /tmp/imgui/dst/ 2>/dev/null || {
            echo "WARNING: Could not find libc++_shared.so in NDK, searching..."
            find $ANDROID_NDK_HOME -name "libc++_shared.so" -path "*/aarch64*" | head -1 | xargs -I{} cp {} /tmp/imgui/dst/ || {
                echo "ERROR: Could not copy libc++_shared.so"
                exit 1
            }
        }

        echo "Android arm64 build completed successfully"
        echo "Output files:"
        ls -la /tmp/imgui/dst/
        ;;

    *)
        echo "Unknown vendor type: $VTYPE"
        exit 1
        ;;
esac

echo "Script completed successfully."

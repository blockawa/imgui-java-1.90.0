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
        LDFLAGS="-Wl,--gc-sections -shared -static-libstdc++ -Wl,--export-dynamic -Lbuild/vendor/freetype/lib -lfreetype"

        JNI_DIR=/tmp/imgui/android-arm64-build/jni
        rm -rf /tmp/imgui/android-arm64-build
        mkdir -p $JNI_DIR

        echo "Generating JNI C++ sources..."
        ./gradlew :imgui-binding:classes || {
            echo "ERROR: Gradle classes task failed"
            exit 1
        }
        ./gradlew :imgui-binding:generateJni -DjniOutputDir=$JNI_DIR || {
            echo "ERROR: NativeCodeGenerator failed"
            exit 1
        }
        echo "Generated JNI .cpp files:"
        ls $JNI_DIR/*.cpp 2>/dev/null | head -10

        echo "Applying vendor patches..."
        patch -p1 -d include/imgui-node-editor < patches/imgui-node-editor-imgui-1.92-operator-star.patch || true

        echo "Copying ImGui source files..."
        cp include/imgui/*.h include/imgui/*.cpp $JNI_DIR/
        cp include/imnodes/*.h include/imnodes/*.cpp $JNI_DIR/
        cp include/imgui-node-editor/*.h include/imgui-node-editor/*.cpp include/imgui-node-editor/*.inl $JNI_DIR/
        cp include/imguizmo/src/*.h include/imguizmo/src/*.cpp $JNI_DIR/ 2>/dev/null || true
        cp include/implot/*.h include/implot/*.cpp $JNI_DIR/
        cp include/ImGuiColorTextEdit/*.h include/ImGuiColorTextEdit/*.cpp $JNI_DIR/ 2>/dev/null || true
        cp include/imgui_club/imgui_memory_editor/*.h $JNI_DIR/
        cp include/imgui-knobs/*.h include/imgui-knobs/*.cpp $JNI_DIR/ 2>/dev/null || true
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

        $TOOLCHAIN/bin/llvm-strip --strip-debug /tmp/imgui/libsNative/android-arm64/libimgui-moulberry90-java64.so

        echo "Verifying JNI symbols..."
        JNI_COUNT=$($TOOLCHAIN/bin/llvm-nm -D /tmp/imgui/libsNative/android-arm64/libimgui-moulberry90-java64.so 2>/dev/null | grep -c "Java_" || true)
        echo "Found $JNI_COUNT Java_ symbols"
        if [ "$JNI_COUNT" -eq 0 ]; then
            echo "ERROR: No Java_ JNI symbols found! Build will fail on device."
            echo "All exported symbols:"
            $TOOLCHAIN/bin/llvm-nm -D /tmp/imgui/libsNative/android-arm64/libimgui-moulberry90-java64.so 2>/dev/null | head -20
            exit 1
        fi

        if [ ! -f /tmp/imgui/libsNative/android-arm64/libimgui-moulberry90-java64.so ]; then
            echo "Android arm64 library not found!"
            exit 1
        fi

        echo "Copying Android arm64 library to destination..."
        cp /tmp/imgui/libsNative/android-arm64/libimgui-moulberry90-java64.so /tmp/imgui/dst/

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

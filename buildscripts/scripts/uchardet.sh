#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

build=_build$ndk_suffix

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf $build
	exit 0
else
	exit 255
fi

abi=armeabi-v7a
[[ "$ndk_triple" == "aarch64"* ]] && abi=arm64-v8a
[[ "$ndk_triple" == "x86_64"* ]] && abi=x86_64
[[ "$ndk_triple" == "i686"* ]] && abi=x86

cmake_bin="$ANDROID_HOME/cmake/$v_cmake/bin/cmake"
ndk_dir="$ANDROID_HOME/ndk/$v_ndk"

# uchardet's CMakeLists predates CMake 4's policy floor, hence CMAKE_POLICY_VERSION_MINIMUM.
unset CC CXX
"$cmake_bin" -S . -B $build -G Ninja \
	-DCMAKE_TOOLCHAIN_FILE="$ndk_dir/build/cmake/android.toolchain.cmake" \
	-DANDROID_ABI=$abi -DANDROID_PLATFORM=android-$apilvl \
	-DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
	-DCMAKE_INSTALL_PREFIX=/ -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DBUILD_SHARED_LIBS=OFF -DBUILD_BINARY=OFF -DBUILD_STATIC=ON

ninja -C $build -j$cores
DESTDIR="$prefix_dir" ninja -C $build install

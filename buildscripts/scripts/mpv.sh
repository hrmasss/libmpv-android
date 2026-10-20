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

unset CC CXX # meson wants these unset

# Link GNU libiconv (built into the prefix) instead of bionic's: its iconv.h maps iconv_* to
# libiconv_*, so meson's iconv check and mpv both resolve to the static libiconv.a.
cat >"$prefix_dir/iconv.ini" <<ICONV
[built-in options]
c_args = ['-I$prefix_dir/include']
c_link_args = ['-L$prefix_dir/lib', '-liconv']
ICONV

meson setup $build --cross-file "$prefix_dir"/crossfile.txt --cross-file "$prefix_dir"/iconv.ini \
	--default-library shared \
	-Diconv=enabled -Duchardet=enabled -Dlua=enabled \
	-Dlibmpv=true -Dcplayer=false \
	-Dmanpage-build=disabled

ninja -C $build -j$cores
DESTDIR="$prefix_dir" ninja -C $build install

ln -sf "$prefix_dir"/lib/libmpv.so "$native_dir"

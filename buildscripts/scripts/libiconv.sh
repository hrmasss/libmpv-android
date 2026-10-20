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

# GNU libiconv: bionic's iconv only knows UTF-8/16/32, ASCII and Latin-1, so mpv's
# sub-codepage could not convert legacy subtitle encodings such as cp1250 or cp1251.
mkdir -p $build
cd $build

../configure \
	--host=$ndk_triple --with-pic \
	--enable-static --disable-shared --disable-nls

make -j$cores
make DESTDIR="$prefix_dir" install

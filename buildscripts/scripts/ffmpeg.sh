#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf _build$ndk_suffix
	exit 0
else
	exit 255
fi

mkdir -p _build$ndk_suffix
cd _build$ndk_suffix

cpu=armv7-a
[[ "$ndk_triple" == "aarch64"* ]] && cpu=armv8-a
[[ "$ndk_triple" == "x86_64"* ]] && cpu=generic
[[ "$ndk_triple" == "i686"* ]] && cpu="i686 --disable-asm"

cpuflags=

# Encoders: png and mjpeg only, for mpv screenshots (US-33.1); zlib is the NDK's.
# Filters the player uses through mpv's --vf/--af lavfi bridge. Everything else stays out to keep
# the APK small. Plumbing first, then video (flip, rotate, deinterlace, picture), then audio.
filters=(
	buffer buffersink abuffer abuffersink format aformat null anull scale aresample
	split asplit setpts asetpts trim atrim fps setsar setdar
	hflip vflip transpose rotate crop pad
	bwdif yadif w3fdif
	eq hue negate colorchannelmixer lutyuv unsharp gblur
	pan afade volume alimiter acompressor compand
	equalizer superequalizer bass treble highpass lowpass
	dynaudnorm loudnorm atempo asetrate channelmap channelsplit amerge
	extrastereo stereotools crossfeed earwax
)
filters=$(IFS=,; echo "${filters[*]}")
[[ "$ndk_triple" == "arm"* ]] && cpuflags="$cpuflags -mfpu=neon -mcpu=cortex-a8"

../configure \
	--target-os=android --enable-cross-compile --cross-prefix=$ndk_triple- --cc=$CC \
	--arch=${ndk_triple%%-*} --cpu=$cpu --pkg-config=pkg-config --nm=llvm-nm \
	--extra-cflags="-I$prefix_dir/include $cpuflags" --extra-ldflags="-L$prefix_dir/lib" \
	--enable-{jni,mediacodec,mbedtls,libdav1d,libxml2} --disable-vulkan \
	--disable-static --enable-shared --enable-{gpl,version3} \
	--disable-{stripping,doc,programs} \
	--disable-{muxers,encoders,devices,filters} \
	--enable-filter=$filters \
	--enable-encoder=png,mjpeg --enable-zlib \
	--disable-v4l2-m2m

make -j$cores
make DESTDIR="$prefix_dir" install

ln -sf "$prefix_dir"/lib/libswresample.so "$native_dir"
ln -sf "$prefix_dir"/lib/libpostproc.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavutil.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavcodec.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavformat.so "$native_dir"
ln -sf "$prefix_dir"/lib/libswscale.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavfilter.so "$native_dir"
ln -sf "$prefix_dir"/lib/libavdevice.so "$native_dir"

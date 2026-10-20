# libmpv for Android

Fork of [jarnedemeulemeester/libmpv-android](https://github.com/jarnedemeulemeester/libmpv-android),
itself based on [mpv-android](https://github.com/mpv-android/mpv-android).

Differences from upstream:

- FFmpeg keeps a chosen set of audio and video filters (list in `buildscripts/scripts/ffmpeg.sh`)
  instead of none, for mpv's `--vf`/`--af` lavfi filters.
- mpv is built with iconv (bionic, API 28+) and uchardet, so `sub-codepage` works.
- Native code targets API 29; the AAR's minSdk is 29.
- Releases are GitHub releases (AAR plus sha256), built by `.github/workflows/publish.yaml` on a
  `v*` tag. No Maven publishing.

## Building from source

Take a look at [README.md](buildscripts/README.md) inside the `buildscripts` directory.

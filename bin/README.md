# FFMPEG Build

Build on Ubuntu 14.04 64bit.
With this [compilation guide](https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu), and [this](http://ffmpeg.gusari.org/static/).

`The ffprobe bin file in this directory is without openssl/https support`

```
PATH="$PATH:$HOME/bin" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --bindir="$HOME/bin" \
  --disable-ffserver \
  --disable-doc \
  --enable-version3 \
  --enable-gpl \
  --enable-libfdk-aac \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-nonfree \
  --enable-openssl
```

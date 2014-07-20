# FFMPEG Build

Based on Ubuntu 14.04 64bit.
With this [compilation guide](https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu), [this](http://ffmpeg.gusari.org/static/) and [this](https://wiki.rvijay.in/index.php/Compiling_ffmpeg).

```
PATH="$HOME/bin:/usr/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --extra-cflags="-I$HOME/ffmpeg_build/include -I/usr/include/x86_64-linux-gnu/openssl -I/usr/include/openssl -static" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib -L/usr/lib/x86_64-linux-gnu -static" \
  --extra-libs="-lssl -lcrypto" \
  --bindir="$HOME/bin" \
  --enable-static \
  --disable-shared \
  --disable-ffserver \
  --disable-doc \
  --enable-version3 \
  --enable-bzlib \
  --enable-zlib \
  --enable-gpl \
  --enable-libfdk-aac \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-nonfree \
  --enable-openssl
```

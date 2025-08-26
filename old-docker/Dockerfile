FROM ubuntu:24.04

# install build tools
RUN apt-get update \
  && apt-get install -y --no-install-recommends software-properties-common gpg-agent \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64 mingw-w64-tools \
    lua5.2 libtool automake autoconf autopoint make gettext pkg-config \
    qtbase5-dev qt5-qmake git subversion cmake cvs \
    wine64-tools libwine-dev zip p7zip nsis bzip2 \
    yasm ragel ant default-jdk dos2unix \
    curl patch python3 \
    g++ gperf libltdl-dev meson nasm python-is-python3 unzip \
    bison flex \
    wine \
    wget \
  && apt-get --purge autoremove -y software-properties-common \
  && rm -rf /var/lib/apt/lists/*

# fetch player source code
RUN git clone --depth=1 https://github.com/MartinEesmaa/vlc-old-vvc.git

# build protoc
RUN cd /vlc-old-vvc/extras/tools \
  && chmod +x bootstrap \
  && ./bootstrap \
  && make .protoc

# bootstrap dependencies
RUN mkdir -p vlc-old-vvc/contrib/win32 \
  && cd vlc-old-vvc/contrib/win32 \
  && chmod +x ../bootstrap ../src/pkg-static.sh ../src/get-arch.sh ../src/gen-meson-crossfile.py \
  && ../bootstrap --host=x86_64-w64-mingw32 \
  && make fetch

# Set from WIN32 to POSIX to avoid error compiling issues
RUN update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix \
  && update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix

# build dependencies
RUN cd /vlc-old-vvc/contrib/win32 \
  && PATH=../../extras/tools/build/bin:$PATH make \
  && rm -f ../i686-w64-mingw32/bin/moc ../i686-w64-mingw32/bin/uic ../i686-w64-mingw32/bin/rcc \
  && ln -sf x86_64-w64-mingw32 ../i686-w64-mingw32

# avoid static linking to libssp
RUN rm /usr/lib/gcc/x86_64-w64-mingw32/*-posix/libssp.dll.a

# bootstrap and configure player
RUN cd /vlc-old-vvc \
  && ./bootstrap \
  && mkdir win32 \
  && cd win32 \
  && chmod +x ../extras/package/win32/configure.sh \ 
  && PKG_CONFIG_LIBDIR=/usr/local/lib/pkgconfig:/vlc-old-vvc/contrib/x86_64-w64-mingw32/lib/pkgconfig ../extras/package/win32/configure.sh --host=x86_64-w64-mingw32 --build=x86_64-pc-linux-gnu

# build player
RUN cd /vlc-old-vvc/win32 \
  && PATH=/vlc-old-vvc/extras/tools/build/bin:$PATH make -j`nproc`

# build package
RUN ln -sf /usr/include/wine/wine/windows /usr/include/wine/windows \
  && cd /vlc-old-vvc/win32 \
  && LIBVLC_CFLAGS=-I/vlc-old-vvc/win32/_win32/include LIBVLC_LIBS="-L/vlc-old-vvc/win32/_win32/lib -lvlc" make package-win-strip -j`nproc` \
  && cp /usr/lib/gcc/x86_64-w64-mingw32/*-posix/libgcc_s_seh-1.dll vlc-*/ \
  && cp /usr/lib/gcc/x86_64-w64-mingw32/*-posix/libstdc++-6.dll vlc-*/ \
  && cp /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll vlc-*/ \
  && make package-win32-zip

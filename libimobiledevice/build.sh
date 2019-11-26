#!/bin/bash

set -e;

if [ -z "$PREFIX" ]; then
    export PREFIX="$HOME/local/dist";
fi;

if [ -z "$SDK" ]; then
    export SDK='/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk';
fi;

if [ -z "$LIBTOOLIZE" ]; then
    export LIBTOOLIZE='glibtoolize';
fi;
if ! hash "$LIBTOOLIZE" &>/dev/null; then
    echo 'Failed to find (g)libtoolize. Please set LIBTOOLIZE env var.';
    exit 1;
fi;

targets=();
if [ "$#" == 0 ]; then
    targets=('libplist' 'libusbmuxd' 'libimobiledevice' 'libirecovery' 'libcrippy-1' 'libpartialzip-1' 'libgeneral' 'libfragmentzip' 'idevicerestore' 'ideviceinstaller' 'libideviceactivation');
else
    cflags=('-mmacosx-version-min=10.10' '-O3' "-I$PREFIX/include");
    cxxflags=('-mmacosx-version-min=10.10' '-O3' "-I$PREFIX/include");
    ldflags=("-L$PREFIX/lib");
    x="$1";
    shift;
    case "$x" in
        'gmp')
            dir="$PWD";
            mkdir -p "$PWD-build";
            cd "$PWD-build";
            "$dir/configure" --prefix="$PREFIX" --enable-static --disable-shared --disable-assembly PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}";
            make;
            make install;
            cd "$dir";
            ;;
        'nettle')
            dir="$PWD";
            mkdir -p "$PWD-build";
            cd "$PWD-build";
            "$dir/configure" --prefix="$PREFIX" --enable-static --disable-shared --enable-x86-aesni PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}";
            make;
            make install;
            cd "$dir";
            ;;
        'gnutls')
            dir="$PWD";
            mkdir -p "$PWD-build";
            cd "$PWD-build";
            "$dir/configure" --prefix="$PREFIX" --enable-static --disable-shared --disable-nls --without-p11-kit --enable-openssl-compatibility --with-included-unistring PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}";
            make;
            make install;
            cd "$dir";
            ;;
        'libgpg-error')
            dir="$PWD";
            mkdir -p "$PWD-build";
            cd "$PWD-build";
            "$dir/configure" --prefix="$PREFIX" --enable-static --disable-shared --disable-nls PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}";
            make;
            make install;
            cd "$dir";
            ;;
        'libtasn1'|'libgcrypt'|'libzip')
            dir="$PWD";
            mkdir -p "$PWD-build";
            cd "$PWD-build";
            "$dir/configure" --prefix="$PREFIX" --enable-static --disable-shared PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}";
            make;
            make install;
            cd "$dir";
            ;;
        *)
            targets+=("$x");
            ;;
    esac
fi;

if [ "${#targets[@]}" == 0 ]; then
    exit 0;
fi;

urls=('https://github.com/libimobiledevice/libplist.git' \
      'https://github.com/libimobiledevice/libusbmuxd.git' \
      'https://github.com/libimobiledevice/libimobiledevice.git' \
      'https://github.com/libimobiledevice/libirecovery.git' \
      'https://github.com/Siguza/libcrippy-1.git' \
      'https://github.com/Siguza/libpartialzip-1.git' \
      'https://github.com/tihmstar/libgeneral.git' \
      'https://github.com/tihmstar/libfragmentzip.git' \
      'https://github.com/libimobiledevice/idevicerestore.git' \
      'https://github.com/libimobiledevice/ideviceinstaller.git' \
      'https://github.com/libimobiledevice/libideviceactivation.git');
for x in "${urls[@]}"; do
    dir="$(basename "$x")";
    dir="${dir:0:${#dir}-4}";
    if ! [ -d "$dir" ]; then
        git clone "$x";
    fi;
done;

cd "$(dirname "$0")";
for target in "${targets[@]}"; do
    cd "$target";
    git fetch --all;
    git reset --hard origin/master;
    if [ "$target" == 'libfragmentzip' ] || [ "$target" == 'libgeneral' ]; then
        "$LIBTOOLIZE" --force;
        aclocal -I 'm4';
        autoconf;
        autoheader;
        automake -a -c;
        autoreconf -i;
    else
        NOCONFIGURE=1 ./autogen.sh;
    fi;
    cd ..;
    rm -rf "$target-build";
    mkdir "$target-build";
    cd "$target-build";
    flags=();
    cflags=('-mmacosx-version-min=10.10' '-O3' "-I$PREFIX/include");
    cxxflags=('-mmacosx-version-min=10.10' '-O3' "-I$PREFIX/include");
    ldflags=("-L$PREFIX/lib");
    if [ "$target" == 'libimobiledevice' ]; then
        flags+=('--disable-openssl');
        ldflags+=('-lgpg-error');
    elif [ "$target" == 'idevicerestore' ]; then
        cflags+=('-Dmutex_destroy=idr_mutex_destroy' '-Dthread_new=idr_thread_new' '-Dmutex_init=idr_mutex_init' '-Dthread_join=idr_thread_join' '-Dmutex_unlock=idr_mutex_unlock' '-Dmutex_lock=idr_mutex_lock' '-Dthread_alive=idr_thread_alive' '-Dthread_free=idr_thread_free' '-Dthread_once=idr_thread_once');
    elif [ "$target" == 'ideviceinstaller' ]; then
        cflags+=('-Wno-error=format' '-Wno-error=sign-compare' '-Wno-error=unused-command-line-argument');
    elif [ "$target" == 'libideviceactivation' ]; then
        export libxml2_CFLAGS="-I$SDK/usr/include/libxml2";
        export libxml2_LIBS="-lxml2";
    fi;
    "${PWD:0:${#PWD}-6}/configure" --prefix="$PREFIX" --enable-static --disable-shared "${flags[@]}" PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}";
    make -j16;
    make install;
    cd ..;
done;

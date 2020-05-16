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
    while [ "$#" -gt 0 ]; do
        x="$1";
        shift;
        case "$x" in
            'gmp'|'nettle'|'gnutls'|'libgpg-error'|'libtasn1'|'libgcrypt'|'libzip')
                cflags=('-mmacosx-version-min=10.10' '-O3' "-I$PREFIX/include");
                cxxflags=('-mmacosx-version-min=10.10' '-O3' "-I$PREFIX/include");
                ldflags=('-flto' '-Wl,-dead_strip' "-L$PREFIX/lib");
                dir="$(pwd)";
                mkdir -p "$dir-build";
                cd "$dir-build";
                case "$x" in
                    'gmp')
                        "$dir/configure" --prefix="$PREFIX" --enable-static --disable-shared --disable-assembly PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}";
                        ;;
                    'nettle')
                        "$dir/configure" --prefix="$PREFIX" --enable-static --disable-shared --enable-x86-aesni PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}";
                        ;;
                    'gnutls')
                        "$dir/configure" --prefix="$PREFIX" --enable-static --disable-shared --disable-nls --without-p11-kit --enable-openssl-compatibility --with-included-unistring PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}";
                        ;;
                    'libgpg-error')
                        "$dir/configure" --prefix="$PREFIX" --enable-static --disable-shared --disable-nls PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}";
                        ;;
                    'libtasn1'|'libgcrypt')
                        "$dir/configure" --prefix="$PREFIX" --enable-static --disable-shared PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}";
                        ;;
                    'libzip')
                        PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}" cmake -DCMAKE_INSTALL_PREFIX:PATH="$PREFIX" -DBUILD_SHARED_LIBS:BOOL=OFF "$dir";
                        ;;
                esac;
                make;
                make install;
                exit 0;
                ;;
            *)
                targets+=("$x");
                ;;
        esac;
    done;
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
    git clean -xdf;
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
    ldflags=('-flto' '-Wl,-dead_strip' "-L$PREFIX/lib");
    if [ "$target" == 'libimobiledevice' ]; then
        flags+=('--disable-openssl');
        ldflags+=('-lgpg-error');
    elif [ "$target" == 'idevicerestore' ]; then
        mkdir -p "__siguza/openssl";
        ln -s "$SDK/usr/include/CommonCrypto/CommonCrypto.h" '__siguza/openssl/sha.h';
        cflags+=("-I$(pwd)/__siguza" '-DCOMMON_DIGEST_FOR_OPENSSL=1' '-Dmutex_destroy=idr_mutex_destroy' '-Dthread_new=idr_thread_new' '-Dmutex_init=idr_mutex_init' '-Dthread_join=idr_thread_join' '-Dmutex_unlock=idr_mutex_unlock' '-Dmutex_lock=idr_mutex_lock' '-Dthread_alive=idr_thread_alive' '-Dthread_free=idr_thread_free' '-Dthread_once=idr_thread_once');
        ldflags+=('-lbz2');
    elif [ "$target" == 'ideviceinstaller' ]; then
        cflags+=('-Wno-error=format' '-Wno-error=sign-compare' '-Wno-error=unused-command-line-argument');
        ldflags+=('-lbz2');
    elif [ "$target" == 'libideviceactivation' ]; then
        export libxml2_CFLAGS="-I$SDK/usr/include/libxml2";
        export libxml2_LIBS="-lxml2";
    fi;
    "${PWD:0:${#PWD}-6}/configure" --prefix="$PREFIX" --enable-static --disable-shared "${flags[@]}" PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}";
    make -j16;
    make install;
    cd ..;
done;

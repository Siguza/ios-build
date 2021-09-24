#!/bin/bash

set -e;

pushd "$(dirname "$(dirname "$0")/$(readlink "$0")")" &>/dev/null;
repo="$(pwd)";
popd &>/dev/null;

arch="$(uname -m)";

if [ "$arch" = 'arm64' ] || [ "$arch" = 'arm64e' ]; then
    min='11.0';
    if [ -z "$USE_LIBRESSL" ]; then
        USE_LIBRESSL=true;
    fi;
else
    min='10.9';
    if [ -z "$USE_LIBRESSL" ]; then
        USE_LIBRESSL=false;
    fi;
fi;

if [ -z "$PREFIX" ]; then
    if [ "$arch" = 'arm64' ] || [ "$arch" = 'arm64e' ]; then
        export PREFIX="$HOME/Developer/local/dist";
    else
        export PREFIX="$HOME/local/dist";
    fi;
fi;

if [ -z "$BUILD_SHARED" ]; then
    BUILD_SHARED=false;
fi;

if $BUILD_SHARED; then
    gflags=('--enable-shared' '--disable-static');
    gcmflags=('-DBUILD_SHARED_LIBS:BOOL=ON');
else
    gflags=('--enable-static' '--disable-shared');
    gcmflags=('-DBUILD_SHARED_LIBS:BOOL=OFF');
fi;

if [ -z "$SDK" ]; then
    export SDK='/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk';
fi;

targets=();
if [ "$#" = 0 ]; then
    targets=('libplist' 'libimobiledevice-glue' 'libusbmuxd' 'libimobiledevice' 'libirecovery' 'idevicerestore' 'ideviceinstaller' 'libideviceactivation');
else
    while [ "$#" -gt 0 ]; do
        x="$1";
        shift;
        case "$x" in
            'gmp'|'nettle'|'gnutls'|'libgpg-error'|'libtasn1'|'libgcrypt'|'libzip')
                cflags=("-mmacosx-version-min=$min" '-O3' "-I$PREFIX/include");
                cxxflags=("-mmacosx-version-min=$min" '-O3' "-I$PREFIX/include");
                ldflags=('-flto' '-Wl,-dead_strip' "-L$PREFIX/lib");
                dir="$(pwd)";
                mkdir -p "$dir-build";
                cd "$dir-build";
                case "$x" in
                    'gmp')
                        "$dir/configure" --prefix="$PREFIX" "${gflags[@]}" --disable-assembly PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}";
                        ;;
                    'nettle')
                        "$dir/configure" --prefix="$PREFIX" "${gflags[@]}" --build=aarch64-apple-darwin20.1.0 --host=aarch64-apple-darwin20.1.0 --enable-x86-aesni PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}";
                        ;;
                    'gnutls')
                        "$dir/configure" --prefix="$PREFIX" "${gflags[@]}" --disable-nls --without-p11-kit --enable-openssl-compatibility --with-included-unistring PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}";
                        ;;
                    'libgpg-error')
                        "$dir/configure" --prefix="$PREFIX" "${gflags[@]}" --disable-nls PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}";
                        ;;
                    'libtasn1'|'libgcrypt')
                        "$dir/configure" --prefix="$PREFIX" "${gflags[@]}" PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}";
                        ;;
                    'libzip')
                        PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}" cmake -DCMAKE_INSTALL_PREFIX:PATH="$PREFIX" "${gcmflags[@]}" "$dir";
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

if [ "${#targets[@]}" = 0 ]; then
    exit 0;
fi;

urls=('https://github.com/libimobiledevice/libplist.git' \
      'https://github.com/libimobiledevice/libimobiledevice-glue.git' \
      'https://github.com/libimobiledevice/libusbmuxd.git' \
      'https://github.com/libimobiledevice/libimobiledevice.git' \
      'https://github.com/libimobiledevice/libirecovery.git' \
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
    NOCONFIGURE=1 ./autogen.sh;
    cd ..;
    rm -rf "$target-build";
    mkdir "$target-build";
    cd "$target-build";
    flags=();
    cflags=("-mmacosx-version-min=$min" '-O3' "-I$PREFIX/include");
    cxxflags=("-mmacosx-version-min=$min" '-O3' "-I$PREFIX/include");
    ldflags=('-flto' '-Wl,-dead_strip' "-L$PREFIX/lib");
    if $USE_LIBRESSL; then
        export openssl_CFLAGS="-I$repo/inc";
        export openssl_LIBS="-L$repo/lib -lssl.35 -lcrypto.35";
    fi;
    if [ "$target" = 'libplist' ]; then
        flags+=('--without-cython');
    elif [ "$target" = 'libimobiledevice' ]; then
        flags+=('--without-cython');
        if ! $USE_LIBRESSL; then
            flags+=('--disable-openssl');
            ldflags+=('-lgpg-error');
        fi;
    elif [ "$target" = 'idevicerestore' ]; then
        mkdir -p "__siguza/openssl";
        ln -s "$SDK/usr/include/CommonCrypto/CommonCrypto.h" '__siguza/openssl/sha.h';
        cflags+=("-I$(pwd)/__siguza" '-DCOMMON_DIGEST_FOR_OPENSSL=1');
        ldflags+=('-lbz2');
        export libcurl_CFLAGS="-I$SDK/usr/include";
        export libcurl_LIBS='-lcurl';
        export zlib_CFLAGS="-I$SDK/usr/include";
        export zlib_LIBS='-lz';
    elif [ "$target" = 'ideviceinstaller' ]; then
        cflags+=('-Wno-error=format' '-Wno-error=sign-compare' '-Wno-error=unused-command-line-argument');
        ldflags+=('-lbz2 -lz');
    elif [ "$target" = 'libideviceactivation' ]; then
        export libxml2_CFLAGS="-I$SDK/usr/include/libxml2";
        export libxml2_LIBS="-lxml2";
        export libcurl_CFLAGS="-I$SDK/usr/include";
        export libcurl_LIBS='-lcurl';
    fi;
    "${PWD:0:${#PWD}-6}/configure" --prefix="$PREFIX" "${gflags[@]}" "${flags[@]}" PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}";
    make -j16;
    make install;
    if [ "$target" = 'libimobiledevice' ] && $USE_LIBRESSL; then
        sed -i '' -E 's/ openssl >= [[:graph:]]+//' "$PREFIX/lib/pkgconfig/libimobiledevice-1.0.pc";
    fi;
    cd ..;
done;

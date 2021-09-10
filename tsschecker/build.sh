#!/bin/bash

set -e;

arch="$(uname -m)";

if [ "$arch" = 'arm64' ] || [ "$arch" = 'arm64e' ]; then
    min='11.0';
else
    min='10.9';
fi;

if [ -z "$PREFIX" ]; then
    if [ "$arch" = 'arm64' ] || [ "$arch" = 'arm64e' ]; then
        export PREFIX="$HOME/Developer/local/dist";
    else
        export PREFIX="$HOME/local/dist";
    fi;
fi;

if [ -z "$LIBTOOLIZE" ]; then
    export LIBTOOLIZE='glibtoolize';
fi;
if ! hash "$LIBTOOLIZE" &>/dev/null; then
    echo 'Failed to find (g)libtoolize. Please set LIBTOOLIZE env var.';
    exit 1;
fi;

if [ -z "$SDK" ]; then
    export SDK='/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk';
fi;

targets=();
if [ "$#" = 0 ]; then
    targets=('libgeneral' 'libfragmentzip' 'tsschecker');
else
    targets=("$@");
fi;

urls=('https://github.com/tihmstar/libgeneral.git' \
      'https://github.com/tihmstar/libfragmentzip.git' \
      'https://github.com/1Conan/tsschecker.git');
#      'https://github.com/tihmstar/tsschecker.git');
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
    git submodule update --init --recursive;
    if [ "$target" = 'libfragmentzip' ] || [ "$target" = 'libgeneral' ]; then
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
    cflags=("-mmacosx-version-min=$min" '-O3' "-I$PREFIX/include");
    cxxflags=("-mmacosx-version-min=$min" '-O3' "-I$PREFIX/include");
    ldflags=('-flto' '-Wl,-dead_strip' "-L$PREFIX/lib");
    if [ "$target" = 'libfragmentzip' ]; then
        export curl_CFLAGS="-I$SDK/usr/include";
        export curl_LIBS='-lcurl';
        export zlib_CFLAGS="-I$SDK/usr/include";
        export zlib_LIBS='-lz';
    elif [ "$target" = 'tsschecker' ]; then
        export libcurl_CFLAGS="-I$SDK/usr/include";
        export libcurl_LIBS='-lcurl';
        export zlib_CFLAGS="-I$SDK/usr/include";
        export zlib_LIBS='-lz';
    fi;
    "${PWD:0:${#PWD}-6}/configure" --prefix="$PREFIX" --enable-static --disable-shared "${flags[@]}" PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" CFLAGS="${cflags[*]}" CXXFLAGS="${cxxflags[*]}" LDFLAGS="${ldflags[*]}";
    make -j16;
    make install;
    if [ "$target" = 'libfragmentzip' ]; then
        sed -i '' -E 's/ libcurl >= [[:graph:]]+//;s/ zlib >= [[:graph:]]+//' "$PREFIX/lib/pkgconfig/libfragmentzip.pc";
    fi;
    cd ..;
done;

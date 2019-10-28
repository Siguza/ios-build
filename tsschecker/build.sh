#!/bin/bash

set -e;

if [ -z "$PREFIX" ]; then
    export PREFIX="$HOME/local/dist";
fi;

target='tsschecker';
cd "$(dirname "$0")";
basedir="$PWD";

cd "$basedir/$target";
NOCONFIGURE=1 ./autogen.sh;

cd "$basedir";
rm -rf "$basedir/$target-build";
mkdir -p "$basedir/$target-build";
cd "$basedir/$target-build";

"${PWD:0:${#PWD}-6}/configure" --prefix="$PREFIX" --enable-static --disable-shared PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$(pkg-config --variable pc_path pkg-config)";
make -j8;
make install;

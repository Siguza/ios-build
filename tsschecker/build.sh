#!/bin/bash

set -e;

target='tsschecker';
cd "$(dirname "$0")";
basedir="$PWD";

cd "$basedir/$target";
NOCONFIGURE=1 ./autogen.sh;

cd "$basedir";
rm -rf "$basedir/$target-build";
mkdir -p "$basedir/$target-build";
cd "$basedir/$target-build";

"${PWD:0:${#PWD}-6}/configure" --prefix="$HOME/local/dist" --enable-static --disable-shared PKG_CONFIG_PATH="$HOME/local/dist/lib/pkgconfig:$(pkg-config --variable pc_path pkg-config)";
make -j8;
make install;

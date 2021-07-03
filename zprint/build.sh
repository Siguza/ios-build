#!/bin/bash

set -e;

if [ $# -ne 1 ]; then
    echo "Usage: $0 path/to/zprint.tproj";
    exit 1;
fi;

src="$1";
aux="$(dirname "$0")";

if ! [ -e "$src/zprint.c" ]; then
    echo 'Cannot find zprint.c';
    exit 1;
fi;
if ! [ -e "$src/entitlements.plist" ]; then
    echo 'Cannot find entitlements.plist';
    exit 1;
fi;

if [ -z "${IOS_CC+x}" ]; then
    IOS_CC='xcrun -sdk iphoneos clang';
fi;
if [ -z "${IOS_SIGN+x}" ]; then
    IOS_SIGN='codesign -s - --entitlements';
fi;

set -v;
$IOS_CC -arch arm64 -o zprint -Wall -O3 -DKERNEL_PRIVATE=1 -I"$aux/inc" "$src/zprint.c" -F"$aux/lib" -framework CoreSymbolication -framework IOKit -framework CoreFoundation;
$IOS_SIGN "$src/entitlements.plist" zprint;

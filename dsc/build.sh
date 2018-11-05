#!/bin/bash

set -e;

if [ $# -ne 1 ]; then
    echo "Usage: $0 path/to/dyld-src";
    exit 1;
fi;

if [ -z "$GXX" ]; then
    GXX=g++;
fi;

in="$1/launch-cache";
out="$(dirname "$0")";

"$GXX" -Wall -O3 -flto -o "$out/dsc_extractor" "$in/dsc_extractor.cpp" "$in/dsc_iterator.cpp" -xobjective-c++ -- - <<EOF
#include <stdio.h>

extern "C" int dyld_shared_cache_extract_dylibs_progress(const char*, const char*, void (^)(unsigned, unsigned));

int main(int argc, const char **argv)
{
    if(argc != 3)
    {
        fprintf(stderr, "Usage: dsc_extractor <path-to-cache> <path-to-dir>\n");
        return 1;
    }
    int r = dyld_shared_cache_extract_dylibs_progress(argv[1], argv[2], ^(unsigned c, unsigned total) { printf("%d/%d\n", c, total); } );
    fprintf(stderr, "dyld_shared_cache_extract_dylibs_progress() => %d\n", r);
    return r;
}
EOF

found=false;
data='';
while read -r line; do
    data+="$line"$'\n';
    if [ "$line" == 'else if ( options.mode == modeExtract ) {' ]; then
        found=true;
        data+='return dyld_shared_cache_extract_dylibs(sharedCachePath, options.extractionDir); } else if(0) {'$'\n';
    fi;
done < "$in/dyld_shared_cache_util.cpp";
if ! "$found"; then
    echo 'Failed to find dsc_util extract codepath';
    exit 1;
fi;
"$GXX" -Wall -O3 -flto -I"$in/../dyld3/shared-cache" -o "$out/dsc_util" "$in/dsc_extractor.cpp" "$in/dsc_iterator.cpp" -I"$in" -xobjective-c++ -- - <<<"$data";

echo 'Success';

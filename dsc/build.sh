#!/bin/bash

set -e;

if [ $# -ne 1 ]; then
    echo "Usage: $0 path/to/dyld-src";
    exit 1;
fi;

in="$1/launch-cache";
out="$(dirname "$0")";

if [ -z "$GXX" ]; then
    GXX=g++;
fi;
GXXFLAGS=('-std=c++11' '-Wall' '-O3' '-flto' '-DSUPPORT_ARCH_arm64e=1' '-DSUPPORT_ARCH_arm64_32=1' "-I${out}/inc" "-I${in}" "-I${in}/../include" "-I${in}/../dyld3" "-I${in}/../dyld3/shared-cache" "-I${in}/../interlinked-dylibs");

found=false;
data='#include <string.h>';
while read -r; do
    if egrep -q '^\s*map\[dylibInfo->path\]\.push_back\(seg_info\(segInfo->name, segInfo->fileOffset, segInfo->fileSize\)\);$' <<<"$REPLY"; then
        found=true;
        data+='extern const char *siguza_filter;'$'\n';
        data+='if(!siguza_filter || strstr(dylibInfo->path, siguza_filter))'$'\n';
    fi;
    data+="$REPLY"$'\n';
done < "$in/dsc_extractor.cpp";
if ! "$found"; then
    echo 'Failed to find dsc_extractor block code';
    exit 1;
fi;

"$GXX" "${GXXFLAGS[@]}" -Wl,-interposable -o "$out/dsc_extractor" "$in/dsc_iterator.cpp" -xobjective-c++ -- - <<EOF
${data}

#include <stdio.h>

const char *siguza_filter = NULL;

int main(int argc, const char **argv)
{
    if(argc < 3 || argc > 4)
    {
        fprintf(stderr, "Usage: dsc_extractor <path-to-cache> <path-to-dir> [library-name]\n");
        return 1;
    }
    if(argc >= 4)
    {
        siguza_filter = argv[3];
    }
    int r = dyld_shared_cache_extract_dylibs_progress(argv[1], argv[2], ^(unsigned c, unsigned total) { printf("%d/%d\n", c, total); } );
    fprintf(stderr, "dyld_shared_cache_extract_dylibs_progress() => %d\n", r);
    return r;
}
EOF

found=false;
data='';
while read -r; do
    data+="$REPLY"$'\n';
    if egrep -q '^\s*else if \( options\.mode == modeExtract \) \{$' <<<"$REPLY"; then
        found=true;
        data+='return dyld_shared_cache_extract_dylibs(sharedCachePath, options.extractionDir); } else if(0) {'$'\n';
    fi;
done < "$in/dyld_shared_cache_util.cpp";
if ! "$found"; then
    echo 'Failed to find dsc_util extract codepath';
    exit 1;
fi;
files=();
for f in 'Diagnostics.cpp' 'MachOFile.cpp' 'MachOLoaded.cpp' "shared-cache/DyldSharedCache.cpp"; do
    f="${in}/../dyld3/$f";
    if [ -e "$f" ]; then
        files+=("$f");
    fi;
done;
"$GXX" "${GXXFLAGS[@]}" -o "$out/dsc_util" "$in/dsc_extractor.cpp" "$in/dsc_iterator.cpp" "${files[@]}" -xobjective-c++ -- - <<<"$data";

echo;
echo '[*] Success';

#!/bin/bash

set -e;

if [ $# -ne 1 ]; then
    echo "Usage: $0 path/to/dyld-src";
    exit 1;
fi;

std='c++17';
base="$1";
if [ -e "$base/launch-cache" ]; then
    in="$base/launch-cache";
else
    in="$base/dyld3/shared-cache";
fi;
out="$(dirname "$0")";

if [ -z "$GXX" ]; then
    GXX=clang++;
fi;
GXXFLAGS=("-std=${std}" '-Wall' '-O3' '-flto' '-DSUPPORT_ARCH_arm64e=1' '-DSUPPORT_ARCH_arm64_32=1' '-D__API_AVAILABLE_PLATFORM_bridgeos(x)=watchos,introduced=x' '-D__API_UNAVAILABLE_PLATFORM_bridgeos=bridgeos,unavailable' "-I${out}/inc" "-I${in}" "-I${base}/include" "-I${base}/dyld3" "-I${base}/dyld3/shared-cache" "-I${base}/interlinked-dylibs");

printf "\x1b[1;95m===== dsc_extractor =====\x1b[0m\n";

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
files=();
for f in 'Diagnostics.cpp' 'MachOFile.cpp' 'shared-cache/DyldSharedCache.cpp'; do
    file="${base}/dyld3/$f";
    if [ -e "$file" ]; then
        files+=("$file");
    fi;
done;

echo "$GXX" "${GXXFLAGS[@]}" -Wl,-interposable -o "$out/dsc_extractor" "$in/dsc_iterator.cpp" "${files[@]}" -xobjective-c++ ...;
"$GXX" "${GXXFLAGS[@]}" -Wl,-interposable -o "$out/dsc_extractor" "$in/dsc_iterator.cpp" "${files[@]}" -xobjective-c++ <(cat <<EOF
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
);

printf "\x1b[1;95m===== dsc_util =====\x1b[0m\n";

found=false;
data='extern "C" int dyld_shared_cache_extract_dylibs(const char*, const char*);';
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
for f in 'Closure.cpp' 'ClosureFileSystemPhysical.cpp' 'Diagnostics.cpp' 'MachOAnalyzer.cpp' 'MachOFile.cpp' 'MachOLoaded.cpp' 'shared-cache/DyldSharedCache.cpp'; do
    file="${base}/dyld3/$f";
    if [ -e "$file" ]; then
        files+=("$file");
    fi;
done;
echo "$GXX" "${GXXFLAGS[@]}" -o "$out/dsc_util" "$in/dsc_extractor.cpp" "$in/dsc_iterator.cpp" "${files[@]}" -xobjective-c++ ...;
"$GXX" "${GXXFLAGS[@]}" -o "$out/dsc_util" "$in/dsc_extractor.cpp" "$in/dsc_iterator.cpp" "${files[@]}" -xobjective-c++ <(echo "$data");

if [ -e "$base/dyld3/shared-cache/dyld_closure_util.cpp" ]; then
    printf "\x1b[1;95m===== dsc_closure =====\x1b[0m\n";

    files=();
    for f in 'Closure.cpp' 'ClosureBuffer.cpp' 'ClosureBuilder.cpp' 'ClosureFileSystemPhysical.cpp' 'ClosurePrinter.cpp' 'ClosureWriter.cpp' 'Diagnostics.cpp' 'DyldCacheParser.cpp' 'LaunchCacheReader.cpp' 'LaunchCachePrinter.cpp' 'LaunchCacheWriter.cpp' 'MachOAnalyzer.cpp' 'MachOAnalyzerSet.cpp' 'MachOFile.cpp' 'MachOLoaded.cpp' 'MachOParser.cpp' 'PathOverrides.cpp' 'RootsChecker.cpp' 'shared-cache/DyldSharedCache.cpp' 'shared-cache/FileUtils.cpp' 'shared-cache/ImageProxy.cpp'; do
        file="${base}/dyld3/$f";
        if [ -e "$file" ]; then
            files+=("$file");
        fi;
    done;
    echo "$GXX" "${GXXFLAGS[@]}" -o "$out/dsc_closure" "$base/dyld3/shared-cache/dyld_closure_util.cpp" "${files[@]}";
    "$GXX" "${GXXFLAGS[@]}" -o "$out/dsc_closure" "$base/dyld3/shared-cache/dyld_closure_util.cpp" "${files[@]}";
fi;

echo;
echo '[*] Success';

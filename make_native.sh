#!/bin/bash

set -eux

chromium_dir=~/devel/newgit-chromium/src
zlib_dir=$chromium_dir/third_party/zlib

mkdir -p out

files=""
for f in inflate.c inftrees.c inffast.c adler32.c crc32.c zutil.c \
         contrib/minizip/ioapi.c \
         contrib/minizip/miniunz.c \
         contrib/minizip/unzip.c \
         ; do
  files="$files $zlib_dir/$f"
done
cflags="-O2 -g -I$chromium_dir"

obj_files=""
for file in $files; do
  obj="out/$(basename $file).o"
  ccache gcc $cflags -c $file -o $obj
  obj_files="$obj_files $obj"
done

g++ $obj_files -lrt -o out/unzip

# Test

rm -rf tmp
mkdir -p tmp/test
cp $files tmp/test
(cd tmp/test && zip -r ../test.zip .)
./out/unzip -l tmp/test.zip
mkdir tmp/extract
./out/unzip tmp/test.zip -d tmp/extract
diff -r tmp/test tmp/extract

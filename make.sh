#!/bin/bash

set -eux

nacl_dir=~/devel/nacl-git3/native_client
chromium_dir=~/devel/newgit-chromium/src
zlib_dir=$chromium_dir/third_party/zlib

rm -rf out
mkdir -p out


# Build and run minsfi_test

cflags="-Wall -Werror"
pnacl-clang $cflags -c $nacl_dir/src/untrusted/nacl/lock.c -o out/lock.c.o
pnacl-clang $cflags -c untrusted_support.c -o out/untrusted_support.c.o
pnacl-clang $cflags -c minsfi_test.c -o out/minsfi_test.c.o
pnacl-ld -r out/lock.c.o out/untrusted_support.c.o out/minsfi_test.c.o -lc \
    -o out/minsfi_test.before.bc
./link_nonsfi_prog.sh out/minsfi_test.before.bc out/minsfi_test
./out/minsfi_test


# Build and run unzip_prog

files=""
for f in inflate.c inftrees.c inffast.c adler32.c crc32.c zutil.c \
         contrib/minizip/ioapi.c \
         contrib/minizip/miniunz.c \
         contrib/minizip/unzip.c \
         ; do
  files="$files $zlib_dir/$f"
done
files="$files $nacl_dir/src/untrusted/nacl/lock.c untrusted_support.c"

# USE_FILE32API tells ioapi.c not to use fopen64().
cflags="-g -Wall -I$chromium_dir -I$nacl_dir -DUSE_FILE32API"
obj_files=""
for file in $files; do
  obj="out/$(basename $file).o"
  pnacl-clang $cflags -c $file -o $obj
  obj_files="$obj_files $obj"
done

pnacl-ld -r $obj_files -lc -o out/unzip_prog.before.bc
./link_nonsfi_prog.sh out/unzip_prog.before.bc out/unzip_prog
./out/unzip_prog

# Test

rm -rf tmp
# Make a test zip file
mkdir -p tmp/test
cp ./out/unzip_prog untrusted_support.c tmp/test/
(cd tmp/test && zip -r ../test.zip .)
# Test listing contents
./out/unzip_prog -l tmp/test.zip
# Test extracting
rm -rf tmp/extract
mkdir tmp/extract
./out/unzip_prog tmp/test.zip -d tmp/extract
diff -r tmp/test tmp/extract

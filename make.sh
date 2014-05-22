#!/bin/bash

set -eux

nacl_dir=~/devel/nacl-git3/native_client
tc_bin=$nacl_dir/toolchain/pnacl_linux_x86/host_x86_64/bin
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
files="$files $nacl_dir/src/untrusted/nacl/lock.c untrusted_support.c"

# USE_FILE32API tells ioapi.c not to use fopen64().
cflags="-O2 -g -Wall -I$chromium_dir -I$nacl_dir -DUSE_FILE32API"
obj_files=""
for file in $files; do
  obj="out/$(basename $file).o"
  pnacl-clang $cflags -c $file -o $obj
  obj_files="$obj_files $obj"
done

pnacl-ld $obj_files -lc -o out/unzip_prog.before.bc
pnacl-opt \
    -pnacl-abi-simplify-preopt \
    -pnacl-abi-simplify-postopt \
    -expand-allocas -allocate-data-segment -sandbox-memory-accesses \
    out/unzip_prog.before.bc -o out/unzip_prog.bc
$tc_bin/llc -mtriple=x86_64-linux-gnu -relocation-model=pic -filetype=obj -O2 \
    out/unzip_prog.bc -o out/unzip_prog.o

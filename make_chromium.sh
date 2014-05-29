#!/bin/bash

set -eu

chromium_dir=..
nacl_dir=$chromium_dir/native_client
pnacl_bin=$chromium_dir/out/Release/gen/sdk/linux_x86/pnacl_newlib/bin

files="\
    untrusted_support.c
    $nacl_dir/src/untrusted/nacl/lock.c
    $nacl_dir/src/untrusted/nacl/random.c
    $nacl_dir/pnacl/support/bitcode/crtbegin.c
    $nacl_dir/pnacl/support/bitcode/pnaclmm.c
    $nacl_dir/pnacl/support/bitcode/unwind_stubs.c
    $chromium_dir/third_party/zlib/google/zip.cc
    $chromium_dir/third_party/zlib/google/zip_reader.cc
    $chromium_dir/third_party/zlib/google/zip_internal.cc
    chromium_unzip.cc"

zlib_dir=$chromium_dir/third_party/zlib
# Skip contrib/minizip/miniunz.c (defines a main())
for f in inflate.c inftrees.c inffast.c adler32.c crc32.c zutil.c \
         deflate.c trees.c \
         contrib/minizip/ioapi.c \
         contrib/minizip/unzip.c \
         contrib/minizip/zip.c \
         ; do
  files="$files $zlib_dir/$f"
done


mkdir -p out

cflags="-g -Wall -I$chromium_dir -DUSE_FILE32API
    -Wno-c++11-extensions -Wno-parentheses-equality"

obj_files=""
for file in $files; do
  echo compile $file
  obj="out/$(basename $file).o"
  $pnacl_bin/pnacl-clang $cflags -c $file -o $obj
  obj_files="$obj_files $obj"
done

echo link
$pnacl_bin/pnacl-ld -r $obj_files \
     $chromium_dir/out/Release/gen/tc_pnacl_newlib/lib/libbase_nacl.a \
     -lc++ \
     $chromium_dir/out/Release/gen/tc_pnacl_newlib/lib/libpthread.a \
     -lc -lm \
     $chromium_dir/out/Release/gen/tc_pnacl_newlib/lib/libnacl.a \
     -o out/chromium_unzip.before.bc
./link_nonsfi_prog.sh out/chromium_unzip.before.bc out/chromium_unzip

#!/bin/bash

set -eux

nacl_dir=~/devel/nacl-git3/native_client
tc_bin=$nacl_dir/toolchain/pnacl_linux_x86/host_x86_64/bin
chromium_dir=~/devel/newgit-chromium/src
zlib_dir=$chromium_dir/third_party/zlib

rm -rf out
mkdir -p out

# files=""
# for f in inflate.c inftrees.c inffast.c adler32.c crc32.c zutil.c \
#          contrib/minizip/ioapi.c \
#          contrib/minizip/miniunz.c \
#          contrib/minizip/unzip.c \
#          ; do
#   files="$files $zlib_dir/$f"
# done

files="minsfi_test.c"
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
# We run -globaldce to remove some dead code (-std-link-opts doesn't
# seem to work for that).
# Of the sandboxing passes, "-sandbox-indirect-calls" must come last.
# "-strip-debug" is currently required by "-sandbox-indirect-calls".
pnacl-opt \
    -strip-tls \
    -pnacl-abi-simplify-preopt \
    -globaldce \
    -pnacl-abi-simplify-postopt \
    -strip-debug \
    -expand-allocas -allocate-data-segment \
    -sandbox-memory-accesses -sandbox-indirect-calls \
    out/unzip_prog.before.bc -o out/unzip_prog.bc
$tc_bin/llc -mtriple=x86_64-linux-gnu -relocation-model=pic -filetype=obj \
    out/unzip_prog.bc -o out/unzip_prog.o
objcopy --redefine-sym _start=sandbox_entry out/unzip_prog.o out/unzip_prog.o
gcc -m64 -Wall -Werror trusted_runtime.c out/unzip_prog.o -o out/unzip_prog
./out/unzip_prog

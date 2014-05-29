#!/bin/bash

set -eu

if [ "$#" != 2 ]; then
  echo Usage: $0 input.o output_prog
  exit 1
fi

nacl_dir=~/devel/nacl-git3/native_client
tc_bin=$nacl_dir/toolchain/pnacl_linux_x86/host_x86_64/bin

input="$1"
output="$2"

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
    $input -o $output.bc
$tc_bin/llc -mtriple=x86_64-linux-gnu -relocation-model=pic -filetype=obj \
    $output.bc -o $output.o
objcopy --redefine-sym _start=sandbox_entry $output.o $output.o
gcc -g -m64 -Wall -Werror trusted_runtime.c $output.o -o $output

#!/bin/sh
#/opt/ace/bin/clang++ -static-libstdc++ -isystem /opt/ace/sys/linux/x86-64-v3/include/c++/v1 -L /opt/ace/sys/linux/x86-64-v3/lib \
# -Xclang -ast-dump
/opt/ace/build/llvm-linux-x86-64-v3-debug/bin/clang++ \
  -std=c++26 -fno-rtti -fno-exceptions -DNDEBUG \
  -o /opt/ace/build/llvm-linux-x86-64-v3-debug/test \
  /opt/ace/src/unwrap/test.cpp || exit 1
/opt/ace/build/llvm-linux-x86-64-v3-debug/test
echo $?

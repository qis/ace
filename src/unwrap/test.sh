#!/bin/sh
/opt/ace/build/llvm-linux-x86-64-v3-debug/bin/clang++ \
  -std=c++26 -fno-rtti -fno-exceptions -o \
  /opt/ace/build/llvm-linux-x86-64-v3-debug/test \
  /opt/ace/src/unwrap/test.cpp || exit 1
/opt/ace/build/llvm-linux-x86-64-v3-debug/test
echo $?

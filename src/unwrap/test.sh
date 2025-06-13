#!/bin/sh
#/opt/ace/bin/clang++ -static-libstdc++ -isystem /opt/ace/sys/linux/x86-64-v3/include/c++/v1 -L /opt/ace/sys/linux/x86-64-v3/lib \
# 

/opt/ace/build/llvm-debug/bin/clang++ -fsyntax-only -Xclang -ast-dump \
  -std=c++26 -fno-rtti -fno-exceptions -DNDEBUG \
  -o /opt/ace/build/llvm-debug/test \
  /opt/ace/src/unwrap/ast.cpp || exit 1

/opt/ace/build/llvm-debug/bin/clang++ \
  -std=c++26 -fuse-ld=lld -stdlib=libc++ -fno-rtti -fno-exceptions -DNDEBUG \
  -o /opt/ace/build/llvm-debug/test \
  /opt/ace/src/unwrap/test.cpp || exit 1
/opt/ace/build/llvm-debug/test
result=$?
echo ${result}
exit ${result}

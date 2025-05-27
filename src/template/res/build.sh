#!/bin/sh
set -e
SRC=$(readlink -f -- "${0}" || realpath -- "${0}")
RES=$(dirname "${SRC}")
TOP=$(dirname "${RES}")
cd "${TOP}"

print() {
  printf "\e[1;32m$*\e[0m\n" 1>&2
}

jq -r '.workflowPresets[]?.name' CMakePresets.json | while read config; do
  print "Building ${config} ..."
  cmake --workflow --preset "${config}"
done

for config in linux-x86-64-v2-coverage linux-x86-64-v3-coverage; do
  print "Coverage ${config} ..."

  ${ACE}/bin/llvm-profdata merge \
    -sparse build/${config}/default.profraw \
         -o build/${config}/default.profdata

  ${ACE}/bin/llvm-cov show build/${config}/tests \
            -instr-profile=build/${config}/default.profdata
done

for config in mingw-x86-64-v2-coverage mingw-x86-64-v3-coverage; do
  print "Coverage ${config} ..."

  ${ACE}/bin/llvm-profdata merge \
    -sparse build/${config}/default.profraw \
         -o build/${config}/default.profdata

  ${ACE}/bin/llvm-cov show build/${config}/tests.exe \
            -instr-profile=build/${config}/default.profdata
done

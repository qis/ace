#!/bin/sh
set -e
SRC=$(readlink -f -- "${0}" || realpath -- "${0}")
RES=$(dirname "${SRC}")
PRO=$(dirname "${RES}")
cd "${PRO}"

print() {
  printf "\e[1;32m$*\e[0m\n" 1>&2
}

jq -r '.workflowPresets[]?.name' CMakePresets.json | while read config; do
  print "Building ${config} ..."
  cmake --workflow --preset "${config}"
done

print "Parsing coverage data ..."

${ACE}/bin/llvm-profdata merge \
  -sparse build/linux-coverage/default.profraw \
       -o build/linux-coverage/default.profdata

${ACE}/bin/llvm-cov show build/linux-coverage/tests \
          -instr-profile=build/linux-coverage/default.profdata

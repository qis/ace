#!/bin/sh
set -e

# Create tools archive.
if [ ! -f tools-linux.tar.gs ]; then
  make tools
fi

# Create clang-format archive.
if [ ! -f tools-linux-clang-format.tar.gs ]; then
  make clang-format
fi

# Create sysroot archive.
if [ ! -f sys-x86_64-pc-linux-gnu.tar.gz ]; then
  make sys
fi

# Install ports.
if [ ! -f sys-x86_64-pc-linux-gnu-ports.tar.gz ]; then
  make ports
fi

# Create WebAssembly sysroot archive.
if [ ! -f sys-wasm32-wasi.tar.gz ]; then
  make TARGET=wasm32-wasi sys
fi

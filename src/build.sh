#!/bin/sh
set -e

# Create tools archive.
make tools

# Create clang-format archive.
make clang-format

# Create sysroot archive.
make sys

# Install ports.
make -C src/ports install

# Check ports linkage.
make -C src/ports check

# Create ports archive.
make ports

# Create WebAssembly sysroot archive.
make TARGET=wasm32-wasi sys

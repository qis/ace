#!/bin/sh
set -e

# Create tools archive.
make tools

# Create clang-format archive.
make clang-format

# Create sysroot archive.
make sys

# Install ports.
make ports

# Create WebAssembly sysroot archive.
make TARGET=wasm32-wasi sys

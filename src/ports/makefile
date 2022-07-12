# Editline
ifneq ($(OS),Windows_NT)
# https://troglobit.com/projects/editline/
DIRECTORIES := editline
else
# http://mingweditline.sourceforge.net/
DIRECTORIES := wineditline
endif

# Lua
# https://www.lua.org/
# Dependencies: editline (linux), wineditline (windows)
DIRECTORIES += lua

# LuaJIT
# https://luajit.org/luajit.html
DIRECTORIES += luajit

# oneAPI Threading Building Blocks
# https://oneapi-src.github.io/oneTBB/
DIRECTORIES += tbb

# Google Benchmark
# https://github.com/google/benchmark
DIRECTORIES += benchmark

# Google Test
# https://github.com/google/googletest
DIRECTORIES += gtest

# Zlib
# https://zlib.net/
DIRECTORIES += zlib

# BZip2
# https://www.sourceware.org/bzip2/
DIRECTORIES += bzip2

# LZ4
# https://github.com/lz4/lz4
DIRECTORIES += lz4

# LZMA
# https://tukaani.org/xz/
DIRECTORIES += lzma

# Brotli
# https://github.com/google/brotli
DIRECTORIES += brotli

# Zstandard
# https://github.com/facebook/zstd
DIRECTORIES += zstd

# International Components for Unicode
# https://icu.unicode.org/
DIRECTORIES += icu

# Libxml2
# https://gitlab.gnome.org/GNOME/libxml2
# Dependencies: zlib, lzma, icu
DIRECTORIES += xml2

# LibreSSL
# https://www.libressl.org/
DIRECTORIES += ssl

# Backtrace
# https://github.com/ianlancetaylor/libbacktrace
# Dependencies: unix, zlib, lzma
ifneq ($(OS),Windows_NT)
DIRECTORIES += backtrace
endif

# Boost
# https://github.com/boostorg/boost
# Dependencies: zlib, bzip2, lzma, zstd, icu, backtrace (linux)
DIRECTORIES += boost

# OpenEXR Imath
# https://github.com/AcademySoftwareFoundation/Imath
DIRECTORIES += imath

# OpenEXR
# https://github.com/AcademySoftwareFoundation/OpenEXR
# Dependencies: imath, zlib
DIRECTORIES += exr

# PNG
# http://www.libpng.org/pub/png/libpng.html
# Dependencies: zlib
DIRECTORIES += png

# TurboJPEG
# https://www.libjpeg-turbo.org/
DIRECTORIES += jpeg

# WebP
# https://developers.google.com/speed/webp
DIRECTORIES += webp

# LERC
# https://github.com/Esri/lerc
DIRECTORIES += lerc

# TIFF
# https://libtiff.gitlab.io/libtiff/
# Dependencies: zlib, lzma, zstd, jpeg, lerc, webp
DIRECTORIES += tiff

# Ogg
# https://xiph.org/ogg/
DIRECTORIES += ogg

# FLAC
# https://xiph.org/flac/
# Dependencies: ogg
DIRECTORIES += flac

# Opus
# https://opus-codec.org/
DIRECTORIES += opus

# AV1 Codec
# https://aomedia.googlesource.com/aom/
DIRECTORIES += aom

# Vulkan
# https://github.com/KhronosGroup/Vulkan-Headers
# https://github.com/KhronosGroup/SPIRV-Headers
# https://github.com/KhronosGroup/SPIRV-Tools
# https://github.com/KhronosGroup/glslang
# https://github.com/google/shaderc
DIRECTORIES += vulkan

# ANGLE
# https://www.nuget.org/packages/ANGLE.WindowsStore
ifeq ($(OS),Windows_NT)
DIRECTORIES += angle
endif

# FasTC
# https://github.com/GammaUNC/FasTC
DIRECTORIES += fastc

# Blend2D
# https://asmjit.com/
# https://blend2d.com/
# Dependencies: asmjit
DIRECTORIES += blend2d

# ==========================================================================
# Options
# ==========================================================================

PORT ?= $(DIRECTORIES)
PORTS ?= $(PORT)

# ==========================================================================
# Targets
# ==========================================================================

TARGETS := test update install register check clean clean/src

$(TARGETS): $(PORTS)

$(PORTS):
	@$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(TARGETS) $(PORTS)

DISABLE_CHECK := 1
include ../common.mk

# https://github.com/google/googletest
SRC := https://github.com/google/googletest/archive/refs/tags/release-1.12.1.tar.gz

COMMON_CMAKE_OPTIONS := \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -Dgtest_hide_internal_symbols=OFF

build/shared/build.ninja: src src/patch-cmake.diff
	@cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  -DCMAKE_INSTALL_LIBDIR="lib/shared" \
	  -DBUILD_SHARED_LIBS=ON \
	  -B build/shared src

build/static/build.ninja: src src/patch-cmake.diff
	@cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  -DCMAKE_INSTALL_LIBDIR="lib/static" \
	  -DBUILD_SHARED_LIBS=OFF \
	  -B build/static src

update: clean build/shared/build.ninja build/static/build.ninja
	@ninja -C build/shared install
	@ninja -C build/static install

register:
	@$(MAKE) cmake/GTest
	@$(MAKE) share/gtest

check: prepare
	ctest --test-dir build/static -C Debug
	ctest --test-dir build/static -C Release
	ctest --test-dir build/static -C MinSizeRel
	ctest --test-dir build/static -C RelWithDebInfo
	ctest --test-dir build/shared -C Release

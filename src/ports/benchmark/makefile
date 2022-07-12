include ../common.mk

# https://github.com/google/benchmark
SRC := https://github.com/google/benchmark/archive/refs/tags/v1.6.1.tar.gz

COMMON_CMAKE_OPTIONS := \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=OFF \
	  -DBENCHMARK_ENABLE_LTO=OFF \
	  -DBENCHMARK_ENABLE_TESTING=OFF \
	  -DBENCHMARK_ENABLE_GTEST_TESTS=OFF \
	  -DBENCHMARK_ENABLE_WERROR=OFF \
	  -DBENCHMARK_INSTALL_DOCS=OFF

ifneq ($(OS),Windows_NT)

build/build.ninja: src src/patch-cmake.diff
	@cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  -B build src

update: clean build/build.ninja
	@ninja -C build install

else

build/shared/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CXXFLAGS="/MD" \
	 cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  -DCMAKE_INSTALL_LIBDIR="lib/shared" \
	  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
	  -DCMAKE_MSVC_RUNTIME_LIBRARY="MultiThreadedDLL" \
	  -B build/shared src

build/static/build.ninja: src src/patch-cmake.diff
	@cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  -DCMAKE_INSTALL_LIBDIR="lib/static" \
	  -B build/static src

update: clean build/shared/build.ninja build/static/build.ninja
	@ninja -C build/shared install
	@ninja -C build/static install

endif

register:
	@$(MAKE) cmake/benchmark
	@$(MAKE) share/benchmark

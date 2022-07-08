include ../common.mk

# https://github.com/google/brotli/releases
SRC := https://github.com/google/brotli/archive/refs/tags/v1.0.9.tar.gz

build/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CFLAGS="-Wno-implicit-function-declaration -Wno-int-conversion" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DBROTLI_DISABLE_TESTS=ON \
	  -DBUILD_SHARED_LIBS=ON \
	  -B build src

update: clean build/build.ninja
	@ninja -C build install

register:
	@$(MAKE) cmake/Brotli
	@$(MAKE) share/brotli

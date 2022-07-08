include ../common.mk

# https://github.com/facebook/zstd/releases
SRC := https://github.com/facebook/zstd/releases/download/v1.5.2/zstd-1.5.2.tar.gz

build/build.ninja: src src/patch-cmake.diff
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DZSTD_BUILD_SHARED=ON \
	  -DZSTD_BUILD_STATIC=ON \
	  -DZSTD_BUILD_PROGRAMS=OFF \
	  -DBUILD_SHARED_LIBS=ON \
	  -B build src/build/cmake

update: clean build/build.ninja
	@ninja -C build install

register:
	@$(MAKE) cmake/zstd
	@$(MAKE) share/zstd

include ../common.mk

# https://github.com/libjpeg-turbo/libjpeg-turbo/releases
SRC := https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/2.0.7-esr.tar.gz

CFLAGS := -D_CRT_SECURE_NO_WARNINGS \
	  -Wno-deprecated-declarations \
	  -Wno-implicit-function-declaration

build/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CFLAGS="$(CFLAGS)" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DBUILD_SHARED_LIBS=ON \
	  -DREQUIRE_SIMD=ON \
	  -B build src

update: clean build/build.ninja
	@ninja -C build install

register:
	@$(MAKE) cmake/JPEG
	@$(MAKE) share/jpeg

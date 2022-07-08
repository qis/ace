include ../common.mk

# https://zlib.net/
SRC := https://zlib.net/zlib-1.2.12.tar.gz

build/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CFLAGS="-Wno-implicit-function-declaration" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DSKIP_INSTALL_FILES=ON \
	  -DBUILD_SHARED_LIBS=ON \
	  -DAMD64=ON \
	  -B build src

update: clean build/build.ninja
	@ninja -C build install

register:
	@$(MAKE) cmake/ZLIB
	@$(MAKE) share/zlib

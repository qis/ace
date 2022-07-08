include ../common.mk

# http://www.libpng.org/pub/png/libpng.html
SRC := https://downloads.sourceforge.net/project/libpng/libpng16/1.6.37/libpng-1.6.37.tar.gz

CFLAGS := -Wno-tautological-constant-out-of-range-compare

build/build.ninja: src
	@cmake -E env \
	 CFLAGS="$(CFLAGS)" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DBUILD_SHARED_LIBS=ON \
	  -B build

update: clean build/build.ninja
	@ninja -C build install

register:
	@$(MAKE) cmake/PNG
	@$(MAKE) share/png

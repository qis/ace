include ../common.mk

# https://www.sourceware.org/bzip2/downloads.html
SRC := https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz

CFLAGS := -Wno-deprecated-declarations
CFLAGS += -Wno-implicit-function-declaration

build/build.ninja: src src/patch-import.diff
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
	@$(MAKE) cmake/BZip2
	@$(MAKE) share/bzip2

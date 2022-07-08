include ../common.mk

# https://luajit.org/download.html
SRC := https://luajit.org/download/LuaJIT-2.0.5.tar.gz

CFLAGS :=

build/build.ninja: src src/patch-cmake.diff
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
	@$(MAKE) cmake/LuaJIT
	@$(MAKE) share/luajit

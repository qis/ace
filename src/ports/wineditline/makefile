include ../common.mk

# https://sourceforge.net/projects/mingweditline/files/
SRC := https://downloads.sourceforge.net/project/mingweditline/wineditline-2.206.zip

build/shared/build.ninja: src
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_LIBDIR="lib/shared" \
	  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
	  -DCMAKE_MSVC_RUNTIME_LIBRARY="MultiThreadedDLL" \
	  -B build/shared

build/static/build.ninja: src
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_LIBDIR="lib/static" \
	  -B build/static

update: clean build/shared/build.ninja build/static/build.ninja
	@ninja -C build/shared install
	@ninja -C build/static install

register:
	@$(MAKE) cmake/Editline
	@$(MAKE) share/editline

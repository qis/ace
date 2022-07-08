include ../common.mk

# https://www.lua.org/download.html
# See $(ACE)/src/llvm/lldb/CMakeLists.txt for supported versions.
SRC := https://www.lua.org/ftp/lua-5.3.4.tar.gz

build/build.ninja: src
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DBUILD_SHARED_LIBS=ON \
	  -B build

update: clean build/build.ninja
	@ninja -C build install

register:
	@$(MAKE) cmake/Lua
	@$(MAKE) share/lua

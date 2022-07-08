include ../common.mk

# https://github.com/ianlancetaylor/libbacktrace
SRC := https://github.com/ianlancetaylor/libbacktrace/archive/4d2dd0b.tar.gz

build/build.ninja: src
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -B build

update: clean build/build.ninja
	@ninja -C build install

register:
	@$(MAKE) cmake/Backtrace
	@$(MAKE) share/backtrace

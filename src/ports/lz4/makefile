include ../common.mk

# https://github.com/lz4/lz4/releases
SRC := https://github.com/lz4/lz4/archive/refs/tags/v1.9.3.tar.gz

CFLAGS := -Wno-bad-function-cast
CFLAGS += -Wno-covered-switch-default
CFLAGS += -Wno-extra-semi-stmt
CFLAGS += -Wno-implicit-fallthrough
CFLAGS += -Wno-implicit-int-float-conversion
CFLAGS += -Wno-missing-prototypes
CFLAGS += -Wno-missing-variable-declarations
CFLAGS += -Wno-nonportable-system-include-path
CFLAGS += -Wno-reserved-identifier
CFLAGS += -Wno-sign-conversion
CFLAGS += -Wno-unused-macros

build/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CFLAGS="$(CFLAGS)" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DBUILD_SHARED_LIBS=ON \
	  -DBUILD_STATIC_LIBS=ON \
	  -DLZ4_BUILD_CLI=OFF \
	  -DLZ4_BUILD_LEGACY_LZ4C=OFF \
	  -B build src/build/cmake

update: clean build/build.ninja
	@ninja -C build install

register:
	@$(MAKE) cmake/LZ4
	@$(MAKE) share/lz4

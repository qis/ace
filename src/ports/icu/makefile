include ../common.mk

# https://github.com/unicode-org/icu/releases
SRC := https://github.com/unicode-org/icu/releases/download/release-71-1/icu4c-71_1-src.tgz

CFLAGS := -Wno-ambiguous-reversed-operator
CFLAGS += -Wno-deprecated-anon-enum-enum-conversion
CFLAGS += -Wno-deprecated-enum-enum-conversion
CFLAGS += -Wno-deprecated-enum-float-conversion
CFLAGS += -Wno-parentheses

build/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CXXFLAGS="$(CFLAGS)" \
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
	@$(MAKE) cmake/ICU
	@$(MAKE) share/icu

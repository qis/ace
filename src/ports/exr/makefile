include ../common.mk

# Version should match OpenEXR Imath port: imath
# https://github.com/AcademySoftwareFoundation/OpenEXR/releases
SRC := https://github.com/AcademySoftwareFoundation/OpenEXR/archive/refs/tags/v3.1.5.tar.gz

CFLAGS := -Wno-format \
	  -Wno-deprecated-declarations \
	  -Wno-ignored-pragma-optimize \
	  -Wno-implicit-function-declaration \
	  -Wno-parentheses \
	  -Wno-pointer-sign \
	  -Wno-unused-result \

ifneq ($(OS),Windows_NT)
CFLAGS += -D_POSIX_C_SOURCE=200112L -D_GNU_SOURCE
endif

COMMON_CMAKE_OPTIONS := \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_BINDIR="$(PREFIX)/tools" \
	  -DOPENEXR_CXX_STANDARD="20" \
	  -DOPENEXR_INSTALL_PKG_CONFIG=OFF \
	  -DOPENEXR_LIB_SUFFIX="" \
	  -DOPENEXR_STATIC_LIB_SUFFIX="" \
	  -DOPENEXR_INSTALL_EXAMPLES=OFF

build/shared/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CFLAGS="$(CFLAGS)" \
	 CXXFLAGS="$(CFLAGS)" \
	 cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DBUILD_SHARED_LIBS=ON \
	  -DOPENEXR_BUILD_TOOLS=OFF \
	  -B build/shared src

build/static/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CFLAGS="$(CFLAGS)" \
	 CXXFLAGS="$(CFLAGS)" \
	 cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN/../lib" \
	  -DBUILD_SHARED_LIBS=OFF \
	  -DOPENEXR_BUILD_TOOLS=ON \
	  -B build/static src

update: clean build/shared/build.ninja build/static/build.ninja
	@ninja -C build/shared install
	@ninja -C build/static install

register:
	@$(MAKE) cmake/OpenEXR
	@$(MAKE) share/exr

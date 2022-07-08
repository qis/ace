include ../common.mk

# Version should match OpenEXR port: exr
# https://github.com/AcademySoftwareFoundation/Imath/releases
SRC := https://github.com/AcademySoftwareFoundation/Imath/archive/refs/tags/v3.1.5.tar.gz

CFLAGS := -Wno-format

COMMON_CMAKE_OPTIONS := \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DIMATH_CXX_STANDARD="20" \
	  -DIMATH_INSTALL_PKG_CONFIG=OFF \
	  -DIMATH_INSTALL_SYM_LINK=OFF \
	  -DIMATH_LIB_SUFFIX="" \
	  -DIMATH_STATIC_LIB_SUFFIX=""

build/shared/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CXXFLAGS="-Wno-format" \
	 cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  -DBUILD_SHARED_LIBS=ON \
	  -B build/shared src

build/static/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CXXFLAGS="-Wno-format" \
	 cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  -DBUILD_SHARED_LIBS=OFF \
	  -B build/static src

update: clean build/shared/build.ninja build/static/build.ninja
	@ninja -C build/shared install
	@ninja -C build/static install

register:
	@$(MAKE) cmake/Imath
	@$(MAKE) share/imath

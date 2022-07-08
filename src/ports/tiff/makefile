include ../common.mk

# https://download.osgeo.org/libtiff/
SRC := http://download.osgeo.org/libtiff/tiff-4.4.0.tar.gz

CFLAGS := -Wno-missing-variable-declarations

COMMON_CMAKE_OPTIONS := \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DHAVE_LD_VERSION_SCRIPT=OFF

build/shared/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CFLAGS="$(CFLAGS)" \
	 cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  -DBUILD_SHARED_LIBS=ON \
	  -B build/shared src

build/static/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CFLAGS="$(CFLAGS)" \
	 cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  -DBUILD_SHARED_LIBS=OFF \
	  -B build/static src

update: clean build/shared/build.ninja build/static/build.ninja
	@ninja -C build/shared install
	@ninja -C build/static install

register:
	@$(MAKE) cmake/TIFF
	@$(MAKE) share/tiff

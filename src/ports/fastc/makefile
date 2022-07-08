DISABLE_DOWNLOAD := 1
include ../common.mk

# https://github.com/GammaUNC/FasTC
src:
	@git clone -c advice.detachedHead=false \
	  --depth 1 --recurse-submodules --shallow-submodules \
	  https://github.com/GammaUNC/FasTC src

CFLAGS := -Wno-writable-strings

build/shared/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CFLAGS="$(CFLAGS)" \
	 CXXFLAGS="$(CFLAGS)" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_LIBDIR="lib/shared" \
	  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
	  -DCMAKE_MSVC_RUNTIME_LIBRARY="MultiThreadedDLL" \
	  -B build/shared src

build/static/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CFLAGS="$(CFLAGS)" \
	 CXXFLAGS="$(CFLAGS)" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_LIBDIR="lib/static" \
	  -B build/static src

update: clean build/shared/build.ninja build/static/build.ninja
	@ninja -C build/shared install
	@ninja -C build/static install

register:
	@$(MAKE) cmake/FasTC
	@$(MAKE) share/fastc

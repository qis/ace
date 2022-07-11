DISABLE_DOWNLOAD := 1
include ../common.mk

# https://github.com/asmjit/asmjit
src/asmjit:
	@git clone -c advice.detachedHead=false \
	  --depth 1 --recurse-submodules --shallow-submodules \
	  https://github.com/asmjit/asmjit src/asmjit

# https://github.com/blend2d/blend2d
src/blend2d:
	@git clone -c advice.detachedHead=false \
	  --depth 1 --recurse-submodules --shallow-submodules \
	  https://github.com/blend2d/blend2d src/blend2d

CFLAGS := -Wno-switch \
	  -Wno-deprecated-volatile \
	  -Wno-deprecated-anon-enum-enum-conversion \
	  -Wno-unused-command-line-argument

COMMON_CMAKE_OPTIONS := \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN"

build/shared/build.ninja: src/asmjit src/blend2d src/patch-cmake.diff
	@cmake -E env \
	 CFLAGS="$(CFLAGS)" \
	 CXXFLAGS="$(CFLAGS)" \
	 cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  -DBUILD_SHARED_LIBS=ON \
	  -DBLEND2D_STATIC=OFF \
	  -B build/shared src/blend2d

build/static/build.ninja: src/asmjit src/blend2d src/patch-cmake.diff
	@cmake -E env \
	 CFLAGS="$(CFLAGS)" \
	 CXXFLAGS="$(CFLAGS)" \
	 cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  -DBUILD_SHARED_LIBS=OFF \
	  -DBLEND2D_STATIC=ON \
	  -B build/static src/blend2d

update: clean build/shared/build.ninja build/static/build.ninja
	@ninja -C build/shared install
	@ninja -C build/static install

register:
	@$(MAKE) cmake/Blend2D
	@$(MAKE) share/blend2d


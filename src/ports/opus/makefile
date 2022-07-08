include ../common.mk

# https://opus-codec.org/downloads/
SRC := https://archive.mozilla.org/pub/opus/opus-1.3.1.tar.gz

CFLAGS := -Wno-unused-command-line-argument \
	  -Wno-implicit-function-declaration \
	  -Wno-int-to-pointer-cast

COMMON_CMAKE_OPTIONS := \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DOPUS_STACK_PROTECTOR=OFF \
	  -DOPUS_INSTALL_PKG_CONFIG_MODULE=OFF \
	  -DOPUS_INSTALL_CMAKE_CONFIG_MODULE=OFF \
	  -DOPUS_X86_MAY_HAVE_SSE=ON \
	  -DOPUS_X86_MAY_HAVE_SSE2=ON \
	  -DOPUS_X86_MAY_HAVE_SSE4_1=ON \
	  -DOPUS_X86_MAY_HAVE_AVX=ON

build/shared/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CFLAGS="$(CFLAGS)" \
	 CXXFLAGS="$(CFLAGS)" \
	 cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  -DBUILD_SHARED_LIBS=ON \
	  -B build/shared src

build/static/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CFLAGS="$(CFLAGS)" \
	 CXXFLAGS="$(CFLAGS)" \
	 cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  -DBUILD_SHARED_LIBS=OFF \
	  -B build/static src

update: clean build/shared/build.ninja build/static/build.ninja
	@ninja -C build/shared install
	@ninja -C build/static install

register:
	@$(MAKE) cmake/Opus
	@$(MAKE) share/opus

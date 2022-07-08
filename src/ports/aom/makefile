DISABLE_DOWNLOAD := 1
include ../common.mk

# https://aomedia.googlesource.com/aom/
src:
	@git clone -c advice.detachedHead=false -b v3.4.0 \
	  --depth 1 --recurse-submodules --shallow-submodules \
	  https://aomedia.googlesource.com/aom src

CFLAGS := -Wno-unused-command-line-argument

build/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CFLAGS="$(CFLAGS)" \
	 CXXFLAGS="$(CFLAGS)" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DBUILD_SHARED_LIBS=ON \
	  -DENABLE_DOCS=OFF \
	  -DENABLE_EXAMPLES=OFF \
	  -DENABLE_TESTDATA=OFF \
	  -DENABLE_TESTS=OFF \
	  -DENABLE_TOOLS=OFF \
	  -DENABLE_MMX=ON \
	  -DENABLE_SSE=ON \
	  -DENABLE_SSE2=ON \
	  -DENABLE_SSE3=ON \
	  -DENABLE_SSSE3=ON \
	  -DENABLE_SSE4_1=ON \
	  -DENABLE_SSE4_2=ON \
	  -DENABLE_AVX=ON \
	  -DENABLE_AVX2=ON \
	  -B build src

update: clean build/build.ninja
	@ninja -C build install

register:
	@$(MAKE) cmake/aom
	@$(MAKE) share/aom

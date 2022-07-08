include ../common.mk

# https://storage.googleapis.com/downloads.webmproject.org/releases/webp/index.html
SRC := https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.2.2.tar.gz

COMMON_CMAKE_OPTIONS := \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DWEBP_BUILD_ANIM_UTILS=OFF \
	  -DWEBP_BUILD_CWEBP=OFF \
	  -DWEBP_BUILD_DWEBP=OFF \
	  -DWEBP_BUILD_GIF2WEBP=OFF \
	  -DWEBP_BUILD_IMG2WEBP=OFF \
	  -DWEBP_BUILD_VWEBP=OFF \
	  -DWEBP_BUILD_WEBPINFO=OFF \
	  -DWEBP_BUILD_LIBWEBPMUX=OFF \
	  -DWEBP_BUILD_WEBPMUX=OFF \
	  -DWEBP_BUILD_EXTRAS=OFF \
	  -DWEBP_BUILD_WEBP_JS=OFF

build/shared/build.ninja: src src/patch-cmake.diff
	@cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  -DBUILD_SHARED_LIBS=ON \
	  -B build/shared src

build/static/build.ninja: src src/patch-cmake.diff
	@cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  -DBUILD_SHARED_LIBS=OFF \
	  -B build/static src

update: clean build/shared/build.ninja build/static/build.ninja
	@ninja -C build/shared install
	@ninja -C build/static install

register:
	@$(MAKE) cmake/WebP
	@$(MAKE) share/webp

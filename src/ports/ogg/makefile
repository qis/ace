DISABLE_DOWNLOAD := 1
include ../common.mk

# https://ftp.osuosl.org/pub/xiph/releases/ogg/
SRC := https://ftp.osuosl.org/pub/xiph/releases/ogg/libogg-1.3.5.tar.xz

src.tar.xz:
	@curl -L "$(SRC)" -o $@

src.tar: src.tar.xz
	@7z x src.tar.xz

src: src.tar
	@cmake -E make_directory $@
	@tar xf $< -C $@ -m --strip-components=1

COMMON_CMAKE_OPTIONS := \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DINSTALL_DOCS=OFF \
	  -DINSTALL_PKG_CONFIG_MODULE=OFF \
	  -DINSTALL_CMAKE_PACKAGE_MODULE=OFF

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
	@$(MAKE) cmake/Ogg
	@$(MAKE) share/ogg

DISABLE_DOWNLOAD := 1
include ../common.mk

# https://ftp.osuosl.org/pub/xiph/releases/flac/
SRC := https://ftp.osuosl.org/pub/xiph/releases/flac/flac-1.3.4.tar.xz

src.tar.xz:
	@curl -L "$(SRC)" -o $@

src.tar: src.tar.xz
	@7z x src.tar.xz

src: src.tar
	@cmake -E make_directory $@
	@tar xf $< -C $@ -m --strip-components=1

CFLAGS := -Wno-incompatible-pointer-types \
	  -Wno-knr-promoted-parameter

COMMON_CMAKE_OPTIONS := \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DBUILD_CXXLIBS=ON \
	  -DBUILD_PROGRAMS=OFF \
	  -DBUILD_EXAMPLES=OFF \
	  -DBUILD_TESTING=OFF \
	  -DBUILD_UTILS=OFF \
	  -DBUILD_DOCS=OFF \
	  -DWITH_STACK_PROTECTOR=OFF \
	  -DINSTALL_MANPAGES=OFF \
	  -DINSTALL_PKGCONFIG_MODULES=OFF \
	  -DINSTALL_CMAKE_CONFIG_MODULE=OFF \
	  -DWITH_OGG=ON

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
	@$(MAKE) cmake/FLAC
	@$(MAKE) share/flac

include ../common.mk

# https://gitlab.gnome.org/GNOME/libxml2/-/releases
SRC := https://gitlab.gnome.org/GNOME/libxml2/-/archive/v2.9.14/libxml2-v2.9.14.tar.gz

CFLAGS := -Wno-deprecated-declarations -Wno-pointer-sign

COMMON_CMAKE_OPTIONS := \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DLIBXML2_WITH_FTP=OFF \
	  -DLIBXML2_WITH_HTML=OFF \
	  -DLIBXML2_WITH_HTTP=OFF \
	  -DLIBXML2_WITH_ICONV=OFF \
	  -DLIBXML2_WITH_ICU=ON \
	  -DLIBXML2_WITH_ISO8859X=OFF \
	  -DLIBXML2_WITH_LZMA=ON \
	  -DLIBXML2_WITH_MODULES=OFF \
	  -DLIBXML2_WITH_PROGRAMS=OFF \
	  -DLIBXML2_WITH_PYTHON=OFF \
	  -DLIBXML2_WITH_TESTS=OFF \
	  -DLIBXML2_WITH_ZLIB=ON

build/shared/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CFLAGS="$(CFLAGS)" \
	 cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  -DBUILD_SHARED_LIBS=ON \
	  -DSKIP_INSTALL_HEADERS=ON \
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
	@$(MAKE) cmake/LibXml2
	@$(MAKE) share/xml2

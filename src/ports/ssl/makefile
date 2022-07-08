include ../common.mk

# https://www.libressl.org/releases.html
SRC := https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-3.5.3.tar.gz

CFLAGS := -Wno-missing-field-initializers \
	  -Wno-unused-command-line-argument \
	  -Wno-unused-function

COMMON_CMAKE_OPTIONS := \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DLIBRESSL_APPS=OFF \
	  -DLIBRESSL_TESTS=OFF

ifneq ($(OS),Windows_NT)
COMMON_CMAKE_OPTIONS += -DOPENSSLDIR="/etc/ssl"
else
COMMON_CMAKE_OPTIONS += -DOPENSSLDIR="C:/Windows/ssl"
endif

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
	@$(MAKE) cmake/OpenSSL
	@$(MAKE) share/ssl

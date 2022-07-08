DISABLE_DOWNLOAD := 1
include ../common.mk

# https://www.boost.org/
src:
	@git clone -c advice.detachedHead=false -b boost-1.79.0 \
	  --depth 1 --recurse-submodules --shallow-submodules \
	  https://github.com/boostorg/boost src

CFLAGS := -Wno-deprecated-declarations \
	  -Wno-implicit-const-int-float-conversion \
	  -Wno-incompatible-pointer-types \
	  -Wno-unused-result

COMMON_CMAKE_OPTIONS := \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DBOOST_INSTALL_LAYOUT="system" \
	  -DBOOST_IOSTREAMS_ENABLE_ZLIB=ON \
	  -DBOOST_IOSTREAMS_ENABLE_BZIP2=ON \
	  -DBOOST_IOSTREAMS_ENABLE_LZMA=ON \
	  -DBOOST_IOSTREAMS_ENABLE_ZSTD=ON \
	  -DBOOST_LOCALE_ENABLE_ICONV=OFF \
	  -DBOOST_LOCALE_ENABLE_ICU=ON \
	  -DBOOST_LOCALE_ENABLE_STD=OFF \
	  -DBOOST_LOCALE_ENABLE_WINAPI=OFF \
	  -DBOOST_LOCALE_ENABLE_POSIX=OFF \
	  -DBOOST_STACKTRACE_ENABLE_ADDR2LINE=OFF \
	  -DBOOST_STACKTRACE_ENABLE_BASIC=ON \
	  -DBOOST_STACKTRACE_ENABLE_NOOP=ON

ifneq ($(OS),Windows_NT)

COMMON_CMAKE_OPTIONS += \
	  -DBOOST_STACKTRACE_ENABLE_BACKTRACE=ON

else

COMMON_CMAKE_OPTIONS += \
	  -DBOOST_STACKTRACE_ENABLE_BACKTRACE=OFF \
	  -DBOOST_CONTEXT_ASSEMBLER="masm"

COMMON_CMAKE_OPTIONS_SHARED := \
	  -DCMAKE_INSTALL_LIBDIR="$(PREFIX)/lib/shared"

COMMON_CMAKE_OPTIONS_STATIC := \
	  -DCMAKE_INSTALL_LIBDIR="$(PREFIX)/lib/static"

endif

build/shared/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CFLAGS="$(CFLAGS)" \
	 CXXFLAGS="$(CFLAGS)" \
	 cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  $(COMMON_CMAKE_OPTIONS_SHARED) \
	  -DBUILD_SHARED_LIBS=ON \
	  -DSKIP_INSTALL_HEADERS=ON \
	  -B build/shared src

build/static/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CFLAGS="$(CFLAGS)" \
	 CXXFLAGS="$(CFLAGS)" \
	 cmake -GNinja -Wno-dev \
	  $(COMMON_CMAKE_OPTIONS) \
	  $(COMMON_CMAKE_OPTIONS_STATIC) \
	  -DBUILD_SHARED_LIBS=OFF \
	  -B build/static src

update: clean build/shared/build.ninja build/static/build.ninja
	@ninja -C build/shared install
	@ninja -C build/static install

register:
	@$(MAKE) cmake/Boost
	@$(MAKE) share/boost

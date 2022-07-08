include ../common.mk

# https://github.com/oneapi-src/oneTBB/releases
SRC := https://github.com/oneapi-src/oneTBB/archive/refs/tags/v2021.5.0.tar.gz

build/shared/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CXXFLAGS="-D_LIBCPP_DISABLE_DEPRECATION_WARNINGS" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_CXX_FLAGS="-D_LIBCPP_DISABLE_DEPRECATION_WARNINGS" \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_DOCDIR="$(CURDIR)/build/share" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DTBB_TEST=OFF \
	  -DTBB_EXAMPLES=OFF \
	  -DTBBMALLOC_BUILD=ON \
	  -DBUILD_SHARED_LIBS=ON \
	  -B build/shared src

build/static/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CXXFLAGS="-D_LIBCPP_DISABLE_DEPRECATION_WARNINGS" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_DOCDIR="$(CURDIR)/build/share" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DTBB_TEST=OFF \
	  -DTBB_EXAMPLES=OFF \
	  -DTBBMALLOC_BUILD=ON \
	  -DBUILD_SHARED_LIBS=OFF \
	  -B build/static src

update: clean build/shared/build.ninja build/static/build.ninja
	@ninja -C build/shared install
	@ninja -C build/static src/tbb/install
	@ninja -C build/static src/tbbmalloc/install

register:
	@$(MAKE) cmake/TBB
	@$(MAKE) share/tbb

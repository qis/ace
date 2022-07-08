DISABLE_DOWNLOAD := 1
include ../common.mk

# https://github.com/troglobit/editline/releases
SRC := https://github.com/troglobit/editline/releases/download/1.17.1/editline-1.17.1.tar.gz

src.tar:
	@curl -L "$(SRC)" -o $@

src: src.tar
	@cmake -E make_directory $@
	@tar xf $< -C $@ -m --strip-components=1 --exclude=aux

CFLAGS := -Wno-int-conversion \
	  -Wno-deprecated-declarations \
	  -Wno-implicit-function-declaration

build/build.ninja: src src/patch-cmake.diff
	@cmake -E env \
	 CFLAGS="$(CFLAGS)" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -B build

update: clean build/build.ninja
	@ninja -C build install

register:
	@$(MAKE) cmake/Editline
	@$(MAKE) share/editline

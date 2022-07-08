MAKEFLAGS += --no-print-directory

PORT := $(abspath $(firstword $(MAKEFILE_LIST)))
PORT := $(notdir $(patsubst %/,%,$(dir $(PORT))))

ifneq ($(OS),Windows_NT)
ACE ?= /opt/ace
else
ACE ?= C:/Ace
EXE := .exe
endif

TOOLCHAIN := $(ACE)/toolchain.cmake

ifneq ($(OS),Windows_NT)
TARGET ?= x86_64-pc-linux-gnu
else
TARGET ?= x86_64-pc-windows-msvc
endif

PREFIX ?= $(ACE)/sys/$(TARGET)

ifneq ($(DISABLE_DOWNLOAD),1)

src.tar:
	@curl -L "$(SRC)" -o $@

src: src.tar
	@cmake -E make_directory $@
	@tar xf $< -C $@ -m --strip-components=1

endif

src/%.diff: %.diff
	@cmake -E remove_directory src/.git
	@git --git-dir=src/.git apply --verbose --whitespace=nowarn --directory=src $*.diff
	@cmake -E touch $@

cmake/%:
	@cmake -E remove_directory "$(PREFIX)/cmake/$*"
	@cmake -E echo "-- Installing: $(PREFIX)/cmake/$*"
	@cmake -E copy_directory cmake "$(PREFIX)/cmake/$*"

share/%:
	@cmake -E make_directory "$(PREFIX)/share/$*"
	@cmake -E echo "-- Installing: $(PREFIX)/share/$*/license.rtf"
	@cmake -E copy share/license.rtf "$(PREFIX)/share/$*"
	@cmake -E echo "-- Installing: $(PREFIX)/share/$*/license.txt"
	@cmake -E copy share/license.txt "$(PREFIX)/share/$*"

prepare: clean
	@cmake -G "Ninja Multi-Config" -Wno-dev --log-level=VERBOSE \
	  -DCMAKE_CONFIGURATION_TYPES="Debug;Release;MinSizeRel;RelWithDebInfo" \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
	  -DBUILD_SHARED_LIBS=OFF \
	  -B build/static check
	@cmake -G "Ninja Multi-Config" -Wno-dev --log-level=VERBOSE \
	  -DCMAKE_CONFIGURATION_TYPES="Release" \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
	  -DBUILD_SHARED_LIBS=ON \
	  -B build/shared check
	cmake --build build/static --config Debug -v
	cmake --build build/static --config Release -v
	cmake --build build/static --config MinSizeRel -v
	cmake --build build/static --config RelWithDebInfo -v
	cmake --build build/shared --config Release -v

build/debug/build.ninja:
	@cmake -GNinja -Wno-dev --log-level=VERBOSE \
	  -DCMAKE_BUILD_TYPE=Debug \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
	  -DBUILD_SHARED_LIBS=OFF \
	  -B build/debug check

ifneq ($(OS),Windows_NT)

check: prepare
	build/static/Debug/main
	build/static/Release/main
	build/static/MinSizeRel/main
	build/static/RelWithDebInfo/main
	build/shared/Release/main

debug: build/debug/build.ninja
	@cmake --build build/debug -v
	@$(ACE)/bin/lldb -b -k bt \
	  -o 'settings set auto-confirm 1' -o run -o quit \
	  build/debug/main

run: build/debug/build.ninja
	@cmake --build build/debug -v
	@build/debug/main

else

check: prepare
	build\static\Debug\main.exe
	build\static\Release\main.exe
	build\static\MinSizeRel\main.exe
	build\static\RelWithDebInfo\main.exe
	build\shared\Release\main.exe

debug: build/debug/build.ninja
	@cmake --build build/debug -v
	@$(ACE)/bin/lldb.exe \
	  -o 'settings set auto-confirm 1'\
	  build/debug/main.exe

run: build/debug/build.ninja
	@cmake --build build/debug -v
	@build\debug\main.exe

PREFIX_CMAKE := $(subst /,\,$(PREFIX)/cmake)

endif

install:
	@cmake -E compare_files --ignore-eol \
	 $(PREFIX)/share/$(PORT)/license.txt share/license.txt || \
	 $(MAKE) ACE="$(ACE)" TARGET="$(TARGET)" PREFIX="$(PREFIX)" update register

test:
	@$(MAKE) ACE="$(ACE)" TARGET="$(TARGET)" PREFIX="$(CURDIR)/test" update

clean:
	@cmake -E remove_directory build test

clean/src: clean
	@cmake -E remove -f src.tar src.tar.xz
	@cmake -E remove_directory src

.PHONY: debug run test update install register clean clean/src

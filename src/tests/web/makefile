ifneq ($(OS),Windows_NT)
ACE ?= /opt/ace
else
ACE ?= C:/Ace
endif

CONFIG ?= Debug

all: build/$(CONFIG)

build/%: phony build/build.ninja
	@cmake --build build --config $* -v

configure: build/build.ninja

build/build.ninja: CMakeLists.txt
	@cmake -G "Ninja Multi-Config" -Wno-dev --log-level=VERBOSE -DACE_TARGET="wasm32-wasi" \
	  -DCMAKE_CONFIGURATION_TYPES="Debug;Release;MinSizeRel;RelWithDebInfo" \
	  -DCMAKE_TOOLCHAIN_FILE="$(ACE)/toolchain.cmake" \
	  -B build

clean:
	@cmake -E remove_directory build

phony:

.PHONY: all configure clean phony

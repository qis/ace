ifeq ($(OS),Windows_NT)
llvm ?= C:/LLVM
else
llvm ?= /opt/llvm
endif

config ?= Debug

all: build/$(config)

build/%: phony build/build.ninja
	@cmake --build build --config $* -v

configure: build/build.ninja

build/build.ninja: CMakeLists.txt
	@cmake --no-warn-unused-cli -G "Ninja Multi-Config" \
	  -DCMAKE_CONFIGURATION_TYPES="Debug;Release;MinSizeRel;RelWithDebInfo" \
	  -DCMAKE_TOOLCHAIN_FILE="$(llvm)/web.cmake" \
	  -B build

clean:
	@cmake -E remove_directory build

phony:

.PHONY: all configure clean phony

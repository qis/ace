config ?= debug

ifeq ($(config),debug)
output := Debug
endif

ifeq ($(config),release)
output := Release
endif

ifeq ($(config),minsizerel)
output := MinSizeRel
endif

ifeq ($(config),relwithdebinfo)
output := RelWithDebInfo
endif

ifeq ($(config),coverage)
output := Coverage
endif

build: configure
	@cmake --build build --config $(output)

install: build/build.ninja
	@cmake --build build --config MinSizeRel --target install

format:
	@cmake -P $(ACE)/format.cmake src

clean:
	@cmake -E remove_directory build

configure: build/build.ninja

build/build.ninja: CMakeLists.txt
	@cmake -B build --preset default

.PHONY: build install format clean configure

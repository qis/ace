ACE := $(abspath $(CURDIR)/../..)

export PATH := $(ACE)/bin:$(PATH)

PRESETS := linux-shared linux-static mingw-shared mingw-static
BUILDDIRS := $(addprefix $(ACE)/build/modules/,$(PRESETS))
BUILDFILES := $(addsuffix /build.ninja,$(BUILDDIRS))

all: $(BUILDFILES)
	cmake --build   $(ACE)/build/modules/linux-shared --config Debug
	cmake --build   $(ACE)/build/modules/linux-shared --config Release
	cmake --build   $(ACE)/build/modules/linux-shared --config MinSizeRel
	cmake --build   $(ACE)/build/modules/linux-shared --config RelWithDebInfo
	cmake --build   $(ACE)/build/modules/linux-shared --config Coverage
	cmake --build   $(ACE)/build/modules/linux-static --config Debug
	cmake --build   $(ACE)/build/modules/linux-static --config Release
	cmake --build   $(ACE)/build/modules/linux-static --config MinSizeRel
	cmake --build   $(ACE)/build/modules/linux-static --config RelWithDebInfo
	cmake --build   $(ACE)/build/modules/linux-static --config Coverage
	cmake --build   $(ACE)/build/modules/mingw-shared --config Debug
	cmake --build   $(ACE)/build/modules/mingw-shared --config Release
	cmake --build   $(ACE)/build/modules/mingw-shared --config MinSizeRel
	cmake --build   $(ACE)/build/modules/mingw-shared --config RelWithDebInfo
	cmake --build   $(ACE)/build/modules/mingw-shared --config Coverage
	cmake --build   $(ACE)/build/modules/mingw-static --config Debug
	cmake --build   $(ACE)/build/modules/mingw-static --config Release
	cmake --build   $(ACE)/build/modules/mingw-static --config MinSizeRel
	cmake --build   $(ACE)/build/modules/mingw-static --config RelWithDebInfo
	cmake --build   $(ACE)/build/modules/mingw-static --config Coverage
	cmake --install $(ACE)/build/modules/linux-shared --config Debug
	cmake --install $(ACE)/build/modules/linux-shared --config Release
	cmake --install $(ACE)/build/modules/linux-shared --config MinSizeRel
	cmake --install $(ACE)/build/modules/linux-shared --config RelWithDebInfo
	cmake --install $(ACE)/build/modules/linux-shared --config Coverage
	cmake --install $(ACE)/build/modules/linux-static --config Debug
	cmake --install $(ACE)/build/modules/linux-static --config Release
	cmake --install $(ACE)/build/modules/linux-static --config MinSizeRel
	cmake --install $(ACE)/build/modules/linux-static --config RelWithDebInfo
	cmake --install $(ACE)/build/modules/linux-static --config Coverage
	cmake --install $(ACE)/build/modules/mingw-shared --config Debug
	cmake --install $(ACE)/build/modules/mingw-shared --config Release
	cmake --install $(ACE)/build/modules/mingw-shared --config MinSizeRel
	cmake --install $(ACE)/build/modules/mingw-shared --config RelWithDebInfo
	cmake --install $(ACE)/build/modules/mingw-shared --config Coverage
	cmake --install $(ACE)/build/modules/mingw-static --config Debug
	cmake --install $(ACE)/build/modules/mingw-static --config Release
	cmake --install $(ACE)/build/modules/mingw-static --config MinSizeRel
	cmake --install $(ACE)/build/modules/mingw-static --config RelWithDebInfo
	cmake --install $(ACE)/build/modules/mingw-static --config Coverage

$(ACE)/build/modules/%/build.ninja: CMakeLists.txt CMakePresets.json
	cmake --preset "$*"

test:
	rm -rf $(ACE)/tests/modules
	$(ACE)/src/vcpkg test modules

.PHONY: all test

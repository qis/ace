ifneq ($(OS),Windows_NT)
ACE ?= /opt/ace
else
ACE ?= C:/Ace
EXE := .exe
endif

CONFIG ?= Debug
PARAMS ?= 128
SHARED ?= 0

all: build/$(CONFIG)

build/%: phony build/build.ninja
	@cmake --build build --config $* -v

run: run/$(CONFIG)

run/%: build/%
	@cmake -E env LLVM_PROFILE_FILE="$*/main$(EXE).profraw" \
	 cmake -E chdir build $*/main$(EXE) $(PARAMS)

debug: debug/$(CONFIG)

debug/%: build/%
	@cmake -E env LLVM_PROFILE_FILE="$*/main$(EXE).profraw" \
	 cmake -E chdir build $(ACE)/bin/lldb -l lua -b -k bt \
	  -o 'settings set auto-confirm 1' -o run -o quit \
	  $*/main$(EXE) $(PARAMS)

test: build/Coverage
	@cmake -E env LLVM_PROFILE_FILE="Coverage/main$(EXE).profraw" \
	 cmake -E chdir build Coverage/main$(EXE) $(PARAMS)
	@cmake -E compare_files \
	  build/Coverage/main$(EXE).profraw \
	  build/Coverage/main$(EXE).profraw && \
	$(ACE)/bin/llvm-profdata merge \
	  -sparse build/Coverage/main$(EXE).profraw \
	  -o build/Coverage/main$(EXE).profdata && \
	$(ACE)/bin/llvm-cov show build/Coverage/main$(EXE) \
	  -instr-profile=build/Coverage/main$(EXE).profdata && \
	$(ACE)/bin/llvm-cov report build/Coverage/main$(EXE) \
	  -instr-profile=build/Coverage/main$(EXE).profdata

configure: build/build.ninja

build/build.ninja: CMakeLists.txt
	@cmake -G "Ninja Multi-Config" -Wno-dev --log-level=VERBOSE -DACE_TARGET="$(TARGET)" \
	  -DCMAKE_CONFIGURATION_TYPES="Debug;Release;MinSizeRel;RelWithDebInfo;Coverage" \
	  -DCMAKE_TOOLCHAIN_FILE="$(ACE)/toolchain.cmake" \
	  -DBUILD_SHARED_LIBS="$(SHARED)" \
	  -B build

clean:
	@cmake -E remove_directory build

phony:

.PHONY: all run debug test configure clean phony

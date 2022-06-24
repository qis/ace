ifeq ($(OS),Windows_NT)
llvm ?= C:/LLVM
root ?= win
main ?= main.exe
test ?= main.exe
else
llvm ?= /opt/llvm
root ?= sys
main ?= main
test ?= main
endif

config ?= Debug
params ?= 128
shared ?= 0

all: build/$(config)

build/%: phony build/build.ninja
	@cmake --build build --config $* -v

run: run/$(config)

run/%: build/%
	@cmake -E env LLVM_PROFILE_FILE="$*/$(main).profraw" \
	 cmake -E chdir build $*/$(main) $(params)

debug: debug/$(config)

debug/%: build/%
	@cmake -E env LLVM_PROFILE_FILE="$*/$(main).profraw" \
	 cmake -E chdir build $(llvm)/bin/lldb -b -k bt \
	  -o 'settings set auto-confirm 1' -o run -o quit \
	  $*/$(main) $(params)

test: build/Coverage
	@cmake -E env LLVM_PROFILE_FILE="Coverage/$(test).profraw" \
	 cmake -E chdir build Coverage/$(test) $(params)
	@cmake -E compare_files \
	  build/Coverage/$(test).profraw \
	  build/Coverage/$(test).profraw && \
	$(llvm)/bin/llvm-profdata merge \
	  -sparse build/Coverage/$(test).profraw \
	  -o build/Coverage/$(test).profdata && \
	$(llvm)/bin/llvm-cov show build/Coverage/$(test) \
	  -instr-profile=build/Coverage/$(test).profdata && \
	$(llvm)/bin/llvm-cov report build/Coverage/$(test) \
	  -instr-profile=build/Coverage/$(test).profdata

configure: build/build.ninja

build/build.ninja: CMakeLists.txt
	@cmake --no-warn-unused-cli -G "Ninja Multi-Config" \
	  -DCMAKE_CONFIGURATION_TYPES="Debug;Release;MinSizeRel;RelWithDebInfo;Coverage" \
	  -DCMAKE_TOOLCHAIN_FILE="$(llvm)/$(root).cmake" \
	  -DBUILD_SHARED_LIBS="$(shared)" \
	  -B build

clean:
	@cmake -E remove_directory build

phony:

.PHONY: all run debug test configure clean phony

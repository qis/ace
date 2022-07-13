preset ?= default
config ?= debug
params ?= 128

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

ifeq ($(OS),Windows_NT)
exe := .exe
endif

build: configure
	@cmake --build build --config $(output)

run: build
	@cmake -E chdir build $(output)/main$(exe) $(params)

test: build
	@ctest --test-dir build -C $(output)

debug: build
	@cmake -E chdir build $(ACE)/bin/lldb -l lua -b -k bt \
	  -o 'settings set auto-confirm 1' -o 'run' -o 'quit' \
	  $(output)/main$(exe) $(params)

coverage: configure
	@cmake --build build --config Coverage
	@cmake -E chdir build Coverage/main$(exe) $(params)
	@cmake -E compare_files build/default.profraw build/default.profraw && \
	$(ACE)/bin/llvm-profdata merge \
	  -sparse build/default.profraw -o build/default.profdata && \
	$(ACE)/bin/llvm-cov show build/Coverage/main$(exe) \
	  -instr-profile=build/default.profdata && \
	$(ACE)/bin/llvm-cov report build/Coverage/main$(exe) \
	  -instr-profile=build/default.profdata

install: build/build.ninja
	@cmake --build build --config Release --target install

format:
	@cmake -P $(ACE)/format.cmake src

clean:
	@cmake -E remove_directory build

preset:
	@cmake --list-presets=configure

configure: build/build.ninja

build/build.ninja: CMakeLists.txt
	@cmake -B build --preset $(preset)

.PHONY: build run test coverage install format clean preset configure

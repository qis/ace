MAKEFLAGS += --no-print-directory

all:
	@cmake -E echo "usage:"
	@cmake -E echo ""
	@cmake -E echo "  make tools sys"
	@cmake -E echo ""

# figlet -t system
# _____________  _  _______________________________________________________________________________
#  ___ _   _ ___| |_ ___ _ __ ___
# / __| | | / __| __/ _ \ '_ ` _ \
# \__ \ |_| \__ \ ||  __/ | | | | |
# |___/\__, |___/\__\___|_| |_| |_| _______________________________________________________________
#      |___/

ifneq ($(OS),Windows_NT)
TARGET ?= x86_64-pc-linux-gnu
else
TARGET ?= x86_64-pc-windows-msvc
endif

PARALLEL_LINK_JOBS ?= 2

LLVM_VER := 14.0.6
LLVM_GIT := https://github.com/llvm/llvm-project
LLVM_URL := $(LLVM_GIT)/releases/download/llvmorg-$(LLVM_VER)
LLVM_SRC := $(LLVM_URL)/llvm-project-$(LLVM_VER).src.tar.xz

YASM_VER := 1.3.0
YASM_SRC := http://www.tortall.net/projects/yasm/releases/yasm-$(YASM_VER).tar.gz

WASI_SHA := 30094b6
WASI_URL := https://github.com/WebAssembly/wasi-libc/archive
WASI_SRC := $(WASI_URL)/$(WASI_SHA).tar.gz

WASM_VER := 109
WASM_URL := https://github.com/WebAssembly/binaryen/releases/download/version_$(WASM_VER)

VLLS_VER := 3.4.2
VLLS_URL := https://github.com/sumneko/lua-language-server/releases/download/$(VLLS_VER)

NVIM_VER := 0.7.2
NVIM_URL := https://github.com/neovim/neovim/releases/download/v$(NVIM_VER)

LIBCXX_CMAKE_MATCH := set\(LIBCXX_COMPILE_FLAGS ""\)
LIBCXX_CMAKE_SUBST := set\(LIBCXX_COMPILE_FLAGS "$${LIBCXX_COMPILE_FLAGS_INIT}"\)

LIBCXX_CONFIG_MATCH := ^\s*\/\*\s*\#undef\s+_LIBCPP_HAS_PARALLEL_ALGORITHMS.*
LIBCXX_CONFIG_SUBST := \#define _LIBCPP_HAS_PARALLEL_ALGORITHMS

src/llvm:
	@git clone -c advice.detachedHead=false \
	  --depth 1 --recurse-submodules --shallow-submodules \
	  $(LLVM_GIT) src/llvm

include src/$(TARGET).mk

#  _  ________  _  ________________________________________________________________________________
# | |_ ___  ___| |_
# | __/ _ \/ __| __|
# | ||  __/\__ \ |_
#  \__\___||___/\__| ______________________________________________________________________________
#

test/lib:
	$(MAKE) -C src/tests/lib ACE="$(CURDIR)" preset=shared clean configure
	$(MAKE) -C src/tests/lib ACE="$(CURDIR)" preset=shared config=release run
	$(MAKE) -C src/tests/lib ACE="$(CURDIR)" clean configure
	$(MAKE) -C src/tests/lib ACE="$(CURDIR)" config=debug run
	$(MAKE) -C src/tests/lib ACE="$(CURDIR)" config=release run
	$(MAKE) -C src/tests/lib ACE="$(CURDIR)" config=minsizerel run
	$(MAKE) -C src/tests/lib ACE="$(CURDIR)" config=relwithdebinfo run
	$(MAKE) -C src/tests/lib ACE="$(CURDIR)" coverage

test/web:
	$(MAKE) -C src/tests/web ACE="$(CURDIR)" clean configure
	$(MAKE) -C src/tests/web ACE="$(CURDIR)" config=debug build
	$(MAKE) -C src/tests/web ACE="$(CURDIR)" config=release build
	$(MAKE) -C src/tests/web ACE="$(CURDIR)" config=minsizerel build
	$(MAKE) -C src/tests/web ACE="$(CURDIR)" config=relwithdebinfo build

test: test/lib test/web

.PHONY: test test/lib test/web

# ____  _  ________________________________________________________________________________________
#   ___| | ___  __ _ _ __
#  / __| |/ _ \/ _` | '_ \
# | (__| |  __/ (_| | | | |
#  \___|_|\___|\__,_|_| |_| _______________________________________________________________________
#

EXTRA_PORTS := angle backtrace editline wineditline

CLEAN_TESTS_TARGETS := $(patsubst %,clean/%, $(TESTS) web)

clean/%: phony
	@$(MAKE) -C src/tests/$* clean

clean: $(CLEAN_TESTS_TARGETS)
	@$(MAKE) -C src/ports ACE="$(CURDIR)" clean
	@$(MAKE) -C src/ports ACE="$(CURDIR)" PORTS="$(EXTRA_PORTS)" clean
	@cmake -E remove_directory \
	  build/share \
	  build/binaryen \
	  build/builtins \
	  build/runtimes \
	  build/compiler-rt \
	  build/pstl \
	  build/make \
	  build/wasi \
	  build/deb \
	  build/lua \
	  build/usr \
	  build/web

clean/src: clean
	@$(MAKE) -C src/ports ACE="$(CURDIR)" clean/src
	@$(MAKE) -C src/ports ACE="$(CURDIR)" PORTS="$(EXTRA_PORTS)" clean/src

.PHONY: clean clean/src

# __________________  _  __________________________________________________________________________
#  _ __ ___  ___  ___| |_
# | '__/ _ \/ __|/ _ \ __|
# | | |  __/\__ \  __/ |_
# |_|  \___||___/\___|\__| ________________________________________________________________________
#

ifneq ($(OS),Windows_NT)
reset/bin:
	@cmake -E remove_directory bin
else
reset/bin:
	@cmd /C start /B cmd /C "cmake -E sleep 1 && cmake -E remove_directory bin"
endif

reset: clean/src
	@cmake -E remove_directory build lib sys/wasm32-wasi \
	  sys/x86_64-pc-linux-gnu sys/x86_64-pc-windows-msvc
	@$(MAKE) reset/bin

.PHONY: reset

# _____  _  _______________________________________________________________________________________
#  _ __ | |__   ___  _ __  _   _
# | '_ \| '_ \ / _ \| '_ \| | | |
# | |_) | | | | (_) | | | | |_| |
# | .__/|_| |_|\___/|_| |_|\__, | _________________________________________________________________
# |_|                      |___/

phony:

.PHONY: phony

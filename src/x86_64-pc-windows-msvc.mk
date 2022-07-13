ifneq ($(TARGET),x86_64-pc-windows-msvc)
$(error Invalid TARGET value)
endif

ifneq ($(OS),Windows_NT)
$(error This target must be compiled on Windows)
endif

ARCH := $(shell cmake -P src/arch.cmake 2>&1)
ROOT := $(CURDIR)/sys/$(TARGET)

# ___  _  _________________  _  _____________  _  _________________________________________________
#   __| | _____      ___ __ | | ___   __ _  __| |
#  / _` |/ _ \ \ /\ / / '_ \| |/ _ \ / _` |/ _` |
# | (_| | (_) \ V  V /| | | | | (_) | (_| | (_| |
#  \__,_|\___/ \_/\_/ |_| |_|_|\___/ \__,_|\__,_| _________________________________________________
#

LLVM_BIN := $(LLVM_URL)/LLVM-$(LLVM_VER)-win64.exe
WASM_SRC := $(WASM_URL)/binaryen-version_$(WASM_VER)-x86_64-windows.tar.gz
VLLS_SRC := $(VLLS_URL)/lua-language-server-$(VLLS_VER)-win32-x64.zip
NVIM_SRC := $(NVIM_URL)/nvim-win64.zip

build/llvm.exe:
	@cmake -E make_directory build
	@curl -L $(LLVM_BIN) -o $@ || cmake -E remove -f $@

build/stage/bin/clang.exe: build/llvm.exe
	@7z -obuild/stage x $<
	@cmake -E remove -f build/stage/bin/llvm-rc.exe
	@cmake -E touch_nocreate $@

build/yasm.tar:
	@cmake -E make_directory build
	@curl -L $(YASM_SRC) -o $@ || cmake -E remove -f $@

build/yasm: build/yasm.tar
	@cmake -E make_directory $@
	@tar xf $< -C $@ -m --strip-components=1

build/llvm.tar.xz:
	@cmake -E make_directory build
	@curl -L $(LLVM_SRC) -o $@ || cmake -E remove -f $@

build/llvm.tar: build/llvm.tar.xz
	@7z -obuild x $<

build/llvm: build/llvm.tar
	@cmake -E make_directory $@
	@tar xf $< -C $@ -m --strip-components=1

build/binaryen.tar.gz:
	@cmake -E make_directory build
	@curl -L $(WASM_SRC) -o $@ || cmake -E remove -f $@

build/binaryen: build/binaryen.tar.gz
	@cmake -E make_directory $@
	@tar xf $< -C $@ -m --strip-components=1

build/vlls.zip:
	@cmake -E make_directory build
	@curl -L $(VLLS_SRC) -o $@ || cmake -E remove -f $@

build/nvim.zip:
	@cmake -E make_directory build
	@curl -L $(NVIM_SRC) -o $@ || cmake -E remove -f $@

dev: build/vlls.zip build/nvim.zip
	@cmake -E make_directory $@
	@tar xf build/vlls.zip -C $@ -m
	@tar xf build/nvim.zip -C $@ -m --strip-components=1

#  _  __________  _  ___________________________________________________________________________
# | |_ ___   ___ | |___
# | __/ _ \ / _ \| / __|
# | || (_) | (_) | \__ \
#  \__\___/ \___/|_|___/ _______________________________________________________________________
#

stage: build/stage/bin/clang.exe

.PHONY: stage

SYSTEM := $(CURDIR)/bin
SYSTEM := $(SYSTEM);$(ROOT)/tools
SYSTEM := $(SYSTEM);$(ROOT)/sdk/bin
SYSTEM := $(SYSTEM);$(CURDIR)/build/stage/bin
SYSTEM := $(SYSTEM);$(CURDIR)/build/usr/bin

INCLUDE := $(ROOT)/include
INCLUDE := $(INCLUDE);$(ROOT)/crt/include
INCLUDE := $(INCLUDE);$(ROOT)/sdk/include/shared
INCLUDE := $(INCLUDE);$(ROOT)/sdk/include/ucrt
INCLUDE := $(INCLUDE);$(ROOT)/sdk/include/um
INCLUDE := $(INCLUDE);$(CURDIR)/build/usr/include

LIBPATH := $(ROOT)/lib
LIBPATH := $(LIBPATH);$(ROOT)/crt/lib
LIBPATH := $(LIBPATH);$(ROOT)/sdk/lib/ucrt
LIBPATH := $(LIBPATH);$(ROOT)/sdk/lib/um
LIBPATH := $(LIBPATH);$(CURDIR)/build/usr/lib

bin/yasm.exe: build/yasm
	@cmake -E echo "Configuring yasm ..." 1>&2
	@cmake -E env \
	 PATH="$(SYSTEM);$(PATH)" \
	 INCLUDE="$(INCLUDE)" \
	 LIBPATH="$(LIBPATH)" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/toolchain.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/build/usr" \
	  -DBUILD_SHARED_LIBS=OFF \
	  -DYASM_BUILD_TESTS=OFF \
	  -B build/yasm/build build/yasm

yasm: bin/yasm.exe
	@cmake -E echo "Installing yasm ..." 1>&2
	@ninja -C build/yasm/build install
	@cmake -E make_directory bin
	@cmake -E copy build/usr/bin/yasm.exe bin

.PHONY: yasm

src/ports/lua/src:
	@$(MAKE) -C src/ports/lua src

build/lua/build.ninja: src/ports/lua/src
	@cmake -E echo "Configuring lua ..." 1>&2
	@cmake -E env \
	 PATH="$(SYSTEM);$(PATH)" \
	 INCLUDE="$(INCLUDE)" \
	 LIBPATH="$(LIBPATH)" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/toolchain.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/build/usr" \
	  -DBUILD_SHARED_LIBS=ON \
	  -DLUA_SKIP_SHARED=ON \
	  -DLUA_SKIP_TOOLS=ON \
	  -B build/lua src/ports/lua

build/usr/include/lua/lua.h: build/lua/build.ninja
	@cmake -E echo "Installing lua ..." 1>&2
	@ninja -C build/lua install

lua: build/usr/include/lua/lua.h

.PHONY: lua

# CMAKE_RC_FLAGS - disables duplicated /nologo flag

build/tools/build.ninja: build/llvm
	@cmake -E echo "Configuring tools ..." 1>&2
	@cmake -E env \
	 PATH="$(SYSTEM);$(PATH)" \
	 INCLUDE="$(INCLUDE)" \
	 LIBPATH="$(LIBPATH)" \
	 CFLAGS="/DLIBXML_STATIC /DLZMA_API_STATIC /DLIBCHARSET_DLL_EXPORTED=" \
	 CXXFLAGS="/DLIBXML_STATIC /DLZMA_API_STATIC /DLIBCHARSET_DLL_EXPORTED=" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_RC_FLAGS="-DWIN32" \
	  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
	  -DCMAKE_SYSTEM_PROGRAM_PATH="$(SYSTEM)" \
	  -DCMAKE_SYSTEM_INCLUDE_PATH="$(INCLUDE)" \
	  -DCMAKE_SYSTEM_LIBRARY_PATH="$(LIBPATH)" \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/toolchain.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)" \
	  -DCMAKE_INSTALL_DATAROOTDIR="$(CURDIR)/build/share" \
	  -DLLVM_DEFAULT_TARGET_TRIPLE="$(TARGET)" \
	  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;polly;lld;lldb" \
	  -DLLVM_ENABLE_BINDINGS=OFF \
	  -DLLVM_ENABLE_DOXYGEN=OFF \
	  -DLLVM_ENABLE_LTO="Full" \
	  -DLLVM_ENABLE_WARNINGS=OFF \
	  -DLLVM_INCLUDE_BENCHMARKS=OFF \
	  -DLLVM_INCLUDE_EXAMPLES=OFF \
	  -DLLVM_INCLUDE_TESTS=OFF \
	  -DLLVM_INCLUDE_DOCS=OFF \
	  -DLLVM_PARALLEL_LINK_JOBS="$(PARALLEL_LINK_JOBS)" \
	  -DLLVM_TARGETS_TO_BUILD="X86;ARM;AArch64;WebAssembly" \
	  -DCLANG_DEFAULT_STD_C="c11" \
	  -DCLANG_DEFAULT_STD_CXX="cxx20" \
	  -DCLANG_DEFAULT_CXX_STDLIB="libc++" \
	  -DCLANG_DEFAULT_RTLIB="compiler-rt" \
	  -DCLANG_DEFAULT_UNWINDLIB="none" \
	  -DCLANG_DEFAULT_LINKER="lld" \
	  -DLLDB_ENABLE_PYTHON=OFF \
	  -DLLDB_ENABLE_LUA=ON \
	  -DLUA_INCLUDE_DIR="$(CURDIR)/build/usr/include/lua" \
	  -DLUA_LIBRARIES="$(CURDIR)/build/usr/lib/static/lua.lib" \
	  -DDEFAULT_SYSROOT="../sys/$(TARGET)" \
	  -B build/tools build/llvm/llvm

bin/clang.exe: build/tools/build.ninja
	@cmake -E echo "Installing tools ..." 1>&2
	@cmake -E env \
	 PATH="$(SYSTEM);$(PATH)" \
	 INCLUDE="$(INCLUDE)" \
	 LIBPATH="$(LIBPATH)" \
	 bin/ninja.exe -C build/tools \
	  install-LTO-stripped \
	  install-lld-stripped \
	  install-llvm-ar-stripped \
	  install-llvm-nm-stripped \
	  install-llvm-lib-stripped \
	  install-llvm-objcopy-stripped \
	  install-llvm-objdump-stripped \
	  install-llvm-ranlib-stripped \
	  install-llvm-strip-stripped \
	  install-llvm-size-stripped \
	  install-llvm-cov-stripped \
	  install-llvm-dwarfdump-stripped \
	  install-llvm-profdata-stripped \
	  install-llvm-strings-stripped \
	  install-llvm-symbolizer-stripped \
	  install-llvm-xray-stripped \
	  install-clang-stripped \
	  install-clang-resource-headers \
	  install-clang-format-stripped \
	  install-clang-tidy-stripped \
	  install-clangd-stripped \
	  install-liblldb-stripped \
	  llvm-config
	@cmake -E env \
	 PATH="$(SYSTEM);$(PATH)" \
	 INCLUDE="$(INCLUDE)" \
	 LIBPATH="$(LIBPATH)" \
	 bin/ninja.exe -C build/tools \
	  install-lldb-lua-library-stripped \
	  install-lldb-instr-stripped \
	  install-lldb-server-stripped \
	  install-lldb-vscode-stripped \
	  install-lldb-stripped
	@cmake -E remove -f bin/git-clang-format
	@cmake -E remove -f bin/run-clang-tidy
	@cmake -E remove_directory include

bin/wasm2js.exe: build/binaryen
	@cmake -E copy $</$@ bin

bin/wasm-opt.exe: build/binaryen
	@cmake -E copy $</$@ bin

bin/wasm-reduce.exe: build/binaryen
	@cmake -E copy $</$@ bin

tools: stage yasm lua bin/clang.exe bin/wasm2js.exe bin/wasm-opt.exe bin/wasm-reduce.exe
	@cmake -E echo "Creating tools-windows.tar.gz ..." 1>&2
	@tar czf tools-windows.tar.gz bin lib

.PHONY: tools

# ____  _  ______________________  __  ________________________  _  _______________________________
#   ___| | __ _ _ __   __ _       / _| ___  _ __ _ __ ___   __ _| |_
#  / __| |/ _` | '_ \ / _` |_____| |_ / _ \| '__| '_ ` _ \ / _` | __|
# | (__| | (_| | | | | (_| |_____|  _| (_) | |  | | | | | | (_| | |_
#  \___|_|\__,_|_| |_|\__, |     |_|  \___/|_|  |_| |_| |_|\__,_|\__| _____________________________
#                     |___/

build/clang-format/build.ninja: src/llvm
	@cmake -E echo "Configuring clang-format ..." 1>&2
	@cmake -E env \
	 PATH="$(SYSTEM);$(PATH)" \
	 INCLUDE="$(INCLUDE)" \
	 LIBPATH="$(LIBPATH)" \
	 CFLAGS="/DLIBXML_STATIC /DLZMA_API_STATIC /DLIBCHARSET_DLL_EXPORTED=" \
	 CXXFLAGS="/DLIBXML_STATIC /DLZMA_API_STATIC /DLIBCHARSET_DLL_EXPORTED=" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_RC_FLAGS="-DWIN32" \
	  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
	  -DCMAKE_SYSTEM_PROGRAM_PATH="$(SYSTEM)" \
	  -DCMAKE_SYSTEM_INCLUDE_PATH="$(INCLUDE)" \
	  -DCMAKE_SYSTEM_LIBRARY_PATH="$(LIBPATH)" \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/toolchain.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)" \
	  -DCMAKE_INSTALL_DATAROOTDIR="$(CURDIR)/build/share" \
	  -DLLVM_ENABLE_PROJECTS="clang" \
	  -DLLVM_ENABLE_BINDINGS=OFF \
	  -DLLVM_ENABLE_DOXYGEN=OFF \
	  -DLLVM_ENABLE_WARNINGS=OFF \
	  -DLLVM_INCLUDE_BENCHMARKS=OFF \
	  -DLLVM_INCLUDE_EXAMPLES=OFF \
	  -DLLVM_INCLUDE_TESTS=OFF \
	  -DLLVM_INCLUDE_DOCS=OFF \
	  -DLLVM_TARGETS_TO_BUILD="X86" \
	  -DCLANG_DEFAULT_STD_C="c11" \
	  -DCLANG_DEFAULT_STD_CXX="cxx20" \
	  -B build/clang-format src/llvm/llvm

clang-format: build/clang-format/build.ninja
	@cmake -E echo "Installing clang-format ..." 1>&2
	@cmake -E env \
	 PATH="$(SYSTEM);$(PATH)" \
	 INCLUDE="$(INCLUDE)" \
	 LIBPATH="$(LIBPATH)" \
	 ninja -C build/clang-format \
	  install-clang-format-stripped
	@cmake -E remove -f bin/git-clang-format
	@cmake -E echo "Creating tools-windows-clang-format.tar.gz ..." 1>&2
	@tar czf tools-windows-clang-format.tar.gz bin/clang-format.exe

.PHONY: clang-format

#  ___ _   _ ___  _________________________________________________________________________________
# / __| | | / __|
# \__ \ |_| \__ \
# |___/\__, |___/ _________________________________________________________________________________
#      |___/

# CMAKE_PREFIX_PATH - disable search path restrictions
# CMAKE_BUILD_TYPE=MinSizeRel - replaces /MT with /MD

build/compiler-rt/build.ninja:
	@cmake -E echo "Configuring compiler-rt ..." 1>&2
	@cmake -E env \
	 PATH="$(SYSTEM);$(PATH)" \
	 CFLAGS="-Wno-unused-command-line-argument" \
	 CXXFLAGS="-Wno-unused-command-line-argument" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_PREFIX_PATH="" \
	  -DCMAKE_BUILD_TYPE=MinSizeRel \
	  -DCMAKE_C_COMPILER_TARGET="$(TARGET)" \
	  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/toolchain.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/sys/$(TARGET)/crt" \
	  -DLLVM_CONFIG_PATH="$(CURDIR)/build/tools/bin/llvm-config" \
	  -DLLVM_ENABLE_RUNTIMES="compiler-rt" \
	  -DLLVM_ENABLE_WARNINGS=OFF \
	  -DLLVM_INCLUDE_TESTS=OFF \
	  -DLLVM_INCLUDE_DOCS=OFF \
	  -DCOMPILER_RT_DEFAULT_TARGET_ARCH="$(ARCH)" \
	  -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
	  -DCOMPILER_RT_BUILD_BUILTINS=OFF \
	  -DCOMPILER_RT_BUILD_SANITIZERS=ON \
	  -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
	  -DCOMPILER_RT_BUILD_PROFILE=ON \
	  -DCOMPILER_RT_BUILD_XRAY=ON \
	  -B build/compiler-rt build/llvm/runtimes

win/crt/lib/clang_rt.profile.lib: build/compiler-rt/build.ninja
	@cmake -E echo "Installing compiler-rt ..." 1>&2
	@cmake -E env \
	 PATH="$(SYSTEM);$(PATH)" \
	 bin/ninja.exe -C build/compiler-rt \
	  install-compiler-rt-headers \
	  install-compiler-rt-stripped
	@cmake -E copy_directory sys/$(TARGET)/crt/lib/windows lib/clang/$(LLVM_VER)/lib
	@move sys\$(TARGET)\crt\lib\windows\* sys\$(TARGET)\crt\lib
	@rd /q /s sys\$(TARGET)\crt\lib\windows

sys:	win/crt/lib/clang_rt.profile.lib
	@cmake -E echo "Creating sys-$(TARGET).tar.gz ..." 1>&2
	@tar czf sys-$(TARGET).tar.gz \
	  sys/$(TARGET)

.PHONY: sys

# ________________  _  ____________________________________________________________________________
#  _ __   ___  _ __| |_ ___
# | '_ \ / _ \| '__| __/ __|
# | |_) | (_) | |  | |_\__ \
# | .__/ \___/|_|   \__|___/ ______________________________________________________________________
# |_|

ports:
	@cmake -E echo "Creating sys-$(TARGET)-ports.tar.gz ..." 1>&2
	@cmake -E make_directory \
	  sys/$(TARGET)/bin \
	  sys/$(TARGET)/cmake \
	  sys/$(TARGET)/include \
	  sys/$(TARGET)/lib \
	  sys/$(TARGET)/share \
	  sys/$(TARGET)/tools
	@tar czf sys-$(TARGET)-ports.tar.gz \
	  sys/$(TARGET)/bin \
	  sys/$(TARGET)/cmake \
	  sys/$(TARGET)/include \
	  sys/$(TARGET)/lib \
	  sys/$(TARGET)/share \
	  sys/$(TARGET)/tools

.PHONY: ports

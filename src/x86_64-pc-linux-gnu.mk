ifneq ($(TARGET),x86_64-pc-linux-gnu)
$(error Invalid TARGET value)
endif

ifeq ($(OS),Windows_NT)
$(error This target must be compiled on Linux)
endif

ARCH := $(shell cmake -P src/arch.cmake 2>&1)
ROOT := $(CURDIR)/sys/$(TARGET)

# ___________  _   _  _____________________________________________________________________________
#   ___  _ __ | |_(_) ___  _ __  ___
#  / _ \| '_ \| __| |/ _ \| '_ \/ __|
# | (_) | |_) | |_| | (_) | | | \__ \
#  \___/| .__/ \__|_|\___/|_| |_|___/ _____________________________________________________________
#       |_|

# Based on https://packages.debian.org/stable/linux-headers-amd64 information.
LINUX_VERSION ?= 5.10.0-13

# ___  _  _________________  _  _____________  _  _________________________________________________
#   __| | _____      ___ __ | | ___   __ _  __| |
#  / _` |/ _ \ \ /\ / / '_ \| |/ _ \ / _` |/ _` |
# | (_| | (_) \ V  V /| | | | | (_) | (_| | (_| |
#  \__,_|\___/ \_/\_/ |_| |_|_|\___/ \__,_|\__,_| _________________________________________________
#

WASM_SRC := $(WASM_URL)/binaryen-version_$(WASM_VER)-x86_64-linux.tar.gz
VLLS_SRC := $(VLLS_URL)/lua-language-server-$(VLLS_VER)-linux-x64.tar.gz
NVIM_SRC := $(NVIM_URL)/nvim-linux64.tar.gz

build/llvm.tar.xz:
	@mkdir -p build
	@wget -c -nc -q --show-progress --no-use-server-timestamps \
	  "$(LLVM_SRC)" -O $@ || (rm -f $@; false)

build/llvm: build/llvm.tar.xz
	@mkdir -p $@
	@tar xf $< -C $@ -m --strip-components=1 || (rm -rf $@; false)

build/binaryen.tar.gz:
	@mkdir -p build
	@wget -c -nc -q --show-progress --no-use-server-timestamps \
	  "$(WASM_SRC)" -O $@ || (rm -f $@; false)

build/binaryen: build/binaryen.tar.gz
	@mkdir -p $@
	@tar xf $< -C $@ -m --strip-components=1 || (rm -rf $@; false)

build/vlls.tar.gz:
	@mkdir -p build
	@wget -c -nc -q --show-progress --no-use-server-timestamps \
	  "$(VLLS_SRC)" -O $@ || (rm -f $@; false)

build/nvim.tar.gz:
	@mkdir -p build
	@wget -c -nc -q --show-progress --no-use-server-timestamps \
	  "$(NVIM_SRC)" -O $@ || (rm -f $@; false)

dev: build/vlls.tar.gz build/nvim.tar.gz
	@mkdir -p $@
	@tar xf build/vlls.tar.gz -C $@ -m
	@tar xf build/nvim.tar.gz -C $@ -m  --strip-components=1

#  _  __________  _  ___________________________________________________________________________
# | |_ ___   ___ | |___
# | __/ _ \ / _ \| / __|
# | || (_) | (_) | \__ \
#  \__\___/ \___/|_|___/ _______________________________________________________________________
#

build/stage/build.ninja: build/llvm
	@echo "Configuring stage ..." 1>&2
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)" \
	  -DLLVM_DEFAULT_TARGET_TRIPLE="$(TARGET)" \
	  -DLLVM_ENABLE_PROJECTS="clang;lld" \
	  -DLLVM_ENABLE_RUNTIMES="compiler-rt;libunwind;libcxxabi;libcxx" \
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
	  -DCLANG_DEFAULT_CXX_STDLIB="libc++" \
	  -DCLANG_DEFAULT_RTLIB="compiler-rt" \
	  -DCLANG_DEFAULT_UNWINDLIB="none" \
	  -DCLANG_DEFAULT_LINKER="lld" \
	  -DCOMPILER_RT_BUILD_BUILTINS=ON \
	  -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
	  -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
	  -DCOMPILER_RT_BUILD_PROFILE=OFF \
	  -DCOMPILER_RT_BUILD_XRAY=OFF \
	  -DLIBUNWIND_ENABLE_SHARED=OFF \
	  -DLIBUNWIND_ENABLE_STATIC=ON \
	  -DLIBUNWIND_USE_COMPILER_RT=ON \
	  -DLIBCXXABI_ENABLE_SHARED=OFF \
	  -DLIBCXXABI_ENABLE_STATIC=ON \
	  -DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
	  -DLIBCXXABI_STATICALLY_LINK_UNWINDER_IN_SHARED_LIBRARY=ON \
	  -DLIBCXXABI_STATICALLY_LINK_UNWINDER_IN_STATIC_LIBRARY=ON \
	  -DLIBCXXABI_USE_COMPILER_RT=ON \
	  -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
	  -DLIBCXX_ABI_UNSTABLE=ON \
	  -DLIBCXX_ABI_VERSION=2 \
	  -DLIBCXX_ENABLE_EXPERIMENTAL_LIBRARY=OFF \
	  -DLIBCXX_ENABLE_INCOMPLETE_FEATURES=ON \
	  -DLIBCXX_ENABLE_SHARED=OFF \
	  -DLIBCXX_ENABLE_STATIC=ON \
	  -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
	  -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
	  -DLIBCXX_USE_COMPILER_RT=ON \
	  -B build/stage build/llvm/llvm

build/stage/bin/clang: build/stage/build.ninja
	@echo "Building stage ..." 1>&2
	@ninja -C build/stage \
	  LTO \
	  lld \
	  llvm-ar \
	  llvm-nm \
	  llvm-objcopy \
	  llvm-objdump \
	  llvm-ranlib \
	  llvm-strip \
	  llvm-size \
	  clang \
	  clang-resource-headers \
	  llvm-config \
	  runtimes

stage: build/stage/bin/clang

.PHONY: stage

src/ports/lua/src:
	@$(MAKE) -C src/ports/lua src

build/lua/build.ninja: src/ports/lua/src
	@cmake -E echo "Configuring lua ..." 1>&2
	@cmake -E env \
	 PATH="$(CURDIR)/build/stage/bin:$${PATH}" \
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
	@ninja -C build/lua install

lua: build/usr/include/lua/lua.h

.PHONY: lua

# CMAKE_PREFIX_PATH - disable search path restrictions
# CMAKE_FIND_ROOT_PATH - disable search path restrictions

build/tools/build.ninja:
	@echo "Configuring tools ..." 1>&2
	@cmake -E env \
	 PATH="$(CURDIR)/build/stage/bin:$${PATH}" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_PREFIX_PATH="" \
	  -DCMAKE_FIND_ROOT_PATH="" \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
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
	  -DLUA_LIBRARIES="$(CURDIR)/build/usr/lib/liblua.a" \
	  -DDEFAULT_SYSROOT="../sys/$(TARGET)" \
	  -B build/tools build/llvm/llvm

bin/clang: build/tools/build.ninja
	@echo "Installing tools ..." 1>&2
	@ninja -C build/tools \
	  install-LTO-stripped \
	  install-lld-stripped \
	  install-llvm-ar-stripped \
	  install-llvm-nm-stripped \
	  install-llvm-mt-stripped \
	  install-llvm-rc-stripped \
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
	  install-lldb-lua-library-stripped \
	  install-lldb-instr-stripped \
	  install-lldb-server-stripped \
	  install-lldb-vscode-stripped \
	  install-lldb-stripped \
	  llvm-config
	@rm -f bin/git-clang-format
	@rm -f bin/run-clang-tidy
	@rm -rf include

bin/wasm2js: build/binaryen
	@cp $</$@ $@

bin/wasm-opt: build/binaryen
	@cp $</$@ $@

bin/wasm-reduce: build/binaryen
	@cp $</$@ $@

# Runtime dependencies for tools executables.
#
# WARNING: Do not include libraries provided by the libc6 package in this list!
#
lib/libxml2.so.2:
	@cp $(shell readlink -f /lib/x86_64-linux-gnu/libgcc_s.so.1) lib/libgcc_s.so.1
	@cp $(shell readlink -f /lib/x86_64-linux-gnu/liblzma.so.5) lib/liblzma.so.5
	@cp $(shell readlink -f /lib/x86_64-linux-gnu/libncurses.so.6) lib/libncurses.so.6
	@cp $(shell readlink -f /lib/x86_64-linux-gnu/libtinfo.so.6) lib/libtinfo.so.6
	@cp $(shell readlink -f /lib/x86_64-linux-gnu/libz.so.1) lib/libz.so.1
	@cp $(shell readlink -f /usr/lib/x86_64-linux-gnu/libbsd.so.0) lib/libbsd.so.0
	@cp $(shell readlink -f /usr/lib/x86_64-linux-gnu/libedit.so.2) lib/libedit.so.2
	@cp $(shell readlink -f /usr/lib/x86_64-linux-gnu/libform.so.6) lib/libform.so.6
	@cp $(shell readlink -f /usr/lib/x86_64-linux-gnu/libicudata.so.67) lib/libicudata.so.67
	@cp $(shell readlink -f /usr/lib/x86_64-linux-gnu/libicuuc.so.67) lib/libicuuc.so.67
	@cp $(shell readlink -f /usr/lib/x86_64-linux-gnu/libmd.so.0) lib/libmd.so.0
	@cp $(shell readlink -f /usr/lib/x86_64-linux-gnu/libpanel.so.6) lib/libpanel.so.6
	@cp $(shell readlink -f /usr/lib/x86_64-linux-gnu/libstdc++.so.6) lib/libstdc++.so.6
	@cp $(shell readlink -f /usr/lib/x86_64-linux-gnu/libxml2.so.2) lib/libxml2.so.2
	@find lib -maxdepth 1 -type f -name '*.so*' -exec patchelf --set-rpath '$$ORIGIN' '{}' ';'
	@find lib -maxdepth 1 -type f -name '*.so*' -exec chmod 0644 '{}' ';'

tools: stage lua bin/clang bin/wasm2js bin/wasm-opt bin/wasm-reduce lib/libxml2.so.2
	@echo "Creating tools-linux.tar.gz ..." 1>&2
	@tar czf tools-linux.tar.gz bin lib

.PHONY: tools

# ____  _  ______________________  __  ________________________  _  _______________________________
#   ___| | __ _ _ __   __ _       / _| ___  _ __ _ __ ___   __ _| |_
#  / __| |/ _` | '_ \ / _` |_____| |_ / _ \| '__| '_ ` _ \ / _` | __|
# | (__| | (_| | | | | (_| |_____|  _| (_) | |  | | | | | | (_| | |_
#  \___|_|\__,_|_| |_|\__, |     |_|  \___/|_|  |_| |_| |_|\__,_|\__| _____________________________
#                     |___/

build/clang-format/build.ninja: src/llvm
	@echo "Configuring clang-format ..." 1>&2
	@cmake -E env \
	 PATH="$(CURDIR)/build/stage/bin:$${PATH}" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_PREFIX_PATH="" \
	  -DCMAKE_FIND_ROOT_PATH="" \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
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
	@echo "Installing clang-format ..." 1>&2
	@ninja -C build/clang-format \
	  install-clang-format-stripped
	@rm -f bin/git-clang-format
	@echo "Creating tools-linux-clang-format.tar.gz ..." 1>&2
	@tar czf tools-linux-clang-format.tar.gz bin/clang-format

.PHONY: clang-format

#  ___ _   _ ___  _________________________________________________________________________________
# / __| | | / __|
# \__ \ |_| \__ \
# |___/\__, |___/ _________________________________________________________________________________
#      |___/

# Based on https://packages.debian.org/stable/libc-dev information.
# Use the following commands to figure out what's needed:
#
#   apt-file search <path>
#   apt-cache depends -i <package>
#   apt-cache depends -i --recurse <package>
#

# Kernel headers.
PACKAGES := linux-headers-$(LINUX_VERSION)-amd64
PACKAGES += linux-headers-$(LINUX_VERSION)-common

# System libraries.
PACKAGES += libdbus-1-dev libdbus-1-3
PACKAGES += libsystemd-dev libsystemd0
PACKAGES += libgcrypt20-dev libgcrypt20
PACKAGES += libgpg-error-dev libgpg-error0
PACKAGES += liblz4-dev liblz4-1
PACKAGES += liblzma-dev liblzma5
PACKAGES += libzstd-dev libzstd1

# Standard libraries.
PACKAGES += linux-libc-dev
PACKAGES += libc6-dev libc6
PACKAGES += libcrypt-dev libcrypt1
PACKAGES += libnsl-dev libnsl2
PACKAGES += libtirpc-dev libtirpc3

# Compiler libraries.
PACKAGES += libgcc-10-dev
PACKAGES += libgcc-s1
PACKAGES += libitm1
PACKAGES += libatomic1
PACKAGES += libquadmath0

# Common libraries.
PACKAGES += libreadline-dev libreadline8 libtinfo6
PACKAGES += libncurses-dev libncurses6 libncursesw6

# Audio libraries.
PACKAGES += libasound2-dev libasound2
PACKAGES += libpulse-dev

# XCB libraries.
PACKAGES += libxcb1-dev libxcb1
PACKAGES += libxdmcp-dev libxdmcp6
PACKAGES += libxau-dev libxau6

# X11 libraries.
PACKAGES += libx11-dev libx11-6
PACKAGES += x11proto-dev
PACKAGES += xtrans-dev

# Wayland libraries.
PACKAGES += libwayland-dev
PACKAGES += libffi-dev libffi7
PACKAGES += libwayland-client0
PACKAGES += libwayland-server0
PACKAGES += libwayland-cursor0
PACKAGES += libwayland-egl1

# OpenGL libraries.
PACKAGES += libegl-dev libegl1
PACKAGES += libgles-dev libgles1 libgles2 libglvnd0
PACKAGES += libglx-dev libglx0
PACKAGES += libgl-dev libgl1

build/deb:
	@mkdir -p build/deb
	@cmake -E chdir build/deb apt download $(PACKAGES) symlinks

sys/$(TARGET)/usr/lib/x86_64-linux-gnu/libc.so: build/deb
	@echo "Creating sysroot ..." 1>&2
	@mkdir -p sys/$(TARGET)
	@find build/deb -name '*.deb' -exec dpkg-deb -x '{}' sys/$(TARGET) ';'
	@rm -rf sys/$(TARGET)/etc
	@rm -rf sys/$(TARGET)/lib/modules
	@rm -rf sys/$(TARGET)/usr/share
	@rm -f sys/$(TARGET)/usr/lib/x86_64-linux-gnu/libpulse*.so
	@rm -f sys/$(TARGET)/usr/lib/gcc/x86_64-linux-gnu/10/liblsan.so
	@rm -f sys/$(TARGET)/usr/lib/gcc/x86_64-linux-gnu/10/libubsan.so
	@rm -f sys/$(TARGET)/usr/lib/gcc/x86_64-linux-gnu/10/libasan.so
	@rm -f sys/$(TARGET)/usr/lib/gcc/x86_64-linux-gnu/10/libtsan.so
	@rm -f sys/$(TARGET)/usr/lib/gcc/x86_64-linux-gnu/10/libgomp.so
	@rm -f sys/$(TARGET)/usr/src/linux-headers-$(LINUX_VERSION)-amd64/scripts
	@rm -f sys/$(TARGET)/usr/src/linux-headers-$(LINUX_VERSION)-amd64/tools
	@rm -f sys/$(TARGET)/usr/src/linux-headers-$(LINUX_VERSION)-common/scripts
	@rm -f sys/$(TARGET)/usr/src/linux-headers-$(LINUX_VERSION)-common/tools
	@rm -rf sys/$(TARGET)/usr/src/linux-headers-$(LINUX_VERSION)-amd64/include/config
	@mv sys/$(TARGET)/usr/src/linux-headers-$(LINUX_VERSION)-common/include/soc/arc/aux.h \
	    sys/$(TARGET)/usr/src/linux-headers-$(LINUX_VERSION)-common/include/soc/arc/_aux.h
	@sed -E 's/soc\/arc\/aux\.h/soc\/arc\/_aux.h/g' -i \
	    sys/$(TARGET)/usr/src/linux-headers-$(LINUX_VERSION)-common/include/soc/arc/timers.h \
	    sys/$(TARGET)/usr/src/linux-headers-$(LINUX_VERSION)-common/include/soc/arc/mcip.h
	@find sys/$(TARGET) -name '*.a' -not -name libc_nonshared.a -delete
	@find sys/$(TARGET) -name 'libatomic*' -delete
	@unshare -r sh -c '/usr/sbin/chroot sys/$(TARGET) /usr/bin/symlinks -cr .' >/dev/null
	@unshare -r sh -c '/usr/sbin/chroot sys/$(TARGET) /usr/bin/symlinks -crt .'
	@touch -d "$(shell date -R -r $(CURDIR)/build/deb) + 1 seconds" $@
	@find sys/$(TARGET)/usr/bin '(' -type f -or -type l ')' -not -name symlinks -delete
	@find sys/$(TARGET)/usr/lib/x86_64-linux-gnu -maxdepth 1 -type f -name '*.so' \
	  -exec patchelf --set-rpath '$$ORIGIN' '{}' ';' >/dev/null 2>&1
	@find sys/$(TARGET) -type d -exec chmod 0755 '{}' ';'
	@find sys/$(TARGET) -type f -exec chmod 0644 '{}' ';'
	@chmod 0755 sys/$(TARGET)/usr/bin/symlinks
	@sleep 1

sysroot: sys/$(TARGET)/usr/lib/x86_64-linux-gnu/libc.so

.PHONY: sysroot

# CMAKE_PREFIX_PATH - disable search path restrictions

build/builtins/build.ninja:
	@echo "Configuring builtins ..." 1>&2
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_PREFIX_PATH="" \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_C_COMPILER_WORKS=ON \
	  -DCMAKE_C_COMPILER_TARGET="$(TARGET)" \
	  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/toolchain.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/lib/clang/$(LLVM_VER)" \
	  -DLLVM_CONFIG_PATH="$(CURDIR)/build/tools/bin/llvm-config" \
	  -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON \
	  -DCOMPILER_RT_DEFAULT_TARGET_ARCH="$(ARCH)" \
	  -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
	  -DCOMPILER_RT_EXCLUDE_ATOMIC_BUILTIN=OFF \
	  -DCOMPILER_RT_INCLUDE_TESTS=OFF \
	  -B build/builtins build/llvm/compiler-rt/lib/builtins

lib/clang/$(LLVM_VER)/lib/$(TARGET)/libclang_rt.builtins.a: build/builtins/build.ninja
	@echo "Installing builtins ..." 1>&2
	@ninja -C build/builtins install-compiler-rt-stripped
	@touch $@

builtins: lib/clang/$(LLVM_VER)/lib/$(TARGET)/libclang_rt.builtins.a

.PHONY: builtins

# LIBCXX_COMPILE_FLAGS_INIT - enables -flto for libc++ (requires patch)
# NOTE: Building libunwind and libc++abi with -flto breaks exceptions handling.

build/runtimes/build.ninja:
	@echo "Patching runtimes ..." 1>&2
	@sed -E 's/$(LIBCXX_CMAKE_MATCH)/$(LIBCXX_CMAKE_SUBST)/g' -i build/llvm/libcxx/CMakeLists.txt
	@echo "Configuring runtimes ..." 1>&2
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_CXX_COMPILER_WORKS=ON \
	  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/toolchain.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/sys/$(TARGET)" \
	  -DCMAKE_INSTALL_INCLUDEDIR="usr/include" \
	  -DLLVM_DEFAULT_TARGET_TRIPLE="$(TARGET)" \
	  -DLLVM_ENABLE_RUNTIMES="libunwind;libcxxabi;libcxx" \
	  -DLLVM_ENABLE_WARNINGS=OFF \
	  -DLLVM_INCLUDE_TESTS=OFF \
	  -DLLVM_INCLUDE_DOCS=OFF \
	  -DLIBUNWIND_ENABLE_SHARED=OFF \
	  -DLIBUNWIND_ENABLE_STATIC=ON \
	  -DLIBUNWIND_USE_COMPILER_RT=ON \
	  -DLIBCXXABI_ENABLE_SHARED=OFF \
	  -DLIBCXXABI_ENABLE_STATIC=ON \
	  -DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
	  -DLIBCXXABI_STATICALLY_LINK_UNWINDER_IN_SHARED_LIBRARY=ON \
	  -DLIBCXXABI_STATICALLY_LINK_UNWINDER_IN_STATIC_LIBRARY=ON \
	  -DLIBCXXABI_USE_COMPILER_RT=ON \
	  -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
	  -DLIBCXX_ABI_UNSTABLE=ON \
	  -DLIBCXX_ABI_VERSION=2 \
	  -DLIBCXX_COMPILE_FLAGS_INIT="-flto=thin -fwhole-program-vtables" \
	  -DLIBCXX_ENABLE_EXPERIMENTAL_LIBRARY=OFF \
	  -DLIBCXX_ENABLE_INCOMPLETE_FEATURES=ON \
	  -DLIBCXX_ENABLE_SHARED=ON \
	  -DLIBCXX_ENABLE_STATIC=ON \
	  -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
	  -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
	  -DLIBCXX_USE_COMPILER_RT=ON \
	  -B build/runtimes build/llvm/runtimes

sys/$(TARGET)/usr/include/c++: build/runtimes/build.ninja
	@echo "Building runtimes ..." 1>&2
	@ninja -C build/runtimes install-cxx-stripped
	@file=`readlink -f sys/$(TARGET)/lib/libc++.so`; \
	 if [ "$${file}" != "$(CURDIR)/sys/$(TARGET)/lib/libc++.so" ]; then \
	   mv "$${file}" "sys/$(TARGET)/lib/libc++.so"; \
	 fi
	@patchelf --set-soname "libc++.so" sys/$(TARGET)/lib/libc++.so
	@rm -f sys/$(TARGET)/lib/libc++.so.*

runtimes: sys/$(TARGET)/usr/include/c++

.PHONY: runtimes

# CMAKE_BUILD_TYPE=MinSizeRel - links shared libraries to libc++.so
# CMAKE_PREFIX_PATH - disable search path restrictions
# CMAKE_FIND_ROOT_PATH - disable search path restrictions
# COMPILER_RT_HAS_NODEFAULTLIBS_FLAG - links to default libraries
# COMPILER_RT_HAS_NOSTDLIBXX_FLAG - links to libc++ (provides libunwind symbols)

build/compiler-rt/build.ninja:
	@echo "Configuring compiler-rt ..." 1>&2
	@cmake -E env \
	 CFLAGS="-D_DEFAULT_SOURCE" \
	 CXXFLAGS="-D_DEFAULT_SOURCE" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_PREFIX_PATH="" \
	  -DCMAKE_FIND_ROOT_PATH="" \
	  -DCMAKE_BUILD_TYPE=MinSizeRel \
	  -DCMAKE_C_COMPILER_TARGET="x86_64-pc-linux-gnu" \
	  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/toolchain.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/lib/clang/$(LLVM_VER)" \
	  -DLLVM_CONFIG_PATH="$(CURDIR)/build/tools/bin/llvm-config" \
	  -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON \
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
	  -DCOMPILER_RT_HAS_NODEFAULTLIBS_FLAG=OFF \
	  -DCOMPILER_RT_HAS_NOSTDLIBXX_FLAG=OFF \
	  -B build/compiler-rt build/llvm/runtimes

lib/clang/$(LLVM_VER)/lib/$(TARGET)/libclang_rt.profile.a: build/compiler-rt/build.ninja
	@echo "Installing compiler-rt ..." 1>&2
	@ninja -C build/compiler-rt \
	  install-compiler-rt-headers \
	  install-compiler-rt-stripped

compiler-rt: lib/clang/$(LLVM_VER)/lib/$(TARGET)/libclang_rt.profile.a

.PHONY: compiler-rt

PSTL_CONFIG_MATCH := ^\s*\#\s*define\s+_PSTL_PAR_BACKEND_SERIAL.*
PSTL_CONFIG_SUBST := \#if __has_include(<oneapi\/tbb.h>)\n
PSTL_CONFIG_SUBST := $(PSTL_CONFIG_SUBST)\#define _PSTL_PAR_BACKEND_TBB\n
PSTL_CONFIG_SUBST := $(PSTL_CONFIG_SUBST)\#else\n
PSTL_CONFIG_SUBST := $(PSTL_CONFIG_SUBST)\#define _PSTL_PAR_BACKEND_SERIAL\n
PSTL_CONFIG_SUBST := $(PSTL_CONFIG_SUBST)\#endif\n

build/pstl/build.ninja:
	@echo "Configuring pstl ..." 1>&2
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/toolchain.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/sys/$(TARGET)" \
	  -DCMAKE_INSTALL_INCLUDEDIR="usr/include/c++/v1" \
	  -DLLVM_ENABLE_RUNTIMES="pstl" \
	  -DLLVM_ENABLE_WARNINGS=OFF \
	  -DLLVM_INCLUDE_TESTS=OFF \
	  -DLLVM_INCLUDE_DOCS=OFF \
	  -DPSTL_PARALLEL_BACKEND="serial" \
	  -B build/pstl build/llvm/runtimes

sys/$(TARGET)/usr/include/c++/v1/pstl: build/pstl/build.ninja
	@echo "Installing pstl ..." 1>&2
	@ninja -C build/pstl install-pstl
	@rm -rf sys/$(TARGET)/lib/cmake
	@sed -E 's/$(LIBCXX_CONFIG_MATCH)/$(LIBCXX_CONFIG_SUBST)/' -i \
	  sys/$(TARGET)/usr/include/c++/v1/__config_site
	@sed -E 's/$(PSTL_CONFIG_MATCH)/$(PSTL_CONFIG_SUBST)/' -i \
	  sys/$(TARGET)/usr/include/c++/v1/__pstl_config_site

pstl: sys/$(TARGET)/usr/include/c++/v1/pstl

.PHONY: pstl

sys: sysroot builtins runtimes compiler-rt pstl
	@echo "Creating sys-$(TARGET).tar.gz ..." 1>&2
	@tar czf sys-$(TARGET).tar.gz \
	  lib/clang/$(LLVM_VER)/include/fuzzer \
	  lib/clang/$(LLVM_VER)/include/profile \
	  lib/clang/$(LLVM_VER)/include/sanitizer \
	  lib/clang/$(LLVM_VER)/include/xray \
	  lib/clang/$(LLVM_VER)/lib/$(TARGET) \
	  lib/clang/$(LLVM_VER)/share \
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
	  sys/$(TARGET)/cmake \
	  sys/$(TARGET)/include \
	  sys/$(TARGET)/lib \
	  sys/$(TARGET)/share \
	  sys/$(TARGET)/tools
	@tar czf sys-$(TARGET)-ports.tar.gz \
	  --exclude='sys/$(TARGET)/lib/x86_64-linux-gnu' \
	  --exclude='sys/$(TARGET)/lib/libc++.a' \
	  --exclude='sys/$(TARGET)/lib/libc++.so' \
	  sys/$(TARGET)/cmake \
	  sys/$(TARGET)/include \
	  sys/$(TARGET)/lib \
	  sys/$(TARGET)/share \
	  sys/$(TARGET)/tools

.PHONY: ports

#  _  ____  __  ___________________________________________________________________________________
# (_)_ __  / _| ___
# | | '_ \| |_ / _ \
# | | | | |  _| (_) |
# |_|_| |_|_|  \___/ ______________________________________________________________________________
#

info/bin:
	@find bin -maxdepth 1 -type f | sort | xargs -i sh -c \
	  'echo "{}"; readelf -a "{}" 2>/dev/null | grep --color -E "RPATH|RUNPATH"' || true

info/tools:
	@find sys/$(TARGET)/tools -maxdepth 1 '(' -type f -or -type l ')' | sort | xargs -i sh -c \
	  'echo "{}"; readelf -a "{}" 2>/dev/null | grep --color -E "RPATH|RUNPATH"' || true; \

info:
	@find sys/$(TARGET)/lib -maxdepth 1 '(' -type f -or -type l ')' -name '*.so' | sort | xargs -i sh -c \
	  'echo "{}"; readelf -a "{}" 2>/dev/null | grep --color -E "RPATH|RUNPATH|SONAME"' || true

.PHONY: info/bin info/tools info

#  _  _  _  _  _  _________________________________________________________________________________
# | | __| | __| |
# | |/ _` |/ _` |
# | | (_| | (_| |
# |_|\__,_|\__,_| _________________________________________________________________________________
#

LDD_FILTER := linux-vdso\.so|libdl\.so|libpthread\.so|libc\.so|libm\.so|librt\.so

ldd/bin:
	@lddtree bin/* | grep -v -E '$(LDD_FILTER)' | grep --color -100 -E '^[^ ]+' || true

ldd/tools:
	@lddtree sys/$(TARGET)/tools/* | grep -v -E '$(LDD_FILTER)' | grep --color -100 -E '^[^ ]+' || true

ldd:
	@lddtree sys/$(TARGET)/lib/*.so | grep -v -E '$(LDD_FILTER)|ld-linux-x86-64\.so' | grep --color -100 -E '^[^ ]+' || true

.PHONY: ldd/bin ldd/tools ldd

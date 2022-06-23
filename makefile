MAKEFLAGS += --no-print-directory

all:
	@echo "usage: sys-tools sys"
	@echo "usage: win-tools win"
	@echo "usage: web"

# ___________  _   _  _____________________________________________________________________________
#   ___  _ __ | |_(_) ___  _ __  ___
#  / _ \| '_ \| __| |/ _ \| '_ \/ __|
# | (_) | |_) | |_| | (_) | | | \__ \
#  \___/| .__/ \__|_|\___/|_| |_|___/ _____________________________________________________________
#       |_|

# Architecture used in the toolchain file.
LLVM_ARCH ?= x86-64-v3

# Permit only one link job per 15GB of RAM available on a 32GB machine.
LLVM_PARALLEL_LINK_JOBS ?= 2

# Based on https://packages.debian.org/stable/linux-headers-amd64 information.
LINUX_VERSION ?= 5.10.0-13

# _______________  _  ___  _     _  _______________________________________________________________
# __   ____ _ _ __(_) __ _| |__ | | ___  ___
# \ \ / / _` | '__| |/ _` | '_ \| |/ _ \/ __|
#  \ V / (_| | |  | | (_| | |_) | |  __/\__ \
# _ \_/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/ _____________________________________________________
#

CFLAGS := -march=$(LLVM_ARCH) -fPIC -fasm -fmerge-all-constants
CFLAGS_RELEASE := -O3 -DNDEBUG
CFLAGS_MINSIZEREL := -Oz -DNDEBUG

CFLAGS_RELEASE_MD := /O2 /Oi /GS- /analyze- /DNDEBUG /MD
CFLAGS_RELEASE_MT := /O2 /Oi /GS- /analyze- /DNDEBUG /MT

CFLAGS_LTO := -flto=thin -fwhole-program-vtables

# ___  _  _________________  _  _____________  _  _________________________________________________
#   __| | _____      ___ __ | | ___   __ _  __| |
#  / _` |/ _ \ \ /\ / / '_ \| |/ _ \ / _` |/ _` |
# | (_| | (_) \ V  V /| | | | | (_) | (_| | (_| |
#  \__,_|\___/ \_/\_/ |_| |_|_|\___/ \__,_|\__,_| _________________________________________________
#

LLVM_VER       := 14.0.4
LLVM_URL       := https://github.com/llvm/llvm-project/releases/download/llvmorg-$(LLVM_VER)
LLVM_SRC       := $(LLVM_URL)/llvm-project-$(LLVM_VER).src.tar.xz
LLVM_WIN       := $(LLVM_URL)/LLVM-$(LLVM_VER)-win64.exe

BINARYEN_URL   := https://github.com/WebAssembly/binaryen/releases/download/version_109
BINARYEN_L_SRC := $(BINARYEN_URL)/binaryen-version_109-x86_64-windows.tar.gz
BINARYEN_W_SRC := $(BINARYEN_URL)/binaryen-version_109-x86_64-linux.tar.gz

TBB_SRC        := https://github.com/oneapi-src/oneTBB/archive/refs/tags/v2021.5.0.tar.gz
WASI_SRC       := https://github.com/WebAssembly/wasi-libc/archive/30094b6.tar.gz


ifneq ($(OS),Windows_NT)

src/%.tar:
	@mkdir -p src
	@wget -c -nc -q --show-progress --no-use-server-timestamps \
	  "$($(shell echo '$*' | tr a-z A-Z )_SRC)" -O $@ || (rm -f $@; false)

src/%: src/%.tar
	@mkdir -p $@
	@tar xf $< -C $@ -m --strip-components=1 || (rm -rf $@; false)

src/binaryen: src/binaryen_l.tar src/binaryen_w.tar
	@mkdir -p $@
	@tar xf src/binaryen_l.tar -C $@ -m --strip-components=1 || (rm -rf $@; false)
	@tar xf src/binaryen_w.tar -C $@ -m --strip-components=1 || (rm -rf $@; false)

endif


ifneq ($(OS),Windows_NT)

# =================================================================================================
#                                   888                      888
#                                   888                      888
#                                   888                      888
# .d8888b  888  888 .d8888b         888888  .d88b.   .d88b.  888 .d8888b
# 88K      888  888 88K             888    d88""88b d88""88b 888 88K
# "Y8888b. 888  888 "Y8888b. 888888 888    888  888 888  888 888 "Y8888b.
#      X88 Y88b 888      X88        Y88b.  Y88..88P Y88..88P 888      X88
#  88888P'  "Y88888  88888P'         "Y888  "Y88P"   "Y88P"  888  88888P'
#               888
#          Y8b d88P
#           "Y88P"
# =================================================================================================

sys-tools: stage tools
	@echo "Creating $@.tar.gz ..." 1>&2
	@tar czf $@.tar.gz bin lib

.PHONY: sys-tools

sys-build: stage tools
	@echo "Creating $@.tar.gz ..." 1>&2
	@tar czf $@.tar.gz build/stage build/tools

.PHONY: sys-build

# ___  _  _________________________________________________________________________________________
#  ___| |_ __ _  __ _  ___
# / __| __/ _` |/ _` |/ _ \
# \__ \ || (_| | (_| |  __/
# |___/\__\__,_|\__, |\___| _______________________________________________________________________
#               |___/

build/stage/build.ninja: src/llvm
	@echo "Configuring stage ..." 1>&2
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)" \
	  -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-pc-linux-gnu" \
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
	  -B build/stage src/llvm/llvm

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

#  _  __________  _  ___________________________________________________________________________
# | |_ ___   ___ | |___
# | __/ _ \ / _ \| / __|
# | || (_) | (_) | \__ \
#  \__\___/ \___/|_|___/ _______________________________________________________________________
#
# CMAKE_SYSROOT - disable sysroot
# CMAKE_PREFIX_PATH - disable search path restrictions
# CMAKE_FIND_ROOT_PATH - disable search path restrictions
# CMAKE_<LANG>_FLAGS_RELEASE - disables -flto
# LLVM_ENABLE_LTO="Full" - enables -flto
#

build/tools/build.ninja:
	@echo "Configuring tools ..." 1>&2
	@cmake -E env PATH="$(CURDIR)/build/stage/bin:$${PATH}" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_SYSROOT="" \
	  -DCMAKE_PREFIX_PATH="" \
	  -DCMAKE_FIND_ROOT_PATH="" \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_C_FLAGS_RELEASE="$(CFLAGS_RELEASE)" \
	  -DCMAKE_CXX_FLAGS_RELEASE="$(CFLAGS_RELEASE)" \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/sys.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)" \
	  -DCMAKE_INSTALL_DATAROOTDIR="$(CURDIR)/build/share" \
	  -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-pc-linux-gnu" \
	  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;polly;lld;lldb" \
	  -DLLVM_ENABLE_BINDINGS=OFF \
	  -DLLVM_ENABLE_DOXYGEN=OFF \
	  -DLLVM_ENABLE_LTO="Full" \
	  -DLLVM_ENABLE_WARNINGS=OFF \
	  -DLLVM_INCLUDE_BENCHMARKS=OFF \
	  -DLLVM_INCLUDE_EXAMPLES=OFF \
	  -DLLVM_INCLUDE_TESTS=OFF \
	  -DLLVM_INCLUDE_DOCS=OFF \
	  -DLLVM_PARALLEL_LINK_JOBS="$(LLVM_PARALLEL_LINK_JOBS)" \
	  -DLLVM_TARGETS_TO_BUILD="X86;WebAssembly" \
	  -DCLANG_DEFAULT_STD_C="c11" \
	  -DCLANG_DEFAULT_STD_CXX="cxx20" \
	  -DCLANG_DEFAULT_CXX_STDLIB="libc++" \
	  -DCLANG_DEFAULT_RTLIB="compiler-rt" \
	  -DCLANG_DEFAULT_UNWINDLIB="none" \
	  -DCLANG_DEFAULT_LINKER="lld" \
	  -DLLDB_ENABLE_PYTHON=OFF \
	  -DLLDB_ENABLE_LUA=OFF \
	  -DDEFAULT_SYSROOT="../sys" \
	  -B build/tools src/llvm/llvm

bin/clang: build/tools/build.ninja
	@echo "Installing tools ..." 1>&2
	@ninja -C build/tools \
	  install-LTO-stripped \
	  install-lld-stripped \
	  install-llvm-ar-stripped \
	  install-llvm-nm-stripped \
	  install-llvm-mt-stripped \
	  install-llvm-rc-stripped \
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
	  install-lldb-instr-stripped \
	  install-lldb-server-stripped \
	  install-lldb-vscode-stripped \
	  install-lldb-stripped \
	  llvm-config
	@rm -f bin/git-clang-format
	@rm -f bin/run-clang-tidy
	@rm -rf include

bin/wasm2js: src/binaryen
	@cp $</$@ $@

bin/wasm-opt: src/binaryen
	@cp $</$@ $@

bin/wasm-reduce: src/binaryen
	@cp $</$@ $@

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

tools: bin/clang bin/wasm2js bin/wasm-opt bin/wasm-reduce lib/libxml2.so.2

.PHONY: tools

endif


ifneq ($(OS),Windows_NT)

# =================================================================================================
#
#
#
# .d8888b  888  888 .d8888b
# 88K      888  888 88K
# "Y8888b. 888  888 "Y8888b.
#      X88 Y88b 888      X88
#  88888P'  "Y88888  88888P'
#               888
#          Y8b d88P
#           "Y88P"
# =================================================================================================

sys:	system builtins runtimes compiler-rt pstl tbb
	@echo "Creating $@.tar.gz ..." 1>&2
	@tar czf $@.tar.gz \
	  lib/clang/$(LLVM_VER)/include/fuzzer \
	  lib/clang/$(LLVM_VER)/include/profile \
	  lib/clang/$(LLVM_VER)/include/sanitizer \
	  lib/clang/$(LLVM_VER)/include/xray \
	  lib/clang/$(LLVM_VER)/lib/x86_64-pc-linux-gnu \
	  lib/clang/$(LLVM_VER)/share \
	  $@

.PHONY: sys

# _____________  _  _______________________________________________________________________________
#  ___ _   _ ___| |_ ___ _ __ ___
# / __| | | / __| __/ _ \ '_ ` _ \
# \__ \ |_| \__ \ ||  __/ | | | | |
# |___/\__, |___/\__\___|_| |_| |_| _______________________________________________________________
#      |___/
#
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
PACKAGES += libgles-dev libgles1 libgles2 libglvnd0
PACKAGES += libglx-dev libglx0
PACKAGES += libgl-dev libgl1

src/deb:
	@mkdir -p src/deb
	@cmake -E chdir src/deb apt download $(PACKAGES) symlinks

sys/usr/lib/x86_64-linux-gnu/libc.so: src/deb
	@echo "Extracting packages ..." 1>&2
	@mkdir -p build
	@find src/deb -name '*.deb' -exec dpkg-deb -x '{}' sys ';'
	@rm -rf sys/etc
	@rm -rf sys/lib/modules
	@rm -rf sys/usr/share
	@rm -f sys/usr/lib/x86_64-linux-gnu/libpulse*.so
	@rm -f sys/usr/lib/gcc/x86_64-linux-gnu/10/liblsan.so
	@rm -f sys/usr/lib/gcc/x86_64-linux-gnu/10/libubsan.so
	@rm -f sys/usr/lib/gcc/x86_64-linux-gnu/10/libasan.so
	@rm -f sys/usr/lib/gcc/x86_64-linux-gnu/10/libtsan.so
	@rm -f sys/usr/lib/gcc/x86_64-linux-gnu/10/libgomp.so
	@rm -f sys/usr/src/linux-headers-$(LINUX_VERSION)-amd64/scripts
	@rm -f sys/usr/src/linux-headers-$(LINUX_VERSION)-amd64/tools
	@rm -f sys/usr/src/linux-headers-$(LINUX_VERSION)-common/scripts
	@rm -f sys/usr/src/linux-headers-$(LINUX_VERSION)-common/tools
	@rm -rf sys/usr/src/linux-headers-$(LINUX_VERSION)-amd64/include/config
	@mv sys/usr/src/linux-headers-$(LINUX_VERSION)-common/include/soc/arc/aux.h \
	    sys/usr/src/linux-headers-$(LINUX_VERSION)-common/include/soc/arc/_aux.h
	@sed -E 's/soc\/arc\/aux\.h/soc\/arc\/_aux.h/g' -i \
	    sys/usr/src/linux-headers-$(LINUX_VERSION)-common/include/soc/arc/timers.h \
	    sys/usr/src/linux-headers-$(LINUX_VERSION)-common/include/soc/arc/mcip.h
	@find sys -name '*.a' -not -name libc_nonshared.a -delete
	@find sys -name 'libatomic*' -delete
	@unshare -r sh -c '/usr/sbin/chroot sys /usr/bin/symlinks -cr .' >/dev/null
	@unshare -r sh -c '/usr/sbin/chroot sys /usr/bin/symlinks -crt .'
	@touch -d "$(shell date -R -r $(CURDIR)/src/deb) + 1 seconds" $@
	@find sys/usr/bin '(' -type f -or -type l ')' -not -name symlinks -delete
	@find sys/usr/lib/x86_64-linux-gnu -maxdepth 1 -type f -name '*.so' \
	  -exec patchelf --set-rpath '$$ORIGIN' '{}' ';' >/dev/null 2>&1
	@find sys -type d -exec chmod 0755 '{}' ';'
	@find sys -type f -exec chmod 0644 '{}' ';'
	@chmod 0755 sys/usr/bin/symlinks
	@sleep 1

system: sys/usr/lib/x86_64-linux-gnu/libc.so

.PHONY: system

#  _  _______  _   _   _  _________________________________________________________________________
# | |__  _   _(_) | |_(_)_ __  ___
# | '_ \| | | | | | __| | '_ \/ __|
# | |_) | |_| | | | |_| | | | \__ \
# |_.__/ \__,_|_|_|\__|_|_| |_|___/ _______________________________________________________________
#
# CMAKE_PREFIX_PATH - disable search path restrictions
# CMAKE_C_FLAGS_RELEASE - disables -flto
#

build/builtins/linux/build.ninja: sys/usr/lib/x86_64-linux-gnu/libc.so
	@echo "Configuring builtins for x86_64-pc-linux-gnu ..." 1>&2
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_PREFIX_PATH="" \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_C_COMPILER_WORKS=ON \
	  -DCMAKE_C_FLAGS_RELEASE="$(CFLAGS_RELEASE)" \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/sys.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/lib/clang/$(LLVM_VER)" \
	  -DLLVM_CONFIG_PATH="$(CURDIR)/build/tools/bin/llvm-config" \
	  -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON \
	  -DCOMPILER_RT_DEFAULT_TARGET_ARCH="$(LLVM_ARCH)" \
	  -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
	  -DCOMPILER_RT_EXCLUDE_ATOMIC_BUILTIN=OFF \
	  -DCOMPILER_RT_INCLUDE_TESTS=OFF \
	  -B build/builtins/linux src/llvm/compiler-rt/lib/builtins

lib/clang/$(LLVM_VER)/lib/x86_64-pc-linux-gnu/libclang_rt.builtins.a: build/builtins/linux/build.ninja
	@echo "Installing builtins for x86_64-pc-linux-gnu ..." 1>&2
	@ninja -C build/builtins/linux install-compiler-rt-stripped
	@touch $@

builtins: lib/clang/$(LLVM_VER)/lib/x86_64-pc-linux-gnu/libclang_rt.builtins.a

.PHONY: builtins

# ________________  _   _  ________________________________________________________________________
#  _ __ _   _ _ __ | |_(_)_ __ ___   ___  ___
# | '__| | | | '_ \| __| | '_ ` _ \ / _ \/ __|
# | |  | |_| | | | | |_| | | | | | |  __/\__ \
# |_|   \__,_|_| |_|\__|_|_| |_| |_|\___||___/ ____________________________________________________
#
# NOTE: Building libunwind and libc++abi with -flto breaks exceptions handling.
#
# CMAKE_<LANG>_FLAGS_RELEASE - disables -flto
# LIBCXX_COMPILE_FLAGS_INIT - enables -flto for libc++ (requires patch)
#

LIBCXX_CMAKE_MATCH := set\(LIBCXX_COMPILE_FLAGS ""\)
LIBCXX_CMAKE_SUBST := set\(LIBCXX_COMPILE_FLAGS "$${LIBCXX_COMPILE_FLAGS_INIT}"\)

build/runtimes/build.ninja: lib/clang/$(LLVM_VER)/lib/x86_64-pc-linux-gnu/libclang_rt.builtins.a
	@echo "Patching libc++ ..." 1>&2
	@sed -E 's/$(LIBCXX_CMAKE_MATCH)/$(LIBCXX_CMAKE_SUBST)/g' -i src/llvm/libcxx/CMakeLists.txt
	@echo "Configuring runtimes ..." 1>&2
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_CXX_COMPILER_WORKS=ON \
	  -DCMAKE_C_FLAGS_RELEASE="$(CFLAGS_RELEASE)" \
	  -DCMAKE_CXX_FLAGS_RELEASE="$(CFLAGS_RELEASE)" \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/sys.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/sys" \
	  -DCMAKE_INSTALL_INCLUDEDIR="usr/include" \
	  -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-pc-linux-gnu" \
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
	  -DLIBCXX_COMPILE_FLAGS_INIT="$(CFLAGS_LTO)" \
	  -DLIBCXX_ENABLE_EXPERIMENTAL_LIBRARY=OFF \
	  -DLIBCXX_ENABLE_INCOMPLETE_FEATURES=ON \
	  -DLIBCXX_ENABLE_SHARED=ON \
	  -DLIBCXX_ENABLE_STATIC=ON \
	  -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
	  -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
	  -DLIBCXX_USE_COMPILER_RT=ON \
	  -B build/runtimes src/llvm/runtimes

sys/usr/include/c++: build/runtimes/build.ninja
	@echo "Building runtimes ..." 1>&2
	@ninja -C build/runtimes install-cxx-stripped

runtimes: sys/usr/include/c++
	@$(MAKE) patch

.PHONY: runtimes

# _________________________  _ _  _________________  _  ___________________________________________
#   ___ ___  _ __ ___  _ __ (_) | ___ _ __      _ __| |_
#  / __/ _ \| '_ ` _ \| '_ \| | |/ _ \ '__|____| '__| __|
# | (_| (_) | | | | | | |_) | | |  __/ | |_____| |  | |_
#  \___\___/|_| |_| |_| .__/|_|_|\___|_|       |_|   \__| _________________________________________
#                     |_|
#
# CMAKE_PREFIX_PATH - disable search path restrictions
# CMAKE_FIND_ROOT_PATH - disable search path restrictions
# CMAKE_<LANG>_FLAGS_RELEASE - disables -flto
# COMPILER_RT_HAS_NODEFAULTLIBS_FLAG - links to default libraries
# COMPILER_RT_HAS_NOSTDLIBXX_FLAG - links to libc++ (provides libunwind symbols)
#

build/compiler-rt/build.ninja: sys/usr/include/c++
	@echo "Configuring compiler-rt ..." 1>&2
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_PREFIX_PATH="" \
	  -DCMAKE_FIND_ROOT_PATH="" \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_C_FLAGS_RELEASE="$(CFLAGS_RELEASE) -D_DEFAULT_SOURCE" \
	  -DCMAKE_CXX_FLAGS_RELEASE="$(CFLAGS_RELEASE) -D_DEFAULT_SOURCE" \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/sys.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/lib/clang/$(LLVM_VER)" \
	  -DLLVM_CONFIG_PATH="$(CURDIR)/build/tools/bin/llvm-config" \
	  -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON \
	  -DLLVM_ENABLE_RUNTIMES="compiler-rt" \
	  -DLLVM_ENABLE_WARNINGS=OFF \
	  -DLLVM_INCLUDE_TESTS=OFF \
	  -DLLVM_INCLUDE_DOCS=OFF \
	  -DCOMPILER_RT_DEFAULT_TARGET_ARCH="$(LLVM_ARCH)" \
	  -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
	  -DCOMPILER_RT_BUILD_BUILTINS=OFF \
	  -DCOMPILER_RT_BUILD_SANITIZERS=ON \
	  -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
	  -DCOMPILER_RT_BUILD_PROFILE=ON \
	  -DCOMPILER_RT_BUILD_XRAY=ON \
	  -DCOMPILER_RT_HAS_NODEFAULTLIBS_FLAG=OFF \
	  -DCOMPILER_RT_HAS_NOSTDLIBXX_FLAG=OFF \
	  -B build/compiler-rt src/llvm/runtimes

lib/clang/$(LLVM_VER)/lib/x86_64-pc-linux-gnu/libclang_rt.profile.a: build/compiler-rt/build.ninja
	@echo "Installing compiler-rt ..." 1>&2
	@ninja -C build/compiler-rt \
	  install-compiler-rt-headers \
	  install-compiler-rt-stripped

compiler-rt: lib/clang/$(LLVM_VER)/lib/x86_64-pc-linux-gnu/libclang_rt.profile.a

.PHONY: compiler-rt

# _________  _   _  _______________________________________________________________________________
#  _ __  ___| |_| |
# | '_ \/ __| __| |
# | |_) \__ \ |_| |
# | .__/|___/\__|_| _______________________________________________________________________________
# |_|

LLVM_LIBCXX_CONFIG_MATCH := ^\s*\/\*\s*\#undef\s+_LIBCPP_HAS_PARALLEL_ALGORITHMS.*
LLVM_LIBCXX_CONFIG_SUBST := \#define _LIBCPP_HAS_PARALLEL_ALGORITHMS

LLVM_PSTL_CONFIG_MATCH := ^\s*\#\s*define\s+_PSTL_PAR_BACKEND_SERIAL.*
LLVM_PSTL_CONFIG_SUBST := \#if __has_include(<oneapi\/tbb.h>)\n
LLVM_PSTL_CONFIG_SUBST := $(LLVM_PSTL_CONFIG_SUBST)\#define _PSTL_PAR_BACKEND_TBB\n
LLVM_PSTL_CONFIG_SUBST := $(LLVM_PSTL_CONFIG_SUBST)\#else\n
LLVM_PSTL_CONFIG_SUBST := $(LLVM_PSTL_CONFIG_SUBST)\#define _PSTL_PAR_BACKEND_SERIAL\n
LLVM_PSTL_CONFIG_SUBST := $(LLVM_PSTL_CONFIG_SUBST)\#endif\n

build/pstl/build.ninja: sys/usr/include/c++
	@echo "Configuring pstl ..." 1>&2
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/sys.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/sys" \
	  -DCMAKE_INSTALL_INCLUDEDIR="usr/include/c++/v1" \
	  -DLLVM_ENABLE_RUNTIMES="pstl" \
	  -DLLVM_ENABLE_WARNINGS=OFF \
	  -DLLVM_INCLUDE_TESTS=OFF \
	  -DLLVM_INCLUDE_DOCS=OFF \
	  -DPSTL_PARALLEL_BACKEND="serial" \
	  -B build/pstl src/llvm/runtimes

sys/usr/include/c++/v1/pstl: build/pstl/build.ninja
	@echo "Installing pstl ..." 1>&2
	@ninja -C build/pstl install-pstl
	@rm -rf sys/lib/cmake/ParallelSTL
	@sed -E 's/$(LLVM_LIBCXX_CONFIG_MATCH)/$(LLVM_LIBCXX_CONFIG_SUBST)/' -i \
	  sys/usr/include/c++/v1/__config_site
	@sed -E 's/$(LLVM_PSTL_CONFIG_MATCH)/$(LLVM_PSTL_CONFIG_SUBST)/' -i \
	  sys/usr/include/c++/v1/__pstl_config_site

pstl: sys/usr/include/c++/v1/pstl

.PHONY: pstl

#  _   _  _  _  ___________________________________________________________________________________
# | |_| |__ | |__
# | __| '_ \| '_ \
# | |_| |_) | |_) |
#  \__|_.__/|_.__/ ________________________________________________________________________________
#

TBB_CMAKE_MATCH := ^\s*set_target_properties\(tbb PROPERTIES OUTPUT_NAME
TBB_CMAKE_SUBST := \ \ \ \ \#set_target_properties(tbb PROPERTIES OUTPUT_NAME

build/tbb/shared/build.ninja: src/tbb sys/usr/include/c++
	@echo "Patching tbb ..." 1>&2
	@sed -E 's/-flto//g' -i src/tbb/cmake/compilers/*
	@sed -E 's/$(TBB_CMAKE_MATCH)/$(TBB_CMAKE_SUBST)/' \
	  -i src/tbb/src/tbb/CMakeLists.txt
	@echo "Configuring tbb (shared) ..." 1>&2
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_CXX_FLAGS="$(CFLAGS) -D_LIBCPP_DISABLE_DEPRECATION_WARNINGS" \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/sys.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/sys" \
	  -DCMAKE_INSTALL_DOCDIR="$(CURDIR)/build/share" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN" \
	  -DTBB_TEST=OFF \
	  -DTBB_EXAMPLES=OFF \
	  -DTBBMALLOC_BUILD=ON \
	  -DBUILD_SHARED_LIBS=ON \
	  -B build/tbb/shared src/tbb

sys/lib/libtbb.so: build/tbb/shared/build.ninja
	@echo "Installing tbb (shared) ..." 1>&2
	@ninja -C build/tbb/shared install/strip
	@rm -f sys/lib/libtbbmalloc_proxy.*
	@rm -rf sys/lib/cmake/TBB

build/tbb/static/build.ninja: src/tbb sys/usr/include/c++
	@echo "Patching tbb ..." 1>&2
	@sed -E 's/-flto//g' -i src/tbb/cmake/compilers/*
	@echo "Configuring tbb (static) ..." 1>&2
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_CXX_FLAGS="$(CFLAGS) -D_LIBCPP_DISABLE_DEPRECATION_WARNINGS" \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/sys.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/sys" \
	  -DCMAKE_INSTALL_DOCDIR="$(CURDIR)/build/share" \
	  -DTBB_TEST=OFF \
	  -DTBB_EXAMPLES=OFF \
	  -DTBBMALLOC_BUILD=ON \
	  -DBUILD_SHARED_LIBS=OFF \
	  -B build/tbb/static src/tbb

sys/lib/libtbb.a: build/tbb/static/build.ninja
	@echo "Installing tbb (static) ..." 1>&2
	@ninja -C build/tbb/static install/strip
	@rm -f sys/lib/libtbbmalloc_proxy.*
	@rm -rf sys/lib/cmake/TBB

tbb: sys/lib/libtbb.so sys/lib/libtbb.a
	@$(MAKE) patch

.PHONY: tbb

endif


ifneq ($(OS),Windows_NT)

# =================================================================================================
#                        888
#                        888
#                        888
# 888  888  888  .d88b.  88888b.
# 888  888  888 d8P  Y8b 888 "88b
# 888  888  888 88888888 888  888
# Y88b 888 d88P Y8b.     888 d88P
#  "Y8888888P"   "Y8888  88888P"
#
#
#
# =================================================================================================

web:	web/wasi web/builtins web/runtimes web/pstl
	@echo "Creating $@.tar.gz ..." 1>&2
	@tar czf $@.tar.gz lib/clang/$(LLVM_VER)/lib/wasi $@

.PHONY: web

# ____________________  __  ______________  _  ____________________________________________________
# __      _____| |__   / /_      ____ _ ___(_)
# \ \ /\ / / _ \ '_ \ / /\ \ /\ / / _` / __| |
#  \ V  V /  __/ |_) / /  \ V  V / (_| \__ \ |
#   \_/\_/ \___|_.__/_/    \_/\_/ \__,_|___/_| ____________________________________________________
#
# The wasi-libc Makefile sets "-mthread-model single -fno-trapping-math" by default.
#

WASI_CFLAGS := -mno-atomics -mno-exception-handling
WASI_CFLAGS += -ftls-model=local-exec -fmerge-all-constants -fvisibility=hidden

web/lib/wasm32-wasi/libc.a: src/wasi
	@cmake -E copy_directory src/wasi build/web/wasi
	@sed -E 's/^LIBC_OBJS.*+=.*LIBC_BOTTOM_HALF_ALL_OBJS.*//' -i build/web/wasi/Makefile
	@$(MAKE) -C build/web/wasi \
	  CC="$(CURDIR)/bin/clang" \
	  AR="$(CURDIR)/bin/llvm-ar" \
	  NM="$(CURDIR)/bin/llvm-nm" \
	  SYSROOT="$(CURDIR)/web" \
	  SYSROOT_INC="$(CURDIR)/web/include/wasm32-wasi" \
	  INSTALL_DIR="$(CURDIR)/web" \
	  EXTRA_CFLAGS="$(WASI_CFLAGS) $(CFLAGS_MINSIZEREL) -D_DEFAULT_SOURCE -Wno-macro-redefined" \
	  libc

web/wasi: web/lib/wasm32-wasi/libc.a

.PHONY: web/wasi

# ____________  _  ___  ___  _______  _ _ _   _  __________________________________________________
# __      _____| |__   / / |__  _   _(_) | |_(_)_ __  ___
# \ \ /\ / / _ \ '_ \ / /| '_ \| | | | | | __| | '_ \/ __|
#  \ V  V /  __/ |_) / / | |_) | |_| | | | |_| | | | \__ \
#   \_/\_/ \___|_.__/_/  |_.__/ \__,_|_|_|\__|_|_| |_|___/ ________________________________________
#
# CMAKE_C_FLAGS_MINSIZEREL - disables -flto
#

build/builtins/wasm32-wasi/build.ninja:
	@echo "Configuring builtins for wasi ..." 1>&2
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=MinSizeRel \
	  -DCMAKE_C_COMPILER_WORKS=ON \
	  -DCMAKE_C_FLAGS_MINSIZEREL="$(CFLAGS_MINSIZEREL)" \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/web.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/lib/clang/$(LLVM_VER)" \
	  -DLLVM_CONFIG_PATH="$(CURDIR)/build/tools/bin/llvm-config" \
	  -DCOMPILER_RT_BAREMETAL_BUILD=ON \
	  -DCOMPILER_RT_DEFAULT_TARGET_ARCH="wasm32" \
	  -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
	  -DCOMPILER_RT_HAS_FPIC_FLAG=OFF \
	  -DCOMPILER_RT_INCLUDE_TESTS=OFF \
	  -DCOMPILER_RT_OS_DIR="wasi" \
	  -B build/builtins/wasm32-wasi src/llvm/compiler-rt/lib/builtins

lib/clang/$(LLVM_VER)/lib/wasi/libclang_rt.builtins-wasm32.a: build/builtins/wasm32-wasi/build.ninja
	@echo "Installing builtins for wasm32-wasi ..." 1>&2
	@ninja -C build/builtins/wasm32-wasi install-compiler-rt-stripped
	@touch $@

web/builtins: lib/clang/$(LLVM_VER)/lib/wasi/libclang_rt.builtins-wasm32.a

.PHONY: web/builtins

# ____________  _  ___  __  ____________  _   _  __________________________________________________
# __      _____| |__   / / __ _   _ _ __ | |_(_)_ __ ___   ___  ___
# \ \ /\ / / _ \ '_ \ / / '__| | | | '_ \| __| | '_ ` _ \ / _ \/ __|
#  \ V  V /  __/ |_) / /| |  | |_| | | | | |_| | | | | | |  __/\__ \
#   \_/\_/ \___|_.__/_/ |_|   \__,_|_| |_|\__|_|_| |_| |_|\___||___/ ______________________________
#
# NOTE: Building libc++abi with -flto breaks linker code generation.
#
# CMAKE_<LANG>_FLAGS_MINSIZEREL - disables -flto
# LIBCXX_COMPILE_FLAGS_INIT - enables -flto for libc++ (requires patch)
#

WASM_RTTI_SOURCES := private_typeinfo.cpp
WASM_RTTI_SOURCES += stdlib_typeinfo.cpp
WASM_RTTI_SOURCES += cxa_personality.cpp
WASM_RTTI_SOURCES += cxa_default_handlers.cpp
WASM_RTTI_SOURCES += cxa_exception.cpp

build/web/runtimes/build.ninja: web/lib/wasm32-wasi/libc.a
	@echo "Patching libc++abi ..." 1>&2
	@grep -q -- -frtti src/llvm/libcxxabi/src/CMakeLists.txt || \
	  echo 'set_source_files_properties($(WASM_RTTI_SOURCES) PROPERTIES COMPILE_FLAGS -frtti)' >> \
	  src/llvm/libcxxabi/src/CMakeLists.txt
	@echo "Patching libc++ ..." 1>&2
	@sed -E 's/$(LIBCXX_CMAKE_MATCH)/$(LIBCXX_CMAKE_SUBST)/g' -i src/llvm/libcxx/CMakeLists.txt
	@echo "Configuring web/runtimes ..." 1>&2
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=MinSizeRel \
	  -DCMAKE_CXX_COMPILER_WORKS=ON \
	  -DCMAKE_C_FLAGS_MINSIZEREL="$(CFLAGS_MINSIZEREL)" \
	  -DCMAKE_CXX_FLAGS_MINSIZEREL="$(CFLAGS_MINSIZEREL)" \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/web.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/web" \
	  -DCMAKE_INSTALL_INCLUDEDIR="include/wasm32-wasi" \
	  -DLLVM_DEFAULT_TARGET_TRIPLE="wasm32-wasi" \
	  -DLLVM_ENABLE_RUNTIMES="libcxxabi;libcxx" \
	  -DLLVM_ENABLE_WARNINGS=OFF \
	  -DLLVM_INCLUDE_TESTS=OFF \
	  -DLLVM_INCLUDE_DOCS=OFF \
	  -DLIBCXXABI_BUILD_EXTERNAL_THREAD_LIBRARY=OFF \
	  -DLIBCXXABI_ENABLE_ASSERTIONS=OFF \
	  -DLIBCXXABI_ENABLE_EXCEPTIONS=OFF \
	  -DLIBCXXABI_ENABLE_SHARED=OFF \
	  -DLIBCXXABI_ENABLE_STATIC=ON \
	  -DLIBCXXABI_ENABLE_THREADS=OFF \
	  -DLIBCXXABI_HAS_EXTERNAL_THREAD_API=OFF \
	  -DLIBCXXABI_HAS_PTHREAD_API=OFF \
	  -DLIBCXXABI_HAS_WIN32_THREAD_API=OFF \
	  -DLIBCXXABI_LIBDIR_SUFFIX="/wasm32-wasi" \
	  -DLIBCXXABI_SILENT_TERMINATE=ON \
	  -DLIBCXXABI_USE_COMPILER_RT=ON \
	  -DLIBCXX_ABI_UNSTABLE=ON \
	  -DLIBCXX_ABI_VERSION=2 \
	  -DLIBCXX_BUILD_EXTERNAL_THREAD_LIBRARY=OFF \
	  -DLIBCXX_COMPILE_FLAGS_INIT="$(CFLAGS_LTO)" \
	  -DLIBCXX_ENABLE_DEBUG_MODE_SUPPORT=OFF \
	  -DLIBCXX_ENABLE_ASSERTIONS=OFF \
	  -DLIBCXX_ENABLE_EXCEPTIONS=OFF \
	  -DLIBCXX_ENABLE_EXPERIMENTAL_LIBRARY=OFF \
	  -DLIBCXX_ENABLE_FILESYSTEM=OFF \
	  -DLIBCXX_ENABLE_INCOMPLETE_FEATURES=ON \
	  -DLIBCXX_ENABLE_LOCALIZATION=OFF \
	  -DLIBCXX_ENABLE_MONOTONIC_CLOCK=OFF \
	  -DLIBCXX_ENABLE_RANDOM_DEVICE=OFF \
	  -DLIBCXX_ENABLE_RTTI=OFF \
	  -DLIBCXX_ENABLE_SHARED=OFF \
	  -DLIBCXX_ENABLE_STATIC=ON \
	  -DLIBCXX_ENABLE_THREADS=OFF \
	  -DLIBCXX_HAS_EXTERNAL_THREAD_API=OFF \
	  -DLIBCXX_HAS_MUSL_LIBC=ON \
	  -DLIBCXX_HAS_PTHREAD_API=OFF \
	  -DLIBCXX_HAS_WIN32_THREAD_API=OFF \
	  -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
	  -DLIBCXX_LIBDIR_SUFFIX="/wasm32-wasi" \
	  -DLIBCXX_USE_COMPILER_RT=ON \
	  -DUNIX=ON \
	  -B build/web/runtimes src/llvm/runtimes

web/lib/wasm32-wasi/libc++.a: build/web/runtimes/build.ninja
	@echo "Building web/runtimes ..." 1>&2
	@ninja -C build/web/runtimes \
	  install-cxxabi-stripped \
	  install-cxx-stripped

web/runtimes: web/lib/wasm32-wasi/libc++.a

.PHONY: web/runtimes

# ____________  _  ___  __  _____  _   _  _________________________________________________________
# __      _____| |__   / / __  ___| |_| |
# \ \ /\ / / _ \ '_ \ / / '_ \/ __| __| |
#  \ V  V /  __/ |_) / /| |_) \__ \ |_| |
#   \_/\_/ \___|_.__/_/ | .__/|___/\__|_| _________________________________________________________
#                       |_|

build/web/pstl/build.ninja: web/lib/wasm32-wasi/libc++.a
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=MinSizeRel \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/web.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/web" \
	  -DCMAKE_INSTALL_INCLUDEDIR="include/wasm32-wasi/c++/v1" \
	  -DLLVM_DEFAULT_TARGET_TRIPLE="wasm32-wasi" \
	  -DLLVM_ENABLE_RUNTIMES="pstl" \
	  -DLLVM_ENABLE_WARNINGS=OFF \
	  -DLLVM_INCLUDE_TESTS=OFF \
	  -DLLVM_INCLUDE_DOCS=OFF \
	  -DPSTL_PARALLEL_BACKEND="serial" \
	  -DUNIX=ON \
	  -B build/web/pstl src/llvm/runtimes

web/include/c++/v1/pstl: build/web/pstl/build.ninja
	@ninja -C build/web/pstl install-pstl
	@rm -rf web/lib/cmake
	@sed -E 's/$(LLVM_LIBCXX_CONFIG_MATCH)/$(LLVM_LIBCXX_CONFIG_SUBST)/' -i \
	  web/include/wasm32-wasi/c++/v1/__config_site

web/pstl: web/include/c++/v1/pstl

.PHONY: web/pstl

endif


ifneq ($(OS),Windows_NT)

# =================================================================================================
#
#
#
# .d8888b  888d888  .d8888b
# 88K      888P"   d88P"
# "Y8888b. 888     888
#      X88 888     Y88b.
#  88888P' 888      "Y8888P
#
#
#
# =================================================================================================

LLVM_SRC_EXCLUDE := ^(src|src/(deb|test|wasi))$$

src:
	@echo "Creating $@.tar.gz ..." 1>&2
	@tar czf $@.tar.gz $(shell find src -maxdepth 1 -type d | grep -vE '$(LLVM_SRC_EXCLUDE)')

.PHONY: src

endif


ifeq ($(OS),Windows_NT)

# =================================================================================================
#               d8b                 888                      888
#               Y8P                 888                      888
#                                   888                      888
# 888  888  888 888 88888b.         888888  .d88b.   .d88b.  888 .d8888b
# 888  888  888 888 888 "88b        888    d88""88b d88""88b 888 88K
# 888  888  888 888 888  888 888888 888    888  888 888  888 888 "Y8888b.
# Y88b 888 d88P 888 888  888        Y88b.  Y88..88P Y88..88P 888      X88
#  "Y8888888P"  888 888  888         "Y888  "Y88P"   "Y88P"  888  88888P'
#
#
#
# =================================================================================================

win-tools: stage tools
	@echo "Creating $@.tar.gz ..." 1>&2
	@tar czf $@.tar.gz bin lib

.PHONY: win-tools

# ___  _  _________________________________________________________________________________________
#  ___| |_ __ _  __ _  ___
# / __| __/ _` |/ _` |/ _ \
# \__ \ || (_| | (_| |  __/
# |___/\__\__,_|\__, |\___| _______________________________________________________________________
#               |___/

src/llvm.exe:
	@curl -L $(LLVM_WIN) -o $@ || cmake -E remove -f $@

build/stage/bin/clang.exe: src/llvm.exe
	@7z -obuild/stage x $<
	@cmake -E remove -f build/stage/bin/llvm-rc.exe
	@cmake -E touch_nocreate $@

stage: build/stage/bin/clang.exe

.PHONY: stage

#  _  __________  _  ___________________________________________________________________________
# | |_ ___   ___ | |___
# | __/ _ \ / _ \| / __|
# | || (_) | (_) | \__ \
#  \__\___/ \___/|_|___/ _______________________________________________________________________
#
# CMAKE_PREFIX_PATH - disable search path restrictions
# CMAKE_<LANG>_FLAGS_RELEASE - disables -flto
# CMAKE_<TYPE>_LINKER_FLAGS - disables /MANIFEST:NO
# CMAKE_SYSTEM_INCLUDE_PATH - sets dependency include path
# CMAKE_SYSTEM_LIBRARY_PATH - sets dependency library path
# LLVM_ENABLE_LTO="Full" - enables -flto
#

build/tools/build.ninja: build/stage/bin/clang.exe
	@echo "Configuring tools ..." 1>&2
	@cmake -E env PATH="$(CURDIR)/bin;$(CURDIR)/build/stage/bin;$(PATH)" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_PREFIX_PATH="" \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_C_FLAGS_RELEASE="$(CFLAGS_RELEASE_MT) /DLIBXML_STATIC /DLZMA_API_STATIC /DLIBCHARSET_DLL_EXPORTED=" \
	  -DCMAKE_CXX_FLAGS_RELEASE="$(CFLAGS_RELEASE_MT) /DLIBXML_STATIC /DLZMA_API_STATIC /DLIBCHARSET_DLL_EXPORTED=" \
	  -DCMAKE_EXE_LINKER_FLAGS="" \
	  -DCMAKE_SHARED_LINKER_FLAGS="" \
	  -DCMAKE_SYSTEM_INCLUDE_PATH="$(CURDIR)/win/usr/include" \
	  -DCMAKE_SYSTEM_LIBRARY_PATH="$(CURDIR)/win/usr/lib" \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/win.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)" \
	  -DCMAKE_INSTALL_DATAROOTDIR="$(CURDIR)/build/share" \
	  -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-pc-windows-msvc" \
	  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;polly;lld;lldb" \
	  -DLLVM_ENABLE_BINDINGS=OFF \
	  -DLLVM_ENABLE_DOXYGEN=OFF \
	  -DLLVM_ENABLE_LTO="Full" \
	  -DLLVM_ENABLE_WARNINGS=OFF \
	  -DLLVM_INCLUDE_BENCHMARKS=OFF \
	  -DLLVM_INCLUDE_EXAMPLES=OFF \
	  -DLLVM_INCLUDE_TESTS=OFF \
	  -DLLVM_INCLUDE_DOCS=OFF \
	  -DLLVM_PARALLEL_LINK_JOBS="$(LLVM_PARALLEL_LINK_JOBS)" \
	  -DLLVM_TARGETS_TO_BUILD="X86;WebAssembly" \
	  -DCLANG_DEFAULT_STD_C="c11" \
	  -DCLANG_DEFAULT_STD_CXX="cxx20" \
	  -DCLANG_DEFAULT_CXX_STDLIB="libc++" \
	  -DCLANG_DEFAULT_RTLIB="compiler-rt" \
	  -DCLANG_DEFAULT_UNWINDLIB="none" \
	  -DCLANG_DEFAULT_LINKER="lld" \
	  -DLLDB_ENABLE_PYTHON=OFF \
	  -DLLDB_ENABLE_LUA=OFF \
	  -DDEFAULT_SYSROOT="../win" \
	  -B build/tools src/llvm/llvm

bin/clang.exe: build/tools/build.ninja
	@echo "Installing tools ..." 1>&2
	@cmake -E env PATH="$(CURDIR)/bin;$(CURDIR)/build/stage/bin;$(PATH)" \
	 bin/ninja.exe -C build/tools \
	  install-LTO-stripped \
	  install-lld-stripped \
	  install-llvm-ar-stripped \
	  install-llvm-nm-stripped \
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
	  install-lldb-instr-stripped \
	  install-lldb-server-stripped \
	  install-lldb-vscode-stripped \
	  install-lldb-stripped \
	  llvm-config
	@cmake -E remove -f bin/git-clang-format
	@cmake -E remove -f bin/run-clang-tidy
	@cmake -E remove_directory include

bin/wasm2js.exe:
	@cmake -E copy src/binaryen/$@ bin

bin/wasm-opt.exe:
	@cmake -E copy src/binaryen/$@ bin

bin/wasm-reduce.exe:
	@cmake -E copy src/binaryen/$@ bin

tools: bin/clang.exe bin/wasm2js.exe bin/wasm-opt.exe bin/wasm-reduce.exe

.PHONY: tools

endif


ifeq ($(OS),Windows_NT)

# =================================================================================================
#               d8b
#               Y8P
#
# 888  888  888 888 88888b.
# 888  888  888 888 888 "88b
# 888  888  888 888 888  888
# Y88b 888 d88P 888 888  888
#  "Y8888888P"  888 888  888
#
#
#
# =================================================================================================

win:	compiler-rt tbb
	@echo "Creating $@.tar.gz ..." 1>&2
	@tar czf $@.tar.gz $@

.PHONY: win

# _________________________  _ _  _________________  _  ___________________________________________
#   ___ ___  _ __ ___  _ __ (_) | ___ _ __      _ __| |_
#  / __/ _ \| '_ ` _ \| '_ \| | |/ _ \ '__|____| '__| __|
# | (_| (_) | | | | | | |_) | | |  __/ | |_____| |  | |_
#  \___\___/|_| |_| |_| .__/|_|_|\___|_|       |_|   \__| _________________________________________
#                     |_|
#
# CMAKE_PREFIX_PATH - disable search path restrictions
# CMAKE_<LANG>_FLAGS_RELEASE - disables -flto
#

build/compiler-rt/build.ninja:
	@echo "Configuring compiler-rt ..." 1>&2
	@cmake -E env PATH="$(CURDIR)/bin;$(CURDIR)/build/stage/bin;$(PATH)" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_PREFIX_PATH="" \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_C_FLAGS_RELEASE="$(CFLAGS_RELEASE_MD)" \
	  -DCMAKE_CXX_FLAGS_RELEASE="$(CFLAGS_RELEASE_MD)" \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/win.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/win/crt" \
	  -DLLVM_CONFIG_PATH="$(CURDIR)/build/tools/bin/llvm-config" \
	  -DLLVM_ENABLE_RUNTIMES="compiler-rt" \
	  -DLLVM_ENABLE_WARNINGS=OFF \
	  -DLLVM_INCLUDE_TESTS=OFF \
	  -DLLVM_INCLUDE_DOCS=OFF \
	  -DCOMPILER_RT_DEFAULT_TARGET_ARCH="$(LLVM_ARCH)" \
	  -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
	  -DCOMPILER_RT_BUILD_BUILTINS=OFF \
	  -DCOMPILER_RT_BUILD_SANITIZERS=ON \
	  -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
	  -DCOMPILER_RT_BUILD_PROFILE=ON \
	  -DCOMPILER_RT_BUILD_XRAY=ON \
	  -B build/compiler-rt src/llvm/runtimes

win/crt/lib/clang_rt.profile.lib: build/compiler-rt/build.ninja
	@echo "Installing compiler-rt ..." 1>&2
	@cmake -E env PATH="$(CURDIR)/bin;$(CURDIR)/build/stage/bin;$(PATH)" \
	 bin/ninja.exe -C build/compiler-rt \
	  install-compiler-rt-headers \
	  install-compiler-rt-stripped
	@move win\crt\lib\windows\* win\crt\lib
	@rd /q /s win\crt\lib\windows

compiler-rt: win/crt/lib/clang_rt.profile.lib

.PHONY: compiler-rt

#  _   _  _  _  ___________________________________________________________________________________
# | |_| |__ | |__
# | __| '_ \| '_ \
# | |_| |_) | |_) |
#  \__|_.__/|_.__/ ________________________________________________________________________________
#

build/tbb/shared/build.ninja:
	@echo "Configuring tbb (shared) ..." 1>&2
	@cmake -E env PATH="$(CURDIR)/bin;$(CURDIR)/build/stage/bin;$(PATH)" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/win.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/win" \
	  -DCMAKE_INSTALL_DOCDIR="$(CURDIR)/build/share" \
	  -DCMAKE_INSTALL_LIBDIR="lib/shared" \
	  -DTBB_TEST=OFF \
	  -DTBB_EXAMPLES=OFF \
	  -DTBBMALLOC_BUILD=ON \
	  -DBUILD_SHARED_LIBS=ON \
	  -B build/tbb/shared src/tbb

win/lib/shared/tbb.lib: build/tbb/shared/build.ninja
	@echo "Installing tbb (shared) ..." 1>&2
	@cmake -E env PATH="$(CURDIR)/bin;$(CURDIR)/build/stage/bin;$(PATH)" \
	 ninja -C build/tbb/shared install
	@cmake -E remove -f win/bin/tbbmalloc_proxy.dll
	@cmake -E remove -f win/lib/shared/tbbmalloc_proxy.lib
	@cmake -E remove -f win/lib/tbb.lib
	@cmake -E remove_directory win/lib/shared/cmake
	@cmake -E remove_directory win/lib/shared/pkgconfig

build/tbb/static/build.ninja:
	@echo "Configuring tbb (static) ..." 1>&2
	@cmake -E env PATH="$(CURDIR)/bin;$(CURDIR)/build/stage/bin;$(PATH)" \
	 cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/win.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/win" \
	  -DCMAKE_INSTALL_DOCDIR="$(CURDIR)/build/share" \
	  -DCMAKE_INSTALL_LIBDIR="lib/static" \
	  -DTBB_TEST=OFF \
	  -DTBB_EXAMPLES=OFF \
	  -DTBBMALLOC_BUILD=ON \
	  -DBUILD_SHARED_LIBS=OFF \
	  -B build/tbb/static src/tbb

win/lib/static/tbb.lib: build/tbb/static/build.ninja
	@echo "Installing tbb (static) ..." 1>&2
	@cmake -E env PATH="$(CURDIR)/bin;$(CURDIR)/build/stage/bin;$(PATH)" \
	 ninja -C build/tbb/static install
	@cmake -E remove -f win/lib/tbb.lib
	@cmake -E remove_directory win/lib/static/cmake
	@cmake -E remove_directory win/lib/static/pkgconfig

tbb: win/lib/shared/tbb.lib win/lib/static/tbb.lib

.PHONY: tbb

endif


# ____  _  ________________________________________________________________________________________
#   ___| | ___  __ _ _ __
#  / __| |/ _ \/ _` | '_ \
# | (__| |  __/ (_| | | | |
#  \___|_|\___|\__,_|_| |_| _______________________________________________________________________
#

clean:
	@cmake -E remove_directory \
	  bin lib sys web win \
	  build/share \
	  build/builtins \
	  build/runtimes \
	  build/compiler-rt \
	  build/tbb \
	  build/pstl \
	  build/backtrace \
	  build/make \
	  build/usr \
	  build/web

.PHONY: clean

#  _  ____  __  ___________________________________________________________________________________
# (_)_ __  / _| ___
# | | '_ \| |_ / _ \
# | | | | |  _| (_) |
# |_|_| |_|_|  \___/ ______________________________________________________________________________
#

ifneq ($(OS),Windows_NT)

info/bin:
	@find bin -maxdepth 1 -type f | sort | xargs -i sh -c \
	  'echo "{}"; readelf -a "{}" 2>/dev/null | grep --color -E "RPATH|RUNPATH"' || true
	@if [ -d sys/sbin ]; then \
	  echo "================================================================================="; \
	  find sys/sbin -maxdepth 1 '(' -type f -or -type l ')' | sort | xargs -i sh -c \
	    'echo "{}"; readelf -a "{}" 2>/dev/null | grep --color -E "RPATH|RUNPATH"' || true; \
	fi
	@if [ -d sys/bin ]; then \
	  echo "================================================================================="; \
	  find sys/bin -maxdepth 1 '(' -type f -or -type l ')' | sort | xargs -i sh -c \
	    'echo "{}"; readelf -a "{}" 2>/dev/null | grep --color -E "RPATH|RUNPATH"' || true; \
	fi

.PHONY: info/bin

info:
	@find sys/lib -maxdepth 1 '(' -type f -or -type l ')' -name '*.so' | sort | xargs -i sh -c \
	  'echo "{}"; readelf -a "{}" 2>/dev/null | grep --color -E "RPATH|RUNPATH|SONAME"' || true

.PHONY: info

endif

#  _  _  _  _  _  _________________________________________________________________________________
# | | __| | __| |
# | |/ _` |/ _` |
# | | (_| | (_| |
# |_|\__,_|\__,_| _________________________________________________________________________________
#

ifneq ($(OS),Windows_NT)

LDD_FILTER := linux-vdso\.so|libdl\.so|libpthread\.so|libc\.so|libm\.so|librt\.so

ldd/bin:
	@lddtree bin/* | grep -v -E '$(LDD_FILTER)' | grep --color -100 -E '^[^ ]+' || true
	@if [ -d sys/sbin ]; then \
	  echo "================================================================================="; \
	  lddtree sys/sbin/* | grep -v -E '$(LDD_FILTER)' | grep --color -100 -E '^[^ ]+' || true; \
	fi
	@if [ -d sys/bin ]; then \
	  echo "================================================================================="; \
	  lddtree sys/bin/* | grep -v -E '$(LDD_FILTER)' | grep --color -100 -E '^[^ ]+' || true; \
	fi

ldd:
	@lddtree sys/lib/*.so | grep -v -E '$(LDD_FILTER)|ld-linux-x86-64\.so' | grep --color -100 -E '^[^ ]+' || true

.PHONY: ldd/bin ldd/lib

endif

# ___________  _  ___  _  _________________________________________________________________________
#  _ __   __ _| |_ ___| |__
# | '_ \ / _` | __/ __| '_ \
# | |_) | (_| | || (__| | | |
# | .__/ \__,_|\__\___|_| |_| _____________________________________________________________________
# |_|

ifneq ($(OS),Windows_NT)

BINARIES ?=

patch:
	@echo "Patching binaries ..." 1>&2
	@for lib in sys/lib/*.so; do \
	  chmod -x $${lib}; \
	  name=`echo $${lib} | cut -d/ -f3 | cut -d. -f1`; \
	  if [ -h $${lib} ]; then \
	    file=`find $${lib}.* -type f -print -quit`; \
	    if [ -n "$${file}" ]; then \
	      echo "$${lib}: replaced with $${file}"; \
	      mv $${file} $${lib}; \
	      rm -f $${lib}.*; \
	    fi; \
	  fi; \
	  rm -f sys/lib/$${name}.la; \
	  patchelf --set-soname "$${name}.so" $${lib}; \
	  patchelf --set-rpath '$$ORIGIN' $${lib}; \
	  for file in sys/lib/*.so $(BINARIES); do \
	    vname=`bin/llvm-objdump -p $${file} | grep -E "\s+NEEDED\s+" | \
	      sed -E 's/\s+NEEDED\s+//' | grep -F "$${name}.so." || true`; \
	    if [ -n "$${vname}" ]; then \
	      echo "$${file}: replaced NEEDED $${vname} with $${name}.so"; \
	      patchelf --replace-needed "$${vname}" "$${name}.so" $${file}; \
	    fi; \
	  done; \
	done
	@for lib in sys/lib/*.a; do \
	  chmod -x $${lib}; \
	done
	@if [ -n "$(BINARIES)" ]; then \
	  for bin in $(BINARIES); do \
	    echo "$${bin}: set RUNPATH to \$$ORIGIN/../lib"; \
	    patchelf --set-rpath '$$ORIGIN/../lib' $${bin}; \
	  done; \
	fi
	@rm -rf sys/lib/pkgconfig

endif

# wget http://www.figlet.org/fonts/colossal.flf
# figlet -tkf colossal.flf sys
# figlet -t stage

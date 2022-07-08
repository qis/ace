ifneq ($(TARGET),wasm32-wasi)
$(error Invalid TARGET value)
endif

ifeq ($(OS),Windows_NT)
$(error This target must be compiled on Linux)
endif

ARCH := $(shell cmake -P src/arch.cmake $(TARGET) 2>&1)
ROOT := $(CURDIR)/sys/$(TARGET)

# ___  _  _________________  _  _____________  _  _________________________________________________
#   __| | _____      ___ __ | | ___   __ _  __| |
#  / _` |/ _ \ \ /\ / / '_ \| |/ _ \ / _` |/ _` |
# | (_| | (_) \ V  V /| | | | | (_) | (_| | (_| |
#  \__,_|\___/ \_/\_/ |_| |_|_|\___/ \__,_|\__,_| _________________________________________________
#

build/wasi.tar.xz:
	@mkdir -p build
	@wget -c -nc -q --show-progress --no-use-server-timestamps \
	  "$(WASI_SRC)" -O $@ || (rm -f $@; false)

build/wasi: build/wasi.tar.xz
	@mkdir -p $@
	@tar xf $< -C $@ -m --strip-components=1 || (rm -rf $@; false)

#  ___ _   _ ___  _________________________________________________________________________________
# / __| | | / __|
# \__ \ |_| \__ \
# |___/\__, |___/ _________________________________________________________________________________
#      |___/

WASI_CFLAGS := -mno-atomics -mno-exception-handling
WASI_CFLAGS += -ftls-model=local-exec -fmerge-all-constants -fvisibility=hidden

sys/$(TARGET)/lib/wasm32-wasi/libc.a: build/wasi
	@echo "Installing wasi ..." 1>&2
	@cmake -E copy_directory build/wasi build/web/wasi
	@sed -E 's/^LIBC_OBJS.*+=.*LIBC_BOTTOM_HALF_ALL_OBJS.*//' -i build/web/wasi/Makefile
	@$(MAKE) -C build/web/wasi \
	  CC="$(CURDIR)/bin/clang" \
	  AR="$(CURDIR)/bin/llvm-ar" \
	  NM="$(CURDIR)/bin/llvm-nm" \
	  SYSROOT="$(CURDIR)/sys/$(TARGET)" \
	  SYSROOT_INC="$(CURDIR)/sys/$(TARGET)/include/wasm32-wasi" \
	  INSTALL_DIR="$(CURDIR)/sys/$(TARGET)" \
	  EXTRA_CFLAGS="$(WASI_CFLAGS) -Oz -DNDEBUG -D_DEFAULT_SOURCE -Wno-macro-redefined" \
	  libc

wasi: sys/$(TARGET)/lib/wasm32-wasi/libc.a

.PHONY: wasi

build/builtins/wasm32-wasi/build.ninja:
	@echo "Configuring builtins ..." 1>&2
	@cmake -GNinja -Wno-dev \
	  -DACE_TARGET="$(TARGET)" \
	  -DCMAKE_BUILD_TYPE=MinSizeRel \
	  -DCMAKE_C_COMPILER_WORKS=ON \
	  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/toolchain.cmake" \
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
	@echo "Installing builtins ..." 1>&2
	@ninja -C build/builtins/wasm32-wasi install-compiler-rt-stripped
	@touch $@

builtins: lib/clang/$(LLVM_VER)/lib/wasi/libclang_rt.builtins-wasm32.a

.PHONY: builtins

WASM_RTTI_SOURCES := private_typeinfo.cpp
WASM_RTTI_SOURCES += stdlib_typeinfo.cpp
WASM_RTTI_SOURCES += cxa_personality.cpp
WASM_RTTI_SOURCES += cxa_default_handlers.cpp
WASM_RTTI_SOURCES += cxa_exception.cpp

# LIBCXX_COMPILE_FLAGS_INIT - enables -flto for libc++ (requires patch)
# NOTE: Building libc++abi with -flto breaks linker code generation.

build/web/runtimes/build.ninja:
	@echo "Patching runtimes ..." 1>&2
	@grep -q -- -frtti src/llvm/libcxxabi/src/CMakeLists.txt || \
	  echo 'set_source_files_properties($(WASM_RTTI_SOURCES) PROPERTIES COMPILE_FLAGS -frtti)' >> \
	  src/llvm/libcxxabi/src/CMakeLists.txt
	@sed -E 's/$(LIBCXX_CMAKE_MATCH)/$(LIBCXX_CMAKE_SUBST)/g' -i src/llvm/libcxx/CMakeLists.txt
	@echo "Configuring runtimes ..." 1>&2
	@cmake -GNinja -Wno-dev \
	  -DACE_TARGET="$(TARGET)" \
	  -DCMAKE_BUILD_TYPE=MinSizeRel \
	  -DCMAKE_CXX_COMPILER_WORKS=ON \
	  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/toolchain.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/sys/$(TARGET)" \
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
	  -DLIBCXX_COMPILE_FLAGS_INIT="-flto=thin -fwhole-program-vtables" \
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

sys/$(TARGET)/lib/wasm32-wasi/libc++.a: build/web/runtimes/build.ninja
	@echo "Building runtimes ..." 1>&2
	@ninja -C build/web/runtimes \
	  install-cxxabi-stripped \
	  install-cxx-stripped

runtimes: sys/$(TARGET)/lib/wasm32-wasi/libc++.a

.PHONY: runtimes

build/web/pstl/build.ninja:
	@echo "Patching pstl ..." 1>&2
	@cmake -GNinja -Wno-dev \
	  -DACE_TARGET="$(TARGET)" \
	  -DCMAKE_BUILD_TYPE=MinSizeRel \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/toolchain.cmake" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/sys/$(TARGET)" \
	  -DCMAKE_INSTALL_INCLUDEDIR="include/wasm32-wasi/c++/v1" \
	  -DLLVM_DEFAULT_TARGET_TRIPLE="wasm32-wasi" \
	  -DLLVM_ENABLE_RUNTIMES="pstl" \
	  -DLLVM_ENABLE_WARNINGS=OFF \
	  -DLLVM_INCLUDE_TESTS=OFF \
	  -DLLVM_INCLUDE_DOCS=OFF \
	  -DPSTL_PARALLEL_BACKEND="serial" \
	  -DUNIX=ON \
	  -B build/web/pstl src/llvm/runtimes

sys/$(TARGET)/include/c++/v1/pstl: build/web/pstl/build.ninja
	@echo "Building pstl ..." 1>&2
	@ninja -C build/web/pstl install-pstl
	@rm -rf sys/$(TARGET)/lib/cmake
	@sed -E 's/$(LIBCXX_CONFIG_MATCH)/$(LIBCXX_CONFIG_SUBST)/' -i \
	  sys/$(TARGET)/include/wasm32-wasi/c++/v1/__config_site

pstl: sys/$(TARGET)/include/c++/v1/pstl

.PHONY: pstl

sys:	wasi builtins runtimes pstl
	@echo "Creating sys-$(TARGET).tar.gz ..." 1>&2
	@tar czf sys-$(TARGET).tar.gz \
	  lib/clang/$(LLVM_VER)/lib/wasi \
	  sys/$(TARGET)

.PHONY: sys

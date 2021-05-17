# =============================================================================
# usage
# =============================================================================

all:
	@echo "usage:"
	@echo ""
	@echo "  make reset"
	@echo "  make download"
	@echo "  make stage llvm msvc libs"
	@echo "  make clean"
	@echo ""

# =============================================================================
# settings
# =============================================================================
# x86-64: CMOV, CMPXCHG8B, FPU, FXSR, MMX, FXSR, SCE, SSE, SSE2
# x86-64-v2: (close to Nehalem) CMPXCHG16B, LAHF-SAHF, POPCNT, SSE3, SSE4.1, SSE4.2, SSSE3
# x86-64-v3: (close to Haswell) AVX, AVX2, BMI1, BMI2, F16C, FMA, LZCNT, MOVBE, XSAVE
# x86-64-v4: AVX512F, AVX512BW, AVX512CD, AVX512DQ, AVX512VL

ARCH = x86-64-v3
LLVM_TRIPLE = x86_64-pc-linux-gcc
MSVC_TRIPLE = x86_64-pc-windows-msvc

LLVM_RELEASE := 12
LLVM_VERSION := $(LLVM_RELEASE).0.0
LLVM_SOURCES := https://github.com/llvm/llvm-project/releases/download/llvmorg-$(LLVM_VERSION)

MSVC_SOURCES := https://github.com/mstorsjo/msvc-wine

FMT_VERSION := 7.1.3
FMT_ARCHIVE := https://github.com/fmtlib/fmt/archive/refs/tags/$(FMT_VERSION).tar.gz

LZ4_VERSION := 1.9.3
LZ4_ARCHIVE := https://github.com/lz4/lz4/archive/refs/tags/v$(LZ4_VERSION).tar.gz

BENCHMARK_VERSION := 1.5.2
BENCHMARK_ARCHIVE := https://github.com/google/benchmark/archive/refs/tags/v$(BENCHMARK_VERSION).tar.gz

DOCTEST_VERSION := 2.4.6
DOCTEST_ARCHIVE := https://github.com/onqtam/doctest/archive/refs/tags/$(DOCTEST_VERSION).tar.gz

BUILD = $(CURDIR)/build

LLVM = $(CURDIR)
MSVC = $(CURDIR)/msvc

LLVM_TOOLCHAIN = $(CURDIR)/llvm.cmake
MSVC_TOOLCHAIN = $(CURDIR)/msvc.cmake

# =============================================================================
# download
# =============================================================================

DOWNLOAD = mkdir -p src; wget -c -nc -q --show-progress --no-use-server-timestamps

download: \
  download/llvm \
  download/msvc \
  download/libs

download/llvm: \
  src/llvm \
  src/lld \
  src/lldb \
  src/clang \
  src/clang-tools-extra \
  src/compiler-rt \
  src/libunwind \
  src/libcxxabi \
  src/libcxx

download/msvc: \
  src/msvc

download/libs: \
  src/fmt \
  src/lz4 \
  src/benchmark \
  src/doctest

src/llvm.tar.xz:
	@$(DOWNLOAD) $(LLVM_SOURCES)/llvm-$(LLVM_VERSION).src.tar.xz -O $@

src/llvm: src/llvm.tar.xz
	@mkdir -p $@ && tar xf $< -C $@ -m --strip-components=1

src/lld.tar.xz:
	@$(DOWNLOAD) $(LLVM_SOURCES)/lld-$(LLVM_VERSION).src.tar.xz -O $@

src/lld: src/lld.tar.xz
	@mkdir -p $@ && tar xf $< -C $@ -m --strip-components=1

src/lldb.tar.xz:
	@$(DOWNLOAD) $(LLVM_SOURCES)/lldb-$(LLVM_VERSION).src.tar.xz -O $@

src/lldb: src/lldb.tar.xz
	@mkdir -p $@ && tar xf $< -C $@ -m --strip-components=1

src/clang.tar.xz:
	@$(DOWNLOAD) $(LLVM_SOURCES)/clang-$(LLVM_VERSION).src.tar.xz -O $@

src/clang: src/clang.tar.xz
	@mkdir -p $@ && tar xf $< -C $@ -m --strip-components=1

src/clang-tools-extra.tar.xz:
	@$(DOWNLOAD) $(LLVM_SOURCES)/clang-tools-extra-$(LLVM_VERSION).src.tar.xz -O $@

src/clang-tools-extra: src/clang-tools-extra.tar.xz
	@mkdir -p $@ && tar xf $< -C $@ -m --strip-components=1

src/compiler-rt.tar.xz:
	@$(DOWNLOAD) $(LLVM_SOURCES)/compiler-rt-$(LLVM_VERSION).src.tar.xz -O $@

src/compiler-rt: src/compiler-rt.tar.xz
	@mkdir -p $@ && tar xf $< -C $@ -m --strip-components=1

src/libunwind.tar.xz:
	@$(DOWNLOAD) $(LLVM_SOURCES)/libunwind-$(LLVM_VERSION).src.tar.xz -O $@

src/libunwind: src/libunwind.tar.xz
	@mkdir -p $@ && tar xf $< -C $@ -m --strip-components=1

src/libcxxabi.tar.xz:
	@$(DOWNLOAD) $(LLVM_SOURCES)/libcxxabi-$(LLVM_VERSION).src.tar.xz -O $@

src/libcxxabi: src/libcxxabi.tar.xz
	@mkdir -p $@ && tar xf $< -C $@ -m --strip-components=1

src/libcxx.tar.xz:
	@$(DOWNLOAD) $(LLVM_SOURCES)/libcxx-$(LLVM_VERSION).src.tar.xz -O $@

src/libcxx: src/libcxx.tar.xz
	@mkdir -p $@ && tar xf $< -C $@ -m --strip-components=1

src/msvc:
	@git clone --depth 1 $(MSVC_SOURCES) src/msvc
	@python src/msvc/vsdownload.py --cache src/msvc/cache --dest src/msvc --accept-license
	@sh src/msvc/install.sh src/msvc
	@rm -rf src/msvc/cache

src/fmt.tar.gz:
	@$(DOWNLOAD) $(FMT_ARCHIVE) -O $@

src/fmt: src/fmt.tar.gz
	@mkdir -p $@ && tar xf $< -C $@ -m --strip-components=1
	@cd $@ && patch -p0 < $(CURDIR)/res/fmt-$(FMT_VERSION).patch

src/lz4.tar.gz:
	@$(DOWNLOAD) $(LZ4_ARCHIVE) -O $@

src/lz4: src/lz4.tar.gz
	@mkdir -p $@ && tar xf $< -C $@ -m --strip-components=1
	@cd $@ && patch -p0 < $(CURDIR)/res/lz4-$(LZ4_VERSION).patch
	@cp res/lz4/CMakeLists.txt src/lz4/CMakeLists.txt

src/benchmark.tar.gz:
	@$(DOWNLOAD) $(BENCHMARK_ARCHIVE) -O $@

src/benchmark: src/benchmark.tar.gz
	@mkdir -p $@ && tar xf $< -C $@ -m --strip-components=1
	@cd $@ && patch -p0 < $(CURDIR)/res/benchmark-$(BENCHMARK_VERSION).patch

src/doctest.tar.gz:
	@$(DOWNLOAD) $(DOCTEST_ARCHIVE) -O $@

src/doctest: src/doctest.tar.gz
	@mkdir -p $@ && tar xf $< -C $@ -m --strip-components=1
	@cd $@ && patch -p0 < $(CURDIR)/res/doctest-$(DOCTEST_VERSION).patch

# =============================================================================
# stage
# =============================================================================

stage: \
  stage/configure \
  stage/build

stage/configure:
	@cmake -Wno-dev -GNinja \
	  -DCMAKE_BUILD_TYPE="Release" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)" \
	  -DLLD_SYMLINKS_TO_CREATE="ld.lld;ld64.lld;lld-link" \
	  -DLLVM_DEFAULT_TARGET_TRIPLE="$(LLVM_TRIPLE)" \
	  -DLLVM_ENABLE_BACKTRACES=OFF \
	  -DLLVM_ENABLE_BINDINGS=OFF \
	  -DLLVM_ENABLE_LIBEDIT=ON \
	  -DLLVM_ENABLE_LIBPFM=ON \
	  -DLLVM_ENABLE_LIBXML2=ON \
	  -DLLVM_ENABLE_OCAMLDOC=OFF \
	  -DLLVM_ENABLE_PLUGINS=OFF \
	  -DLLVM_ENABLE_PROJECTS="lld;clang;compiler-rt;libcxxabi;libcxx" \
	  -DLLVM_ENABLE_TERMINFO=ON \
	  -DLLVM_ENABLE_UNWIND_TABLES=OFF \
	  -DLLVM_ENABLE_Z3_SOLVER=OFF \
	  -DLLVM_ENABLE_ZLIB=ON \
	  -DLLVM_INCLUDE_BENCHMARKS=OFF \
	  -DLLVM_INCLUDE_DOCS=OFF \
	  -DLLVM_INCLUDE_EXAMPLES=OFF \
	  -DLLVM_INCLUDE_GO_TESTS=OFF \
	  -DLLVM_INCLUDE_TESTS=OFF \
	  -DLLVM_INCLUDE_UTILS=OFF \
	  -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
	  -DLLVM_TARGETS_TO_BUILD="X86" \
	  -DLLVM_TOOLCHAIN_TOOLS="llvm-ar;llvm-nm;llvm-objcopy;llvm-ranlib;llvm-config" \
	  -DCLANG_DEFAULT_CXX_STDLIB="libc++" \
	  -DCLANG_DEFAULT_LINKER="lld" \
	  -DCLANG_DEFAULT_OBJCOPY="llvm-objcopy" \
	  -DCLANG_DEFAULT_RTLIB="compiler-rt" \
	  -DCLANG_DEFAULT_STD_C="c11" \
	  -DCLANG_DEFAULT_STD_CXX="cxx20" \
	  -DCLANG_DEFAULT_UNWINDLIB="none" \
	  -DCLANG_ENABLE_ARCMT=ON \
	  -DCLANG_ENABLE_PROTO_FUZZER=OFF \
	  -DCLANG_ENABLE_STATIC_ANALYZER=ON \
	  -DCLANG_LINKS_TO_CREATE="clang++" \
	  -DCLANG_PLUGIN_SUPPORT=OFF \
	  -DCOMPILER_RT_BUILD_BUILTINS=ON \
	  -DCOMPILER_RT_BUILD_CRT=ON \
	  -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
	  -DCOMPILER_RT_BUILD_MEMPROF=OFF \
	  -DCOMPILER_RT_BUILD_PROFILE=OFF \
	  -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
	  -DCOMPILER_RT_BUILD_XRAY=OFF \
	  -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="$(LLVM_TRIPLE)" \
	  -DCOMPILER_RT_SANITIZERS_TO_BUILD="" \
	  -DCOMPILER_RT_USE_LIBCXX=ON \
	  -DLIBCXXABI_ENABLE_ASSERTIONS=OFF \
	  -DLIBCXXABI_ENABLE_EXCEPTIONS=OFF \
	  -DLIBCXXABI_ENABLE_SHARED=OFF \
	  -DLIBCXXABI_ENABLE_STATIC=ON \
	  -DLIBCXXABI_HERMETIC_STATIC_LIBRARY=ON \
	  -DLIBCXXABI_INCLUDE_TESTS=OFF \
	  -DLIBCXXABI_USE_COMPILER_RT=ON \
	  -DLIBCXX_ABI_UNSTABLE=ON \
	  -DLIBCXX_ABI_VERSION=2 \
	  -DLIBCXX_CXX_ABI="libcxxabi" \
	  -DLIBCXX_ENABLE_ASSERTIONS=OFF \
	  -DLIBCXX_ENABLE_EXCEPTIONS=OFF \
	  -DLIBCXX_ENABLE_EXPERIMENTAL_LIBRARY=OFF \
	  -DLIBCXX_ENABLE_FILESYSTEM=OFF \
	  -DLIBCXX_ENABLE_RTTI=OFF \
	  -DLIBCXX_ENABLE_SHARED=OFF \
	  -DLIBCXX_ENABLE_STATIC=ON \
	  -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
	  -DLIBCXX_HERMETIC_STATIC_LIBRARY=ON \
	  -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
	  -DLIBCXX_INCLUDE_DOCS=OFF \
	  -DLIBCXX_INCLUDE_TESTS=OFF \
	  -DLIBCXX_USE_COMPILER_RT=ON \
	  -B $(BUILD)/stage src/llvm

stage/build:
	@ninja -C $(BUILD)/stage \
	  lld \
	  llvm-ar \
	  llvm-nm \
	  llvm-objcopy \
	  llvm-ranlib \
	  llvm-config \
	  llvm-tblgen \
	  clang \
	  compiler-rt \
	  cxxabi \
	  cxx

# =============================================================================
# llvm
# =============================================================================

llvm: \
  llvm/configure \
  llvm/install

llvm/configure:
	@cmake -Wno-dev -GNinja \
	  -DCMAKE_BUILD_TYPE="Release" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)" \
	  -DCMAKE_AR="$(BUILD)/stage/bin/llvm-ar" \
	  -DCMAKE_NM="$(BUILD)/stage/bin/llvm-nm" \
	  -DCMAKE_RANLIB="$(BUILD)/stage/bin/llvm-ranlib" \
	  -DCMAKE_C_COMPILER="$(BUILD)/stage/bin/clang" \
	  -DCMAKE_C_FLAGS="-march=$(ARCH) -D_DEFAULT_SOURCE=1" \
	  -DCMAKE_CXX_COMPILER="$(BUILD)/stage/bin/clang++" \
	  -DCMAKE_CXX_FLAGS="-march=$(ARCH) -D_DEFAULT_SOURCE=1" \
	  -DCMAKE_EXE_LINKER_FLAGS="-s -Wl,--as-needed" \
	  -DCMAKE_MODULE_LINKER_FLAGS="-s -Wl,--as-needed" \
	  -DCMAKE_SHARED_LINKER_FLAGS="-s -Wl,--as-needed" \
	  -DLLD_SYMLINKS_TO_CREATE="ld.lld;ld64.lld;lld-link" \
	  -DLLVM_DEFAULT_TARGET_TRIPLE="$(LLVM_TRIPLE)" \
	  -DLLVM_ENABLE_BACKTRACES=OFF \
	  -DLLVM_ENABLE_BINDINGS=OFF \
	  -DLLVM_ENABLE_LIBEDIT=ON \
	  -DLLVM_ENABLE_LIBPFM=ON \
	  -DLLVM_ENABLE_LIBXML2=ON \
	  -DLLVM_ENABLE_LTO="Full" \
	  -DLLVM_ENABLE_OCAMLDOC=OFF \
	  -DLLVM_ENABLE_PLUGINS=OFF \
	  -DLLVM_ENABLE_PROJECTS="lld;clang;clang-tools-extra;compiler-rt;lldb;libcxxabi;libcxx" \
	  -DLLVM_ENABLE_TERMINFO=ON \
	  -DLLVM_ENABLE_UNWIND_TABLES=OFF \
	  -DLLVM_ENABLE_Z3_SOLVER=OFF \
	  -DLLVM_ENABLE_ZLIB=ON \
	  -DLLVM_INCLUDE_BENCHMARKS=OFF \
	  -DLLVM_INCLUDE_DOCS=OFF \
	  -DLLVM_INCLUDE_EXAMPLES=OFF \
	  -DLLVM_INCLUDE_GO_TESTS=OFF \
	  -DLLVM_INCLUDE_TESTS=OFF \
	  -DLLVM_INCLUDE_UTILS=OFF \
	  -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
	  -DLLVM_TARGETS_TO_BUILD="X86" \
	  -DLLVM_TOOLCHAIN_TOOLS="llvm-ar;llvm-nm;llvm-mt;llvm-objcopy;llvm-ranlib;llvm-rc;llvm-config" \
	  -DCLANG_DEFAULT_CXX_STDLIB="libc++" \
	  -DCLANG_DEFAULT_LINKER="lld" \
	  -DCLANG_DEFAULT_OBJCOPY="llvm-objcopy" \
	  -DCLANG_DEFAULT_RTLIB="compiler-rt" \
	  -DCLANG_DEFAULT_STD_C="c11" \
	  -DCLANG_DEFAULT_STD_CXX="cxx20" \
	  -DCLANG_DEFAULT_UNWINDLIB="none" \
	  -DCLANG_ENABLE_ARCMT=ON \
	  -DCLANG_ENABLE_PROTO_FUZZER=OFF \
	  -DCLANG_ENABLE_STATIC_ANALYZER=ON \
	  -DCLANG_LINKS_TO_CREATE="clang++" \
	  -DCLANG_PLUGIN_SUPPORT=OFF \
	  -DCOMPILER_RT_BUILD_BUILTINS=ON \
	  -DCOMPILER_RT_BUILD_CRT=ON \
	  -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
	  -DCOMPILER_RT_BUILD_MEMPROF=OFF \
	  -DCOMPILER_RT_BUILD_PROFILE=OFF \
	  -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
	  -DCOMPILER_RT_BUILD_XRAY=OFF \
	  -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="$(LLVM_TRIPLE)" \
	  -DCOMPILER_RT_SANITIZERS_TO_BUILD="" \
	  -DCOMPILER_RT_USE_LIBCXX=ON \
	  -DLIBCXXABI_ENABLE_ASSERTIONS=OFF \
	  -DLIBCXXABI_ENABLE_EXCEPTIONS=OFF \
	  -DLIBCXXABI_ENABLE_SHARED=ON \
	  -DLIBCXXABI_ENABLE_STATIC=ON \
	  -DLIBCXXABI_TARGET_TRIPLE="$(LLVM_TRIPLE)" \
	  -DLIBCXXABI_USE_COMPILER_RT=ON \
	  -DLIBCXX_ABI_UNSTABLE=ON \
	  -DLIBCXX_ABI_VERSION=2 \
	  -DLIBCXX_CXX_ABI="libcxxabi" \
	  -DLIBCXX_ENABLE_ASSERTIONS=OFF \
	  -DLIBCXX_ENABLE_EXCEPTIONS=OFF \
	  -DLIBCXX_ENABLE_FILESYSTEM=ON \
	  -DLIBCXX_ENABLE_RTTI=OFF \
	  -DLIBCXX_ENABLE_SHARED=ON \
	  -DLIBCXX_ENABLE_STATIC=ON \
	  -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
	  -DLIBCXX_ENABLE_EXPERIMENTAL_LIBRARY=OFF \
	  -DLIBCXX_HERMETIC_STATIC_LIBRARY=ON \
	  -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
	  -DLIBCXX_STATICALLY_LINK_ABI_IN_SHARED_LIBRARY=OFF \
	  -DLIBCXX_STATICALLY_LINK_ABI_IN_STATIC_LIBRARY=ON \
	  -DLIBCXX_TARGET_TRIPLE="$(LLVM_TRIPLE)" \
	  -DLIBCXX_USE_COMPILER_RT=ON \
	  -DLLDB_ENABLE_CURSES=ON \
	  -DLLDB_ENABLE_LIBEDIT=ON \
	  -DLLDB_ENABLE_LIBXML2=ON \
	  -DLLDB_ENABLE_LUA=OFF \
	  -DLLDB_ENABLE_LZMA=ON \
	  -DLLDB_ENABLE_PYTHON=OFF \
	  -B $(BUILD)/llvm src/llvm

llvm/install:
	@ninja -C $(BUILD)/llvm \
	  install-lld \
	  install-llvm-ar \
	  install-llvm-nm \
	  install-llvm-mt \
	  install-llvm-objcopy \
	  install-llvm-ranlib \
	  install-llvm-rc \
	  install-llvm-config \
	  install-clang \
	  install-clang-resource-headers \
	  install-clang-format \
	  install-clang-tidy \
	  install-clangd \
	  install-libclang-headers \
	  install-libclang \
	  install-compiler-rt-headers \
	  install-compiler-rt \
	  install-cxxabi \
	  install-cxx-headers \
	  install-cxx \
	  install-lldb \
	  install-lldb-instr \
	  install-lldb-server \
	  install-lldb-vscode \
	  install-liblldb
	@ln -snf clang bin/clang++
	@mv bin/clang-$(LLVM_RELEASE) bin/clang
	@patchelf --set-rpath '$$ORIGIN' lib/libc++.so.2.0
	@patchelf --set-rpath '$$ORIGIN' lib/libc++abi.so.1.0
	@patchelf --set-rpath '$$ORIGIN' lib/libclang.so.$(LLVM_RELEASE)
	@patchelf --set-rpath '$$ORIGIN' lib/liblldb.so.$(LLVM_VERSION)
	@rm -rf share

# =============================================================================
# msvc
# =============================================================================

MSVC_RELEASE := $$(ls src/msvc/vc/Redist/MSVC | grep '^v' | head -1 | sed -E 's/v([0-9]+)/\1/')
MSVC_VERSION := $$(ls src/msvc/vc/tools/msvc | head -1)
MSVC_SRCPATH := src/msvc/vc/tools/msvc/$(MSVC_VERSION)
MSVC_BINPATH := src/msvc/vc/Redist/MSVC/$(MSVC_VERSION)/debug_nonredist

WSDK_RELEASE := $$(ls src/msvc/kits | head -1)
WSDK_VERSION := $$(ls src/msvc/kits/$(WSDK_RELEASE)/include | head -1)
WSDK_LIBPATH := src/msvc/kits/$(WSDK_RELEASE)/lib/$(WSDK_VERSION)
WSDK_BINPATH := src/msvc/kits/$(WSDK_RELEASE)/bin/$(WSDK_VERSION)
WSDK_INCPATH := src/msvc/kits/$(WSDK_RELEASE)/include/$(WSDK_VERSION)

msvc: \
  msvc/prepare \
  msvc/compiler-rt

msvc/prepare:
	@echo "Installing MSVC Headers ..."
	@cmake -E copy_directory $(MSVC_SRCPATH)/include $(MSVC)/include
	@cmake -E copy_directory $(WSDK_INCPATH)/ucrt $(MSVC)/include
	@cmake -E copy_directory $(WSDK_INCPATH)/um $(MSVC)/include
	@cmake -E copy_directory $(WSDK_INCPATH)/shared $(MSVC)/include
	@echo "Installing MSVC Libraries ..."
	@cmake -E copy_directory $(MSVC_SRCPATH)/lib/x64 $(MSVC)/lib
	@cmake -E copy_directory $(WSDK_LIBPATH)/ucrt/x64 $(MSVC)/lib
	@cmake -E copy_directory $(WSDK_LIBPATH)/um/x64 $(MSVC)/lib
	@echo "Installing MSVC Binaries ..."
	@mkdir -p $(MSVC)/bin
	@cp $(MSVC_SRCPATH)/bin/Hostx64/x64/vcruntime140.dll $(MSVC)/bin/vcruntime140.dll
	@cp $(MSVC_SRCPATH)/bin/Hostx64/x64/vcruntime140_1.dll $(MSVC)/bin/vcruntime140_1.dll
	@cp $(MSVC_SRCPATH)/bin/Hostx64/x64/msvcp140.dll $(MSVC)/bin/msvcp140.dll
	@cp $(MSVC_SRCPATH)/bin/Hostx64/x64/msvcp140_1.dll $(MSVC)/bin/msvcp140_1.dll
	@cp $(MSVC_SRCPATH)/bin/Hostx64/x64/msvcp140_2.dll $(MSVC)/bin/msvcp140_2.dll
	@cp $(MSVC_SRCPATH)/bin/Hostx64/x64/msvcp140_atomic_wait.dll $(MSVC)/bin/msvcp140_atomic_wait.dll
	@mv $(MSVC)/include/gdiplusmem.h $(MSVC)/include/GdiplusMem.h
	@mv $(MSVC)/include/gdiplusbase.h $(MSVC)/include/GdiplusBase.h
	@mv $(MSVC)/include/gdiplusenums.h $(MSVC)/include/GdiplusEnums.h
	@mv $(MSVC)/include/gdiplustypes.h $(MSVC)/include/GdiplusTypes.h
	@mv $(MSVC)/include/gdiplusinit.h $(MSVC)/include/GdiplusInit.h
	@mv $(MSVC)/include/gdipluspixelformats.h $(MSVC)/include/GdiplusPixelFormats.h
	@mv $(MSVC)/include/gdipluscolor.h $(MSVC)/include/GdiplusColor.h
	@mv $(MSVC)/include/gdiplusmetaheader.h $(MSVC)/include/GdiplusMetaHeader.h
	@mv $(MSVC)/include/gdiplusimaging.h $(MSVC)/include/GdiplusImaging.h
	@mv $(MSVC)/include/gdipluscolormatrix.h $(MSVC)/include/GdiplusColorMatrix.h
	@mv $(MSVC)/include/gdiplusgpstubs.h $(MSVC)/include/GdiplusGpStubs.h
	@mv $(MSVC)/include/gdiplusheaders.h $(MSVC)/include/GdiplusHeaders.h
	@mv $(MSVC)/include/gdiplusflat.h $(MSVC)/include/GdiplusFlat.h
	@mv $(MSVC)/include/gdiplusimageattributes.h $(MSVC)/include/GdiplusImageAttributes.h
	@mv $(MSVC)/include/gdiplusbitmap.h $(MSVC)/include/GdiplusBitmap.h
	@mv $(MSVC)/include/gdiplusbrush.h $(MSVC)/include/GdiplusBrush.h
	@mv $(MSVC)/include/gdipluscachedbitmap.h $(MSVC)/include/GdiplusCachedBitmap.h
	@mv $(MSVC)/include/gdipluseffects.h $(MSVC)/include/GdiplusEffects.h
	@mv $(MSVC)/include/gdiplusfont.h $(MSVC)/include/GdiplusFont.h
	@mv $(MSVC)/include/gdiplusfontcollection.h $(MSVC)/include/GdiplusFontCollection.h
	@mv $(MSVC)/include/gdiplusfontfamily.h $(MSVC)/include/GdiplusFontFamily.h
	@mv $(MSVC)/include/gdiplusgraphics.h $(MSVC)/include/GdiplusGraphics.h
	@mv $(MSVC)/include/gdiplusimagecodec.h $(MSVC)/include/GdiplusImageCodec.h
	@mv $(MSVC)/include/gdipluslinecaps.h $(MSVC)/include/GdiplusLineCaps.h
	@mv $(MSVC)/include/gdiplusmatrix.h $(MSVC)/include/GdiplusMatrix.h
	@mv $(MSVC)/include/gdiplusmetafile.h $(MSVC)/include/GdiplusMetafile.h
	@mv $(MSVC)/include/gdipluspath.h $(MSVC)/include/GdiplusPath.h
	@mv $(MSVC)/include/gdipluspen.h $(MSVC)/include/GdiplusPen.h
	@mv $(MSVC)/include/gdiplusregion.h $(MSVC)/include/GdiplusRegion.h
	@mv $(MSVC)/include/gdiplusstringformat.h $(MSVC)/include/GdiplusStringFormat.h

msvc/compiler-rt: \
  msvc/compiler-rt/configure \
  msvc/compiler-rt/install

msvc/compiler-rt/configure:
	@cmake -Wno-dev -GNinja \
	  -DCMAKE_BUILD_TYPE="Release" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/lib/clang/12.0.0" \
	  -DCMAKE_TOOLCHAIN_FILE="$(MSVC_TOOLCHAIN)" \
	  -DCMAKE_CXX_FLAGS_RELEASE="-O3 -DNDEBUG -D_MT -Xclang --dependent-lib=libcmt" \
	  -DLLVM_CONFIG_PATH="$(BUILD)/llvm/bin/llvm-config" \
	  -DCOMPILER_RT_BUILD_BUILTINS=ON \
	  -DCOMPILER_RT_BUILD_CRT=ON \
	  -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
	  -DCOMPILER_RT_BUILD_MEMPROF=OFF \
	  -DCOMPILER_RT_BUILD_PROFILE=OFF \
	  -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
	  -DCOMPILER_RT_BUILD_XRAY=OFF \
	  -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="$(MSVC_TRIPLE)" \
	  -DCOMPILER_RT_SANITIZERS_TO_BUILD="" \
	  -DCOMPILER_RT_USE_LIBCXX=ON \
	  -B $(BUILD)/msvc/compiler-rt src/compiler-rt

msvc/compiler-rt/install:
	@ninja -C $(BUILD)/msvc/compiler-rt install

# =============================================================================
# toolchain
# =============================================================================

LLVM_C_FLAGS_RELEASE := -O3 -DNDEBUG -flto=full
LLVM_C_FLAGS_MINSIZEREL := -Os -DNDEBUG

LLVM_CXX_FLAGS_RELEASE := -O3 -DNDEBUG -flto=full -fwhole-program-vtables
LLVM_CXX_FLAGS_MINSIZEREL := -Os -DNDEBUG

MSVC_C_FLAGS_RELEASE := -O3 -DNDEBUG -flto=full
MSVC_C_FLAGS_RELEASE += -Xclang -flto-visibility-public-std -D_MT -Xclang --dependent-lib=libcmt
MSVC_C_FLAGS_MINSIZEREL := -Os -DNDEBUG -D_DLL -D_MT -Xclang --dependent-lib=msvcrt

MSVC_CXX_FLAGS_RELEASE := -O3 -DNDEBUG -flto=full -fwhole-program-vtables
MSVC_CXX_FLAGS_RELEASE += -Xclang -flto-visibility-public-std -D_MT -Xclang --dependent-lib=libcmt
MSVC_CXX_FLAGS_MINSIZEREL := -Os -DNDEBUG -D_DLL -D_MT -Xclang --dependent-lib=msvcrt

# =============================================================================
# libs
# =============================================================================

libs: fmt lz4 benchmark doctest

# =============================================================================
# fmt
# =============================================================================

fmt: \
  fmt/llvm \
  fmt/msvc

fmt/llvm: \
  fmt/llvm/debug \
  fmt/llvm/release

fmt/llvm/debug: \
  fmt/llvm/debug/configure \
  fmt/llvm/debug/install

fmt/llvm/debug/configure:
	@cmake -Wno-dev -GNinja \
	  -DCMAKE_BUILD_TYPE="MinSizeRel" \
	  -DCMAKE_INSTALL_PREFIX="$(BUILD)/fmt/debug/install" \
	  -DCMAKE_TOOLCHAIN_FILE="$(LLVM_TOOLCHAIN)" \
	  -DBUILD_SHARED_LIBS=ON \
	  -DHAVE_STRTOD_L=OFF \
	  -DFMT_DOC=OFF \
	  -DFMT_FUZZ=OFF \
	  -DFMT_TEST=OFF \
	  -B $(BUILD)/fmt/debug/build src/fmt

fmt/llvm/debug/install:
	@ninja -C $(BUILD)/fmt/debug/build install
	@cp build/fmt/debug/install/lib/libfmt.so.$(FMT_VERSION) $(LLVM)/lib/libfmt.so
	@patchelf --set-soname libfmt.so $(LLVM)/lib/libfmt.so
	@patchelf --set-rpath '$$ORIGIN' $(LLVM)/lib/libfmt.so

fmt/llvm/release: \
  fmt/llvm/release/configure \
  fmt/llvm/release/install

fmt/llvm/release/configure:
	@cmake -Wno-dev -GNinja \
	  -DCMAKE_BUILD_TYPE="Release" \
	  -DCMAKE_INSTALL_PREFIX="$(BUILD)/fmt/release/install" \
	  -DCMAKE_TOOLCHAIN_FILE="$(LLVM_TOOLCHAIN)" \
	  -DHAVE_STRTOD_L=OFF \
	  -DFMT_DOC=OFF \
	  -DFMT_FUZZ=OFF \
	  -DFMT_TEST=OFF \
	  -B $(BUILD)/fmt/release/build src/fmt

fmt/llvm/release/install:
	@ninja -C $(BUILD)/fmt/release/build install
	@cp build/fmt/release/install/lib/libfmt.a $(LLVM)/lib/libfmt.a
	@cmake -E copy_directory build/fmt/release/install/include/fmt $(LLVM)/include/fmt

fmt/msvc: \
  fmt/msvc/debug \
  fmt/msvc/release

fmt/msvc/debug: \
  fmt/msvc/debug/configure \
  fmt/msvc/debug/install

fmt/msvc/debug/configure:
	@cmake -Wno-dev -GNinja \
	  -DCMAKE_BUILD_TYPE="MinSizeRel" \
	  -DCMAKE_INSTALL_PREFIX="$(BUILD)/msvc/fmt/debug/install" \
	  -DCMAKE_TOOLCHAIN_FILE="$(MSVC_TOOLCHAIN)" \
	  -DCMAKE_CXX_FLAGS_MINSIZEREL="$(MSVC_CXX_FLAGS_MINSIZEREL) -Wno-undefined-var-template" \
	  -DCMAKE_MINSIZEREL_POSTFIX="d" \
	  -DBUILD_SHARED_LIBS=ON \
	  -DHAVE_STRTOD_L=OFF \
	  -DFMT_DOC=OFF \
	  -DFMT_FUZZ=OFF \
	  -DFMT_TEST=OFF \
	  -B $(BUILD)/msvc/fmt/debug/build src/fmt

fmt/msvc/debug/install:
	@ninja -C $(BUILD)/msvc/fmt/debug/build install
	@cp build/msvc/fmt/debug/install/bin/fmtd.dll $(MSVC)/bin/fmtd.dll
	@cp build/msvc/fmt/debug/install/lib/fmtd.lib $(MSVC)/lib/fmtd.lib

fmt/msvc/release: \
  fmt/msvc/release/configure \
  fmt/msvc/release/install

fmt/msvc/release/configure:
	@cmake -Wno-dev -GNinja \
	  -DCMAKE_BUILD_TYPE="Release" \
	  -DCMAKE_INSTALL_PREFIX="$(BUILD)/msvc/fmt/release/install" \
	  -DCMAKE_TOOLCHAIN_FILE="$(MSVC_TOOLCHAIN)" \
	  -DHAVE_STRTOD_L=OFF \
	  -DFMT_DOC=OFF \
	  -DFMT_FUZZ=OFF \
	  -DFMT_TEST=OFF \
	  -B $(BUILD)/msvc/fmt/release/build src/fmt

fmt/msvc/release/install:
	@ninja -C $(BUILD)/msvc/fmt/release/build install
	@cp build/msvc/fmt/release/install/lib/fmt.lib $(MSVC)/lib/fmt.lib
	@cmake -E copy_directory build/msvc/fmt/release/install/include/fmt $(MSVC)/include/fmt

# =============================================================================
# lz4
# =============================================================================

lz4: \
  lz4/llvm \
  lz4/msvc

lz4/llvm: \
  lz4/llvm/debug \
  lz4/llvm/release

lz4/llvm/debug: \
  lz4/llvm/debug/configure \
  lz4/llvm/debug/install

lz4/llvm/debug/configure:
	@cmake -Wno-dev -GNinja \
	  -DCMAKE_BUILD_TYPE="MinSizeRel" \
	  -DCMAKE_INSTALL_PREFIX="$(BUILD)/lz4/debug/install" \
	  -DCMAKE_TOOLCHAIN_FILE="$(LLVM_TOOLCHAIN)" \
	  -DBUILD_SHARED_LIBS=ON \
	  -B $(BUILD)/lz4/debug/build src/lz4

lz4/llvm/debug/install:
	@ninja -C $(BUILD)/lz4/debug/build install
	@cp build/lz4/debug/install/lib/liblz4.so $(LLVM)/lib/liblz4.so
	@patchelf --set-soname liblz4.so $(LLVM)/lib/liblz4.so
	@patchelf --set-rpath '$$ORIGIN' $(LLVM)/lib/liblz4.so

lz4/llvm/release: \
  lz4/llvm/release/configure \
  lz4/llvm/release/install

lz4/llvm/release/configure:
	@cmake -Wno-dev -GNinja \
	  -DCMAKE_BUILD_TYPE="Release" \
	  -DCMAKE_INSTALL_PREFIX="$(BUILD)/lz4/release/install" \
	  -DCMAKE_TOOLCHAIN_FILE="$(LLVM_TOOLCHAIN)" \
	  -B $(BUILD)/lz4/release/build src/lz4

lz4/llvm/release/install:
	@ninja -C $(BUILD)/lz4/release/build install
	@cp build/lz4/release/install/lib/liblz4.a $(LLVM)/lib/liblz4.a
	@cmake -E copy_directory build/lz4/release/install/include $(LLVM)/include

lz4/msvc: \
  lz4/msvc/debug \
  lz4/msvc/release

lz4/msvc/debug: \
  lz4/msvc/debug/configure \
  lz4/msvc/debug/install

lz4/msvc/debug/configure:
	@cmake -Wno-dev -GNinja \
	  -DCMAKE_BUILD_TYPE="MinSizeRel" \
	  -DCMAKE_INSTALL_PREFIX="$(BUILD)/msvc/lz4/debug/install" \
	  -DCMAKE_TOOLCHAIN_FILE="$(MSVC_TOOLCHAIN)" \
	  -DCMAKE_MINSIZEREL_POSTFIX="d" \
	  -DBUILD_SHARED_LIBS=ON \
	  -B $(BUILD)/msvc/lz4/debug/build src/lz4

lz4/msvc/debug/install:
	@ninja -C $(BUILD)/msvc/lz4/debug/build install
	@cp build/msvc/lz4/debug/install/bin/lz4d.dll $(MSVC)/bin/lz4d.dll
	@cp build/msvc/lz4/debug/install/lib/lz4d.lib $(MSVC)/lib/lz4d.lib

lz4/msvc/release: \
  lz4/msvc/release/configure \
  lz4/msvc/release/install

lz4/msvc/release/configure:
	@cmake -Wno-dev -GNinja \
	  -DCMAKE_BUILD_TYPE="Release" \
	  -DCMAKE_INSTALL_PREFIX="$(BUILD)/msvc/lz4/release/install" \
	  -DCMAKE_TOOLCHAIN_FILE="$(MSVC_TOOLCHAIN)" \
	  -B $(BUILD)/msvc/lz4/release/build src/lz4

lz4/msvc/release/install:
	@ninja -C $(BUILD)/msvc/lz4/release/build install
	@cp build/msvc/lz4/release/install/lib/lz4.lib $(MSVC)/lib/lz4.lib
	@cmake -E copy_directory build/msvc/lz4/release/install/include $(MSVC)/include

# =============================================================================
# benchmark
# =============================================================================

benchmark: \
  benchmark/llvm \
  benchmark/msvc

benchmark/llvm: \
  benchmark/llvm/configure \
  benchmark/llvm/install

benchmark/llvm/configure:
	@cmake -Wno-dev -GNinja \
	  -DCMAKE_BUILD_TYPE="Release" \
	  -DCMAKE_INSTALL_PREFIX="$(BUILD)/benchmark/install" \
	  -DCMAKE_TOOLCHAIN_FILE="$(LLVM_TOOLCHAIN)" \
	  -DHAVE_STD_REGEX=ON \
	  -DHAVE_STEADY_CLOCK=ON \
	  -DBENCHMARK_ENABLE_EXCEPTIONS=OFF \
	  -DBENCHMARK_ENABLE_GTEST_TESTS=OFF \
	  -DBENCHMARK_ENABLE_TESTING=OFF \
	  -B $(BUILD)/benchmark/build src/benchmark

benchmark/llvm/install:
	@ninja -C $(BUILD)/benchmark/build install
	@cp build/benchmark/install/lib/libbenchmark.a $(LLVM)/lib/libbenchmark.a
	@cmake -E copy_directory build/benchmark/install/include/benchmark $(LLVM)/include/benchmark

benchmark/msvc: \
  benchmark/msvc/debug \
  benchmark/msvc/release

benchmark/msvc/debug: \
  benchmark/msvc/debug/configure \
  benchmark/msvc/debug/install

benchmark/msvc/debug/configure:
	@cmake -Wno-dev -GNinja \
	  -DCMAKE_BUILD_TYPE="MinSizeRel" \
	  -DCMAKE_INSTALL_PREFIX="$(BUILD)/msvc/benchmark/debug/install" \
	  -DCMAKE_TOOLCHAIN_FILE="$(MSVC_TOOLCHAIN)" \
	  -DCMAKE_MINSIZEREL_POSTFIX="d" \
	  -DHAVE_STD_REGEX=ON \
	  -DHAVE_STEADY_CLOCK=ON \
	  -DBENCHMARK_ENABLE_EXCEPTIONS=OFF \
	  -DBENCHMARK_ENABLE_GTEST_TESTS=OFF \
	  -DBENCHMARK_ENABLE_TESTING=OFF \
	  -B $(BUILD)/msvc/benchmark/debug/build src/benchmark

benchmark/msvc/debug/install:
	@ninja -C $(BUILD)/msvc/benchmark/debug/build install
	@cp build/msvc/benchmark/debug/install/lib/benchmarkd.lib $(MSVC)/lib/benchmarkd.lib

benchmark/msvc/release: \
  benchmark/msvc/release/configure \
  benchmark/msvc/release/install

benchmark/msvc/release/configure:
	@cmake -Wno-dev -GNinja \
	  -DCMAKE_BUILD_TYPE="Release" \
	  -DCMAKE_INSTALL_PREFIX="$(BUILD)/msvc/benchmark/release/install" \
	  -DCMAKE_TOOLCHAIN_FILE="$(MSVC_TOOLCHAIN)" \
	  -DHAVE_STD_REGEX=ON \
	  -DHAVE_STEADY_CLOCK=ON \
	  -DBENCHMARK_ENABLE_EXCEPTIONS=OFF \
	  -DBENCHMARK_ENABLE_GTEST_TESTS=OFF \
	  -DBENCHMARK_ENABLE_TESTING=OFF \
	  -B $(BUILD)/msvc/benchmark/release/build src/benchmark

benchmark/msvc/release/install:
	@ninja -C $(BUILD)/msvc/benchmark/release/build install
	@cp build/msvc/benchmark/release/install/lib/benchmark.lib $(MSVC)/lib/benchmark.lib
	@cmake -E copy_directory build/msvc/benchmark/release/install/include/benchmark $(MSVC)/include/benchmark

# =============================================================================
# doctest
# =============================================================================

doctest: \
  doctest/llvm \
  doctest/msvc

doctest/llvm: \
  doctest/llvm/configure \
  doctest/llvm/install

doctest/llvm/configure:
	@cmake -Wno-dev -GNinja \
	  -DCMAKE_BUILD_TYPE="MinSizeRel" \
	  -DCMAKE_INSTALL_PREFIX="$(BUILD)/doctest/install" \
	  -DCMAKE_TOOLCHAIN_FILE="$(LLVM_TOOLCHAIN)" \
	  -DDOCTEST_USE_STD_HEADERS=ON \
	  -DDOCTEST_WITH_TESTS=OFF \
	  -B $(BUILD)/doctest/build src/doctest

doctest/llvm/install:
	@ninja -C $(BUILD)/doctest/build install
	@cp build/doctest/install/lib/libdoctest.a $(LLVM)/lib/libdoctest.a
	@cmake -E copy_directory build/doctest/install/include/doctest $(LLVM)/include/doctest

doctest/msvc: \
  doctest/msvc/debug \
  doctest/msvc/release

doctest/msvc/debug: \
  doctest/msvc/debug/configure \
  doctest/msvc/debug/install

doctest/msvc/debug/configure:
	@cmake -Wno-dev -GNinja \
	  -DCMAKE_BUILD_TYPE="MinSizeRel" \
	  -DCMAKE_INSTALL_PREFIX="$(BUILD)/msvc/doctest/debug/install" \
	  -DCMAKE_TOOLCHAIN_FILE="$(MSVC_TOOLCHAIN)" \
	  -DCMAKE_MINSIZEREL_POSTFIX="d" \
	  -DDOCTEST_USE_STD_HEADERS=ON \
	  -DDOCTEST_WITH_TESTS=OFF \
	  -B $(BUILD)/msvc/doctest/debug/build src/doctest

doctest/msvc/debug/install:
	@ninja -C $(BUILD)/msvc/doctest/debug/build install
	@cp build/msvc/doctest/debug/install/lib/doctestd.lib $(MSVC)/lib/doctestd.lib

doctest/msvc/release: \
  doctest/msvc/release/configure \
  doctest/msvc/release/install

doctest/msvc/release/configure:
	@cmake -Wno-dev -GNinja \
	  -DCMAKE_BUILD_TYPE="Release" \
	  -DCMAKE_INSTALL_PREFIX="$(BUILD)/msvc/doctest/release/install" \
	  -DCMAKE_TOOLCHAIN_FILE="$(MSVC_TOOLCHAIN)" \
	  -DDOCTEST_USE_STD_HEADERS=ON \
	  -DDOCTEST_WITH_TESTS=OFF \
	  -B $(BUILD)/msvc/doctest/release/build src/doctest

doctest/msvc/release/install:
	@ninja -C $(BUILD)/msvc/doctest/release/build install
	@cp build/msvc/doctest/release/install/lib/doctest.lib $(MSVC)/lib/doctest.lib
	@cmake -E copy_directory build/msvc/doctest/release/install/include/doctest $(MSVC)/include/doctest

# =============================================================================
# clean
# =============================================================================

clean: clean/build clean/src

clean/build:
	rm -rf build

clean/build/stage:
	rm -rf build/stage

clean/build/llvm:
	rm -rf build/llvm

clean/build/msvc:
	rm -rf build/msvc

clean/build/libs:
	rm -rf build/fmt build/lz4 build/benchmark build/doctest

clean/src:
	rm -rf src

clean/src/llvm:
	rm -rf src/lld src/llvm src/clang src/clang-tools-extra src/lldb
	rm -rf src/compiler-rt src/libunwind src/libcxxabi src/libcxx

clean/src/msvc:
	rm -rf src/msvc

clean/src/libs:
	rm -rf src/fmt src/lz4 src/benchmark src/doctest

# =============================================================================
# reset
# =============================================================================

reset: reset/llvm reset/msvc clean

reset/llvm:
	rm -rf bin include lib

reset/msvc:
	rm -rf msvc

.PHONY: download download/llvm download/msvc download/libs
.PHONY: stage llvm msvc libs
.PHONY: fmt lz4 benchmark doctest
.PHONY: clean reset

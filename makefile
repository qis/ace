SYSTEM = linux

# =============================================================================
# usage
# =============================================================================

all:
	@echo "usage:"
	@echo ""
	@echo "  make download"
	@echo "  make llvm msvc"
	@echo "  make package install"
	@echo "  make clean"
	@echo ""

# =============================================================================
# download
# =============================================================================

DOWNLOAD = mkdir -p src; wget -c -nc -q --show-progress --no-use-server-timestamps
LLVM_SRC = https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0
MSVC_SRC = https://github.com/mstorsjo/msvc-wine

download: \
  src/llvm \
  src/msvc

src/llvm.tar.xz:
	@$(DOWNLOAD) $(LLVM_SRC)/clang+llvm-12.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz -O $@

src/llvm.exe:
	@$(DOWNLOAD) $(LLVM_SRC)/LLVM-12.0.0-win64.exe -O $@

src/llvm: src/llvm.tar.xz src/llvm.exe
	@mkdir src/llvm
	@7z x -osrc/llvm src/llvm.exe
	@tar xf src/llvm.tar.xz -C src/llvm -m --strip-components=1

src/msvc-wine:
	@mkdir -p $@; git clone --depth 1 $(MSVC_SRC) $@

src/msvc: src/msvc-wine
	@python src/msvc-wine/vsdownload.py --cache src/msvc/cache --dest src/msvc --accept-license --preview
	@sh src/msvc-wine/install.sh src/msvc; rm -rf src/msvc/cache

# =============================================================================
# llvm
# =============================================================================

llvm:
	@cmake -E copy src/llvm/bin/clang-12 llvm/bin/clang
	@cmake -E copy src/llvm/bin/clang.exe llvm/bin/clang.exe
	@cmake -E copy src/llvm/bin/clangd llvm/bin/clangd
	@cmake -E copy src/llvm/bin/clangd.exe llvm/bin/clangd.exe
	@cmake -E copy src/llvm/bin/clang-format llvm/bin/clang-format
	@cmake -E copy src/llvm/bin/clang-format.exe llvm/bin/clang-format.exe
	@cmake -E copy src/llvm/bin/clang-tidy llvm/bin/clang-tidy
	@cmake -E copy src/llvm/bin/clang-tidy.exe llvm/bin/clang-tidy.exe
	@cmake -E copy src/llvm/bin/lld llvm/bin/lld
	@cmake -E copy src/llvm/bin/lld.exe llvm/bin/lld.exe
	@cmake -E copy src/llvm/bin/lldb llvm/bin/lldb
	@cmake -E copy src/llvm/bin/lldb-instr llvm/bin/lldb-instr
	@cmake -E copy src/llvm/bin/lldb-server llvm/bin/lldb-server
	@cmake -E copy src/llvm/bin/lldb-vscode llvm/bin/lldb-vscode
	@cmake -E copy src/llvm/bin/llvm-ar llvm/bin/llvm-ar
	@cmake -E copy src/llvm/bin/llvm-ar.exe llvm/bin/llvm-ar.exe
	@cmake -E copy src/llvm/bin/llvm-nm llvm/bin/llvm-nm
	@cmake -E copy src/llvm/bin/llvm-nm.exe llvm/bin/llvm-nm.exe
	@cmake -E copy src/llvm/bin/llvm-objcopy llvm/bin/llvm-objcopy
	@cmake -E copy src/llvm/bin/llvm-objcopy.exe llvm/bin/llvm-objcopy.exe
	@cmake -E copy src/llvm/bin/llvm-rc llvm/bin/llvm-rc
	@cmake -E copy src/llvm/bin/llvm-rc.exe llvm/bin/llvm-rc.exe
	@cmake -E copy src/llvm/lib/liblldb.so.12.0.0 llvm/lib/liblldb.so.12
	@cmake -E copy src/llvm/bin/LTO.dll llvm/bin/LTO.dll
	@cmake -E copy src/llvm/lib/libLTO.so.12 llvm/lib/libLTO.so.12
	@cmake -E copy src/llvm/lib/libc++.a llvm/lib/libc++.a
	@cmake -E copy src/llvm/lib/libc++.so.1.0 llvm/lib/libc++.so.1
	@cmake -E copy src/llvm/lib/libc++abi.a llvm/lib/libc++abi.a
	@cmake -E copy src/llvm/lib/libc++abi.so.1.0 llvm/lib/libc++abi.so.1
	@cmake -E copy src/llvm/lib/libunwind.a llvm/lib/libunwind.a
	@cmake -E copy src/llvm/lib/libunwind.so.1.0 llvm/lib/libunwind.so.1
	@cmake -E copy_directory src/llvm/lib/clang llvm/lib/clang
	@cmake -E copy_directory src/llvm/lib/site-packages llvm/lib/site-packages
	@cmake -E copy_directory src/llvm/include/c++ llvm/include/c++
	@patchelf --set-rpath '$$ORIGIN' llvm/lib/libc++.so.1
	@find llvm -type d -exec chmod 0755 '{}' ';'
	@find llvm -type f -exec chmod 0644 '{}' ';'

# =============================================================================
# msvc
# =============================================================================

MSVC_RELEASE = $$(ls src/msvc/vc/Redist/MSVC | grep '^v' | head -1 | sed -E 's/v([0-9]+)/\1/')
MSVC_VERSION = $$(ls src/msvc/vc/tools/msvc | head -1)
MSVC_SRCPATH = src/msvc/vc/tools/msvc/$(MSVC_VERSION)
MSVC_BINPATH = src/msvc/vc/Redist/MSVC/$(MSVC_VERSION)/debug_nonredist

WSDK_RELEASE = $$(ls src/msvc/kits | head -1)
WSDK_VERSION = $$(ls src/msvc/kits/$(WSDK_RELEASE)/include | head -1)
WSDK_LIBPATH = src/msvc/kits/$(WSDK_RELEASE)/lib/$(WSDK_VERSION)
WSDK_BINPATH = src/msvc/kits/$(WSDK_RELEASE)/bin/$(WSDK_VERSION)
WSDK_INCPATH = src/msvc/kits/$(WSDK_RELEASE)/include/$(WSDK_VERSION)

msvc:
	@mkdir -p msvc/bin
	@cmake -E copy_directory $(MSVC_SRCPATH)/include msvc/include
	@cmake -E copy_directory $(WSDK_INCPATH)/ucrt msvc/include
	@cmake -E copy_directory $(WSDK_INCPATH)/um msvc/include
	@cmake -E copy_directory $(WSDK_INCPATH)/shared msvc/include
	@cmake -E copy_directory $(MSVC_SRCPATH)/lib/x64 msvc/lib
	@cmake -E copy_directory $(WSDK_LIBPATH)/ucrt/x64 msvc/lib
	@cmake -E copy_directory $(WSDK_LIBPATH)/um/x64 msvc/lib
	@cp $(MSVC_SRCPATH)/bin/Hostx64/x64/vcruntime140.dll msvc/bin/vcruntime140.dll
	@cp $(MSVC_SRCPATH)/bin/Hostx64/x64/vcruntime140_1.dll msvc/bin/vcruntime140_1.dll
	@cp $(MSVC_SRCPATH)/bin/Hostx64/x64/msvcp140.dll msvc/bin/msvcp140.dll
	@cp $(MSVC_SRCPATH)/bin/Hostx64/x64/msvcp140_1.dll msvc/bin/msvcp140_1.dll
	@cp $(MSVC_SRCPATH)/bin/Hostx64/x64/msvcp140_2.dll msvc/bin/msvcp140_2.dll
	@cp $(MSVC_SRCPATH)/bin/Hostx64/x64/msvcp140_atomic_wait.dll msvc/bin/msvcp140_atomic_wait.dll
	@mv msvc/include/gdiplusmem.h msvc/include/GdiplusMem.h
	@mv msvc/include/gdiplusbase.h msvc/include/GdiplusBase.h
	@mv msvc/include/gdiplusenums.h msvc/include/GdiplusEnums.h
	@mv msvc/include/gdiplustypes.h msvc/include/GdiplusTypes.h
	@mv msvc/include/gdiplusinit.h msvc/include/GdiplusInit.h
	@mv msvc/include/gdipluspixelformats.h msvc/include/GdiplusPixelFormats.h
	@mv msvc/include/gdipluscolor.h msvc/include/GdiplusColor.h
	@mv msvc/include/gdiplusmetaheader.h msvc/include/GdiplusMetaHeader.h
	@mv msvc/include/gdiplusimaging.h msvc/include/GdiplusImaging.h
	@mv msvc/include/gdipluscolormatrix.h msvc/include/GdiplusColorMatrix.h
	@mv msvc/include/gdiplusgpstubs.h msvc/include/GdiplusGpStubs.h
	@mv msvc/include/gdiplusheaders.h msvc/include/GdiplusHeaders.h
	@mv msvc/include/gdiplusflat.h msvc/include/GdiplusFlat.h
	@mv msvc/include/gdiplusimageattributes.h msvc/include/GdiplusImageAttributes.h
	@mv msvc/include/gdiplusbitmap.h msvc/include/GdiplusBitmap.h
	@mv msvc/include/gdiplusbrush.h msvc/include/GdiplusBrush.h
	@mv msvc/include/gdipluscachedbitmap.h msvc/include/GdiplusCachedBitmap.h
	@mv msvc/include/gdipluseffects.h msvc/include/GdiplusEffects.h
	@mv msvc/include/gdiplusfont.h msvc/include/GdiplusFont.h
	@mv msvc/include/gdiplusfontcollection.h msvc/include/GdiplusFontCollection.h
	@mv msvc/include/gdiplusfontfamily.h msvc/include/GdiplusFontFamily.h
	@mv msvc/include/gdiplusgraphics.h msvc/include/GdiplusGraphics.h
	@mv msvc/include/gdiplusimagecodec.h msvc/include/GdiplusImageCodec.h
	@mv msvc/include/gdipluslinecaps.h msvc/include/GdiplusLineCaps.h
	@mv msvc/include/gdiplusmatrix.h msvc/include/GdiplusMatrix.h
	@mv msvc/include/gdiplusmetafile.h msvc/include/GdiplusMetafile.h
	@mv msvc/include/gdipluspath.h msvc/include/GdiplusPath.h
	@mv msvc/include/gdipluspen.h msvc/include/GdiplusPen.h
	@mv msvc/include/gdiplusregion.h msvc/include/GdiplusRegion.h
	@mv msvc/include/gdiplusstringformat.h msvc/include/GdiplusStringFormat.h
	@rm -f msvc/lib/LIBCMT.lib
	@rm -f msvc/lib/LIBCMTD.lib
	@rm -f msvc/lib/MSVCRT.lib
	@rm -f msvc/lib/MSVCRTD.lib
	@rm -f msvc/lib/OLDNAMES.lib
	@find msvc -type d -exec chmod 0755 '{}' ';'
	@find msvc -type f -exec chmod 0644 '{}' ';'

# =============================================================================
# package
# =============================================================================

package:
	@cmake -E rm -f ace-linux.7z
	@7z a ace-linux.7z \
	  llvm/bin/clang \
	  llvm/bin/clangd \
	  llvm/bin/clang-format \
	  llvm/bin/clang-tidy \
	  llvm/bin/lld \
	  llvm/bin/lldb \
	  llvm/bin/lldb-instr \
	  llvm/bin/lldb-server \
	  llvm/bin/lldb-vscode \
	  llvm/bin/llvm-ar \
	  llvm/bin/llvm-nm \
	  llvm/bin/llvm-objcopy \
	  llvm/bin/llvm-rc \
	  llvm/lib/libLTO.so.12 \
	  llvm/lib/liblldb.so.12 \
	  llvm/lib/libc++.a \
	  llvm/lib/libc++.so.1 \
	  llvm/lib/libc++abi.a \
	  llvm/lib/libc++abi.so.1 \
	  llvm/lib/libunwind.a \
	  llvm/lib/libunwind.so.1 \
	  llvm/lib/clang/12.0.0/bin \
	  llvm/lib/clang/12.0.0/lib/linux \
	  llvm/include
	@cmake -E rm -f ace-windows.7z
	@7z a ace-windows.7z \
	  llvm/bin/clang.exe \
	  llvm/bin/clangd.exe \
	  llvm/bin/clang-format.exe \
	  llvm/bin/clang-tidy.exe \
	  llvm/bin/lld.exe \
	  llvm/bin/llvm-ar.exe \
	  llvm/bin/llvm-nm.exe \
	  llvm/bin/llvm-objcopy.exe \
	  llvm/bin/llvm-rc.exe \
	  llvm/bin/LTO.dll \
	  llvm/lib/clang/12.0.0/lib/windows
	@cmake -E rm -f ace-common.7z
	@7z a ace-common.7z msvc \
	  llvm/lib/clang/12.0.0/include \
	  llvm/lib/clang/12.0.0/share \
	  llvm/lib/site-packages

# =============================================================================
# install
# =============================================================================

install: install/$(SYSTEM)

install/linux: ace-linux.7z ace-common.7z
	@cmake -E rm -rf llvm msvc
	@7z x ace-common.7z
	@7z x ace-linux.7z
	@cmake -E create_symlink clang llvm/bin/clang++
	@cmake -E create_symlink lld llvm/bin/ld.lld
	@cmake -E create_symlink lld llvm/bin/ld64.lld
	@cmake -E create_symlink lld llvm/bin/lld-link
	@cmake -E create_symlink llvm-ar llvm/bin/llvm-lib
	@cmake -E create_symlink llvm-ar llvm/bin/llvm-ranlib
	@cmake -E create_symlink llvm-objcopy llvm/bin/llvm-strip
	@cmake -E create_symlink libc++.so.1 llvm/lib/libc++.so
	@cmake -E create_symlink libc++abi.so.1 llvm/lib/libc++abi.so
	@cmake -E create_symlink libunwind.so.1 llvm/lib/libunwind.so
	@cmake -E create_symlink liblldb.so.12 llvm/lib/liblldb.so
	@find llvm msvc -type d -exec chmod 0755 '{}' ';'
	@find llvm msvc -type f -exec chmod 0644 '{}' ';'
	@chmod 0755 llvm/bin/clang
	@chmod 0755 llvm/bin/clang-format
	@chmod 0755 llvm/bin/clang-tidy
	@chmod 0755 llvm/bin/clangd
	@chmod 0755 llvm/bin/lld
	@chmod 0755 llvm/bin/lldb
	@chmod 0755 llvm/bin/lldb-instr
	@chmod 0755 llvm/bin/lldb-server
	@chmod 0755 llvm/bin/lldb-vscode
	@chmod 0755 llvm/bin/llvm-ar
	@chmod 0755 llvm/bin/llvm-nm
	@chmod 0755 llvm/bin/llvm-objcopy
	@chmod 0755 llvm/bin/llvm-rc

install/windows: ace-windows.7z ace-common.7z
	@cmake -E rm -rf llvm msvc
	@7z x ace-common.7z
	@7z x ace-windows.7z
	@cmake -E create_symlink clang.exe llvm/bin/clang++.exe
	@cmake -E create_symlink lld.exe llvm/bin/ld.lld.exe
	@cmake -E create_symlink lld.exe llvm/bin/ld64.lld.exe
	@cmake -E create_symlink lld.exe llvm/bin/lld-link.exe
	@cmake -E create_symlink llvm-ar.exe llvm/bin/llvm-lib.exe
	@cmake -E create_symlink llvm-ar.exe llvm/bin/llvm-ranlib.exe
	@cmake -E create_symlink llvm-objcopy.exe llvm/bin/llvm-strip.exe

# =============================================================================
# clean
# =============================================================================

clean:
	rm -rf llvm msvc src

.PHONY: download
.PHONY: llvm msvc
.PHONY: package install
.PHONY: clean

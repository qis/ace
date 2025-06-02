#!/bin/sh
set -e
export LC_ALL=C
SCRIPT=$(readlink -f -- "${0}" || realpath -- "${0}")
SRC=$(dirname "${SCRIPT}")
ACE=$(dirname "${SRC}")
cd "${ACE}"

error() {
  printf "\e[1;31m$*\e[0m\n" 1>&2
  exit 1
}

warning() {
  printf "\e[1;33m$*\e[0m\n" 1>&2
}

print() {
  printf "\e[1;32m$*\e[0m\n" 1>&2
}

verify() {
  for i in "${@}"; do
    test -e "${i}" || error "File not found: ${i}"
  done
}

create() {
  touch "${1}" || error "Could not create file: ${1}"
}

# =================================================================================================
# downloads
# =================================================================================================

mkdir -p build/src/downloads
export PATH="${ACE}/build/src/pip/bin:${PATH}"
export PYTHONPATH="${ACE}/build/src/pip:${PYTHONPATH}"

download_tar() {
  if [ ! -f "build/src/downloads/${3}" ]; then
    wget -O "build/src/downloads/${3}" "${2}" || \
      (rm -f "build/src/downloads/${3}"; error "Download failed.")
  fi
  if [ ! -d "build/src/${1}" ]; then
    mkdir "build/src/${1}"
    if [ ${4} -gt 0 ]; then
      tar xf "build/src/downloads/${3}" -C "build/src/${1}" --strip-components=${4} || \
        (rm -rf "build/src/downloads/${3}" "build/src/${1}"; error "Extraction failed.")
    else
      tar xf "build/src/downloads/${3}" -C "build/src/${1}" || \
        (rm -rf "build/src/downloads/${3}" "build/src/${1}"; error "Extraction failed.")
    fi
  fi
  verify "build/src/${1}/${5}"
}

download_tag() {
  if [ ! -d "build/src/${1}" ]; then
    git clone -c advice.detachedHead=false -b "${3}" --depth 1 "${2}" "build/src/${1}" || \
      (rm -rf "build/src/${1}"; error "Cloning failed.")
  fi
  verify "build/src/${1}/${4}"
}

download_sha() {
  if [ ! -d "build/src/${1}" ]; then
    mkdir -p "build/src/${1}"
    env --chdir="build/src/${1}" git init -b master || \
      (rm -rf "build/src/${1}"; error "Could not initialize repository.")
    env --chdir="build/src/${1}" git remote add origin "${2}" || \
      (rm -rf "build/src/${1}"; error "Could not add origin: ${2}")
    env --chdir="build/src/${1}" git fetch origin "${3}" || \
      (rm -rf "build/src/${1}"; error "Could not fetch commit: ${3}")
    env --chdir="build/src/${1}" git reset --hard FETCH_HEAD || \
      (rm -rf "build/src/${1}"; error "Could not reset to fetch head.")
  fi
  verify "build/src/${1}/${4}"
}

download_pip() {
  local pkg=$(pip list --path build/src/pip | grep "^${1}")
  if [ -z "${pkg}" ]; then
    python3 -m pip install --no-cache-dir --upgrade -t build/src/pip "${1}"
  fi
}

# =================================================================================================
# download_tar "name" "${NAME_URL}" "${NAME_TAR}" <strip> "CMakeLists.txt"
# download_tag "name" "${NAME_GIT}" "${NAME_TAG}" "CMakeLists.txt"
# download_sha "name" "${NAME_GIT}" "${NAME_SHA}" "CMakeLists.txt"
# download_pip <package>

LLVM_VER="20.1.5"
LLVM_TAG="llvmorg-${LLVM_VER}"
LLVM_GIT="https://github.com/llvm/llvm-project"

download_tag "llvm" "${LLVM_GIT}" "${LLVM_TAG}" "README.md"

LLVM_RES="lib/clang/$(cmake -P src/version.cmake)"

# =================================================================================================

YASM_VER="1.3.0"
YASM_TAG="v${YASM_VER}"
YASM_GIT="https://github.com/yasm/yasm"
YASM_EXE="http://www.tortall.net/projects/yasm/releases/yasm-${YASM_VER}-win64.exe"

download_tag "yasm" "${YASM_GIT}" "${YASM_TAG}" "CMakeLists.txt"

# =================================================================================================

MINGW_VER="12.0.0"
MINGW_TAG="v${MINGW_VER}"
MINGW_GIT="https://github.com/mingw-w64/mingw-w64"

download_tag "mingw" "${MINGW_GIT}" "${MINGW_TAG}" "configure"

# =================================================================================================

VCPKG_VER="2025.04.09"
VCPKG_TAG="${VCPKG_VER}"
VCPKG_GIT="https://github.com/microsoft/vcpkg"

download_tag "vcpkg" "${VCPKG_GIT}" "${VCPKG_TAG}" "bootstrap-vcpkg.sh"

# =================================================================================================

READPE_VER="0.84"
READPE_TAG="v${READPE_VER}"
READPE_GIT="https://github.com/mentebinaria/readpe"

download_tag "readpe" "${READPE_GIT}" "${READPE_TAG}" "Makefile"

# =================================================================================================

POWERSHELL_VER="7.5.0"
POWERSHELL_TAG="v${POWERSHELL_VER}"
POWERSHELL_GIT="https://github.com/PowerShell/PowerShell"
POWERSHELL_URL="${POWERSHELL_GIT}/releases/download/${POWERSHELL_TAG}/powershell-${POWERSHELL_VER}-linux-x64.tar.gz"
POWERSHELL_TAR="powershell.tar.gz"

download_tar "powershell" "${POWERSHELL_URL}" "${POWERSHELL_TAR}" 0 "pwsh"

if [ ! -x build/src/powershell/pwsh ]; then
  chmod +x build/src/powershell/pwsh
fi

# =================================================================================================

download_pip "cross-sysroot"

# =================================================================================================
# linux
# =================================================================================================

if [ ! -d "${ACE}/sys/linux" ]; then
  print "Creating linux sysroot ..."
  cross-sysroot --distribution debian --distribution-version bullseye --architecture amd64 \
    --build-root "${ACE}/sys/linux" src/linux.txt || \
    (rm -rf "${ACE}/sys/linux"; error "Could not create linux sysroot.")

  rm -rf \
    sys/linux/etc \
    sys/linux/var \
    sys/linux/usr/bin \
    sys/linux/usr/sbin \
    sys/linux/usr/share \
    sys/linux/packages \
    sys/linux/debian-bullseye-amd64-Packages.db \
    sys/linux/debian-bullseye-amd64-Packages.gz

  symlinks -cdsr sys/linux
  find sys -type d -exec chmod 0755 '{}' ';'
  find sys -type f -exec chmod 0644 '{}' ';'
fi

# =================================================================================================
# llvm
# =================================================================================================

PLATFORM_VARIABLES="CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES;CMAKE_CXX_STANDARD_LINK_DIRECTORIES"

if [ "${1}" == "llvm/configure" ] || [ ! -e build/llvm/build.ninja ]; then
  print "Configuring llvm ..."
  cmake -GNinja -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}" \
    -DCMAKE_SYSTEM_NAME="Linux" \
    -DCMAKE_SYSTEM_VERSION="5.10.0" \
    -DCMAKE_SYSTEM_PROCESSOR="AMD64" \
    -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
    -DCMAKE_C_FLAGS_INIT="-march=x86-64-v3" \
    -DCMAKE_CXX_FLAGS_INIT="-march=x86-64-v3" \
    -DCMAKE_C_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DCMAKE_CXX_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DCMAKE_ASM_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-pc-linux-gnu" \
    -DLLVM_TARGETS_TO_BUILD="X86;WebAssembly;SPIRV" \
    -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld;lldb" \
    -DLLVM_ENABLE_LTO="Full" \
    -DLLVM_ENABLE_BINDINGS=OFF \
    -DLLVM_ENABLE_DOXYGEN=OFF \
    -DLLVM_ENABLE_LIBCXX=OFF \
    -DLLVM_ENABLE_LTO=OFF \
    -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DCLANG_DEFAULT_CXX_STDLIB="libc++" \
    -DCLANG_DEFAULT_RTLIB="compiler-rt" \
    -DCLANG_DEFAULT_UNWINDLIB="none" \
    -DCLANG_DEFAULT_LINKER="lld" \
    -DLLDB_ENABLE_PYTHON=OFF \
    -DLLDB_ENABLE_LUA=OFF \
    -DDEFAULT_SYSROOT="../sys/linux" \
    -B build/llvm build/src/llvm/llvm
  verify build/llvm/build.ninja
fi

if [ "${1}" == "llvm/build" ] || [ ! -e build/llvm/bin/clang ]; then
  print "Building llvm ..."
  ninja -C build/llvm \
    llvm-config \
    LTO \
    lld \
    lldb \
    lldb-dap \
    lldb-server \
    liblldb \
    llvm-ar \
    llvm-nm \
    llvm-mt \
    llvm-objcopy \
    llvm-objdump \
    llvm-ranlib \
    llvm-strip \
    llvm-size \
    llvm-cov \
    llvm-profdata \
    llvm-symbolizer \
    llvm-dlltool \
    llvm-windres \
    dsymutil \
    core-resource-headers \
    clang-resource-headers \
    clang-scan-deps \
    clang \
    clang-format \
    clang-tidy \
    clangd \
    libclang-headers \
    libclang
  verify build/llvm/bin/clang
fi

if [ "${1}" == "llvm/install" ] || [ ! -e bin/clang ]; then
  print "Installing llvm ..."
  ninja -C build/llvm \
    install-LTO-stripped \
    install-lld-stripped \
    install-lldb-stripped \
    install-lldb-dap-stripped \
    install-lldb-server-stripped \
    install-liblldb-stripped \
    install-llvm-ar-stripped \
    install-llvm-nm-stripped \
    install-llvm-mt-stripped \
    install-llvm-objcopy-stripped \
    install-llvm-objdump-stripped \
    install-llvm-ranlib-stripped \
    install-llvm-strip-stripped \
    install-llvm-size-stripped \
    install-llvm-cov-stripped \
    install-llvm-profdata-stripped \
    install-llvm-symbolizer-stripped \
    install-llvm-dlltool-stripped \
    install-llvm-windres-stripped \
    install-dsymutil-stripped \
    install-core-resource-headers \
    install-clang-resource-headers \
    install-clang-scan-deps-stripped \
    install-clang-stripped \
    install-clang-format-stripped \
    install-clang-tidy-stripped \
    install-clangd-stripped \
    install-libclang-headers \
    install-libclang-stripped
  verify bin/clang
fi

# =================================================================================================
# yasm
# =================================================================================================

if [ ! -e build/yasm/build.ninja ]; then
  print "Configuring yasm ..."
  cmake -GNinja -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}/build/yasm/install" \
    -DCMAKE_INSTALL_RPATH="\$ORIGIN/../lib" \
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
    -DYASM_BUILD_TESTS=OFF \
    -B build/yasm build/src/yasm
  verify build/yasm/build.ninja
fi

if [ ! -e build/yasm/yasm ]; then
  print "Building yasm ..."
  ninja -C build/yasm
  verify build/yasm/yasm
fi

if [ ! -e bin/yasm ]; then
  print "Installing yasm ..."
  ninja -C build/yasm install/strip
  cp -a build/yasm/install/bin/yasm bin/
  cp -a build/yasm/install/lib/libyasm.so lib/
  cp -a build/yasm/install/lib/libyasmstd.so lib/
  verify bin/yasm
fi

# =================================================================================================
# linux builtins
# =================================================================================================

if [ ! -e build/linux/builtins/build.ninja ]; then
  print "Configuring linux builtins ..."
  cmake -GNinja -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}/${LLVM_RES}" \
    -DCMAKE_CROSSCOMPILING=ON \
    -DCMAKE_SYSTEM_NAME="Linux" \
    -DCMAKE_SYSTEM_VERSION="5.10.0" \
    -DCMAKE_SYSTEM_PROCESSOR="AMD64" \
    -DCMAKE_SYSROOT="${ACE}/sys/linux" \
    -DCMAKE_FIND_ROOT_PATH="${ACE}" \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM="BOTH" \
    -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
    -DCMAKE_C_COMPILER_WORKS=ON \
    -DCMAKE_CXX_COMPILER_WORKS=ON \
    -DCMAKE_ASM_COMPILER_WORKS=ON \
    -DCMAKE_C_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_CXX_COMPILER="${ACE}/bin/clang++" \
    -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="${ACE}/bin/clang-scan-deps" \
    -DCMAKE_ASM_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_C_FLAGS_INIT="-march=x86-64-v2" \
    -DCMAKE_CXX_FLAGS_INIT="-march=x86-64-v2 -nostdlib++" \
    -DCMAKE_C_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DCMAKE_CXX_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DCMAKE_ASM_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-pc-linux-gnu" \
    -DLLVM_ENABLE_RUNTIMES="compiler-rt" \
    -DLLVM_ENABLE_LIBCXX=OFF \
    -DLLVM_ENABLE_LTO=OFF \
    -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DCOMPILER_RT_BUILD_BUILTINS=ON \
    -DCOMPILER_RT_BUILD_GWP_ASAN=OFF \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
    -DCOMPILER_RT_BUILD_MEMPROF=OFF \
    -DCOMPILER_RT_BUILD_ORC=OFF \
    -DCOMPILER_RT_BUILD_PROFILE=OFF \
    -DCOMPILER_RT_BUILD_CTX_PROFILE=OFF \
    -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
    -DCOMPILER_RT_BUILD_XRAY=OFF \
    -DCOMPILER_RT_DEFAULT_TARGET_ONLY=OFF \
    -DCAN_TARGET_x86_64=ON \
    -B build/linux/builtins build/src/llvm/runtimes
  verify build/linux/builtins/build.ninja
fi

if [ ! -e ${LLVM_RES}/lib/x86_64-pc-linux-gnu/libclang_rt.builtins.a ]; then
  print "Installing linux builtins ..."
  ninja -C build/linux/builtins install/strip
  verify ${LLVM_RES}/lib/x86_64-pc-linux-gnu/libclang_rt.builtins.a
fi

if [ ! -f "build/test/main" ]; then
  print "Compiling build/test/main ..."
  make -f src/test/makefile build/test/main
fi

# =================================================================================================
# linux runtimes (x86-64-v2)
# =================================================================================================

if [ ! -e build/linux/runtimes/x86-64-v2/build.ninja ]; then
  print "Configuring linux runtimes (x86-64-v2) ..."
  cmake -GNinja -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}/sys/linux/x86-64-v2" \
    -DCMAKE_CROSSCOMPILING=ON \
    -DCMAKE_SYSTEM_NAME="Linux" \
    -DCMAKE_SYSTEM_VERSION="5.10.0" \
    -DCMAKE_SYSTEM_PROCESSOR="AMD64" \
    -DCMAKE_SYSROOT="${ACE}/sys/linux" \
    -DCMAKE_FIND_ROOT_PATH="${ACE}" \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM="BOTH" \
    -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
    -DCMAKE_C_COMPILER_WORKS=ON \
    -DCMAKE_CXX_COMPILER_WORKS=ON \
    -DCMAKE_ASM_COMPILER_WORKS=ON \
    -DCMAKE_C_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_CXX_COMPILER="${ACE}/bin/clang++" \
    -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="${ACE}/bin/clang-scan-deps" \
    -DCMAKE_ASM_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_C_FLAGS_INIT="-march=x86-64-v2 -flto=thin" \
    -DCMAKE_CXX_FLAGS_INIT="-march=x86-64-v2 -flto=thin" \
    -DCMAKE_C_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DCMAKE_CXX_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DCMAKE_ASM_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-pc-linux-gnu" \
    -DLLVM_ENABLE_RUNTIMES="libcxxabi;libcxx" \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DLLVM_USE_LINKER="lld" \
    -DLIBCXXABI_ENABLE_SHARED=OFF \
    -DLIBCXXABI_ENABLE_STATIC=ON \
    -DLIBCXXABI_ENABLE_EXCEPTIONS=OFF \
    -DLIBCXXABI_INSTALL_HEADERS=OFF \
    -DLIBCXXABI_INSTALL_LIBRARY=OFF \
    -DLIBCXXABI_USE_COMPILER_RT=ON \
    -DLIBCXXABI_USE_LLVM_UNWINDER=OFF \
    -DLIBCXX_ABI_UNSTABLE=ON \
    -DLIBCXX_ABI_VERSION=2 \
    -DLIBCXX_ADDITIONAL_COMPILE_FLAGS="-march=x86-64-v2;-flto=thin;-fno-exceptions;-fno-rtti" \
    -DLIBCXX_ENABLE_SHARED=ON \
    -DLIBCXX_ENABLE_STATIC=ON \
    -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
    -DLIBCXX_ENABLE_EXCEPTIONS=OFF \
    -DLIBCXX_ENABLE_RTTI=OFF \
    -DLIBCXX_HAS_ATOMIC_LIB=OFF \
    -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
    -DLIBCXX_INSTALL_HEADERS=ON \
    -DLIBCXX_INSTALL_LIBRARY=ON \
    -DLIBCXX_INSTALL_MODULES=ON \
    -DLIBCXX_USE_COMPILER_RT=ON \
    -B build/linux/runtimes/x86-64-v2 build/src/llvm/runtimes
  verify build/linux/runtimes/x86-64-v2/build.ninja
fi

if [ ! -e sys/linux/x86-64-v2/lib/libc++.a ]; then
  print "Installing linux runtimes (x86-64-v2) ..."
  ninja -C build/linux/runtimes/x86-64-v2 install/strip
  verify sys/linux/x86-64-v2/lib/libc++.a
fi

if [ ! -f "build/test/main-v2" ]; then
  print "Compiling build/test/main-v2 ..."
  make -f src/test/makefile build/test/main-v2
fi

# =================================================================================================
# linux runtimes (x86-64-v3)
# =================================================================================================

if [ ! -e build/linux/runtimes/x86-64-v3/build.ninja ]; then
  print "Configuring linux runtimes (x86-64-v3) ..."
  cmake -GNinja -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}/sys/linux/x86-64-v3" \
    -DCMAKE_CROSSCOMPILING=ON \
    -DCMAKE_SYSTEM_NAME="Linux" \
    -DCMAKE_SYSTEM_VERSION="5.10.0" \
    -DCMAKE_SYSTEM_PROCESSOR="AMD64" \
    -DCMAKE_SYSROOT="${ACE}/sys/linux" \
    -DCMAKE_FIND_ROOT_PATH="${ACE}" \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM="BOTH" \
    -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
    -DCMAKE_C_COMPILER_WORKS=ON \
    -DCMAKE_CXX_COMPILER_WORKS=ON \
    -DCMAKE_ASM_COMPILER_WORKS=ON \
    -DCMAKE_C_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_CXX_COMPILER="${ACE}/bin/clang++" \
    -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="${ACE}/bin/clang-scan-deps" \
    -DCMAKE_ASM_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_C_FLAGS_INIT="-march=x86-64-v3 -mavx2 -flto=thin" \
    -DCMAKE_CXX_FLAGS_INIT="-march=x86-64-v3 -mavx2 -flto=thin" \
    -DCMAKE_C_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DCMAKE_CXX_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DCMAKE_ASM_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-pc-linux-gnu" \
    -DLLVM_ENABLE_RUNTIMES="libcxxabi;libcxx" \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DLLVM_USE_LINKER="lld" \
    -DLIBCXXABI_ENABLE_SHARED=OFF \
    -DLIBCXXABI_ENABLE_STATIC=ON \
    -DLIBCXXABI_ENABLE_EXCEPTIONS=OFF \
    -DLIBCXXABI_INSTALL_HEADERS=OFF \
    -DLIBCXXABI_INSTALL_LIBRARY=OFF \
    -DLIBCXXABI_USE_COMPILER_RT=ON \
    -DLIBCXXABI_USE_LLVM_UNWINDER=OFF \
    -DLIBCXX_ABI_UNSTABLE=ON \
    -DLIBCXX_ABI_VERSION=2 \
    -DLIBCXX_ADDITIONAL_COMPILE_FLAGS="-march=x86-64-v3;-mavx2;-flto=thin;-fno-exceptions;-fno-rtti" \
    -DLIBCXX_ENABLE_SHARED=ON \
    -DLIBCXX_ENABLE_STATIC=ON \
    -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
    -DLIBCXX_ENABLE_EXCEPTIONS=OFF \
    -DLIBCXX_ENABLE_RTTI=OFF \
    -DLIBCXX_HAS_ATOMIC_LIB=OFF \
    -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
    -DLIBCXX_INSTALL_HEADERS=ON \
    -DLIBCXX_INSTALL_LIBRARY=ON \
    -DLIBCXX_INSTALL_MODULES=ON \
    -DLIBCXX_USE_COMPILER_RT=ON \
    -B build/linux/runtimes/x86-64-v3 build/src/llvm/runtimes
  verify build/linux/runtimes/x86-64-v3/build.ninja
fi

if [ ! -e sys/linux/x86-64-v3/lib/libc++.a ]; then
  print "Installing linux runtimes (x86-64-v3) ..."
  ninja -C build/linux/runtimes/x86-64-v3 install/strip
  verify sys/linux/x86-64-v3/lib/libc++.a
fi

if [ ! -f "build/test/main-v3" ]; then
  print "Compiling build/test/main-v3 ..."
  make -f src/test/makefile build/test/main-v3
fi

# =================================================================================================
# linux compiler-rt
# =================================================================================================

if [ ! -e build/linux/compiler-rt/build.ninja ]; then
  print "Configuring linux compiler-rt ..."
  cmake -GNinja -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}/${LLVM_RES}" \
    -DCMAKE_CROSSCOMPILING=ON \
    -DCMAKE_SYSTEM_NAME="Linux" \
    -DCMAKE_SYSTEM_VERSION="5.10.0" \
    -DCMAKE_SYSTEM_PROCESSOR="AMD64" \
    -DCMAKE_SYSROOT="${ACE}/sys/linux" \
    -DCMAKE_FIND_ROOT_PATH="${ACE}" \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM="BOTH" \
    -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
    -DCMAKE_C_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_CXX_COMPILER="${ACE}/bin/clang++" \
    -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="${ACE}/bin/clang-scan-deps" \
    -DCMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES="${ACE}/sys/linux/x86-64-v2/include/c++/v1" \
    -DCMAKE_CXX_STANDARD_LINK_DIRECTORIES="${ACE}/sys/linux/x86-64-v2/lib" \
    -DCMAKE_TRY_COMPILE_PLATFORM_VARIABLES="${PLATFORM_VARIABLES}" \
    -DCMAKE_ASM_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_C_FLAGS_INIT="-march=x86-64-v2" \
    -DCMAKE_CXX_FLAGS_INIT="-march=x86-64-v2 -fno-exceptions -fno-rtti" \
    -DCMAKE_C_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DCMAKE_CXX_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DCMAKE_ASM_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-pc-linux-gnu" \
    -DLLVM_ENABLE_RUNTIMES="compiler-rt" \
    -DLLVM_ENABLE_LIBCXX=ON \
    -DLLVM_ENABLE_LTO=OFF \
    -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DCOMPILER_RT_BUILD_BUILTINS=OFF \
    -DCOMPILER_RT_BUILD_GWP_ASAN=OFF \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
    -DCOMPILER_RT_BUILD_MEMPROF=OFF \
    -DCOMPILER_RT_BUILD_ORC=ON \
    -DCOMPILER_RT_BUILD_PROFILE=ON \
    -DCOMPILER_RT_BUILD_CTX_PROFILE=ON \
    -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
    -DCOMPILER_RT_BUILD_XRAY=ON \
    -DCOMPILER_RT_DEFAULT_TARGET_ONLY=OFF \
    -B build/linux/compiler-rt build/src/llvm/runtimes
  verify build/linux/compiler-rt/build.ninja
fi

if [ ! -e ${LLVM_RES}/lib/x86_64-pc-linux-gnu/libclang_rt.profile.a ]; then
  print "Installing linux compiler-rt ..."
  ninja -C build/linux/compiler-rt install/strip
  verify ${LLVM_RES}/lib/x86_64-pc-linux-gnu/libclang_rt.profile.a
fi

# =================================================================================================
# mingw
# =================================================================================================

MINGW_LFLAGS="--target=x86_64-w64-mingw32 --sysroot=${ACE}/sys/mingw"
MINGW_CFLAGS="-O3 -march=x86-64-v2 ${MINGW_LFLAGS} -fms-compatibility-version=19.40"
MINGW_RFLAGS="-I${ACE}/sys/mingw/include"

if [ ! -e build/mingw/headers/Makefile ] ||
   [ ! -e sys/mingw/include/stddef.h ] ||
   [ ! -e build/mingw/crt/Makefile ] ||
   [ ! -e sys/mingw/lib/libntdll.a ] ||
   [ ! -e build/mingw/tools/Makefile ] ||
   [ ! -e bin/genidl ]; then
  print "Creating mingw sysroot ..."
fi

if [ ! -e build/mingw/headers/Makefile ]; then
  echo "Configuring mingw headers ..."
  mkdir -p build/mingw/headers
  env --chdir=build/mingw/headers ../../src/mingw/mingw-w64-headers/configure \
    CC="${ACE}/bin/clang" \
    AR="${ACE}/bin/llvm-ar" \
    NM="${ACE}/bin/llvm-nm" \
    RC="${ACE}/bin/llvm-windres" \
    RANLIB="${ACE}/bin/llvm-ranlib" \
    OBJCOPY="${ACE}/bin/llvm-objcopy" \
    OBJDUMP="${ACE}/bin/llvm-objdump" \
    DLLTOOL="${ACE}/bin/llvm-dlltool" \
    DSYMUTIL="${ACE}/bin/dsymutil" \
    STRIP="${ACE}/bin/llvm-strip" \
    SIZE="${ACE}/bin/llvm-size" \
    CFLAGS="${MINGW_CFLAGS}" \
    LDFLAGS="${MINGW_LFLAGS}" \
    LIBTOOLFLAGS="${MINGW_LFLAGS}" \
    RCFLAGS="${MINGW_RFLAGS}" \
    --with-default-win32-winnt="0x0A00" \
    --with-default-msvcrt="ucrt" \
    --prefix="${ACE}/sys/mingw" \
    --host="x86_64-w64-mingw32" \
    --enable-idl \
    > build/mingw/headers/configure.log 2>&1
  verify build/mingw/headers/Makefile
fi

if [ ! -e sys/mingw/include/stddef.h ]; then
  echo "Installing mingw headers ..."
  env --chdir=build/mingw/headers make -j17 install-strip \
    > build/mingw/headers/make-install-strip.log 2>&1
  verify sys/mingw/include/stddef.h
fi

if [ ! -e build/mingw/crt/Makefile ]; then
  echo "Configuring mingw crt ..."
  mkdir -p build/mingw/crt
  env --chdir=build/mingw/crt ../../src/mingw/mingw-w64-crt/configure \
    CC="${ACE}/bin/clang" \
    AR="${ACE}/bin/llvm-ar" \
    NM="${ACE}/bin/llvm-nm" \
    RC="${ACE}/bin/llvm-windres" \
    RANLIB="${ACE}/bin/llvm-ranlib" \
    OBJCOPY="${ACE}/bin/llvm-objcopy" \
    OBJDUMP="${ACE}/bin/llvm-objdump" \
    DLLTOOL="${ACE}/bin/llvm-dlltool" \
    DSYMUTIL="${ACE}/bin/dsymutil" \
    STRIP="${ACE}/bin/llvm-strip" \
    SIZE="${ACE}/bin/llvm-size" \
    CFLAGS="${MINGW_CFLAGS}" \
    LDFLAGS="${MINGW_LFLAGS}" \
    LIBTOOLFLAGS="${MINGW_LFLAGS}" \
    RCFLAGS="${MINGW_RFLAGS}" \
    --with-default-msvcrt="ucrt" \
    --prefix="${ACE}/sys/mingw" \
    --host="x86_64-w64-mingw32" \
    --disable-lib32 \
    --enable-lib64 \
    > build/mingw/crt/configure.log 2>&1
  verify build/mingw/crt/Makefile
fi

if [ ! -e sys/mingw/lib/libntdll.a ]; then
  echo "Installing mingw crt ..."
  env --chdir=build/mingw/crt make -j17 install-strip \
    > build/mingw/crt/make-install-strip.log 2>&1
  verify sys/mingw/lib/libntdll.a
fi

if [ ! -e build/mingw/tools/Makefile ]; then
  echo "Configuring mingw tools ..."
  mkdir -p build/mingw/tools
  env --chdir=build/mingw/tools ../../src/mingw/configure \
    CC="${ACE}/bin/clang" \
    AR="${ACE}/bin/llvm-ar" \
    NM="${ACE}/bin/llvm-nm" \
    RANLIB="${ACE}/bin/llvm-ranlib" \
    OBJCOPY="${ACE}/bin/llvm-objcopy" \
    OBJDUMP="${ACE}/bin/llvm-objdump" \
    STRIP="${ACE}/bin/llvm-strip" \
    SIZE="${ACE}/bin/llvm-size" \
    CFLAGS="-O3 -march=x86-64-v2 -flto=thin" \
    --with-default-win32-winnt="0x0A00" \
    --with-default-msvcrt="ucrt" \
    --prefix="${ACE}" \
    --with-tools="all" \
    --without-libraries \
    --without-headers \
    --without-crt \
    > build/mingw/tools/configure.log 2>&1
  verify build/mingw/tools/Makefile
fi

if [ ! -e bin/genidl ]; then
  echo "Installing mingw tools ..."
  env --chdir=build/mingw/tools make -j17 install-strip \
    > build/mingw/tools/make-install-strip.log 2>&1
  verify bin/genidl
fi

# =================================================================================================
# mingw builtins
# =================================================================================================

if [ ! -e build/mingw/builtins/build.ninja ]; then
  print "Configuring mingw builtins ..."
  cmake -GNinja -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}/${LLVM_RES}" \
    -DCMAKE_CROSSCOMPILING=ON \
    -DCMAKE_SYSTEM_NAME="Windows" \
    -DCMAKE_SYSTEM_VERSION="10.0" \
    -DCMAKE_SYSTEM_PROCESSOR="AMD64" \
    -DCMAKE_SYSROOT="${ACE}/sys/mingw" \
    -DCMAKE_FIND_ROOT_PATH="${ACE}" \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM="BOTH" \
    -DCMAKE_C_COMPILER_WORKS=ON \
    -DCMAKE_CXX_COMPILER_WORKS=ON \
    -DCMAKE_ASM_COMPILER_WORKS=ON \
    -DCMAKE_C_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_CXX_COMPILER="${ACE}/bin/clang++" \
    -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="${ACE}/bin/clang-scan-deps" \
    -DCMAKE_ASM_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_C_FLAGS_INIT="-march=x86-64-v2 -fms-compatibility-version=19.40" \
    -DCMAKE_CXX_FLAGS_INIT="-march=x86-64-v2 -fms-compatibility-version=19.40 -nostdlib++" \
    -DCMAKE_C_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DCMAKE_CXX_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DCMAKE_ASM_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-w64-mingw32" \
    -DLLVM_ENABLE_RUNTIMES="compiler-rt" \
    -DLLVM_ENABLE_LIBCXX=OFF \
    -DLLVM_ENABLE_LTO=OFF \
    -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DCOMPILER_RT_BUILD_BUILTINS=ON \
    -DCOMPILER_RT_BUILD_GWP_ASAN=OFF \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
    -DCOMPILER_RT_BUILD_MEMPROF=OFF \
    -DCOMPILER_RT_BUILD_ORC=OFF \
    -DCOMPILER_RT_BUILD_PROFILE=OFF \
    -DCOMPILER_RT_BUILD_CTX_PROFILE=OFF \
    -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
    -DCOMPILER_RT_BUILD_XRAY=OFF \
    -DCOMPILER_RT_DEFAULT_TARGET_ONLY=OFF \
    -DCAN_TARGET_x86_64=ON \
    -B build/mingw/builtins build/src/llvm/runtimes
  verify build/mingw/builtins/build.ninja
fi

if [ ! -e ${LLVM_RES}/lib/x86_64-w64-windows-gnu/libclang_rt.builtins.a ]; then
  print "Installing mingw builtins ..."
  ninja -C build/mingw/builtins install/strip
  verify ${LLVM_RES}/lib/x86_64-w64-windows-gnu/libclang_rt.builtins.a
fi

if [ ! -f "build/test/main.exe" ]; then
  print "Compiling build/test/main.exe ..."
  make -f src/test/makefile build/test/main.exe
fi

# =================================================================================================
# mingw runtimes (x86-64-v2)
# =================================================================================================

if [ ! -e build/mingw/runtimes/x86-64-v2/build.ninja ]; then
  print "Configuring mingw runtimes (x86-64-v2) ..."
  cmake -GNinja -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}/sys/mingw/x86-64-v2" \
    -DCMAKE_CROSSCOMPILING=ON \
    -DCMAKE_SYSTEM_NAME="Windows" \
    -DCMAKE_SYSTEM_VERSION="10.0" \
    -DCMAKE_SYSTEM_PROCESSOR="AMD64" \
    -DCMAKE_SYSROOT="${ACE}/sys/mingw" \
    -DCMAKE_FIND_ROOT_PATH="${ACE}" \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM="BOTH" \
    -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
    -DCMAKE_C_COMPILER_WORKS=ON \
    -DCMAKE_CXX_COMPILER_WORKS=ON \
    -DCMAKE_ASM_COMPILER_WORKS=ON \
    -DCMAKE_C_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_CXX_COMPILER="${ACE}/bin/clang++" \
    -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="${ACE}/bin/clang-scan-deps" \
    -DCMAKE_ASM_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_C_FLAGS_INIT="-march=x86-64-v2 -flto=thin -fms-compatibility-version=19.40" \
    -DCMAKE_CXX_FLAGS_INIT="-march=x86-64-v2 -flto=thin -fms-compatibility-version=19.40" \
    -DCMAKE_C_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DCMAKE_CXX_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DCMAKE_ASM_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-w64-mingw32" \
    -DLLVM_ENABLE_RUNTIMES="libcxxabi;libcxx" \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DLLVM_USE_LINKER="lld" \
    -DLIBCXXABI_ENABLE_SHARED=OFF \
    -DLIBCXXABI_ENABLE_STATIC=ON \
    -DLIBCXXABI_ENABLE_EXCEPTIONS=OFF \
    -DLIBCXXABI_INSTALL_HEADERS=OFF \
    -DLIBCXXABI_INSTALL_LIBRARY=OFF \
    -DLIBCXXABI_USE_COMPILER_RT=ON \
    -DLIBCXXABI_USE_LLVM_UNWINDER=OFF \
    -DLIBCXX_ABI_UNSTABLE=ON \
    -DLIBCXX_ABI_VERSION=2 \
    -DLIBCXX_ADDITIONAL_COMPILE_FLAGS="-march=x86-64-v2;-flto=thin;-fno-exceptions;-fno-rtti" \
    -DLIBCXX_ENABLE_SHARED=ON \
    -DLIBCXX_ENABLE_STATIC=ON \
    -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
    -DLIBCXX_ENABLE_EXCEPTIONS=OFF \
    -DLIBCXX_ENABLE_RTTI=OFF \
    -DLIBCXX_HAS_ATOMIC_LIB=OFF \
    -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
    -DLIBCXX_INSTALL_HEADERS=ON \
    -DLIBCXX_INSTALL_LIBRARY=ON \
    -DLIBCXX_INSTALL_MODULES=ON \
    -DLIBCXX_USE_COMPILER_RT=ON \
    -B build/mingw/runtimes/x86-64-v2 build/src/llvm/runtimes
  verify build/mingw/runtimes/x86-64-v2/build.ninja
fi

if [ ! -e sys/mingw/x86-64-v2/lib/libc++.a ]; then
  print "Installing mingw runtimes (x86-64-v2) ..."
  ninja -C build/mingw/runtimes/x86-64-v2 install/strip
  verify sys/mingw/x86-64-v2/lib/libc++.a
fi

if [ ! -f "build/test/main-v2.exe" ]; then
  print "Compiling build/test/main-v2.exe ..."
  make -f src/test/makefile build/test/main-v2.exe
fi

# =================================================================================================
# mingw runtimes (x86-64-v3)
# =================================================================================================

if [ ! -e build/mingw/runtimes/x86-64-v3/build.ninja ]; then
  print "Configuring mingw runtimes (x86-64-v3) ..."
  cmake -GNinja -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}/sys/mingw/x86-64-v3" \
    -DCMAKE_CROSSCOMPILING=ON \
    -DCMAKE_SYSTEM_NAME="Windows" \
    -DCMAKE_SYSTEM_VERSION="10.0" \
    -DCMAKE_SYSTEM_PROCESSOR="AMD64" \
    -DCMAKE_SYSROOT="${ACE}/sys/mingw" \
    -DCMAKE_FIND_ROOT_PATH="${ACE}" \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM="BOTH" \
    -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
    -DCMAKE_C_COMPILER_WORKS=ON \
    -DCMAKE_CXX_COMPILER_WORKS=ON \
    -DCMAKE_ASM_COMPILER_WORKS=ON \
    -DCMAKE_C_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_CXX_COMPILER="${ACE}/bin/clang++" \
    -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="${ACE}/bin/clang-scan-deps" \
    -DCMAKE_ASM_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_C_FLAGS_INIT="-march=x86-64-v3 -mavx2 -flto=thin -fms-compatibility-version=19.40" \
    -DCMAKE_CXX_FLAGS_INIT="-march=x86-64-v3 -mavx2 -flto=thin -fms-compatibility-version=19.40" \
    -DCMAKE_C_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DCMAKE_CXX_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DCMAKE_ASM_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-w64-mingw32" \
    -DLLVM_ENABLE_RUNTIMES="libcxxabi;libcxx" \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DLLVM_USE_LINKER="lld" \
    -DLIBCXXABI_ENABLE_SHARED=OFF \
    -DLIBCXXABI_ENABLE_STATIC=ON \
    -DLIBCXXABI_ENABLE_EXCEPTIONS=OFF \
    -DLIBCXXABI_INSTALL_HEADERS=OFF \
    -DLIBCXXABI_INSTALL_LIBRARY=OFF \
    -DLIBCXXABI_USE_COMPILER_RT=ON \
    -DLIBCXXABI_USE_LLVM_UNWINDER=OFF \
    -DLIBCXX_ABI_UNSTABLE=ON \
    -DLIBCXX_ABI_VERSION=2 \
    -DLIBCXX_ADDITIONAL_COMPILE_FLAGS="-march=x86-64-v3;-mavx2;-flto=thin;-fno-exceptions;-fno-rtti" \
    -DLIBCXX_ENABLE_SHARED=ON \
    -DLIBCXX_ENABLE_STATIC=ON \
    -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
    -DLIBCXX_ENABLE_EXCEPTIONS=OFF \
    -DLIBCXX_ENABLE_RTTI=OFF \
    -DLIBCXX_HAS_ATOMIC_LIB=OFF \
    -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
    -DLIBCXX_INSTALL_HEADERS=ON \
    -DLIBCXX_INSTALL_LIBRARY=ON \
    -DLIBCXX_INSTALL_MODULES=ON \
    -DLIBCXX_USE_COMPILER_RT=ON \
    -B build/mingw/runtimes/x86-64-v3 build/src/llvm/runtimes
  verify build/mingw/runtimes/x86-64-v3/build.ninja
fi

if [ ! -e sys/mingw/x86-64-v3/lib/libc++.a ]; then
  print "Installing mingw runtimes (x86-64-v3) ..."
  ninja -C build/mingw/runtimes/x86-64-v3 install/strip
  verify sys/mingw/x86-64-v3/lib/libc++.a
fi

if [ ! -f "build/test/main-v3.exe" ]; then
  print "Compiling build/test/main-v3.exe ..."
  make -f src/test/makefile build/test/main-v3.exe
fi

# =================================================================================================
# mingw compiler-rt
# =================================================================================================

if [ ! -e build/mingw/compiler-rt/build.ninja ]; then
  print "Configuring mingw compiler-rt ..."
  cmake -GNinja -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}/${LLVM_RES}" \
    -DCMAKE_CROSSCOMPILING=ON \
    -DCMAKE_SYSTEM_NAME="Windows" \
    -DCMAKE_SYSTEM_VERSION="10.0" \
    -DCMAKE_SYSTEM_PROCESSOR="AMD64" \
    -DCMAKE_SYSROOT="${ACE}/sys/mingw" \
    -DCMAKE_FIND_ROOT_PATH="${ACE}" \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM="BOTH" \
    -DCMAKE_C_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_CXX_COMPILER="${ACE}/bin/clang++" \
    -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="${ACE}/bin/clang-scan-deps" \
    -DCMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES="${ACE}/sys/mingw/x86-64-v2/include/c++/v1" \
    -DCMAKE_CXX_STANDARD_LINK_DIRECTORIES="${ACE}/sys/mingw/x86-64-v2/lib" \
    -DCMAKE_TRY_COMPILE_PLATFORM_VARIABLES="${PLATFORM_VARIABLES}" \
    -DCMAKE_ASM_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_C_FLAGS_INIT="-march=x86-64-v2 -fms-compatibility-version=19.40" \
    -DCMAKE_CXX_FLAGS_INIT="-march=x86-64-v2 -fms-compatibility-version=19.40 -fno-exceptions -fno-rtti" \
    -DCMAKE_C_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DCMAKE_CXX_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DCMAKE_ASM_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-w64-mingw32" \
    -DLLVM_ENABLE_RUNTIMES="compiler-rt" \
    -DLLVM_ENABLE_LIBCXX=ON \
    -DLLVM_ENABLE_LTO=OFF \
    -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=ON \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DCOMPILER_RT_BUILD_BUILTINS=OFF \
    -DCOMPILER_RT_BUILD_GWP_ASAN=OFF \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
    -DCOMPILER_RT_BUILD_MEMPROF=OFF \
    -DCOMPILER_RT_BUILD_ORC=ON \
    -DCOMPILER_RT_BUILD_PROFILE=ON \
    -DCOMPILER_RT_BUILD_CTX_PROFILE=OFF \
    -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
    -DCOMPILER_RT_BUILD_XRAY=OFF \
    -DCOMPILER_RT_DEFAULT_TARGET_ONLY=OFF \
    -B build/mingw/compiler-rt build/src/llvm/runtimes
  verify build/mingw/compiler-rt/build.ninja
fi

if [ ! -e ${LLVM_RES}/lib/x86_64-w64-windows-gnu/libclang_rt.profile.a ]; then
  print "Installing mingw compiler-rt ..."
  ninja -C build/mingw/compiler-rt install/strip
  verify ${LLVM_RES}/lib/x86_64-w64-windows-gnu/libclang_rt.profile.a
fi

# =================================================================================================
# test
# =================================================================================================

if [ "${1}" == "test" ]; then
  print "Running test applications ..."
  make -f src/test/makefile run
fi

# =================================================================================================
# readpe
# =================================================================================================

if [ ! -f build/readpe/Makefile ]; then
  rm -rf build/readpe; cp -a build/src/readpe build/readpe
fi

if [ ! -e build/readpe/src/build/peldd ]; then
  print "Building readpe ..."
  env --chdir=build/readpe make \
    CFLAGS="-march=x86-64-v3" \
    prefix="${ACE}" -j17
  verify build/readpe/src/build/peldd
fi

if [ ! -e bin/peldd ]; then
  print "Installing readpe ..."
  env --chdir=build/readpe make \
    CFLAGS="-march=x86-64-v3" \
    prefix="${ACE}" -j17 install-strip
  find build/readpe/src/build -maxdepth 1 -type f -executable -printf '%f\n' | while read exe; do
    patchelf --set-rpath '$ORIGIN/../lib' "bin/${exe}"
  done
  verify bin/peldd
fi

if [ -n "${1}" ]; then
  exit 0
fi

# =================================================================================================
# vcpkg
# =================================================================================================

if [ ! -x build/src/vcpkg/vcpkg ]; then
  print "Initializing vcpkg ..."
  env --chdir=build/src/vcpkg sh bootstrap-vcpkg.sh -disableMetrics
  verify build/src/vcpkg/vcpkg
fi

export PATH="${ACE}/bin:${ACE}/build/src/vcpkg:${PATH}"
export PATH="${ACE}/build/src/powershell:${PATH}"

export VCPKG_ROOT="${ACE}/build/src/vcpkg"
export VCPKG_DEFAULT_TRIPLET="linux-x86-64-v3"
export VCPKG_DEFAULT_HOST_TRIPLET="linux-x86-64-v3"
export VCPKG_DOWNLOADS="${ACE}/build/src/vcpkg/downloads"
export VCPKG_OVERLAY_TRIPLETS="${ACE}/src/triplets"
export VCPKG_OVERLAY_PORTS="${ACE}/src/ports"
export VCPKG_FEATURE_FLAGS="-binarycaching"
export VCPKG_WORKS_SYSTEM_BINARIES=1
export VCPKG_DISABLE_METRICS=1

# =================================================================================================
# ports
# =================================================================================================

if [ "${1}" = "check" ]; then
  find build/vcpkg/buildtrees -maxdepth 2 -type f -name 'install-*-x86-64-v2*-out.log' | while read file; do
    grep --color=always -- -mavx "${file}" && error "${file}" || true
  done
  print "Missing -mavx in the following files:"
  find build/vcpkg/buildtrees -maxdepth 2 -type f -name 'install-*-x86-64-v3-*-out.log' | while read file; do
    grep -q --color=always -- -mavx "${file}" || warning "${file}"
  done
  exit 0
fi

if [ "${1}" = "clean" ]; then
  print rm -rf build/vcpkg build/ports ports
  rm -rf build/vcpkg build/ports ports
  exit 0
fi

VCPKG_PORTS=$(echo doctest[core] pugixml[core] \
  zlib[core] bzip2[core] liblzma[core] lz4[core] brotli[core] zstd[core] \
  libdeflate[core,compression,decompression,gzip,zlib] miniz[core] draco[core] \
  libjpeg-turbo[core] libpng[core] aom[core] libyuv[core] libavif[core,aom] \
  freetype[core,zlib,bzip2,brotli,png,subpixel-rendering] harfbuzz[core,freetype] \
  plutovg[core] lunasvg[core] glm[core] asmjit[core] simdjson[core,threads] \
  spirv-headers[core] spirv-tools[core,tools] glslang[core,opt,tools] shaderc[core] \
  vulkan-headers[core] vulkan-utility-libraries[core] vulkan-memory-allocator[core] volk[core] \
  convectionkernels[core] meshoptimizer[core,gltfpack] recastnavigation[core] \
  openfbx[core] ktx[core,vulkan] fastgltf[core] \
  sqlite3[core,tool,zlib] openssl[core,tools])

VCPKG_PORTS_LINUX=$(echo libxml2[core,tools] \
  libffi[core] wayland[core,force-build] wayland-protocols[core,force-build] \
  ${VCPKG_PORTS})

VCPKG_PORTS_MINGW=$(echo libxml2[core] \
  ${VCPKG_PORTS})

core() {
  echo "${*}" | sed -E 's/,(tools?|gltfpack)//g'
}

if [ ! -d build/vcpkg ]; then
  print "Cloning vcpkg ..."
  rm -rf build/vcpkg build/ports ports
  git clone -c advice.detachedHead=false build/src/vcpkg build/vcpkg
fi

print "Building linux ports ..."
for port in ${VCPKG_PORTS_LINUX}; do
  export VCPKG_DEFAULT_HOST_TRIPLET="linux-x86-64-v3"
  vcpkg install --vcpkg-root=build/vcpkg --triplet=linux-x86-64-v3 ${port}
  export VCPKG_DEFAULT_HOST_TRIPLET="linux-x86-64-v2"
  vcpkg install --vcpkg-root=build/vcpkg --triplet=linux-x86-64-v2 $(core "${port}")
done

export VCPKG_DEFAULT_HOST_TRIPLET="linux-x86-64-v3"

print "Building mingw ports ..."
for port in ${VCPKG_PORTS_MINGW}; do
  vcpkg install --vcpkg-root=build/vcpkg --triplet=mingw-x86-64-v3 $(core "${port}")
  vcpkg install --vcpkg-root=build/vcpkg --triplet=mingw-x86-64-v2 $(core "${port}")
done

print "Building boost ports ..."
for triplet in linux-x86-64-v3 linux-x86-64-v2 mingw-x86-64-v3 mingw-x86-64-v2; do
  vcpkg install --vcpkg-root=build/vcpkg --triplet=${triplet} \
    boost-container boost-circular-buffer boost-lockfree boost-static-string \
    boost-unordered boost-algorithm boost-intrusive boost-iterator boost-json boost-url
done

print "Exporting ports ..."
rm -rf build/ports ports

vcpkg export --vcpkg-root=build/vcpkg --x-all-installed \
  --raw --output-dir=build/ports --output=.

mkdir ports
mv build/ports/installed/linux-x86-64-v2 ports/
mv build/ports/installed/linux-x86-64-v3 ports/
mv build/ports/installed/mingw-x86-64-v2 ports/
mv build/ports/installed/mingw-x86-64-v3 ports/

#!/bin/sh

# List include directories.
# bin/clang++ main.cpp -v

# List library directories.
# bin/clang++ -print-search-dirs

# Show builtins library path.
# bin/clang++ -print-libgcc-file-name

# Overwrite libc++ include directory.
# bin/clang++ -stdlib++-isystem include/c++/v1 -L lib main.cpp

# Compile for Windows.
# bin/clang++ --target=x86_64-w64-mingw32 --sysroot=sys/mingw -fms-compatibility-version=19.40 main.cpp

set -e
export LC_ALL=C
SCRIPT=$(readlink -f -- "${0}" || realpath -- "${0}")
SRC=$(dirname "${SCRIPT}")
ACE=$(dirname "${SRC}")
SYS=${ACE}/sys
cd "${ACE}"

error() {
  echo "\033[0;31m$*\033[0m" 1>&2
  exit 1
}

print() {
  echo "\033[0;32m$*\033[0m" 1>&2
}

verify() {
  for i in "${@}"; do
    test -e "${i}" || error "File not found: ${i}"
  done
}

create() {
  touch "${1}" || error "Could not create file: ${1}"
}

prepare_chroot() {
  if [ ! -f build/00-chroot.done ] || [ ! -e build/chroot/usr/lib/x86_64-linux-gnu/libc.so ]; then
    print "Creating chroot directory ..."
    rm -f build/00-chroot.done
    mkdir -p build || return 1
    mkdir build/chroot || return 1
    sudo debootstrap --arch amd64 --variant=minbase --exclude=gcc-9-base \
      bullseye build/chroot http://deb.debian.org/debian/ || return 1
    touch build/00-chroot.done || return 1
  fi

  print "Configuring chroot network ..."
  cat /etc/hosts | sudo tee build/chroot/etc/hosts >/dev/null || return 1
  cat /etc/resolv.conf | sudo tee build/chroot/etc/resolv.conf >/dev/null || return 1

  print "Mounting chroot directories ..."
  sudo mkdir -p build/chroot/opt/ace
  sudo mount --bind "${ACE}" build/chroot/opt/ace || return 1
  sudo mount --make-slave build/chroot/opt/ace || return 1
  sudo mount --types proc /proc build/chroot/proc || return 1
  sudo mount --rbind /sys build/chroot/sys || return 1
  sudo mount --make-rslave build/chroot/sys || return 1
  sudo mount --rbind /dev build/chroot/dev || return 1
  sudo mount --make-rslave build/chroot/dev || return 1
  sudo mount --bind /run build/chroot/run || return 1
  sudo mount --make-slave build/chroot/run || return 1
}

execute_chroot() {
  sudo chroot build/chroot /bin/sh /opt/ace/src/build.sh chroot $(id -u) $(id -g) || return 1
}

unmount_chroot() {
  local error=0
  print "Unmounting chroot directories ..."
  sleep 1
  sudo umount build/chroot/dev/shm || error=1
  sudo umount build/chroot/dev/pts || error=1
  sleep 1
  sudo umount -R build/chroot/dev || error=1
  sudo umount -R build/chroot/sys || error=1
  sudo umount -R build/chroot/run || error=1
  sudo umount -R build/chroot/proc || error=1
  sudo umount build/chroot/opt/ace || error=1
  return ${error}
}

if [ "$1" != "chroot" ]; then
  prepare_chroot || ((unmount_chroot || true); error "Could not prepare chroot.")
  execute_chroot || ((unmount_chroot || true); error "Errors inside chroot environment.")
  unmount_chroot || error "Could not unmount chroot directories."
  exit
fi

if [ "$(stat -c %d:%i /)" = "$(stat -c %d:%i /proc/1/root/.)" ]; then
  error "Could not verify, that this is a chroot environment."
fi

uid="${2}"
gid="${3}"

if [ ! "${uid}" -ge 0 ] || [ ! "${gid}" -ge 0 ]; then
  error "Invalid permissions: ${uid}:${gid}"
fi

# =================================================================================================
# 01: chroot
# =================================================================================================

export XZ_OPT="-T16 -9v"

login() {
  /bin/bash --init-file src/bash.sh
}

if [ ! -f build/01-chroot-system.done ] || [ ! -e /usr/bin/ninja ]; then
  rm -f build/01-chroot-system.done

  print "Installing chroot packages ..."
  DEBIAN_FRONTEND=noninteractive \
  apt install -y -o APT::Install-Suggests=0 -o APT::Install-Recommends=0 \
    apt-file automake binutils build-essential bzip2 ca-certificates curl file git less \
    libedit-dev libicu-dev liblzma-dev libncurses-dev libreadline-dev libtinfo-dev libxml2-dev \
    make man-db manpages-dev ninja-build openssh-client p7zip-full patchelf pax-utils perl pev \
    pkg-config python3 python3-distutils python3-lib2to3 strace swig time libtinfo5 \
    symlinks tree tzdata unzip xz-utils yasm wine zip zlib1g-dev libpython3-dev

  print "Configuring chroot system ..."
  git config --global core.eol lf
  git config --global core.autocrlf false
  git config --global core.filemode false
  git config --global pull.rebase false
  apt-file update

  verify /usr/bin/ninja
  create build/01-chroot-system.done
fi

# =================================================================================================
# 02: downloads
# =================================================================================================

download_tar() {
  local name="${1}"
  local url="${2}"
  local src="build/src/${3}"
  local dst="${5}/${name}"
  local file="${dst}/${6}"
  local strip="${4}"
  mkdir -p build/src "${5}"
  if [ ! -f "build/02-${name}-download.done" ] || [ ! -f "${src}" ]; then
    print "Downloading ${name} ..."
    rm -f "build/02-${name}-download.done" "${src}"
    curl -o "${src}" -L "${url}" || error "Download failed."
    verify "${src}"
    create "build/02-${name}-download.done"
  fi
  if [ ! -f "build/02-${name}-extract.done" ] || [ ! -e "${file}" ]; then
    print "Extracting ${name} ..."
    rm -rf "build/02-${name}-extract.done" "${dst}"; mkdir -p "${dst}"
    if [ ${strip} -gt 0 ]; then
      tar xf "${src}" -C "${dst}" --strip-components=${strip} || error "Extraction failed."
    else
      tar xf "${src}" -C "${dst}" || error "Extraction failed."
    fi
    verify "${file}"
    create "build/02-${name}-extract.done"
  fi
}

download_git() {
  local name="${1}"
  local url="${2}"
  local tag="${3}"
  local dst="${4}/${name}"
  local file="${dst}/${5}"
  if [ ! -e "${file}" ]; then
    print "Cloning ${name} ..."
    rm -rf "${dst}"
    git clone -b "${tag}" --depth 1 "${url}" "${dst}" || error "Cloning failed."
    verify "${file}"
  fi
}

# =================================================================================================

LLVM_VER="19.1.5"
LLVM_TAG="llvmorg-${LLVM_VER}"
LLVM_GIT="https://github.com/llvm/llvm-project"
LLVM_URL="${LLVM_GIT}/releases/download/${LLVM_TAG}/LLVM-${LLVM_VER}-Linux-X64.tar.xz"
LLVM_RES="lib/clang/$(echo ${LLVM_VER} | cut -d. -f1)"
LLVM_TAR="llvm.tar.xz"

# Download binaries for the release version.
#download_tar "llvm" "${LLVM_URL}" "${LLVM_TAR}" 1 "build" "bin/clang"

# Download sources for the release version.
#download_git "llvm" "${LLVM_GIT}" "${LLVM_TAG}" "build/src" "llvm/CMakeLists.txt"

# Download sources for the master branch.
download_git "llvm" "${LLVM_GIT}" "main" "build/src" "llvm/CMakeLists.txt"
LLVM_RES="lib/clang/20"

# =================================================================================================

LLDB_MI_TAG="main"
LLDB_MI_GIT="https://github.com/lldb-tools/lldb-mi"

download_git "lldb-mi" "${LLDB_MI_GIT}" "${LLDB_MI_TAG}" "build/src" "CMakeLists.txt"

# =================================================================================================

CMAKE_VER="3.31.3"
CMAKE_TAG="v${CMAKE_VER}"
CMAKE_GIT="https://github.com/Kitware/CMake"
CMAKE_URL="${CMAKE_GIT}/releases/download/${CMAKE_TAG}/cmake-${CMAKE_VER}-linux-x86_64.tar.gz"
CMAKE_TAR="cmake.tar.gz"

download_tar "cmake" "${CMAKE_URL}" "${CMAKE_TAR}" 1 "build" "bin/cmake"

# =================================================================================================

VCPKG_VER="2024.12.16"
VCPKG_TAG="${VCPKG_VER}"
VCPKG_GIT="https://github.com/microsoft/vcpkg"

download_git "vcpkg" "${VCPKG_GIT}" "${VCPKG_TAG}" "build" "bootstrap-vcpkg.sh"

if [ ! -x build/vcpkg/vcpkg ]; then
  env --chdir=build/vcpkg sh bootstrap-vcpkg.sh
fi

# =================================================================================================

RE2C_VER="4.0.2"
RE2C_TAG="${RE2C_VER}"
RE2C_GIT="https://github.com/skvadrik/re2c"

download_git "re2c" "${RE2C_GIT}" "${RE2C_TAG}" "build/src" "CMakeLists.txt"

# =================================================================================================

YASM_VER="1.3.0"
YASM_TAG="v${YASM_VER}"
YASM_GIT="https://github.com/yasm/yasm"
YASM_EXE="http://www.tortall.net/projects/yasm/releases/yasm-${YASM_VER}-win64.exe"

download_git "yasm" "${YASM_GIT}" "${YASM_TAG}" "build/src" "CMakeLists.txt"

# =================================================================================================

NINJA_VER="1.12.1"
NINJA_TAG="v${NINJA_VER}"
NINJA_GIT="https://github.com/ninja-build/ninja"

download_git "ninja" "${NINJA_GIT}" "${NINJA_TAG}" "build/src" "CMakeLists.txt"

# =================================================================================================

MINGW_VER="12.0.0"
MINGW_TAG="v${MINGW_VER}"
MINGW_GIT="https://github.com/mingw-w64/mingw-w64"

download_git "mingw" "${MINGW_GIT}" "${MINGW_TAG}" "build/src" "configure"

# =================================================================================================

READPE_VER="0.84"
READPE_TAG="v${READPE_VER}"
READPE_GIT="https://github.com/mentebinaria/readpe"

download_git "readpe" "${READPE_GIT}" "${READPE_TAG}" "build/src" "Makefile"

# =================================================================================================

POWERSHELL_VER="7.4.6"
POWERSHELL_TAG="v${POWERSHELL_VER}"
POWERSHELL_GIT="https://github.com/PowerShell/PowerShell"
POWERSHELL_URL="${POWERSHELL_GIT}/releases/download/${POWERSHELL_TAG}/powershell-${POWERSHELL_VER}-linux-x64.tar.gz"
POWERSHELL_TAR="powershell.tar.gz"

download_tar "powershell" "${POWERSHELL_URL}" "${POWERSHELL_TAR}" 0 "build" "pwsh"

if [ ! -x build/powershell/pwsh ]; then
  chmod +x build/powershell/pwsh
fi

# =================================================================================================

export PATH="${ACE}/build/powershell:${PATH}"
export PATH="${ACE}/build/cmake/bin:${PATH}"
export PATH="${ACE}/build/vcpkg:${PATH}"
export PATH="${ACE}/bin:${PATH}"

export VCPKG_ROOT="${ACE}/build/vcpkg"
export VCPKG_DEFAULT_TRIPLET="ace-linux"
export VCPKG_DEFAULT_HOST_TRIPLET="ace-linux"
export VCPKG_OVERLAY_TRIPLETS="${ACE}/src/triplets"
export VCPKG_OVERLAY_PORTS="${ACE}/src/ports"
export VCPKG_FEATURE_FLAGS="-binarycaching"
export VCPKG_WORKS_SYSTEM_BINARIES=1
export VCPKG_DISABLE_METRICS=1

# =================================================================================================
# 03: linux
# =================================================================================================

if [ ! -f build/03-linux.done ] || [ ! -f sys/linux/lib64/ld-linux-x86-64.so.2 ]; then
  rm -rf build/03-linux.done build/linux sys/linux

  print "Creating linux sysroot ..."
  mkdir -p build/linux sys/linux; chown _apt build/linux
  env --chdir=build/linux apt download \
    libc6 libc6-dev linux-libc-dev gcc-10-base libgcc-10-dev libgcc-s1 \
    libgomp1 libitm1 libatomic1 libasan6 liblsan0 libtsan0 libquadmath0 \
    libncurses-dev libncurses6 libncursesw6 \
    libtinfo-dev libtinfo6 \
    libedit-dev libedit2 \
    libbsd-dev libbsd0 \
    libmd-dev libmd0

  print "Installing linux sysroot ..."
  find build/linux -name '*.deb' -exec dpkg-deb -x '{}' sys/linux ';'

  print "Deleting linux sysroot static libraries ..."
  find sys/linux -name '*.a' | while read static; do
    if ls $(echo "${static}" | sed -E 's/\.a$/.so*/') 1>/dev/null 2>&1; then
      echo "deleted: ${static}"
      rm -f "${static}"
    fi
  done

  print "Fixing linux sysroot symlinks ..."
  symlinks -r sys/linux/usr/lib/x86_64-linux-gnu | while read symlink; do
    symlink_type=$(echo "${symlink}" | cut -c1-8)
    if [ "${symlink_type}" != "absolute" ]; then
      error "invalid symlink type: ${symlink} (${symlink_type})"
    fi

    symlink_target=$(echo "${symlink}" | sed -E "s;.* -> ;;g")
    if [ ! -e "sys/linux${symlink_target}" ]; then
      error "missing file: sys/linux${symlink_target}"
    fi

    symlink_target_path=$(dirname "${symlink_target}")
    if [ "${symlink_target_path}" != "/lib/x86_64-linux-gnu" ]; then
      error "unknown symlink target path: ${symlink_target_path}"
    fi

    symlink_target_file="../../..${symlink_target}"

    symlink_file=$(echo "${symlink}" | sed -E "s;absolute: ${ACE}/sys/linux/(.*) -> .*;sys/linux/\\1;g")
    echo "relative: ${ACE}/${symlink_file} -> ${symlink_target_file}"
    ln -sf "${symlink_target_file}" "${symlink_file}"
  done

  ln -sf "..$(readlink sys/linux/lib64/ld-linux-x86-64.so.2)" sys/linux/lib64/ld-linux-x86-64.so.2

  symlinks -rd sys/linux

  print "Fixing linux sysroot permissions ..."
  find sys/linux -type d -exec chmod 0755 '{}' ';'
  find sys/linux -type f -exec chmod 0644 '{}' ';'

  verify sys/linux/lib64/ld-linux-x86-64.so.2
  create build/03-linux.done
fi

if [ ! -f build/03-llvm.done ] || [ ! -e build/llvm/bin/clang ]; then
  rm -rf build/03-llvm.done build/llvm build/stage0

  print "Configuring stage 0 ..."
  cmake -GNinja -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}/build/llvm" \
    -DLLVM_ENABLE_PROJECTS="clang;lld" \
    -DLLVM_ENABLE_RUNTIMES="compiler-rt;libunwind;libcxxabi;libcxx" \
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
    -DLLVM_TARGETS_TO_BUILD="X86" \
    -DCLANG_DEFAULT_CXX_STDLIB="libc++" \
    -DCLANG_DEFAULT_RTLIB="compiler-rt" \
    -DCLANG_DEFAULT_UNWINDLIB="none" \
    -DCLANG_DEFAULT_LINKER="lld" \
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
    -DLIBUNWIND_ENABLE_SHARED=OFF \
    -DLIBUNWIND_ENABLE_STATIC=ON \
    -DLIBUNWIND_INSTALL_HEADERS=ON \
    -DLIBUNWIND_INSTALL_LIBRARY=OFF \
    -DLIBUNWIND_USE_COMPILER_RT=ON \
    -DLIBCXXABI_ENABLE_SHARED=OFF \
    -DLIBCXXABI_ENABLE_STATIC=ON \
    -DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
    -DLIBCXXABI_INSTALL_HEADERS=ON \
    -DLIBCXXABI_INSTALL_LIBRARY=OFF \
    -DLIBCXXABI_STATICALLY_LINK_UNWINDER_IN_SHARED_LIBRARY=ON \
    -DLIBCXXABI_STATICALLY_LINK_UNWINDER_IN_STATIC_LIBRARY=ON \
    -DLIBCXXABI_USE_COMPILER_RT=ON \
    -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
    -DLIBCXX_ENABLE_SHARED=ON \
    -DLIBCXX_ENABLE_STATIC=ON \
    -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
    -DLIBCXX_HAS_ATOMIC_LIB=OFF \
    -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
    -DLIBCXX_INSTALL_HEADERS=ON \
    -DLIBCXX_INSTALL_LIBRARY=ON \
    -DLIBCXX_INSTALL_MODULES=ON \
    -DLIBCXX_USE_COMPILER_RT=ON \
    -B build/stage0 build/src/llvm/llvm

  print "Building stage 0 ..."
  ninja -C build/stage0 install

  verify build/llvm/bin/clang
  create build/03-llvm.done
fi

# =================================================================================================
# 04: stage 1
# =================================================================================================

if [ ! -f build/04-stage1-configure.done ] || [ ! -e build/stage1/build.ninja ]; then
  rm -rf build/04-stage1-configure.done build/stage1

  print "Configuring stage 1 ..."
  cmake -GNinja -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}" \
    -DCMAKE_SYSTEM_NAME="Linux" \
    -DCMAKE_SYSTEM_VERSION="5.10.0" \
    -DCMAKE_SYSTEM_PROCESSOR="AMD64" \
    -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
    -DCMAKE_BUILD_RPATH="${ACE}/build/stage1/lib:${ACE}/build/llvm/lib/x86_64-unknown-linux-gnu" \
    -DCMAKE_C_COMPILER="${ACE}/build/llvm/bin/clang" \
    -DCMAKE_CXX_COMPILER="${ACE}/build/llvm/bin/clang++" \
    -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="${ACE}/build/llvm/bin/clang-scan-deps" \
    -DCMAKE_ASM_COMPILER="${ACE}/build/llvm/bin/clang" \
    -DCMAKE_C_FLAGS_INIT="-march=x86-64" \
    -DCMAKE_CXX_FLAGS_INIT="-march=x86-64" \
    -DCMAKE_C_COMPILER_TARGET="x86_64-unknown-linux-gnu" \
    -DCMAKE_CXX_COMPILER_TARGET="x86_64-unknown-linux-gnu" \
    -DCMAKE_ASM_COMPILER_TARGET="x86_64-unknown-linux-gnu" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-pc-linux-gnu" \
    -DLLVM_ENABLE_PROJECTS="clang;lld" \
    -DLLVM_ENABLE_RUNTIMES="compiler-rt;libunwind;libcxxabi;libcxx" \
    -DLLVM_ENABLE_BINDINGS=OFF \
    -DLLVM_ENABLE_DOXYGEN=OFF \
    -DLLVM_ENABLE_LIBCXX=ON \
    -DLLVM_ENABLE_LTO="Thin" \
    -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DLLVM_TARGETS_TO_BUILD="X86" \
    -DLLVM_USE_LINKER="lld" \
    -DCLANG_DEFAULT_CXX_STDLIB="libc++" \
    -DCLANG_DEFAULT_RTLIB="compiler-rt" \
    -DCLANG_DEFAULT_UNWINDLIB="none" \
    -DCLANG_DEFAULT_LINKER="lld" \
    -DCOMPILER_RT_BUILD_BUILTINS=ON \
    -DCOMPILER_RT_BUILD_GWP_ASAN=OFF \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
    -DCOMPILER_RT_BUILD_MEMPROF=OFF \
    -DCOMPILER_RT_BUILD_ORC=OFF \
    -DCOMPILER_RT_BUILD_PROFILE=OFF \
    -DCOMPILER_RT_BUILD_CTX_PROFILE=OFF \
    -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
    -DCOMPILER_RT_BUILD_XRAY=OFF \
    -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
    -DLIBUNWIND_ENABLE_SHARED=OFF \
    -DLIBUNWIND_ENABLE_STATIC=ON \
    -DLIBUNWIND_INSTALL_HEADERS=ON \
    -DLIBUNWIND_INSTALL_LIBRARY=OFF \
    -DLIBUNWIND_USE_COMPILER_RT=ON \
    -DLIBCXXABI_ENABLE_SHARED=OFF \
    -DLIBCXXABI_ENABLE_STATIC=ON \
    -DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
    -DLIBCXXABI_INSTALL_HEADERS=ON \
    -DLIBCXXABI_INSTALL_LIBRARY=OFF \
    -DLIBCXXABI_STATICALLY_LINK_UNWINDER_IN_SHARED_LIBRARY=ON \
    -DLIBCXXABI_STATICALLY_LINK_UNWINDER_IN_STATIC_LIBRARY=ON \
    -DLIBCXXABI_USE_COMPILER_RT=ON \
    -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
    -DLIBCXX_ABI_UNSTABLE=ON \
    -DLIBCXX_ABI_VERSION=2 \
    -DLIBCXX_ADDITIONAL_COMPILE_FLAGS="-march=x86-64;-fno-rtti;-flto=thin" \
    -DLIBCXX_ENABLE_EXPERIMENTAL_LIBRARY=ON \
    -DLIBCXX_ENABLE_INCOMPLETE_FEATURES=ON \
    -DLIBCXX_ENABLE_SHARED=ON \
    -DLIBCXX_ENABLE_STATIC=ON \
    -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
    -DLIBCXX_HAS_ATOMIC_LIB=OFF \
    -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
    -DLIBCXX_INSTALL_HEADERS=ON \
    -DLIBCXX_INSTALL_LIBRARY=ON \
    -DLIBCXX_INSTALL_MODULES=ON \
    -DLIBCXX_USE_COMPILER_RT=ON \
    -DDEFAULT_SYSROOT="${ACE}/sys/linux" \
    -B build/stage1 build/src/llvm/llvm

  verify build/stage1/build.ninja
  create build/04-stage1-configure.done
fi

if [ ! -f build/04-stage1-build.done ] || [ ! -e build/stage1/bin/clang ]; then
  rm -rf build/04-stage1-build.done

  print "Building stage 1 ..."
  ninja -C build/stage1 \
    llvm-config \
    LTO \
    lld \
    llvm-ar \
    llvm-nm \
    llvm-objcopy \
    llvm-objdump \
    llvm-ranlib \
    llvm-strip \
    llvm-size \
    core-resource-headers \
    clang-resource-headers \
    clang-scan-deps \
    clang \
    builtins \
    runtimes

  verify build/stage1/bin/clang
  create build/04-stage1-build.done
fi

if [ ! -f build/04-stage1-install.done ] ||
   [ ! -e ${LLVM_RES}/lib/linux/libclang_rt.builtins-x86_64.a ] ||
   [ ! -e include/c++/v1/__config ] ||
   [ ! -e lib/libc++.modules.json ] ||
   [ ! -e lib/libc++.so.2 ] ||
   [ ! -e sys/linux/lib/libc++.so.2 ]
then
  rm -rf build/04-stage1-install.done

  print "Installing stage 1 ..."
  CC="clang" \
  CXX="clang++" \
  PATH="${ACE}/build/llvm/bin:${PATH}" \
  LD_LIBRARY_PATH="${ACE}/build/llvm/lib/x86_64-unknown-linux-gnu" \
  ninja -C build/stage1 \
    install-builtins-stripped \
    install-runtimes-stripped

  rm -f sys/linux/lib/libc++.a
  ln -sf ../../../lib/libc++.a sys/linux/lib/libc++.a

  rm -f sys/linux/lib/libc++experimental.a
  ln -sf ../../../lib/libc++experimental.a sys/linux/lib/libc++experimental.a

  rm -f sys/linux/lib/libc++.modules.json
  ln -sf ../../../lib/libc++.modules.json sys/linux/lib/libc++.modules.json

  rm -f sys/linux/lib/libc++.so
  ln -sf ../../../lib/libc++.so sys/linux/lib/libc++.so

  rm -f sys/linux/lib/libc++.so.2
  ln -sf ../../../lib/libc++.so.2 sys/linux/lib/libc++.so.2

  rm -f sys/linux/lib/libc++.so.2.0
  ln -sf ../../../lib/libc++.so.2.0 sys/linux/lib/libc++.so.2.0

  mkdir -p sys/linux/share
  rm -f sys/linux/share/libc++
  ln -sf ../../../share/libc++ sys/linux/share/libc++

  verify sys/linux/lib/libc++.so.2
  verify lib/libc++.so.2
  verify lib/libc++.modules.json
  verify include/c++/v1/__config
  verify ${LLVM_RES}/lib/linux/libclang_rt.builtins-x86_64.a
  create build/04-stage1-install.done
fi

# =================================================================================================
# 05: dependencies
# =================================================================================================

if [ ! -f build/05-dependencies.done ] ||
   [ ! -e build/vcpkg/installed/ace-linux/lib/liblzma.a ] ||
   [ ! -e build/vcpkg/installed/ace-linux/lib/libxml2.a ] ||
   [ ! -e build/vcpkg/installed/ace-linux/lib/libcrypto.a ] ||
   [ ! -e build/vcpkg/installed/ace-linux/lib/libssl.a ] ||
   [ ! -e build/vcpkg/installed/ace-linux/lib/libz.a ]
then
  rm -rf build/05-dependencies.done

  print "Building dependencies ..."
  PATH="${ACE}/build/stage1/bin:${PATH}" \
  vcpkg install --triplet=ace-mingw \
    liblzma[core] libxml2[core,lzma,zlib] openssl[core] zlib

  verify build/vcpkg/installed/ace-linux/lib/libz.a
  verify build/vcpkg/installed/ace-linux/lib/libssl.a
  verify build/vcpkg/installed/ace-linux/lib/libcrypto.a
  verify build/vcpkg/installed/ace-linux/lib/libxml2.a
  verify build/vcpkg/installed/ace-linux/lib/liblzma.a
  create build/05-dependencies.done
fi

# =================================================================================================
# 06: stage 2
# =================================================================================================

if [ ! -f build/06-stage2-configure.done ] || [ ! -e build/stage2/build.ninja ]; then
  rm -rf build/06-stage2-configure.done build/stage2

  print "Configuring stage 2 ..."
  cmake -GNinja -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}" \
    -DCMAKE_INSTALL_RPATH="\$ORIGIN/../lib" \
    -DCMAKE_PREFIX_PATH="${ACE}/build/vcpkg/installed/ace-linux" \
    -DCMAKE_CROSSCOMPILING=ON \
    -DCMAKE_SYSTEM_NAME="Linux" \
    -DCMAKE_SYSTEM_VERSION="5.10.0" \
    -DCMAKE_SYSTEM_PROCESSOR="AMD64" \
    -DCMAKE_SYSROOT="${ACE}/sys/linux" \
    -DCMAKE_FIND_ROOT_PATH="${ACE}" \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM="BOTH" \
    -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
    -DCMAKE_BUILD_RPATH="${ACE}/lib:${ACE}/build/stage2/lib" \
    -DCMAKE_C_COMPILER="${ACE}/build/stage1/bin/clang" \
    -DCMAKE_CXX_COMPILER="${ACE}/build/stage1/bin/clang++" \
    -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="${ACE}/build/stage1/bin/clang-scan-deps" \
    -DCMAKE_ASM_COMPILER="${ACE}/build/stage1/bin/clang" \
    -DCMAKE_C_FLAGS_INIT="-march=x86-64" \
    -DCMAKE_CXX_FLAGS_INIT="-march=x86-64" \
    -DCMAKE_C_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DCMAKE_CXX_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DCMAKE_ASM_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-pc-linux-gnu" \
    -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld;lldb" \
    -DLLVM_ENABLE_BINDINGS=OFF \
    -DLLVM_ENABLE_DOXYGEN=OFF \
    -DLLVM_ENABLE_LIBCXX=ON \
    -DLLVM_ENABLE_LTO="Thin" \
    -DLLVM_ENABLE_MODULES=OFF \
    -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DLLVM_TARGETS_TO_BUILD="X86" \
    -DLLVM_USE_LINKER="lld" \
    -DCLANG_DEFAULT_CXX_STDLIB="libc++" \
    -DCLANG_DEFAULT_RTLIB="compiler-rt" \
    -DCLANG_DEFAULT_UNWINDLIB="none" \
    -DCLANG_DEFAULT_LINKER="lld" \
    -DLLDB_ENABLE_PYTHON=OFF \
    -DLLDB_ENABLE_LUA=OFF \
    -DDEFAULT_SYSROOT="../sys/linux" \
    -B build/stage2 build/src/llvm/llvm

  verify build/stage2/build.ninja
  create build/06-stage2-configure.done
fi

if [ ! -f build/06-stage2-build.done ] || [ ! -e build/stage2/bin/clang ]; then
  rm -rf build/06-stage2-build.done

  print "Building stage 2 ..."
  ninja -C build/stage2 \
    llvm-config \
    LTO \
    lld \
    lldb \
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

  verify build/stage2/bin/clang
  create build/06-stage2-build.done
fi

if [ ! -f build/06-stage2-install.done ] || [ ! -e bin/clang ]; then
  rm -rf build/06-stage2-install.done

  print "Installing stage 2 ..."
  ninja -C build/stage2 \
    install-LTO-stripped \
    install-lld-stripped \
    install-lldb-stripped \
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
    install-llvm-dlltool-stripped \
    install-llvm-windres-stripped \
    install-dsymutil-stripped \
    install-core-resource-headers \
    install-clang-resource-headers \
    install-clang-cmake-exports \
    install-clang-scan-deps-stripped \
    install-clang-stripped \
    install-clang-format-stripped \
    install-clang-tidy-stripped \
    install-clangd-stripped \
    install-libclang-headers \
    install-libclang-stripped \
    install-cmake-exports

  patchelf --set-rpath '$ORIGIN' "lib/liblldb.so"
  echo "lib/liblldb.so"; readelf -d "lib/liblldb.so" | grep RUNPATH

  patchelf --set-rpath '$ORIGIN' "lib/libLTO.so"
  echo "lib/libLTO.so"; readelf -d "lib/libLTO.so" | grep RUNPATH

  patchelf --set-rpath '$ORIGIN' "lib/libclang.so"
  echo "lib/libclang.so"; readelf -d "lib/libclang.so" | grep RUNPATH

  verify bin/clang
  create build/06-stage2-install.done
fi

tee bin/windres >/dev/null <<'EOF'
#!/bin/sh
set -e
export LC_ALL=C
SCRIPT=$(readlink -f -- "${0}" || realpath -- "${0}")
BIN=$(dirname "${SCRIPT}")
ACE=$(dirname "${BIN}")
"${BIN}/llvm-windres" "-I" "${ACE}/sys/mingw/include" $*
EOF
chmod +x bin/windres

if [ ! -f build/06-stage2-lldb-mi.done ] || [ ! -e bin/lldb-mi ]; then
  rm -rf build/06-stage2-lldb-mi.done build/stage2-lldb-mi

  print "Configuring stage2 lldb-mi ..."
  if [ ! -d build/stage2/lldb-mi ]; then
    git clone build/src/lldb-mi build/stage2/lldb-mi
  fi
  cmake -GNinja -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}" \
    -DCMAKE_INSTALL_RPATH="\$ORIGIN/../lib" \
    -DCMAKE_PREFIX_PATH="${ACE}/build/vcpkg/installed/ace-linux;${ACE}/build/stage2" \
    -DCMAKE_CROSSCOMPILING=ON \
    -DCMAKE_SYSTEM_NAME="Linux" \
    -DCMAKE_SYSTEM_VERSION="5.10.0" \
    -DCMAKE_SYSTEM_PROCESSOR="AMD64" \
    -DCMAKE_SYSROOT="${ACE}/sys/linux" \
    -DCMAKE_FIND_ROOT_PATH="${ACE}" \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM="BOTH" \
    -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
    -DCMAKE_BUILD_RPATH="${ACE}/lib" \
    -DCMAKE_C_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_CXX_COMPILER="${ACE}/bin/clang++" \
    -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="${ACE}/bin/clang-scan-deps" \
    -DCMAKE_C_FLAGS_INIT="-march=x86-64" \
    -DCMAKE_CXX_FLAGS_INIT="-march=x86-64 -fno-rtti" \
    -DCMAKE_C_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DCMAKE_CXX_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DLLVM_ENABLE_LIBCXX=ON \
    -DLLVM_ENABLE_LTO="Thin" \
    -DLLVM_ENABLE_MODULES=OFF \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_TARGETS_TO_BUILD="X86" \
    -DLLVM_USE_LINKER="lld" \
    -B build/stage2-lldb-mi build/stage2/lldb-mi

  print "Installing stage2 lldb-mi ..."
  ninja -C build/stage2-lldb-mi install/strip

  verify bin/lldb-mi
  create build/06-stage2-lldb-mi.done
fi

# =================================================================================================
# 07: re2c
# =================================================================================================

if [ ! -f build/07-re2c.done ] || [ ! -e build/re2c/re2c ]; then
  rm -rf build/07-re2c.done build/re2c

  print "Configuring re2c ..."
  cmake -GNinja -Wno-dev \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}" \
    -DCMAKE_TOOLCHAIN_FILE="${ACE}/linux.cmake" \
    -DCMAKE_INSTALL_RPATH="\$ORIGIN/../lib" \
    -DRE2C_BUILD_RE2GO=OFF \
    -DRE2C_BUILD_RE2RUST=OFF \
    -B build/re2c build/src/re2c

  print "Building re2c ..."
  ninja -C build/re2c

  verify build/re2c/re2c
  create build/07-re2c.done
fi

if [ ! -f build/07-re2c-install.done ] || [ ! -e bin/re2c ]; then
  rm -rf build/07-re2c-install.done bin/re2c

  print "Installing re2c ..."
  ninja -C build/re2c install/strip

  verify bin/re2c
  create build/07-re2c-install.done
fi

# =================================================================================================
# 08: yasm
# =================================================================================================

if [ ! -f build/08-yasm.done ] || [ ! -e build/yasm/yasm ]; then
  rm -rf build/08-yasm.done build/yasm

  print "Configuring yasm ..."
  cmake -GNinja -Wno-dev \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}/build/yasm-install" \
    -DCMAKE_TOOLCHAIN_FILE="${ACE}/linux.cmake" \
    -DCMAKE_INSTALL_RPATH="\$ORIGIN/../lib" \
    -DYASM_BUILD_TESTS=OFF \
    -B build/yasm build/src/yasm

  print "Building yasm ..."
  ninja -C build/yasm

  verify build/yasm/yasm
  create build/08-yasm.done
fi

if [ ! -f build/08-yasm-install.done ] ||
   [ ! -e lib/libyasmstd.so ] ||
   [ ! -e lib/libyasm.so ] ||
   [ ! -e bin/yasm ]
then
  rm -rf build/08-yasm-install.done bin/yasm lib/libyasm.so

  print "Installing yasm ..."
  ninja -C build/yasm install/strip

  cp -a build/yasm-install/bin/yasm bin/
  cp -a build/yasm-install/lib/libyasm.so lib/
  cp -a build/yasm-install/lib/libyasmstd.so lib/

  verify bin/yasm
  verify lib/libyasm.so
  verify lib/libyasmstd.so
  create build/08-yasm-install.done
fi

# =================================================================================================
# 09: ninja
# =================================================================================================

if [ ! -f build/09-ninja.done ] || [ ! -e build/ninja/ninja ]; then
  rm -rf build/09-ninja.done build/ninja

  print "Configuring ninja ..."
  cmake -GNinja -Wno-dev \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}" \
    -DCMAKE_TOOLCHAIN_FILE="${ACE}/linux.cmake" \
    -DCMAKE_INSTALL_RPATH="\$ORIGIN/../lib" \
    -DBUILD_TESTING=OFF \
    -B build/ninja build/src/ninja

  print "Building ninja ..."
  ninja -C build/ninja

  verify build/ninja/ninja
  create build/09-ninja.done
fi

if [ ! -f build/09-ninja-install.done ] || [ ! -e bin/ninja ]; then
  rm -rf build/09-ninja-install.done bin/ninja

  print "Installing ninja ..."
  ninja -C build/ninja install/strip

  verify bin/ninja
  create build/09-ninja-install.done
fi

# =================================================================================================
# 10: mingw
# =================================================================================================

MINGW_LFLAGS="--target=x86_64-w64-mingw32 --sysroot=${ACE}/sys/mingw"
MINGW_CFLAGS="-O3 -march=x86-64 ${MINGW_LFLAGS} -fms-compatibility-version=19.40"
MINGW_RFLAGS="-I${ACE}/sys/mingw/include"

if [ ! -f build/10-mingw.done ] || [ ! -e bin/genidl ]; then
  rm -rf build/10-mingw.done \
    build/mingw-headers \
    build/mingw-crt \
    build/mingw-tools \
    bin/gendef \
    bin/genidl \
    sys/mingw

  print "Configuring mingw headers ..."
  mkdir -p build/mingw-headers
  env --chdir=build/mingw-headers ../src/mingw/mingw-w64-headers/configure \
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
    > build/mingw-headers.log 2>&1

  print "Installing mingw headers ..."
  env --chdir=build/mingw-headers make -j17 install-strip \
    > build/mingw-headers-install.log 2>&1

  print "Configuring mingw crt ..."
  mkdir -p build/mingw-crt
  env --chdir=build/mingw-crt ../src/mingw/mingw-w64-crt/configure \
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
    > build/mingw-crt.log 2>&1

  print "Installing mingw crt ..."
  env --chdir=build/mingw-crt make -j17 install-strip \
    > build/mingw-crt-install.log 2>&1

  print "Configuring mingw tools ..."
  mkdir -p build/mingw-tools
  env --chdir=build/mingw-tools ../src/mingw/configure \
    CC="${ACE}/bin/clang" \
    AR="${ACE}/bin/llvm-ar" \
    NM="${ACE}/bin/llvm-nm" \
    RANLIB="${ACE}/bin/llvm-ranlib" \
    OBJCOPY="${ACE}/bin/llvm-objcopy" \
    OBJDUMP="${ACE}/bin/llvm-objdump" \
    STRIP="${ACE}/bin/llvm-strip" \
    SIZE="${ACE}/bin/llvm-size" \
    CFLAGS="-O3 -march=x86-64 -flto=thin" \
    --with-default-win32-winnt="0x0A00" \
    --with-default-msvcrt="ucrt" \
    --prefix="${ACE}" \
    --with-tools="all" \
    --without-libraries \
    --without-headers \
    --without-crt \
    > build/mingw-tools.log 2>&1

  print "Installing mingw tools ..."
  env --chdir=build/mingw-tools make -j17 install-strip \
    > build/mingw-tools-install.log 2>&1

  verify bin/genidl
  create build/10-mingw.done
fi

if [ ! -f build/10-mingw-builtins.done ] || [ ! -e ${LLVM_RES}/lib/windows/libclang_rt.builtins-x86_64.a ]; then
  rm -rf build/10-mingw-builtins.done build/mingw-builtins ${LLVM_RES}/lib/windows

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
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM="BOTH" \
    -DCMAKE_C_COMPILER_WORKS=ON \
    -DCMAKE_CXX_COMPILER_WORKS=ON \
    -DCMAKE_ASM_COMPILER_WORKS=ON \
    -DCMAKE_C_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_CXX_COMPILER="${ACE}/bin/clang++" \
    -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="${ACE}/bin/clang-scan-deps" \
    -DCMAKE_ASM_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_C_FLAGS_INIT="-march=x86-64 -fms-compatibility-version=19.40" \
    -DCMAKE_CXX_FLAGS_INIT="-march=x86-64 -fms-compatibility-version=19.40 -nostdlib++" \
    -DCMAKE_C_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DCMAKE_CXX_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DCMAKE_ASM_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-w64-mingw32" \
    -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF \
    -DLLVM_ENABLE_RUNTIMES="compiler-rt" \
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
    -B build/mingw-builtins build/src/llvm/runtimes

  print "Installing mingw builtins ..."
  ninja -C build/mingw-builtins install/strip

  verify ${LLVM_RES}/lib/windows/libclang_rt.builtins-x86_64.a
  create build/10-mingw-builtins.done
fi

if [ ! -f build/10-mingw-pthread.done ] || [ ! -e sys/mingw/lib/libwinpthread.a ]; then
  rm -rf build/10-mingw-pthread.done build/mingw-pthread

  print "Configuring mingw pthread ..."
  mkdir -p build/mingw-pthread
  env --chdir=build/mingw-pthread ../src/mingw/mingw-w64-libraries/winpthreads/configure \
    CC="${ACE}/bin/clang ${MINGW_LFLAGS}" \
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
    --prefix="${ACE}/sys/mingw" \
    --host="x86_64-w64-mingw32" \
    > build/mingw-pthread.log 2>&1

  print "Installing mingw pthread ..."
  env --chdir=build/mingw-pthread make -j17 install-strip \
    > build/mingw-pthread-install.log 2>&1

  verify sys/mingw/lib/libwinpthread.a
  create build/10-mingw-pthread.done
fi

if [ ! -f build/10-mingw-runtimes.done ] ||
   [ ! -e sys/mingw/include/c++/v1/__config ] ||
   [ ! -e sys/mingw/lib/libc++.modules.json ] ||
   [ ! -e sys/mingw/bin/libc++.dll ]
then
  rm -rf build/10-mingw-runtimes.done build/mingw-runtimes

  print "Configuring mingw runtimes ..."
  cmake -GNinja -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}/sys/mingw" \
    -DCMAKE_CROSSCOMPILING=ON \
    -DCMAKE_SYSTEM_NAME="Windows" \
    -DCMAKE_SYSTEM_VERSION="10.0" \
    -DCMAKE_SYSTEM_PROCESSOR="AMD64" \
    -DCMAKE_SYSROOT="${ACE}/sys/mingw" \
    -DCMAKE_FIND_ROOT_PATH="${ACE}" \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM="BOTH" \
    -DCMAKE_CXX_COMPILER_WORKS=ON \
    -DCMAKE_C_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_CXX_COMPILER="${ACE}/bin/clang++" \
    -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="${ACE}/bin/clang-scan-deps" \
    -DCMAKE_ASM_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_C_FLAGS_INIT="-march=x86-64 -fms-compatibility-version=19.40" \
    -DCMAKE_CXX_FLAGS_INIT="-march=x86-64 -fms-compatibility-version=19.40" \
    -DCMAKE_C_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DCMAKE_CXX_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DCMAKE_ASM_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-w64-mingw32" \
    -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF \
    -DLLVM_ENABLE_RUNTIMES="libunwind;libcxxabi;libcxx" \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DLLVM_USE_LINKER="lld" \
    -DLIBUNWIND_ENABLE_SHARED=OFF \
    -DLIBUNWIND_ENABLE_STATIC=ON \
    -DLIBUNWIND_INSTALL_HEADERS=ON \
    -DLIBUNWIND_INSTALL_LIBRARY=OFF \
    -DLIBUNWIND_USE_COMPILER_RT=ON \
    -DLIBCXXABI_ENABLE_SHARED=OFF \
    -DLIBCXXABI_ENABLE_STATIC=ON \
    -DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
    -DLIBCXXABI_INSTALL_HEADERS=OFF \
    -DLIBCXXABI_INSTALL_LIBRARY=OFF \
    -DLIBCXXABI_STATICALLY_LINK_UNWINDER_IN_SHARED_LIBRARY=ON \
    -DLIBCXXABI_STATICALLY_LINK_UNWINDER_IN_STATIC_LIBRARY=ON \
    -DLIBCXXABI_USE_COMPILER_RT=ON \
    -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
    -DLIBCXX_ABI_UNSTABLE=ON \
    -DLIBCXX_ABI_VERSION=2 \
    -DLIBCXX_ADDITIONAL_COMPILE_FLAGS="-march=x86-64;-fno-rtti;-flto=thin" \
    -DLIBCXX_ENABLE_EXPERIMENTAL_LIBRARY=ON \
    -DLIBCXX_ENABLE_INCOMPLETE_FEATURES=ON \
    -DLIBCXX_ENABLE_SHARED=ON \
    -DLIBCXX_ENABLE_STATIC=ON \
    -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
    -DLIBCXX_HAS_ATOMIC_LIB=OFF \
    -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
    -DLIBCXX_INSTALL_HEADERS=ON \
    -DLIBCXX_INSTALL_LIBRARY=ON \
    -DLIBCXX_INSTALL_MODULES=ON \
    -DLIBCXX_USE_COMPILER_RT=ON \
    -B build/mingw-runtimes build/src/llvm/runtimes

  print "Installing mingw runtimes ..."
  ninja -C build/mingw-runtimes install/strip

  verify sys/mingw/include/c++/v1/__config
  verify sys/mingw/lib/libc++.modules.json
  verify sys/mingw/bin/libc++.dll
  create build/10-mingw-runtimes.done
fi

# =================================================================================================
# 11: mingw dependencies
# =================================================================================================

if [ ! -f build/11-mingw-dependencies.done ] ||
   [ ! -e build/vcpkg/installed/ace-mingw/lib/liblzma.a ] ||
   [ ! -e build/vcpkg/installed/ace-mingw/lib/libxml2.a ] ||
   [ ! -e build/vcpkg/installed/ace-mingw/lib/libzlib.a ]
then
  rm -rf build/11-mingw-dependencies.done build/mingw-ports

  print "Building mingw dependencies ..."
  vcpkg install --triplet=ace-mingw \
    liblzma[core] libxml2[core,lzma,zlib] zlib

  verify build/vcpkg/installed/ace-mingw/lib/liblzma.a
  verify build/vcpkg/installed/ace-mingw/lib/libxml2.a
  verify build/vcpkg/installed/ace-mingw/lib/libzlib.a
  create build/11-mingw-dependencies.done
fi

# =================================================================================================
# 12: stage 3
# =================================================================================================

if [ ! -f build/12-stage3-prepare.done ] ||
   [ ! -f build/windows/bin/libc++.dll ] ||
   [ ! -f build/windows/${LLVM_RES}/lib/windows/libclang_rt.builtins-x86_64.a ]
then
  rm -rf build/12-stage3-prepare.done build/windows

  print "Preparing stage 3 ..."
  mkdir -p build/windows/bin
  mkdir -p build/windows/${LLVM_RES}/lib
  mkdir -p build/windows/sys

  cp -a sys/mingw build/windows/sys/
  cp -a ${LLVM_RES}/lib/windows build/windows/${LLVM_RES}/lib/
  cp -a ${LLVM_RES}/include build/windows/${LLVM_RES}/
  mv build/windows/sys/mingw/bin/libc++.dll build/windows/bin/libc++.dll

  verify build/windows/${LLVM_RES}/lib/windows/libclang_rt.builtins-x86_64.a
  verify build/windows/bin/libc++.dll
  create build/12-stage3-prepare.done
fi

if [ ! -f build/12-stage3-configure.done ] || [ ! -e build/stage3/build.ninja ]; then
  rm -rf build/12-stage3-configure.done build/stage3

  print "Configuring stage 3 ..."
  cmake -GNinja -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}/build/windows" \
    -DCMAKE_PREFIX_PATH="${ACE}/build/ports/installed/ace-mingw" \
    -DCMAKE_CROSSCOMPILING=ON \
    -DCMAKE_SYSTEM_NAME="Windows" \
    -DCMAKE_SYSTEM_VERSION="10.0" \
    -DCMAKE_SYSTEM_PROCESSOR="AMD64" \
    -DCMAKE_SYSROOT="${ACE}/sys/mingw" \
    -DCMAKE_FIND_ROOT_PATH="${ACE}" \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM="BOTH" \
    -DCMAKE_C_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_CXX_COMPILER="${ACE}/bin/clang++" \
    -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="${ACE}/bin/clang-scan-deps" \
    -DCMAKE_ASM_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_C_FLAGS_INIT="-march=x86-64 -fms-compatibility-version=19.40" \
    -DCMAKE_CXX_FLAGS_INIT="-march=x86-64 -fms-compatibility-version=19.40" \
    -DCMAKE_C_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DCMAKE_CXX_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DCMAKE_ASM_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-w64-mingw32" \
    -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld;lldb" \
    -DLLVM_ENABLE_BINDINGS=OFF \
    -DLLVM_ENABLE_DOXYGEN=OFF \
    -DLLVM_ENABLE_LIBCXX=ON \
    -DLLVM_ENABLE_LTO="Thin" \
    -DLLVM_ENABLE_MODULES=OFF \
    -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DLLVM_TARGETS_TO_BUILD="X86" \
    -DLLVM_USE_LINKER="lld" \
    -DLLVM_USE_SYMLINKS=OFF \
    -DCLANG_DEFAULT_CXX_STDLIB="libc++" \
    -DCLANG_DEFAULT_RTLIB="compiler-rt" \
    -DCLANG_DEFAULT_UNWINDLIB="none" \
    -DCLANG_DEFAULT_LINKER="lld" \
    -DLLDB_ENABLE_PYTHON=OFF \
    -DLLDB_ENABLE_LUA=OFF \
    -DDEFAULT_SYSROOT="../sys/mingw" \
    -B build/stage3 build/src/llvm/llvm

  verify build/stage3/build.ninja
  create build/12-stage3-configure.done
fi

if [ ! -f build/12-stage3-install.done ] || [ ! -e build/windows/bin/clang.exe ]; then
  rm -rf build/12-stage3-install.done

  print "Installing stage 3 ..."
  ninja -C build/stage3 \
    install-LTO-stripped \
    install-lld-stripped \
    install-lldb-stripped \
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
    install-llvm-dlltool-stripped \
    install-llvm-windres-stripped \
    install-dsymutil-stripped \
    install-core-resource-headers \
    install-clang-resource-headers \
    install-clang-cmake-exports \
    install-clang-scan-deps-stripped \
    install-clang-stripped \
    install-clang-format-stripped \
    install-clang-tidy-stripped \
    install-clangd-stripped \
    install-libclang-headers \
    install-libclang-stripped \
    install-cmake-exports

  rm -f sys/mingw/bin/libclang.dll
  cp build/windows/bin/libclang.dll sys/mingw/bin/libclang.dll

  rm -f sys/mingw/lib/libclang.dll.a
  cp build/windows/lib/libclang.dll.a sys/mingw/lib/libclang.dll.a

  rm -rf sys/mingw/include/clang-c
  cp -R build/windows/include/clang-c sys/mingw/include/clang-c

  verify build/windows/bin/clang.exe
  create build/12-stage3-install.done
fi

if [ ! -f build/12-stage3-lldb-mi.done ] || [ ! -e build/windows/bin/lldb-mi.exe ]; then
  rm -rf build/12-stage3-lldb-mi.done build/stage3-lldb-mi

  print "Configuring stage3 lldb-mi ..."
  if [ ! -d build/stage3/lldb-mi ]; then
    git clone build/src/lldb-mi build/stage3/lldb-mi
  fi
  cmake -GNinja -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}/build/windows" \
    -DCMAKE_PREFIX_PATH="${ACE}/build/ports/installed/ace-mingw;${ACE}/build/stage3" \
    -DCMAKE_CROSSCOMPILING=ON \
    -DCMAKE_SYSTEM_NAME="Windows" \
    -DCMAKE_SYSTEM_VERSION="10.0" \
    -DCMAKE_SYSTEM_PROCESSOR="AMD64" \
    -DCMAKE_SYSROOT="${ACE}/sys/mingw" \
    -DCMAKE_FIND_ROOT_PATH="${ACE}" \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM="BOTH" \
    -DCMAKE_C_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_CXX_COMPILER="${ACE}/bin/clang++" \
    -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="${ACE}/bin/clang-scan-deps" \
    -DCMAKE_ASM_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_C_FLAGS_INIT="-march=x86-64 -fms-compatibility-version=19.40" \
    -DCMAKE_CXX_FLAGS_INIT="-march=x86-64 -fms-compatibility-version=19.40 -fno-rtti" \
    -DCMAKE_C_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DCMAKE_CXX_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DCMAKE_ASM_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DLLVM_ENABLE_LIBCXX=ON \
    -DLLVM_ENABLE_LTO="Thin" \
    -DLLVM_ENABLE_MODULES=OFF \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_TARGETS_TO_BUILD="X86" \
    -DLLVM_USE_LINKER="lld" \
    -B build/stage3-lldb-mi build/stage3/lldb-mi

  print "Installing stage3 lldb-mi ..."
  ninja -C build/stage3-lldb-mi install/strip

  verify build/windows/bin/lldb-mi.exe
  create build/12-stage3-lldb-mi.done
fi

# =================================================================================================
# 13: windows re2c
# =================================================================================================

if [ ! -f build/13-windows-re2c.done ] || [ ! -e build/windows/bin/re2c.exe ]; then
  rm -rf build/13-windows-re2c.done build/windows-re2c build/windows/bin/re2c.exe

  print "Configuring windows re2c ..."
  cmake -GNinja -Wno-dev \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}/build/windows" \
    -DCMAKE_TOOLCHAIN_FILE="${ACE}/mingw.cmake" \
    -DRE2C_BUILD_RE2GO=OFF \
    -DRE2C_BUILD_RE2RUST=OFF \
    -B build/windows-re2c build/src/re2c

  print "Installing windows re2c ..."
  ninja -C build/windows-re2c install/strip

  verify build/windows/bin/re2c.exe
  create build/13-windows-re2c.done
fi

# =================================================================================================
# 14: windows yasm
# =================================================================================================

if [ ! -f build/14-windows-yasm.done ] || [ ! -e build/windows/bin/yasm.exe ]; then
  rm -rf build/14-windows-yasm.done build/windows/bin/yasm.exe

  print "Downloading windows yasm ..."
  curl -o "build/windows/bin/yasm.exe" -L "${YASM_EXE}" || error "Download failed."

  verify build/windows/bin/yasm.exe
  create build/14-windows-yasm.done
fi

# =================================================================================================
# 15: windows ninja
# =================================================================================================

if [ ! -f build/15-windows-ninja.done ] || [ ! -e build/windows/bin/ninja.exe ]; then
  rm -rf build/15-windows-ninja.done build/windows-ninja build/windows/bin/ninja.exe

  print "Configuring windows ninja ..."
  cmake -GNinja -Wno-dev \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}/build/windows" \
    -DCMAKE_TOOLCHAIN_FILE="${ACE}/mingw.cmake" \
    -DBUILD_TESTING=OFF \
    -B build/windows-ninja build/src/ninja

  print "Installing windows ninja ..."
  ninja -C build/windows-ninja install/strip

  verify build/windows/bin/ninja.exe
  create build/15-windows-ninja.done
fi

# =================================================================================================
# 16: compiler-rt
# =================================================================================================

if [ ! -f build/16-compiler-rt-linux.done ] ||
   [ ! -f ${LLVM_RES}/lib/linux/liborc_rt-x86_64.a ] ||
   [ ! -f ${LLVM_RES}/lib/linux/libclang_rt.profile-x86_64.a ]
then
  rm -rf build/16-compiler-rt-linux.done build/compiler-rt-linux

  print "Configuring compiler-rt (linux) ..."
  cmake -GNinja -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ACE}/${LLVM_RES}" \
    -DCMAKE_INSTALL_RPATH="\$ORIGIN/../../../.." \
    -DCMAKE_CROSSCOMPILING=ON \
    -DCMAKE_SYSTEM_NAME="Linux" \
    -DCMAKE_SYSTEM_VERSION="5.10.0" \
    -DCMAKE_SYSTEM_PROCESSOR="AMD64" \
    -DCMAKE_SYSROOT="${ACE}/sys/linux" \
    -DCMAKE_FIND_ROOT_PATH="${ACE}" \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM="BOTH" \
    -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
    -DCMAKE_BUILD_RPATH="${ACE}/lib" \
    -DCMAKE_C_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_CXX_COMPILER="${ACE}/bin/clang++" \
    -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="${ACE}/bin/clang-scan-deps" \
    -DCMAKE_ASM_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_C_FLAGS_INIT="-march=x86-64" \
    -DCMAKE_CXX_FLAGS_INIT="-march=x86-64" \
    -DCMAKE_C_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DCMAKE_CXX_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DCMAKE_ASM_COMPILER_TARGET="x86_64-pc-linux-gnu" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-pc-linux-gnu" \
    -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF \
    -DLLVM_ENABLE_RUNTIMES="compiler-rt" \
    -DLLVM_ENABLE_WARNINGS=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_INCLUDE_DOCS=OFF \
    -DCOMPILER_RT_BUILD_BUILTINS=OFF \
    -DCOMPILER_RT_BUILD_GWP_ASAN=OFF \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
    -DCOMPILER_RT_BUILD_MEMPROF=ON \
    -DCOMPILER_RT_BUILD_ORC=ON \
    -DCOMPILER_RT_BUILD_PROFILE=ON \
    -DCOMPILER_RT_BUILD_CTX_PROFILE=ON \
    -DCOMPILER_RT_BUILD_SANITIZERS=ON \
    -DCOMPILER_RT_BUILD_XRAY=ON \
    -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
    -DCOMPILER_RT_USE_BUILTINS_LIBRARY=ON \
    -B build/compiler-rt-linux build/src/llvm/runtimes

  print "Installing compiler-rt (linux) ..."
  ninja -C build/compiler-rt-linux install/strip

  verify ${LLVM_RES}/lib/linux/libclang_rt.profile-x86_64.a
  verify ${LLVM_RES}/lib/linux/liborc_rt-x86_64.a
  create build/16-compiler-rt-linux.done
fi

if [ ! -f build/16-compiler-rt-mingw.done ] ||
   [ ! -f ${LLVM_RES}/lib/windows/liborc_rt-x86_64.a ] ||
   [ ! -f ${LLVM_RES}/lib/windows/libclang_rt.profile-x86_64.a ] ||
   [ ! -f build/windows/${LLVM_RES}/lib/windows/liborc_rt-x86_64.a ] ||
   [ ! -f build/windows/${LLVM_RES}/lib/windows/libclang_rt.profile-x86_64.a ]
then
  rm -rf build/16-compiler-rt-mingw.done build/compiler-rt-mingw

  print "Configuring compiler-rt (mingw) ..."
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
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE="ONLY" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM="BOTH" \
    -DCMAKE_C_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_CXX_COMPILER="${ACE}/bin/clang++" \
    -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="${ACE}/bin/clang-scan-deps" \
    -DCMAKE_ASM_COMPILER="${ACE}/bin/clang" \
    -DCMAKE_C_FLAGS_INIT="-march=x86-64 -fms-compatibility-version=19.40" \
    -DCMAKE_CXX_FLAGS_INIT="-march=x86-64 -fms-compatibility-version=19.40" \
    -DCMAKE_C_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DCMAKE_CXX_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DCMAKE_ASM_COMPILER_TARGET="x86_64-w64-mingw32" \
    -DLLVM_DEFAULT_TARGET_TRIPLE="x86_64-w64-mingw32" \
    -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF \
    -DLLVM_ENABLE_RUNTIMES="compiler-rt" \
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
    -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
    -DCOMPILER_RT_USE_BUILTINS_LIBRARY=ON \
    -B build/compiler-rt-mingw build/src/llvm/runtimes

  print "Installing compiler-rt (mingw) ..."
  ninja -C build/compiler-rt-mingw install/strip

  verify ${LLVM_RES}/lib/windows/libclang_rt.profile-x86_64.a
  verify ${LLVM_RES}/lib/windows/liborc_rt-x86_64.a

  rm -rf build/windows/${LLVM_RES}/include/orc
  cp -a ${LLVM_RES}/include/orc build/windows/${LLVM_RES}/include/orc

  rm -rf build/windows/${LLVM_RES}/include/profile
  cp -a ${LLVM_RES}/include/profile build/windows/${LLVM_RES}/include/profile

  rm -f build/windows/${LLVM_RES}/lib/windows/libclang_rt.profile-x86_64.a
  cp -a ${LLVM_RES}/lib/windows/libclang_rt.profile-x86_64.a \
        build/windows/${LLVM_RES}/lib/windows/libclang_rt.profile-x86_64.a

  rm -f build/windows/${LLVM_RES}/lib/windows/liborc_rt-x86_64.a
  cp -a ${LLVM_RES}/lib/windows/liborc_rt-x86_64.a \
        build/windows/${LLVM_RES}/lib/windows/liborc_rt-x86_64.a

  verify build/windows/${LLVM_RES}/lib/windows/libclang_rt.profile-x86_64.a
  verify build/windows/${LLVM_RES}/lib/windows/liborc_rt-x86_64.a
  create build/16-compiler-rt-mingw.done
fi

# =================================================================================================
# 17: readpe
# =================================================================================================

if [ ! -f build/17-readpe.done ] ||
   [ ! -f bin/peldd ]
then
  rm -rf build/17-readpe.done build/readpe
  cp -a build/src/readpe build/readpe

  print "Building readpe ..."
  env --chdir=build/readpe make \
    CC="${ACE}/bin/clang" \
    AR="${ACE}/bin/llvm-ar" \
    NM="${ACE}/bin/llvm-nm" \
    RANLIB="${ACE}/bin/llvm-ranlib" \
    OBJCOPY="${ACE}/bin/llvm-objcopy" \
    OBJDUMP="${ACE}/bin/llvm-objdump" \
    STRIP="${ACE}/bin/llvm-strip" \
    SIZE="${ACE}/bin/llvm-size" \
    LDFLAGS="-pthread -L${ACE}/build/vcpkg/installed/ace-linux/lib" \
    CFLAGS="-march=x86-64 -flto=thin -I${ACE}/build/vcpkg/installed/ace-linux/include" \
    prefix="${ACE}" -j17

  print "Installing readpe ..."
  env --chdir=build/readpe make \
    CC="${ACE}/bin/clang" \
    AR="${ACE}/bin/llvm-ar" \
    NM="${ACE}/bin/llvm-nm" \
    RANLIB="${ACE}/bin/llvm-ranlib" \
    OBJCOPY="${ACE}/bin/llvm-objcopy" \
    OBJDUMP="${ACE}/bin/llvm-objdump" \
    STRIP="${ACE}/bin/llvm-strip" \
    SIZE="${ACE}/bin/llvm-size" \
    LDFLAGS="-pthread -L${ACE}/build/vcpkg/installed/ace-linux/lib" \
    CFLAGS="-march=x86-64 -flto=thin -I${ACE}/build/vcpkg/installed/ace-linux/include" \
    prefix="${ACE}" -j17 install-strip

  verify bin/peldd
  create build/17-readpe.done
fi

return

# =================================================================================================
# ports
# =================================================================================================

# =================================================================================================
# archives
# =================================================================================================

if git -C build/src/llvm describe --exact-match --tags >/dev/null 2>&1; then
  ARCHIVE_NAME=ace-${LLVM_VER}
else
  ARCHIVE_NAME=ace-$(git -C build/src/llvm log --format=%cs-%h)
fi

if [ ! -f ${ARCHIVE_NAME}.tar.xz ] || [ ! -f ${ARCHIVE_NAME}.7z ]; then
  print "Fixing library search paths ..."
  find bin -type f | while read executable; do
    if file -bL --mime-type "${executable}" | grep "application/x-.*executable" >/dev/null; then
      patchelf --set-rpath '$ORIGIN/../lib' "${executable}"
      echo "${executable}"; readelf -d "${executable}" | grep RUNPATH
    fi
  done

  print "Cleaning up permissions and ownership ..."
  find bin -exec chmod 0755 '{}' ';'
  find bin -type f -name '*.dll' -exec chmod 0644 '{}' ';'
  find include lib share sys build/windows -type d -exec chmod 0755 '{}' ';'
  find include lib share sys build/windows -type f -exec chmod 0644 '{}' ';'
  chown -R "${uid}:${gid}" bin include lib share sys build/windows

  print "Searching for symlinks in windows directory ..."
  find build/windows -type l | while read link; do
    error "Symlink in windows directory: ${link}"
  done

  print "Creating linux archive: ${ARCHIVE_NAME}.tar.xz ..."
  rm -f ${ARCHIVE_NAME}.tar.xz
  tar cJf ${ARCHIVE_NAME}.tar.xz bin include lib share sys tools
  chown -R "${uid}:${gid}" ${ARCHIVE_NAME}.tar.xz

  print "Creating windows archive: ${ARCHIVE_NAME}.7z ..."
  rm -f ${ARCHIVE_NAME}.7z
  env --chdir=build/windows 7z a ../../${ARCHIVE_NAME}.7z bin include lib share sys
  chown -R "${uid}:${gid}" ${ARCHIVE_NAME}.7z
fi

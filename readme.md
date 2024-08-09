# ACE
Toolchain for portable C++ development.

```
Supported Systems: Linux, Windows
Supported Targets: Linux, MinGW
Supported Architectures: x86_64
Linux Sysroot: Debian 11
MinGW Runtime: UCRT
```

**This is not a general purpose toolchain!**

## Sysroot
See [doc/sysroot.md](doc/sysroot.md) for a list of evaluated Linux distributions.

## Ports
See [doc/ports.md](doc/ports.md) for a list of supported [Vcpkg][pkg] ports.

## Build
See [doc/build.md](doc/build.md) for build instructions.

## Install
Use archives from the build step to install this toolchain.

### Linux
1. Install dependencies.

```sh
# Debian
sudo apt install curl git libncurses6 pkg-config unzip wine xz-utils zip

# Gentoo
sudo emerge -avn \
  app-arch/unzip \
  app-arch/xz-utils \
  app-arch/zip \
  app-emulation/wine-proton \
  dev-util/pkgconf \
  net-misc/curl \
  sys-libs/ncurses
```

2. Install [CMake][cmk].

```sh
# Download cmake archive.
curl -L https://github.com/Kitware/CMake/releases/download/v3.30.1/cmake-3.30.1-linux-x86_64.tar.gz \
     -o /tmp/cmake.tar.gz

# Extract cmake archive.
sudo mkdir /opt/cmake
sudo tar xf /tmp/cmake.tar.gz -C /opt/cmake -m --strip-components=1

# Create cmake environment variables.
sudo tee /etc/profile.d/cmake.sh >/dev/null <<'EOF'
export PATH="/opt/cmake/bin:${PATH}"
EOF

sudo chmod 0755 /etc/profile.d/cmake.sh
source /etc/profile.d/cmake.sh
```

3. Install toolchain.

```sh
# Create toolchain directory.
sudo mkdir /opt/ace
sudo chown $(id -u):$(id -g) /opt/ace

# Clone toolchain repository.
git clone https://github.com/qis/ace /opt/ace

# Install toolchain binaries.
tar xf /tmp/ace.tar.xz -C /opt/ace

# Create toolchain environment variables.
sudo tee /etc/profile.d/ace.sh >/dev/null <<'EOF'
export ACE="/opt/ace"
export PATH="${ACE}/bin:${ACE}/tools/powershell:${PATH}"
EOF

sudo chmod 0755 /etc/profile.d/ace.sh
source /etc/profile.d/ace.sh

# Register toolchain library path.
sudo tee /etc/ld.so.conf.d/ace.conf >/dev/null <<'EOF'
/opt/ace/sys/linux/lib
EOF

sudo ldconfig
```

### Windows
1. Install [Git][git].
2. Install [CMake][cmk].
3. Install [WiX Toolset][wix].
4. Install [7-zip][zip].
5. Install toolchain.

```bat
rem Clone toolchain repository.
git clone https://github.com/qis/ace C:/Ace

rem Install toolchain binaries.
7z x %UserProfile%\Downloads\ace.7z -oC:\Ace

rem Modify system environment variables.
SystemPropertiesAdvanced.exe
```

* Set `ACE` to `C:/Ace`.
* Add `C:\Ace\bin` to `PATH`.

## Vcpkg
Install [Vcpkg][pkg].

### Linux

```sh
# Clone vcpkg repository.
git clone -b 2024.07.12 https://github.com/microsoft/vcpkg /opt/ace/vcpkg

# Install vcpkg binary.
/opt/ace/vcpkg/bootstrap-vcpkg.sh

# Create vcpkg environment variables.
sudo tee /etc/profile.d/vcpkg.sh >/dev/null <<'EOF'
export VCPKG_ROOT="/opt/ace/vcpkg"
export VCPKG_DEFAULT_TRIPLET="ace-linux-shared"
export VCPKG_DEFAULT_HOST_TRIPLET="ace-linux-shared"
export VCPKG_OVERLAY_TRIPLETS="/opt/ace/src/triplets"
export VCPKG_FEATURE_FLAGS="-binarycaching"
export VCPKG_FORCE_SYSTEM_BINARIES=1
export VCPKG_DISABLE_METRICS=1
export PATH="${VCPKG_ROOT}:${PATH}"
EOF

sudo chmod 0755 /etc/profile.d/vcpkg.sh
source /etc/profile.d/vcpkg.sh
```

### Windows

```bat
rem Clone vcpkg repository.
git clone -b 2024.07.12 https://github.com/microsoft/vcpkg C:/Ace/vcpkg

rem Install vcpkg binary.
C:\Ace\vcpkg\bootstrap-vcpkg.bat

rem Modify system environment variables.
SystemPropertiesAdvanced.exe
```

* Set `VCPKG_ROOT` to `C:/Ace/vcpkg`.
* Set `VCPKG_DEFAULT_TRIPLET` to `ace-mingw-shared`.
* Set `VCPKG_DEFAULT_HOST_TRIPLET` to `ace-mingw-shared`.
* Set `VCPKG_OVERLAY_TRIPLETS` to `C:/Ace/src/triplets`.
* Set `VCPKG_FEATURE_FLAGS` to `-binarycaching`.
* Set `VCPKG_FORCE_SYSTEM_BINARIES` to `1`.
* Set `VCPKG_DISABLE_METRICS` to `1`.
* Add `C:\Ace\vcpkg` to `Path`.
* Add `C:\Ace\vcpkg\installed\ace-mingw-shared\bin` to `Path`.

## Editor
Configure editor according to [doc/editor.md](doc/editor.md).

## Optimizations
1. Interprocedural optimizations are enabled in release builds.
2. Everything is compiled for the `x86-64-v3` architecture with AVX2 enabled.
3. If a `-static` Vcpkg triplet is used or `BUILD_SHARED_LIBS` not defined in CMake, then everything
   will be compiled with `-fno-exceptions -fno-rtti` and statically linked to `libc++`.

## Usage
See [src/template](src/template) for a template project.<br/>
See [src/modules](src/modules) for a C++ modules template project.

## License
This is free and unencumbered software released into the public domain.

```
Anyone is free to copy, modify, publish, use, compile, sell, or distribute
this software, either in source code form or as a compiled binary, for any
purpose, commercial or non-commercial, and by any means.

In jurisdictions that recognize copyright laws, the author or authors of
this software dedicate any and all copyright interest in the software to the
public domain. We make this dedication for the benefit of the public at
large and to the detriment of our heirs and successors. We intend this
dedication to be an overt act of relinquishment in perpetuity of all present
and future rights to this software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

Projects compiled with this toolchain must be distributed under the following conditions.

1. Linux: GCC Runtime Library<br/>
   No license needed (GCC Runtime Library Exception)

2. Windows: MinGW-w64 Runtime Library<br/>
   [src/template/res/license.txt](src/template/res/license.txt)

3. LLVM Runtime Libraries<br/>
   [src/template/res/license.txt](src/template/res/license.txt)

4. Vcpkg Libraries<br/>
   `vcpkg/installed/*/share/*/copyright`

[git]: https://git-scm.com/
[cmk]: https://cmake.org/download/
[wix]: https://github.com/wixtoolset/wix3/releases
[zip]: https://www.7-zip.org/
[pkg]: https://vcpkg.io/

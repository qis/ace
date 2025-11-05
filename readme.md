# ACE
Toolchain for portable C++ game engine development.

```
Supported Targets: Linux, MinGW
Supported Architectures: x86_64
Linux Sysroot: Debian 11
MinGW Runtime: UCRT
```

## Dependencies
Install dependencies.

```sh
# Install build packages.
sudo apt install -y autoconf binutils debootstrap git libtool nasm patchelf swig symlinks wget

# Install runtime dependencies.
sudo apt install -y p7zip pkg-config vulkan-validationlayers xz-utils

# Install cmake(1).
sudo mkdir /opt/cmake
curl -L https://github.com/Kitware/CMake/releases/download/v4.1.2/cmake-4.1.2-linux-x86_64.tar.gz -o ~/cmake.tar.gz
sudo tar xf ~/cmake.tar.gz -C /opt/cmake -m --strip-components=1

sudo tee /etc/profile.d/cmake.sh >/dev/null <<'EOF'
export PATH="/opt/cmake/bin:${PATH}"
EOF

sudo chmod 0755 /etc/profile.d/cmake.sh
source /etc/profile.d/cmake.sh
```

## Build
Build toolchain.

```sh
# Clone repository.
sudo mkdir /opt/ace
sudo chown $(id -u):$(id -g) /opt/ace
git clone https://github.com/qis/ace /opt/ace

# Build toolchain.
src/build
```

## Install
Install toolchain.

```sh
# Extract archive.
sudo mkdir /opt/ace
sudo chown $(id -u):$(id -g) /opt/ace
tar xf ~/ace.tar.xz -C /opt/ace -m --strip-components=1

# Register toolchain.
sudo tee /etc/profile.d/ace.sh >/dev/null <<'EOF'
export ACE="/opt/ace"
EOF

sudo chmod 0755 /etc/profile.d/ace.sh
source /etc/profile.d/ace.sh
```

## Plugin
Install LLDB DAP VS Code extension.

```sh
cd "${ACE}" || cd /d "%ACE%"
code --install-extension share/lldb-dap.vsix
```

## Usage
1. See [doc/editor.md](doc/editor.md) for editor configuration instructions.
2. See [src/template](src/template) for a template project.

## License
This software is available under the "MIT No Attribution" license.

```
Copyright 2025 Alexej Harm

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

Projects compiled with this toolchain must be distributed under the following conditions.

1. Linux: GCC Runtime Library<br/>
   No license needed (GCC Runtime Library Exception)

2. Windows: MinGW-w64 Runtime Library<br/>
   [res/license.txt](res/license.txt)

3. LLVM Runtime Libraries<br/>
   [res/license.txt](res/license.txt)

4. Ports Libraries<br/>
   `vcpkg/installed/*/share/*/copyright`

[git]: https://git-scm.com/
[cmk]: https://cmake.org/download/
[wsl]: https://learn.microsoft.com/windows/wsl/
[zip]: https://www.7-zip.org/

<!--
bin/clang++ --target=x86_64-w64-windows-gnu --sysroot=sys/mingw -fms-compatibility-version=19.44 \
  -std=c++26 -fstrict-vtable-pointers -fno-exceptions -fno-rtti -Og -g main.cpp -Lsys/mingw/lib/shared

bin/peldd a.exe
bin/lldb

platform select remote-windows
platform connect connect://172.24.32.1:1721
platform settings -w "D:\\Workspace"
platform put-file a.exe a.exe
platform put-file sys/mingw/bin/libc++.dll libc++.dll
file a.exe
b main
r
k

script -l lua -- print(lldb.SBDebugger.Create():IsValid())
-->

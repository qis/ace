# ACE
Toolchain for portable C++ game engine development.

```
Supported Targets: Linux, MinGW
Supported Architectures: x86_64
Linux Sysroot: Debian 11
MinGW Runtime: UCRT
```

<details>
<summary><b>WSL</b></summary>

Create a [WSL][wsl] configuration file: `%UserProfile%\.wslconfig`

```ini
[wsl2]
firewall=false
autoProxy=true
guiApplications=true
networkingMode=mirrored
kernelCommandLine=vsyscall=emulate
nestedVirtualization=true
maxCrashDumpCount=-1
processors=16
memory=18GB
swap=46GB
```

Install WSL and configure the default version.

```bat
wsl --install
wsl --set-default-version 2
```

Install and configure a WSL distribution.

```bat
wsl --install -d Debian
```

```sh
sudo tee /etc/wsl.conf >/dev/null <<'EOF'
[boot]
systemd=true

[automount]
enabled=true
options=case=off,metadata,uid=1000,gid=1000,umask=022
EOF

# Get the user profile directory.
CMD="/mnt/c/Windows/System32/cmd.exe"
USERPROFILE="$(/bin/wslpath -a $(${CMD} /C 'echo %UserProfile%' 2>/dev/null | sed 's/\r//g') 2>/dev/null)"

# Configure ssh(1).
mkdir -p ~/.ssh
chmod 0700 ~/.ssh
cp ${USERPROFILE}/.ssh/config ~/.ssh/
cp ${USERPROFILE}/.ssh/id_rsa ~/.ssh/
cp ${USERPROFILE}/.ssh/id_rsa.pub ~/.ssh/
cp ${USERPROFILE}/.ssh/known_hosts ~/.ssh/
chmod 0600 ~/.ssh/*

# Configure git(1).
ln -sf ${USERPROFILE}/.gitconfig ~/.gitconfig

exit
```

```bat
wsl --shutdown
wsl -d Debian
```

</details>

## Debian
Prepare the system for building or using this toolchain.

```sh
# Update system.
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt autoremove -y --purge
sudo apt clean

# Install runtime dependencies.
sudo apt install -y autoconf libtool \
  curl git make p7zip pkg-config python3 unzip vulkan-validationlayers wget xz-utils zip \
  $(apt-cache search '^libicu[0-9]+$' | grep -v dev | head -1 | awk '{print $1}')

# Install cmake(1).
wget -O ~/cmake.tar.gz https://github.com/Kitware/CMake/releases/download/v3.31.10/cmake-3.31.10-linux-x86_64.tar.gz
sudo rm -rf /opt/cmake; sudo mkdir /opt/cmake; sudo tar xf ~/cmake.tar.gz -C /opt/cmake -m --strip-components=1

sudo tee /etc/profile.d/cmake.sh >/dev/null <<'EOF'
export PATH="/opt/cmake/bin:${PATH}"
EOF

sudo chmod 0755 /etc/profile.d/cmake.sh
source /etc/profile.d/cmake.sh
```

## Build
Build this toolchain.

```sh
# Install build dependencies.
sudo apt install -y \
  autoconf binutils build-essential debootstrap libtool patchelf symlinks \
  nasm python3-pip re2c swig libsqlite3-dev

# Install ninja(1).
wget -O ~/ninja.zip https://github.com/ninja-build/ninja/releases/download/v1.13.2/ninja-linux.zip
env --chdir=/opt/cmake/bin sudo unzip ~/ninja.zip

# Clone repository.
sudo mkdir /opt/ace
sudo chown $(id -u):$(id -g) /opt/ace
git clone https://github.com/qis/ace /opt/ace

# Build toolchain.
cd /opt/ace
src/build.sh
```

## Install
Install this toolchain on Linux.

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

# Install all supported vcpkg ports.
git clone https://github.com/microsoft/vcpkg -b "2025.10.17" --depth 1 "${ACE}/vcpkg"
sh "${ACE}/vcpkg/bootstrap-vcpkg.sh" -disableMetrics
sh "${ACE}/res/install"

# Install the VS Code extensions (optional).
code --install-extension "${ACE}/share/extensions/clangd.vsix"
code --install-extension "${ACE}/share/extensions/lldb-dap.vsix"
```

Install this toolchain on Windows.

1. Install [Git][git].
2. Install [CMake][cmk].
3. Install [7-Zip][zip].
4. Install [Python][py3].
5. Extract `Ace.7z` to `C:\` or `D:\`.
6. Set `ACE=C:\Ace` system environment variable.
7. Add `C:\Ace\bin` to the `Path` system environment variable.
8. Install all supported vcpkg ports.

```bat
git clone https://github.com/microsoft/vcpkg -b "2025.10.17" --depth 1 "%ACE%\vcpkg"
"%ACE%\vcpkg\bootstrap-vcpkg.bat" -disableMetrics
"%ACE%\res\install.cmd"
```

9. Install the VS Code extensions (optional).

```bat
code --install-extension "%ACE%\share\extensions\clangd.vsix"
code --install-extension "%ACE%\share\extensions\lldb-dap.vsix"
```

## Usage
See [src/template](src/template) for a template project.

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
[py3]: https://www.python.org/downloads/
[wsl]: https://learn.microsoft.com/windows/wsl/
[zip]: https://www.7-zip.org/

<!--
wget https://github.com/microsoft/vscode-cmake-tools/releases/download/v1.21.36/cmake-tools.vsix

git clone https://github.com/clangd/vscode-clangd
cd vscode-clangd
npm install
npm run compile
npm run package
code --install-extension vscode-clangd-*.vsix
find ~/.vscode-server/bin -type f -name code-server | while read server; do
  "${server}" --install-extension "${ACE}/share/clangd.vsix"
  "${server}" --install-extension "${ACE}/share/lldb-dap.vsix"
  "${server}" --install-extension "${ACE}/share/cmake-tools.vsix"
done

bin/clang++ --target=x86_64-w64-windows-gnu --sysroot=sys/mingw -fms-compatibility-version=19.44 \
  -std=c++26 -fstrict-vtable-pointers -Og -g main.cpp -Lsys/mingw/lib/shared

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

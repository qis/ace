# LLVM
Toolchain for native Linux, Windows and WebAssembly development.

## Description
This project was created for the following reasons:

1. **Convenience**

   It allows you to build native applications without installing a system compiler.

   - Linux binaries use a sysroot that provides reasonable binary compatibility.
   - Windows binaries use the MSVC CRT and do not require linking to MinGW libraries.
   - WebAssembly binaries are small, but require custom syscall implementations in JS.

2. **Versatility**

   Binaries compiled in **Debug**, **MinSizeRel** and **RelWithDebInfo** mode link to
   shared MS STL or libc++ libraries. This speeds up build times and results in faster
   development cycles.

   Binaries compiled in **Release** mode link to shared MS STL or libc++ libraries
   when `BUILD_SHARED_LIBS` evaluates to `TRUE` and to static MS STL or libc++ libraries
   when `BUILD_SHARED_LIBS` evaluates to `FALSE`. The GCC libc and other (L)GPL licensed
   libraries are always linked as shared libraries.

This toolchain was made for personal use.

## Archives
Contents of the archives generated by this project.

<details>
<summary>Linux</summary>

* `sys.tar.gz` - Linux sysroot
  - `lib/clang/14.0.4/lib/x86_64-pc-linux-gcc/libclang_rt.*.a` - compiler-rt
  - `sys/lib/*.so` - shared libraries meant for distribution

* `sys-tools.tar.gz` - Linux host compiler
  - `lib/clang/14.0.4/include` - compiler headers
  - `lib/*.so` - shared libraries used by compiler tools
  - `bin/*` - compiler tools

</details>

<details>
<summary>Windows</summary>

* `win.tar.gz` - Windows sysroot
  - `win/crt/lib/clang_rt.*-x86_64.lib` - compiler-rt
  - `win/bin/*.dll` - shared libraries meant for distribution

* `win-tools.tar.gz` - Windows host compiler
  - `lib/clang/14.0.4/include` - compiler headers
  - `bin/*.dll` - shared libraries used by compiler tools
  - `bin/*.exe` - compiler tools

</details>

<details>
<summary>WebAssembly</summary>

* `web.tar.gz` - WebAssembly sysroot
  - `lib/clang/14.0.4/lib/wasi/libclang_rt.*-wasm32.a` - compiler-rt

</details>

## Distribution
Select a sysroot Linux distribution.

<details>
<summary>LTS Distributions</summary>

| Distribution                   |      LTS       |    Extended    | Kernel   | GNU libc |
|--------------------------------|:--------------:|:--------------:|----------|----------|
| Debian 8 (Jessie)              |   2020-07-01   |   2025-06-30   | 3.16     | 2.19     |
| Debian 9 (Stretch)             |   2022-07-01   |   2027-06-30   | 4.9      | 2.24     |
| Debian 10 (Buster)             |   2024-07-01   |   2029-06-30   | 4.19     | 2.28     |
| **Debian 11 (Bullseye)**       | **2026-07-01** | **2031-06-30** | **5.10** | **2.31** |
| Ubuntu 16.04 (Xenial Xerus)    |   2021-04-01   |   2026-04-01   | 4.4      | 2.23     |
| Ubuntu 18.04 (Bionic Beaver)   |   2023-04-01   |   2028-04-01   | 5.3      | 2.27     |
| Ubuntu 20.04 (Focal Fossa)     |   2025-04-01   |   2030-04-01   | 5.4      | 2.31     |
| Ubuntu 22.04 (Jammy Jellyfish) |   2027-04-01   |   2032-04-01   | 5.15     | 2.35     |
| Red Hat Enterprise Linux 7     |   2024-06-30   |   2026-06-30   | 3.10     | 2.17     |
| Red Hat Enterprise Linux 8     |   2029-05-31   |   2031-05-31   | 4.18     | 2.28     |
| Red Hat Enterprise Linux 9     |   2032-05-31   |   2034-05-31   | 5.14     | 2.34     |
| Альт Сервер 9                  |   2023-12-31   |                | 4.19     | 2.27     |
| Альт Сервер 10                 |                |                | 5.15     | 2.32     |

</details>

Using a **Debian 11 (Bullseye)** sysroot should result in binary compatibility with:

- Ubuntu 22.04 (Jammy Jellyfish)
- Red Hat Enterprise Linux 9
- Альт Сервер 10

See [ABI Laboratory][abi] and the [Longterm Release Kernels][lts] list for more information.

## Build: Linux
Create a `docker(1)` container or [WSL][wsl] distribution (required for targeting Windows).

<details>
<summary>Docker</summary>

```sh
# Install docker.
sudo apt install -y docker.io
sudo usermod -aG docker `id -un`

# Remove existing container.
docker rm llvm

# Install container and log in as root.
docker run -it -h llvm --name llvm debian:11
```

```sh
# Create user.
useradd -s /bin/bash -d /home/llvm -m -G users llvm
```

</details>

<details>
<summary>WSL</summary>

```cmd
rem Remove existing distribution.
wsl --unregister Debian

rem Install distribution.
wsl --install -d Debian
```

```
Enter new UNIX username: llvm
```

```sh
# Configure distribution.
sudo tee /etc/wsl.conf >/dev/null <<'EOF'
[automount]
enabled=true
options=case=off,metadata,uid=1000,gid=1000,umask=022
EOF

# Configure sudo.
sudo EDITOR=tee visudo >/dev/null <<'EOF'
root ALL=(ALL) ALL
llvm ALL=(ALL) NOPASSWD: ALL
#includedir /etc/sudoers.d
EOF

# Exit shell.
exit
```

```cmd
rem Shut down all distributions.
wsl --shutdown

rem Start distributions.
wsl ~ -u root -d Debian
```

</details>

Configure environment.

```sh
# Update system.
export DEBIAN_FRONTEND=noninteractive
apt update && apt upgrade -y && apt autoremove -y --purge

# Install required packages.
apt install -y --no-install-recommends ca-certificates curl git openssh-client tzdata wget \
  automake build-essential ninja-build patchelf pax-utils python3{,-distutils,-lib2to3} xattr \
  libc6-dev-i386 lib{ncurses,readline,edit,icu,lzma,xml2}-dev zlib1g-dev

# Install optional packages (for convenience).
apt install -y --no-install-recommends apt-file figlet file man-db tree vim
apt-file update

# Install CMake.
rm -rf /opt/cmake; mkdir -p /opt/cmake
curl -L https://github.com/Kitware/CMake/releases/download/v3.22.4/cmake-3.22.4-linux-x86_64.tar.gz -o cmake.tar.gz
tar xf cmake.tar.gz -C /opt/cmake --strip-components=1
echo 'export PATH="/opt/cmake/bin:${PATH}"' > /etc/profile.d/cmake.sh
chmod 0755 /etc/profile.d/cmake.sh

# Install optional vim config (for convenience, replace with your own).
mv /etc/vim /etc/vim.orig; mkdir -p /etc/vim
curl -L https://github.com/qis/vim/archive/refs/heads/master.tar.gz -o vim.tar.gz
tar xf vim.tar.gz -C /etc/vim --strip-components=1

# Install optional bash config (for convenience, replace with your own).
curl -L https://raw.githubusercontent.com/qis/windows/master/wsl/bash.sh -o /etc/profile.d/bash.sh
chmod 0755 /etc/profile.d/bash.sh
rm -f /{root,home/llvm}/.bashrc

# Log in as user
su - llvm
```

Create Linux and WebAssembly archives.

```sh
# Create project directory.
sudo mkdir -p /opt/llvm
sudo chown `id -u`:`id -g` /opt/llvm

# Download project on a Linux host.
# git clone https://github.com/qis/llvm /opt/llvm

# Link to project on a Windows host.
mkdir /opt/llvm/src
ln -s /mnt/c/LLVM/src/test  /opt/llvm/src/
ln -s /mnt/c/LLVM/sys.cmake /opt/llvm/
ln -s /mnt/c/LLVM/web.cmake /opt/llvm/
ln -s /mnt/c/LLVM/win.cmake /opt/llvm/
ln -s /mnt/c/LLVM/makefile  /opt/llvm/
ln -s /mnt/c/LLVM/cmake     /opt/llvm/

# Enter project directory.
cd /opt/llvm

# Create Linux tools and sysroot archives.
make sys-tools sys

# Create WebAssembly sysroot archive.
make web

# Create sources archive for Windows.
make src
```

<!--
Create an archive with `build/stage` and `build/tools` while working on this project.

```sh
make sys-build
```
-->

Copy generated archives to the host system.

```sh
docker cp llvm:/opt/llvm/sys.tar.gz sys.tar.gz
docker cp llvm:/opt/llvm/sys-tools.tar.gz sys.tar-tools.xz
docker cp llvm:/opt/llvm/web.tar.gz web.tar.gz
```

<!--
```sh
docker cp llvm:/opt/llvm/sys-build.tar.gz sys.tar-build.xz
```
-->

## Build: Windows

* Install [Git][git] and enable symbolic links during setup.
* Install [CMake][cmk] and add it to the `PATH` environment variable.
* Install [7-Zip][p7z] and add it to the `PATH` environment variable.
* Install [Conan][con] and add it to the `PATH` environment variable.
* Install [Python 3][py3] and add it to the `PATH` environment variable.
* Install [Visual Studio 2022][vsc] with C/C++ development tools and Windows 10 SDK.
* Build LLVM in the `Developer Command Prompt for VS 2022`.

```cmd
rem Enter project directory.
cd C:\LLVM

rem Copy files from WSL.
copy "\\wsl$\Debian\opt\llvm\src.tar.gz" src.tar.gz
copy "\\wsl$\Debian\opt\llvm\sys.tar.gz" sys.tar.gz
copy "\\wsl$\Debian\opt\llvm\sys-tools.tar.gz" sys-tools.tar.gz
copy "\\wsl$\Debian\opt\llvm\web.tar.gz" web.tar.gz

rem Extract source code.
tar xf src.tar.gz

rem Download make.exe from chocolatey and create Windows sysroot.
cmake -P src/win.cmake

rem Create Windows tools and sysroot archives.
bin\make.exe win-tools win
```

<!--
```cmd
copy "\\wsl$\Debian\opt\llvm\sys-build.tar.gz" sys-build.tar.gz
```
-->

</details>

## Install
Install development tools.

<details>
<summary>Windows</summary>

* Install [Git][git] and enable symbolic links during setup.
* Install [CMake][cmk] and add it to the `PATH` environment variable.
* Install [Microsoft Visual C++ Redistributable][vcr] for binaries built in Debug mode.

```cmd
rem Clone the repository.
git clone https://github.com/qis/llvm C:\LLVM

rem Enter created directory.
cd C:\LLVM

rem Extract tools archive.
tar xf /path/to/win-tools.tar.gz
```

Register toolchain.

* Add `C:\LLVM\win\bin` to the `PATH` environment variable.
* Add `C:\LLVM\bin` to the `PATH` environment variable (optional).

</details>

<details>
<summary>Linux</summary>

```sh
# Install dependencies.
sudo apt install -y --no-install-recommends ca-certificates curl git tzdata wget \
  automake binutils elfutils make ninja-build patchelf pax-utils

# Install CMake.
sudo rm -rf /opt/cmake; sudo mkdir -p /opt/cmake
curl -L https://github.com/Kitware/CMake/releases/download/v3.22.4/cmake-3.22.4-linux-x86_64.tar.gz -o cmake.tar.gz
sudo tar xf cmake.tar.gz -C /opt/cmake --strip-components=1
echo 'export PATH="/opt/cmake/bin:${PATH}"' | sudo tee /etc/profile.d/cmake.sh >/dev/null
sudo chmod 0755 /etc/profile.d/cmake.sh
. /etc/profile.d/cmake.sh

# Create directory.
sudo mkdir -p /opt/llvm
sudo chown `id -u`:`id -g` /opt/llvm

# Clone the repository.
git clone https://github.com/qis/llvm /opt/llvm

# Enter directory.
cd /opt/llvm

# Extract tools archive.
tar xf /path/to/sys-tools.tar.gz

# Add /opt/llvm/bin to the PATH environment variable (optional).
echo 'export PATH="/opt/llvm/bin:${PATH}"' | sudo tee /etc/profile.d/llvm.sh >/dev/null
```

When cross-compilation for Windows is desired, the `/opt/llvm/win` directory must reside
on a case-insensitive filesystem (or be a symlink to a Windows directory in WSL).

```sh
# Check if the kernel supports case-insensitive filesystems.
cat /sys/fs/ext4/features/casefold
cat /sys/fs/unicode/version

# Create case-insensitive filesystem on a spare drive.
# mkfs -t ext4 -O casefold /dev/<device>

# Verify case-insensitive filesystem.
# dumpe2fs -h /dev/<device> | grep 'Filesystem features'

# Mount case-insensitive filesystem.
# mkdir -p /opt/llvm/win
# mount /dev/<device> /opt/llvm/win
```

</details>

Extract sysroot archives.

```
tar xf path/to/sys.tar.gz
tar xf path/to/web.tar.gz
tar xf path/to/win.tar.gz
```

Compile test projects.

<details>
<summary>Windows</summary>

```cmd
rem Enter one of the test project directories.
cd C:\LLVM\src\test\tbb

rem Configure project.
C:\LLVM\bin\make.exe clean configure

rem Build with coverage support, execute and display the results.
C:\LLVM\bin\make.exe test

rem Configure project for Linux cross-compilation.
C:\LLVM\bin\make.exe clean configure root=sys

rem Build release.
C:\LLVM\bin\make.exe config=Release

rem Enter WebAssembly test project directory.
cd C:\LLVM\src\test\web

rem Configure and build project.
C:\LLVM\bin\make.exe clean all config=MinSizeRel
```

</details>

<details>
<summary>Linux</summary>

```sh
# Enter one of the test project directories.
cd /opt/llvm/src/test/tbb

# Configure project.
make clean configure

# Build with coverage support, execute and display the results.
make test

# Configure project for Windows cross-compilation.
make clean configure root=win

# Build release.
make config=Release

# Enter WebAssembly test project directory.
cd /opt/llvm/src/test/web

# Configure and build project.
make clean all config=MinSizeRel
```

</details>

Use the [sys.cmake](sys.cmake), [web.cmake](web.cmake) and [win.cmake](win.cmake)
toolchain files. See [src/test/cpp/makefile](src/test/cpp/makefile) for examples.

## Runtime Dependencies
Linux runtime dependencies for binaries compiled with this toolchain in **Release** mode.

* `kernel (>= 5.10)` - Linux kernel
* `libc6 (>= 2.31)` - GNU libc
* `sys/lib/*.so` - Dependencies (only when `BUILD_SHARED_LIBS` evaluates to `TRUE`)

Windows runtime dependencies for binaries compiled with this toolchain in **Release** mode.

* [Microsoft Visual C++ Redistributable][vcr] (only when `BUILD_SHARED_LIBS` evaluates to `TRUE`)
* `win/bin/*.dll` - Dependencies (only when `BUILD_SHARED_LIBS` evaluates to `TRUE`)

[web]: https://htmlpreview.github.io/?https://github.com/qis/llvm/blob/master/test/wasm/index.html

[abi]: https://abi-laboratory.pro/?view=timeline&l=glibc
[lts]: https://www.kernel.org/category/releases.html
[wsl]: https://docs.microsoft.com/en-us/windows/wsl/
[git]: https://git-scm.com/download/win
[cmk]: https://cmake.org/download/
[p7z]: https://www.7-zip.org/
[con]: https://conan.io/downloads.html
[py3]: https://www.python.org/downloads/windows/
[vsc]: https://visualstudio.microsoft.com/downloads/
[vcr]: https://aka.ms/vs/17/release/vc_redist.x64.exe

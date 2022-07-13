# Ace
Toolchain for native Linux, Windows and WebAssembly development.

## Description
This project aims to provide the following benefits:

1. **Convenience**

   Build native applications without installing a system compiler.

   - Linux binaries use a sysroot that provides reasonable binary compatibility.
   - Windows binaries use the MSVC CRT and do not require linking to MinGW libraries.
   - WebAssembly binaries are small, but require syscall implementations in JS.

   Cross-compile from Windows to Linux and from Linux to Windows.

2. **Versatility**

   Binaries compiled in **Debug**, **MinSizeRel** and **RelWithDebInfo** mode link to
   shared MS STL or libc++ libraries. This speeds up build times and results in a faster
   development cycle.

   Binaries compiled in **Release** mode link to shared MS STL or libc++ libraries
   when `BUILD_SHARED_LIBS` evaluates to `TRUE` and to static MS STL or libc++ libraries
   when `BUILD_SHARED_LIBS` evaluates to `FALSE`. The GCC libc and other (L)GPL licensed
   libraries are always linked as shared libraries.

3. **Performance**

   All libraries and user projects are compiled with [ThinLTO][lto] if possible. This can
   be disabled by configuring a project with `-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF`.

   All libraries and user projects are compiled with `-march=x86-64-v3`. This can be changed
   by editing the target toolchain files before building any sysroot or ports libraries.

   - [sys/x86_64-pc-linux-gnu.cmake](sys/x86_64-pc-linux-gnu.cmake)
   - [sys/x86_64-pc-windows-msvc.cmake](sys/x86_64-pc-windows-msvc.cmake)
   - [sys/x86_64-pc-windows-msvc-vs.cmake](sys/x86_64-pc-windows-msvc-vs.cmake)

4. **Portability**

   The [src/ports](src/ports) directory contains third party libraries that will be compiled
   with the same features, optimizations and dependencies on Linux and Windows.

## Archives
Contents of the archives generated by this project.

<details>
<summary>Linux</summary>

* `tools-linux.tar.gz` - host compiler
  - `lib/clang/14.0.4/include` - compiler headers
  - `lib/*.so` - shared libraries used by compiler tools
  - `bin/*` - compiler tools

* `tools-linux-clang-format.tar.gz` - latest version of clang-format
  - `bin/clang-format` - overwrites tools-linux binary

* `sys-x86_64-pc-linux-gnu.tar.gz` - sysroot
  - `lib/clang/14.0.4/lib/x86_64-pc-linux-gcc/libclang_rt.*.a` - compiler-rt
  - `sys/x86_64-pc-linux-gnu/lib/*.so` - shared libraries
  - `sys/x86_64-pc-linux-gnu/lib/*.a` - static libraries

* `sys-x86_64-pc-linux-gnu-ports.tar.gz` - third party libraries
  - `sys/x86_64-pc-linux-gnu/include` - header files
  - `sys/x86_64-pc-linux-gnu/lib/*.so` - shared libraries
  - `sys/x86_64-pc-linux-gnu/lib/*.a` - static libraries
  - `sys/x86_64-pc-linux-gnu/share` - licenses and data
  - `sys/x86_64-pc-linux-gnu/tools` - executables

</details>

<details>
<summary>Windows</summary>

* `tools-windows.tar.gz` - host compiler
  - `lib/clang/14.0.4/include` - compiler headers
  - `bin/*.dll` - shared libraries used by compiler tools
  - `bin/*.exe` - compiler tools

* `tools-windows-clang-format.tar.gz` - latest version of clang-format
  - `bin/clang-format.exe` - overwrites tools-windows binary

* `sys-x86_64-pc-windows-msvc.tar.gz` - sysroot
  - `sys/x86_64-pc-windows-msvc/crt/lib/clang_rt.*-x86_64.lib` - compiler-rt
  - `sys/x86_64-pc-windows-msvc/bin/*.dll` - shared libraries

* `sys-x86_64-pc-windows-msvc-ports.tar.gz` - third party libraries
  - `sys/x86_64-pc-windows-msvc/bin/*.dll` - shared libraries
  - `sys/x86_64-pc-windows-msvc/include` - header files
  - `sys/x86_64-pc-windows-msvc/lib/shared/*.lib` - import files
  - `sys/x86_64-pc-windows-msvc/lib/static/*.lib` - static libraries
  - `sys/x86_64-pc-windows-msvc/share` - licenses and data
  - `sys/x86_64-pc-windows-msvc/tools` - executables

</details>

<details>
<summary>WebAssembly</summary>

* `sys-wasm32-wasi.tar.gz` - sysroot
  - `lib/clang/14.0.4/lib/wasi/libclang_rt.*-wasm32.a` - compiler-rt
  - `sys/wasm32-wasi/lib/*.a` - static libraries

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

The default **Debian 11 (Bullseye)** sysroot should result in binary compatibility with:

- Ubuntu 22.04 (Jammy Jellyfish)
- Red Hat Enterprise Linux 9
- Альт Сервер 10

Choosing another sysroot distribution will require careful adjustments to the makefiles.

See [ABI Laboratory][abi] and the [Longterm Release Kernels][lts] list for more information.

## Build: Linux
Create a `docker(1)` container or [WSL][wsl] distribution.

<details>
<summary>Docker</summary>

```sh
# Install docker.
sudo apt install -y docker.io
sudo usermod -aG docker `id -un`

# Remove existing container.
docker rm ace

# Install container and log in as root.
docker run -it -h ace --name ace debian:11
```

```sh
# Create user.
useradd -s /bin/bash -d /home/ace -m -G users ace

# Configure sudo.
EDITOR=tee visudo >/dev/null <<'EOF'
root ALL=(ALL) ALL
ace  ALL=(ALL) NOPASSWD: ALL
#includedir /etc/sudoers.d
EOF
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
Enter new UNIX username: ace
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
ace  ALL=(ALL) NOPASSWD: ALL
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

# Install system packages.
apt install -y --no-install-recommends \
  ca-certificates curl git openssh-client p7zip-full tzdata \
  apt-file figlet file man-db manpages-dev strace tree vim wget xz-utils \
  automake build-essential ninja-build patchelf pax-utils perl swig yasm \
  lib{ncurses,readline,edit,icu,lzma,xml2}-dev zlib1g-dev \
  libc6-dev-i386 python3{,-distutils,-lib2to3}

# Update file database.
apt-file update

# Install CMake.
rm -rf /opt/cmake; mkdir -p /opt/cmake
curl -L https://github.com/Kitware/CMake/releases/download/v3.22.4/cmake-3.22.4-linux-x86_64.tar.gz -o cmake.tar.gz
tar xf cmake.tar.gz -C /opt/cmake --strip-components=1
echo 'export PATH="/opt/cmake/bin:${PATH}"' > /etc/profile.d/cmake.sh
chmod 0755 /etc/profile.d/cmake.sh

# Configure bash (optional).
curl -L https://raw.githubusercontent.com/qis/ace/master/src/bash.sh -o /etc/profile.d/bash.sh
chmod 0755 /etc/profile.d/bash.sh
rm -f /{root,home/ace}/.bashrc

# Log in as user
su - ace
```

Create Linux and WebAssembly archives.

<!--
mkdir /opt/ace/src /opt/ace/sys
ln -s /mnt/c/Ace/cmake /opt/ace/
ln -s /mnt/c/Ace/src/ports /opt/ace/src/
ln -s /mnt/c/Ace/src/tests /opt/ace/src/
ln -s /mnt/c/Ace/src/*.cmake /opt/ace/src/
ln -s /mnt/c/Ace/src/*.mk /opt/ace/src/
ln -s /mnt/c/Ace/sys/*.cmake /opt/ace/sys/
ln -s /mnt/c/Ace/makefile /opt/ace/
ln -s /mnt/c/Ace/*.cmake /opt/ace/
-->

```sh
# Configure git.
git config --global core.eol lf
git config --global core.autocrlf false
git config --global core.filemode false
git config --global pull.rebase false

# Create project directory.
sudo mkdir -p /opt/ace
sudo chown `id -u`:`id -g` /opt/ace

# Download project.
git clone https://github.com/qis/ace /opt/ace

# Enter project directory.
cd /opt/ace

# Create archives.
sh src/build.sh
```

Copy generated archives to the host system.

<details>
<summary>Docker</summary>

```sh
docker cp ace:/opt/ace/tools-linux.tar.gz tools-linux.tar.gz
docker cp ace:/opt/ace/tools-linux-clang-format.tar.gz tools-linux-clang-format.tar.gz
docker cp ace:/opt/ace/sys-x86_64-pc-linux-gnu.tar.gz sys-x86_64-pc-linux-gnu.tar.gz
docker cp ace:/opt/ace/sys-x86_64-pc-linux-gnu-ports.tar.gz sys-x86_64-pc-linux-gnu-ports.tar.gz
docker cp ace:/opt/ace/sys-wasm32-wasi.tar.gz sys-wasm32-wasi.tar.gz
```

</details>

<details>
<summary>WSL</summary>

```cmd
copy "\\wsl$\Debian\opt\ace\tools-linux.tar.gz" tools-linux.tar.gz
copy "\\wsl$\Debian\opt\ace\tools-linux-clang-format.tar.gz" tools-linux-clang-format.tar.gz
copy "\\wsl$\Debian\opt\ace\sys-x86_64-pc-linux-gnu.tar.gz" sys-x86_64-pc-linux-gnu.tar.gz
copy "\\wsl$\Debian\opt\ace\sys-x86_64-pc-linux-gnu-ports.tar.gz" sys-x86_64-pc-linux-gnu-ports.tar.gz
copy "\\wsl$\Debian\opt\ace\sys-wasm32-wasi.tar.gz" sys-wasm32-wasi.tar.gz
```

</details>

## Build: Windows
Create a Windows VM or adjust the [src/build.wsb](src/build.wsb) file to build in a [Windows Sandbox][wsb].

Install tools and make sure that they are added to the `PATH` environment variable.

* [7-Zip][p7z]
* [CMake][cmk]
* [Conan][con]
* [Perl 5][pl5]
* [Python 3][py3]

Install [Git][git] and select the following options during setup:
- Select Components<br/>
  ☑ Git LFS (Large File Support)
- Adjust the name of the initial branch in new repositories<br/>
  ◉ Override the default branch name for new repositories: master
- Adjusting your PATH environment<br/>
  ◉ Git from the command line and also from 3rd-party software
- Configuring the line ending conversions<br/>
  ◉ Checkout as-is, commit as-is
- Configuring the terminal emulator to use with Git Bash<br/>
  ◉ Use Windows' default console window
- Choose a credential helper<br/>
  ◉ None
- Configuring extra options<br/>
  ☑ Enable file system caching<br/>
  ☑ **Enable symbolic links**

Install [Visual Studio 2022][vsc] and select the "**Desktop development with C++**"
package in the left pane. Remove all default selections in the right pane except:
- "**MSVC v143 - VS 2022 C++ x64/x86 build tools**" (default)
- "**C++ ATL for latest v143 build tools**" (default)
- "**Windows 11 SDK**" (latest version)

Create Windows archives.

```cmd
rem Configure git.
git config --global core.eol lf
git config --global core.autocrlf false
git config --global core.filemode false
git config --global pull.rebase false

rem Download project.
git clone https://github.com/qis/ace C:\Ace

rem Enter project directory.
cd C:\Ace

rem Bootstrap sysroot.
cmake -P src/stage.cmake

rem Create tools archive.
make tools

rem Create clang-format archive.
make clang-format

rem Create sysroot archive.
make sys

rem Register toolchain.
set PATH=C:\Ace\sys\x86_64-pc-windows-msvc\bin;%PATH%

rem Install ports.
make -C src/ports install

rem Check ports linkage.
make -C src/ports check

rem Create ports archive.
make ports
```

Copy generated archives to the host system.

</details>

## Install
Install toolchain and runtime dependencies using the generated archives.

<details>
<summary>Linux</summary>

```sh
# Install system packages.
sudo apt install -y --no-install-recommends \
  ca-certificates curl dosfstools git openssh-client tzdata \
  apt-file file man-db manpages-dev p7zip-full tree vim wget xz-utils \
  binutils elfutils make ninja-build patchelf pax-utils strace yasm

# Update file database.
sudo apt-file update

# Install CMake.
sudo rm -rf /opt/cmake; sudo mkdir -p /opt/cmake
curl -L https://github.com/Kitware/CMake/releases/download/v3.22.4/cmake-3.22.4-linux-x86_64.tar.gz -o cmake.tar.gz
sudo tar xf cmake.tar.gz -C /opt/cmake --strip-components=1
echo 'export PATH="/opt/cmake/bin:${PATH}"' | sudo tee /etc/profile.d/cmake.sh >/dev/null
sudo chmod 0755 /etc/profile.d/cmake.sh
. /etc/profile.d/cmake.sh

# Configure bash (optional).
sudo curl -L https://raw.githubusercontent.com/qis/ace/master/src/bash.sh -o /etc/profile.d/bash.sh
sudo chmod 0755 /etc/profile.d/bash.sh
sudo rm -f /root/.bashrc
rm -f ~/.bashrc

# Register toolchain.
echo 'export ACE="/opt/ace"' | sudo tee /etc/profile.d/ace.sh >/dev/null
sudo chmod 0755 /etc/profile.d/ace.sh
. /etc/profile.d/ace.sh

# Configure git (optional).
git config --global core.eol lf
git config --global core.autocrlf false
git config --global core.filemode false
git config --global pull.rebase false

# Create project directory.
sudo mkdir -p /opt/ace
sudo chown `id -u`:`id -g` /opt/ace

# Download project.
git clone https://github.com/qis/ace /opt/ace

# Enter project directory.
cd /opt/ace

# Extract tools archive.
tar xf tools-linux.tar.gz
```

For Windows cross-compilation, the `/opt/ace/sys/x86_64-pc-windows-msvc` directory must
reside on a case-insensitive filesystem (or be a symlink to a Windows directory in WSL).

```sh
# Create filesystem image file (adjust size as needed).
dd if=/dev/zero of=sys/x86_64-pc-windows-msvc.img bs=1M count=2048

# Create filesystem.
mkfs.fat -F 32 sys/x86_64-pc-windows-msvc.img

# Create mount point.
mkdir sys/x86_64-pc-windows-msvc

# Mount image.
sudo mount -t vfat -o umask=0022,uid=`id -u`,gid=`id -g` \
  sys/x86_64-pc-windows-msvc.img sys/x86_64-pc-windows-msvc
```

<!--
```sh
# Check if the kernel supports case-insensitive filesystems.
cat /sys/fs/ext4/features/casefold
cat /sys/fs/unicode/version

# Create case-insensitive filesystem on a spare drive.
# mkfs -t ext4 -O casefold /dev/<device>

# Verify case-insensitive filesystem.
# dumpe2fs -h /dev/<device> | grep 'Filesystem features'

# Mount case-insensitive filesystem.
# mkdir -p /opt/ace/sys/x86_64-pc-windows-msvc
# mount /dev/<device> /opt/ace/sys/x86_64-pc-windows-msvc
```
-->

</details>

<details>
<summary>Windows</summary>

Install tools and make sure that they are added to the `PATH` environment variable.

* [7-Zip][p7z]
* [CMake][cmk]
* [Microsoft Visual C++ Redistributable][vcr]

Install [Git][git] and select the following options during setup:
- Select Components<br/>
  ☑ Git LFS (Large File Support)
- Adjust the name of the initial branch in new repositories<br/>
  ◉ Override the default branch name for new repositories: master
- Adjusting your PATH environment<br/>
  ◉ Git from the command line and also from 3rd-party software
- Configuring the line ending conversions<br/>
  ◉ Checkout as-is, commit as-is
- Configuring the terminal emulator to use with Git Bash<br/>
  ◉ Use Windows' default console window
- Choose a credential helper<br/>
  ◉ None
- Configuring extra options<br/>
  ☑ Enable file system caching<br/>
  ☑ **Enable symbolic links**

```cmd
rem Configure git (optional).
git config --global core.eol lf
git config --global core.autocrlf false
git config --global core.filemode false
git config --global pull.rebase false

rem Download project.
git clone https://github.com/qis/ace C:\Ace

rem Enter project directory.
cd C:\Ace

rem Extract tools archive.
tar xf tools-windows.tar.gz
```

Register toolchain.

* Set the `ACE` environment variable to `C:\Ace`.
* Add `C:\Ace` to `PATH` environment variable (for [make.cmd](make.cmd)).
* Add `C:\Ace\sys\x86_64-pc-windows-msvc\bin` to `PATH` environment variable.
* Set the `VSCMD_SKIP_SENDTELEMETRY` environment variable to `1`.

</details>

Extract sysroot and ports archives.

```
tar xf sys-x86_64-pc-linux-gnu.tar.gz
tar xf sys-x86_64-pc-linux-gnu-ports.tar.gz
tar xf sys-x86_64-pc-windows-msvc.tar.gz
tar xf sys-x86_64-pc-windows-msvc-ports.tar.gz
tar xf sys-wasm32-wasi.tar.gz
```

## Ports
The [src/ports/readme.md](src/ports/readme.md) file describes how to add new ports.

## Runtime Dependencies
Linux runtime dependencies for binaries compiled with this toolchain in **Release** mode.

* `kernel (>= 5.10)` - Linux kernel
* `libc6 (>= 2.31)` - GNU libc
* `sys/x86_64-pc-linux-gnu/lib/*.so` - Ports libraries

Windows runtime dependencies for binaries compiled with this toolchain in **Release** mode.

* [Microsoft Visual C++ Redistributable][vcr]
* `C:\Ace\sys\x86_64-pc-windows-msvc\bin\*.dll` - Ports libraries

Ports libraries are only required if `BUILD_SHARED_LIBS` was enabled during configuration.

## Usage
Use a [CMakePresets.json][cmp] file to configure projects in Visual Studio and VS Code.

* [`src/tests/lib/CMakePresets.json`](src/tests/lib/CMakePresets.json) (Linux and Windows)
* [`src/tests/web/CMakePresets.json`](src/tests/web/CMakePresets.json) (WebAssembly)

[lto]: https://clang.llvm.org/docs/ThinLTO.html
[abi]: https://abi-laboratory.pro/?view=timeline&l=glibc
[lts]: https://www.kernel.org/category/releases.html
[wsl]: https://docs.microsoft.com/en-us/windows/wsl/
[wsb]: https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-overview
[p7z]: https://www.7-zip.org/
[cmk]: https://cmake.org/download/
[con]: https://conan.io/downloads.html
[pl5]: https://strawberryperl.com/
[py3]: https://www.python.org/downloads/windows/
[git]: https://git-scm.com/download/win
[vsc]: https://visualstudio.microsoft.com/downloads/
[vcr]: https://aka.ms/vs/17/release/vc_redist.x64.exe
[cmp]: https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html

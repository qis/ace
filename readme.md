# ACE
Toolchain for native Linux and Windows development.

* Uses Clang and libc++.
* Uses Debian GCC and MinGW UCRT sysroots.
* Uses [Vcpkg][vcp] to build third party libraries.
* Each platform has a `static` and `shared` vcpkg triplet associated with it.
* Enables [ThinLTO][lto] for the C++ runtime and third party libraries.
* Disables LTO for static libraries built with `shared` triplets.

## Dependencies
Runtime dependencies for building and using this toolchain.

```sh
# Install debian packages.
# Replace with equivalent packages for other linux distributions.
apt install -y --no-install-recommends \
  ca-certificates curl git openssh-client sudo tar tzdata unzip xz-utils zip \
  autoconf automake debootstrap libtool make patchelf perl pkg-config python3 strace \
  libatomic1 libc6 libgcc-s1

# Install debian packages for windows development.
# Replace with equivalent proton versions for graphics development.
apt install -y --no-install-recommends wine wine64 fonts-wine
```

Runtime dependencies for binaries compiled using this toolchain.

* `kernel (>= 5.10)` - Linux kernel
* `libatomic1 (>= 10.2.1)` - GCC libatomic
* `libc6 (>= 2.31)` - GNU libc

## Toolchain
Install toolchain.

```sh
# Make project directory.
sudo mkdir /opt/ace
sudo chown $(id -u):$(id -g) /opt/ace

# Clone project repository.
git clone https://github.com/qis/ace /opt/ace
cd /opt/ace

# Create toolchain archive.
sudo src/build

# Clean project directory.
sudo src/build clean

# Extract toolchain archive.
XZ_OPT="-T16 -9v" tar xJf ace.tar.xz
```

## Libraries
Install third party libraries.

```sh
# Install vcpkg.
git clone --depth 1 --single-branch https://github.com/Microsoft/vcpkg
vcpkg/bootstrap-vcpkg.sh -disableMetrics

# Install ports.
src/vcpkg install

# Create ports archive (optional).
XZ_OPT="-T16 -9v" tar cJf ports.tar.xz --exclude="vcpkg/installed/vcpkg" vcpkg/installed
```

## Linux Sysroot
The **Debian 11 (Bullseye)** sysroot should result in binary compatibility with:

- Ubuntu 22.04 (Jammy Jellyfish)
- Red Hat Enterprise Linux 9
- Альт Сервер 10

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

See [ABI Laboratory][abi] and the [Longterm Release Kernels][lts] list for more information.

## License
This is free and unencumbered software released into the public domain.

```
Anyone is free to copy, modify, publish, use, compile, sell, or distribute
this software, either in source code form or as a compiled binary, for any
purpose, commercial or non-commercial, and by any means.

In jurisdictions that recognize copyright laws, the author or authors of
this software dedicate any and all copyright interest in the software to
the public domain. We make this dedication for the benefit of the public
at large and to the detriment of our heirs and successors. We intend this
dedication to be an overt act of relinquishment in perpetuity of all
present and future rights to this software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

Binaries compiled with this toolchain must be distributed under the following conditions.

1. Linux: GCC Runtime Library<br/>
   No license needed (GCC Runtime Library Exception)

2. Windows: MinGW-w64 Runtime Library<br/>
   [src/copyright/mingw.txt](src/copyright/mingw.txt)

3. LLVM Runtime Libraries<br/>
   [src/copyright/llvm.txt](src/copyright/llvm.txt)

4. Backtrace Library<br/>
   [src/copyright/backtrace.txt](src/copyright/backtrace.txt)

5. Third Party Libraries<br/>
   `vcpkg/installed/*/share/*/copyright`


## Development
Instructions on how to create a minimal development environment in a virtual machine.

<details>

Create a virtual machine.

```sh
# Create disk image.
mkdir qemu
qemu-img create -f qcow2 qemu/debian.qcow 50G

# Download debian image.
curl -L https://cdimage.debian.org/cdimage/release/11.7.0/amd64/iso-cd/debian-11.7.0-amd64-netinst.iso -o qemu/debian.iso

# Install debian using defaults where appropriate.
# During software selection, pick only "SSH server" and "standard system utilities".
qemu-system-x86_64 -hda qemu/debian.qcow -m 20480 -enable-kvm -cpu host -smp 16 \
  -boot d -cdrom qemu/debian.iso

# Boot system.
qemu-system-x86_64 -hda qemu/debian.qcow -m 20480 -enable-kvm -cpu host -smp 16 \
  -device e1000,netdev=net0 -netdev user,id=net0,hostfwd=tcp::5555-:22

# Log in as user.
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 5555 localhost

# Update system and install sudo(1).
su -c "apt update && apt upgrade -y && apt autoremove -y --purge && apt install -y sudo" -

# Add user to the sudo group.
su -c "gpasswd -a $(id -un) sudo"

# Log out.
exit

# Log in as user.
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 5555 localhost

# Configure git.
git config --global core.eol lf
git config --global core.autocrlf false
git config --global core.filemode false
git config --global pull.rebase false
```

Follow [Dependencies](#dependencies) and [Toolchain](#toolchain) instructions.

```sh
# Check for rpath defects.
sudo src/build check

# Delete check directory.
sudo rm -rf check
```

Follow [Libraries](#libraries) instructions.

```sh
# Build and run tests.
src/vcpkg test

# Delete tests directory.
rm -rf tests
```

Verify binaries on host.

```sh
# Copy toolchain archive.
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -P 5555 \
  localhost:/opt/ace/ace.tar.xz /opt/ace/

# Copy ports archive.
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -P 5555 \
  localhost:/opt/ace/ports.tar.xz /opt/ace/

# Shutdown virtual machine.
sudo halt -p

# Reset project directory.
sudo src/build reset

# Extract toolchain archive.
XZ_OPT="-T16 -9v" tar xJf ace.tar.xz

# Extract ports archive.
XZ_OPT="-T16 -9v" tar xJf ports.tar.xz

# Build and run tests.
src/vcpkg test

# Delete tests directory.
rm -rf tests

# Delete virtual machine.
rm -rf qemu
```

</details>

Instructions on how to add a port.

<details>

Use the `luajit` port as an example.

```sh
# Create backup.
rm -f vcpkg.tar.xz
XZ_OPT="-T16 -9v" tar cJf vcpkg.tar.xz vcpkg

# Search for port using vcpkg.
vcpkg/vcpkg search luajit

# Inspect dependencies and choose features.
vim vcpkg/ports/luajit/vcpkg.json

# Add "luajit" to the PORTS variable in src/vcpkg.
vim src/vcpkg

# Try to install port.
src/vcpkg install luajit

# If the installation failed and the problem can be solved with
# a simple triplet override, modify src/ports.cmake.
vim src/ports.cmake

# If the installation failed and the build process must be altered,
# create a copy of the port directory in src/ports and edit it.
cp -R vcpkg/ports/luajit src/ports/
vim src/ports/luajit/portfile.cmake

# If the installation failed and the port needs to be patched,
# install it in editable mode until it works.
src/vcpkg --editable install luajit

# Optional: Create a patch and add it to the portfile.
cmake/bin/cmake -E chdir vcpkg/buildtrees/luajit/src \
  diff -ruNp f34f7265aa-eb31d8cee1.clean f34f7265aa-eb31d8cee1 \
  > src/ports/luajit/0001-clang-fixes.patch
vim src/ports/luajit/portfile.cmake

# Clean vcpkg directory.
src/vcpkg clean

# Install port to verify the dependency graph.
src/vcpkg --recurse install luajit

# Create tests.
cp -R src/tests/zlib src/tests/luajit
vim src/tests/luajit/config.cmake
vim src/tests/luajit/main.cpp

# Build and run tests.
src/vcpkg test luajit

# Create commit.
git diff
git status
git add src/vcpkg src/ports.cmake src/ports src/tests
git commit -m "added port: luajit"
git push
```

</details>

[vcp]: https://vcpkg.io/
[lto]: https://clang.llvm.org/docs/ThinLTO.html
[abi]: https://abi-laboratory.pro/?view=timeline&l=glibc
[lts]: https://www.kernel.org/category/releases.html

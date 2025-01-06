# ACE
Toolchain for portable C++ game engine development.

```
Supported Targets: Linux, MinGW
Supported Architectures: x86_64
Linux Sysroot: Debian 11
MinGW Runtime: UCRT
```

## Dependencies
Install dependencies and configure the operating system.

### Windows
1. Install [Git][git].
2. Install [CMake][cmk].
3. Install [Vulakn SDK][sdk].
4. Install [WiX Toolset][wix].
5. Install [7-zip][zip].
6. Create toolchain directory.

```cmd
md C:\Ace
```

### WSL
1. Create a [WSL][wsl] configuration file: `%UserProfile%\.wslconfig`

```ini
[wsl2]
kernelCommandLine=vsyscall=emulate
memory=18GB
```

2. Configure the system in PowerShell as **administrator**.

<!--
# Remove existing WSL distribution.
wsl --shutdown Debian
wsl --unregister Debian
-->

```ps1
# Show known file extensions in Explorer.
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0

# Show hidden files in Explorer.
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1

# Enable NTFS paths with length over 260 characters.
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWord -Value 1

# Enable WSL support.
dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Install WSL distribution if it is not already installed.
# wsl --install --distribution Debian

# Update WSL distribution if it is already installed.
# wsl --shutdown
# wsl --update
```

3. Reboot the system.
4. Log in and finish the WSL installation if prompted.
5. Execute `wsl -s Debian` on the Command Line if you want Debian to be the default WSL distribution.
6. Execute `wsl -d Debian` on the Command Line to start WSL.
7. Configure the WSL distribution.

```sh
# Symlink Wayland socket.
mkdir -p ~/.config/systemd/user

tee ~/.config/systemd/user/symlink-wayland-socket.service >/dev/null <<'EOF'
[Unit]
Description=Symlink Wayland socket to XDG_RUNTIME_DIR

[Service]
Type=oneshot
ExecStart=/usr/bin/ln -s /mnt/wslg/runtime-dir/wayland-0 ${XDG_RUNTIME_DIR}/
ExecStart=/usr/bin/ln -s /mnt/wslg/runtime-dir/wayland-0.lock ${XDG_RUNTIME_DIR}/

[Install]
WantedBy=default.target
EOF

systemctl --user --now enable symlink-wayland-socket
```

8. Follow Linux (Debian) instructions below.

### Linux
1. Update system and install dependencies.

```sh
# Debian
sudo apt update
sudo apt upgrade -y
sudo apt autoremove --purge -y
sudo apt clean

sudo apt install -y \
  xz-utils wine pkg-config vulkan-validationlayers libncurses6 \
  man-db manpages manpages-dev xdg-user-dirs

# Gentoo
sudo emaint sync -a
sudo emerge -auUD @world
sudo emerge -ac

sudo emerge -avn \
  app-arch/xz-utils \
  app-emulation/wine-proton \
  dev-util/pkgconf \
  media-libs/vulkan-layers \
  sys-libs/ncurses \
  x11-misc/xdg-user-dirs
```

<!--
# Configure git(1).
USERPROFILE="$(wslpath $(cmd.exe /c '<nul set /p=%UserProfile%' 2>/dev/null))"
ln -s ${USERPROFILE}/.gitconfig ~/.gitconfig

# Configure ssh(1).
mkdir -p ~/.ssh
chmod 0700 ~/.ssh
cp ${USERPROFILE}/.ssh/config ~/.ssh/
cp ${USERPROFILE}/.ssh/id_rsa ~/.ssh/
cp ${USERPROFILE}/.ssh/id_rsa.pub ~/.ssh/
cp ${USERPROFILE}/.ssh/known_hosts ~/.ssh/
chmod 0600 ~/.ssh/*

# Install apt-file(1).
sudo apt install -y apt-file
sudo apt-file update
-->

2. Install [CMake][cmk].

```sh
# Download archive.
curl -L https://github.com/Kitware/CMake/releases/download/v3.31.3/cmake-3.31.3-linux-x86_64.tar.gz \
     -o /tmp/cmake.tar.gz

# Extract archive.
sudo mkdir /opt/cmake
sudo tar xf /tmp/cmake.tar.gz -C /opt/cmake -m --strip-components=1

# Create environment variables.
sudo tee /etc/profile.d/cmake.sh >/dev/null <<'EOF'
export PATH="/opt/cmake/bin:${PATH}"
EOF

sudo chmod 0755 /etc/profile.d/cmake.sh
source /etc/profile.d/cmake.sh
```

3. Configure `wine(1)`.

```sh
winecfg
wine
```

<!--
4. Install and use `foot(1)` and `xterm(1)` to test Wayland and Xorg support.
-->

## Build
1. Install build dependencies.

```sh
# Debian
sudo apt install -y \
  git curl debootstrap sudo make nasm unzip zip

# Gentoo
sudo emerge -avn \
  dev-vcs/git \
  net-misc/curl \
  dev-util/debootstrap \
  app-admin/sudo \
  dev-build/make \
  dev-lang/nasm \
  app-arch/unzip \
  app-arch/zip
```

2. Download source code and build toolchain.

```sh
# Create toolchain directory.
sudo mkdir /opt/ace
sudo chown $(id -u):$(id -g) /opt/ace

# Clone toolchain repository.
git clone https://github.com/qis/ace /opt/ace

# Build toolchain.
cd /opt/ace && sh src/build.sh

# Copy archives to Downloads directories.
cp /opt/ace/build/ace.7z "$(xdg-user-dir DOWNLOADS)/"
cp /opt/ace/build/ace.tar.xz "$(xdg-user-dir DOWNLOADS)/"
if [ -x "$(which wslpath)" ] && [ -x "$(which cmd.exe)" ]; then
  DOWNLOADS="$(wslpath $(cmd.exe /c '<nul set /p=%UserProfile%\Downloads' 2>/dev/null))"
  cp /opt/ace/build/ace.tar.xz "${DOWNLOADS}/"
  cp /opt/ace/build/ace.7z "${DOWNLOADS}/"
fi
```

<!--
# Clone toolchain repository.
git clone git@github.com:qis/ace /opt/ace
-->

## Install
Use archives from the build step to install the toolchain.

### Windows
Install toolchain on Windows.

```bat
rem Create directory.
md C:\Ace

rem Extract archive.
7z x "%UserProfile%\Downloads\ace.7z" -oC:\Ace
```

### Linux
Install toolchain on Linux (in case it was built on another system).

```sh
# Create directory.
sudo mkdir -p /opt/ace
sudo chown $(id -u):$(id -g) /opt/ace

# Extract archive.
tar xf "$(xdg-user-dir DOWNLOADS)/ace.tar.xz" -C /opt/ace
```

## Usage
1. See [doc/editor.md](doc/editor.md) for editor configuration instructions.
2. See [src/template](src/template) for a template project.

## License
This software is available under the "MIT No Attribution" license.

```
Copyright 2024 Alexej Harm

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
   [src/template/res/license.txt](src/template/res/license.txt)

3. LLVM Runtime Libraries<br/>
   [src/template/res/license.txt](src/template/res/license.txt)

4. Ports Libraries<br/>
   `ports/*/share/*/copyright`

[git]: https://git-scm.com/
[cmk]: https://cmake.org/download/
[sdk]: https://vulkan.lunarg.com/sdk/home
[wix]: https://github.com/wixtoolset/wix3/releases
[wsl]: https://learn.microsoft.com/windows/wsl/
[zip]: https://www.7-zip.org/

# Build
Update system and install dependencies.

<details>
<summary>Debian</summary>

```sh
# Update system.
sudo apt update
sudo apt upgrade -y
sudo apt autoremove --purge -y
sudo apt clean

# Install dependencies.
sudo apt install -y curl debootstrap git sudo
```

</details>

<details>
<summary>Gentoo</summary>

```sh
# Update system.
emaint sync -a
emerge -auUD @world
emerge -ac

# Install dependencies.
sudo emerge -avn app-admin/sudo dev-util/debootstrap dev-vcs/git net-misc/curl
```

</details>

<details>
<summary>Windows</summary>

1. Install [Git][git].
2. Install [CMake][cmk].
3. Create a [WSL][wsl] configuration file: `%UserProfile%\.wslconfig`

```ini
[wsl2]
kernelCommandLine=vsyscall=emulate
memory=18GB
```

4. Configure the system in PowerShell as **administrator**.

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

# Update WSL if it is already installed.
# wsl --shutdown
# wsl --update

# Install WSL distribution.
wsl --install --distribution Debian
```

5. Reboot the system.
6. Log in and finish the WSL installation if prompted.
7. Execute `wsl -d Debian` in the Command Line if WSL was already installed.
8. Execute `wsl -s Debian` in the Command Line if you want Debian to be the default WSL distribution.
9. Update the WSL distribution and install dependencies.

```sh
# Update system.
sudo apt update
sudo apt upgrade -y
sudo apt autoremove --purge -y
sudo apt clean

# Install dependencies.
sudo apt install -y curl debootstrap git sudo

# Symlink Wayland socket.
mkdir -p ~/.config/systemd/user

tee ~/.config/systemd/user/symlink-wayland-socket.service >/dev/null <<'EOF'
[Unit]
Description=Symlink Wayland socket to XDG_RUNTIME_DIR

[Service]
Type=oneshot
ExecStart=/usr/bin/ln -s /mnt/wslg/runtime-dir/wayland-0      $XDG_RUNTIME_DIR
ExecStart=/usr/bin/ln -s /mnt/wslg/runtime-dir/wayland-0.lock $XDG_RUNTIME_DIR

[Install]
WantedBy=default.target
EOF

systemctl --user enable symlink-wayland-socket
systemctl --user start symlink-wayland-socket

# Install terminal emulators to test Xorg and Wayland support.
sudo apt install -y xterm foot
```

</details>

Download source code and build toolchain.

```sh
# Create toolchain directory.
sudo mkdir /opt/ace
sudo chown $(id -u):$(id -g) /opt/ace

# Clone toolchain repository.
git clone https://github.com/qis/ace /opt/ace

# Build toolchain.
sh /opt/ace/src/build.sh
```

This will create the archives:
* `/opt/ace/ace-<version>.tar.xz` for Linux
* `/opt/ace/ace-<version>.7z` for Windows

## C++ Modules
Currently, the [src/build.sh](../src/build.sh) script downloads and builds LLVM
from the master branch on GitHub for better C++ modules support.

```sh
# Download sources for the master branch.
download_git "llvm" "${LLVM_GIT}" "main" "build/src" "llvm/CMakeLists.txt"
LLVM_RES="lib/clang/20"
```

If this is not desired, replace the lines above with the following snippet.

```sh
# Download sources for the release version.
download_git "llvm" "${LLVM_GIT}" "${LLVM_TAG}" "build/src" "llvm/CMakeLists.txt"
```

[git]: https://git-scm.com/
[cmk]: https://cmake.org/download/
[wsl]: https://learn.microsoft.com/windows/wsl/

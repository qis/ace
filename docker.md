# ACE Docker
Installation instructions for a minimal Ubuntu 20.04 docker image.

## Requirements
Install `docker(1)`.

```sh
sudo apt install -y docker.io
sudo usermod -aG docker $(id -un)
```

## Build
Build toolchain.

```sh
# Create container.
docker run -it -h ace --name ace ubuntu:20.04

# Configure system.
export DEBIAN_FRONTEND=noninteractive
useradd -s /bin/bash -d /home/user -m -G users user

# Update system.
apt update && apt upgrade -y

# Install dependencies.
apt install -y --no-install-recommends \
  ca-certificates git make patch python tzdata wget xz-utils \
  python{,-simplejson,-six} msitools libgcab-1.0-0 \
  build-essential ninja-build patchelf python3{,-distutils} \
  libedit-dev libpfm4-dev liblzma-dev libxml2-dev zlib1g-dev

# Install CMake.
rm -rf /opt/cmake; mkdir -p /opt/cmake
wget https://github.com/Kitware/CMake/releases/download/v3.20.0/cmake-3.20.0-Linux-x86_64.tar.gz
tar xf cmake-3.20.0-Linux-x86_64.tar.gz -C /opt/cmake --strip-components=1
echo 'export PATH="/opt/cmake/bin:${PATH}"' > /etc/profile.d/cmake.sh
chmod 0755 /etc/profile.d/cmake.sh

# Create directories.
mkdir -p /opt/ace
chown user:user /opt/ace

# Log in as user.
su - user

# Download toolchain.
git clone https://github.com/qis/ace /opt/ace
cd /opt/ace

# Build toolchain.
make download stage llvm msvc libs

# Create package.
tar cJf ace.tar.xz bin include lib msvc

# Log out.
exit

# Exit container.
exit

# Copy package.
docker cp ace:/opt/ace/ace.tar.xz ace.tar.xz

# Remove container.
docker rm ace
```

<details>
<summary><b>Test</b></summary>

Test toolchain.

```sh
# Create container.
docker create -it -h ace --name ace ubuntu:20.04

# Copy package.
docker cp . ace:/ace

# Start container.
docker start ace

# Enter container.
docker exec -it ace bash

# Configure system.
export DEBIAN_FRONTEND=noninteractive
useradd -s /bin/bash -d /home/user -m -G users user

# Update system.
apt update && apt upgrade -y

# Install dependencies.
apt install -y --no-install-recommends \
  ca-certificates git make tzdata wget xz-utils \
  libc6-dev libpfm4 libedit2 liblzma5 libxml2 zlib1g ninja-build wine wine64

update-alternatives --install /usr/bin/wine wine /usr/bin/wine64-stable 100
update-alternatives --install /usr/bin/winedbg winedbg /usr/bin/winedbg-stable 100

# Install CMake.
rm -rf /opt/cmake; mkdir -p /opt/cmake
wget https://github.com/Kitware/CMake/releases/download/v3.20.0/cmake-3.20.0-Linux-x86_64.tar.gz
tar xf cmake-3.20.0-Linux-x86_64.tar.gz -C /opt/cmake --strip-components=1
echo 'export PATH="/opt/cmake/bin:${PATH}"' > /etc/profile.d/cmake.sh
chmod 0755 /etc/profile.d/cmake.sh

# Extract package.
tar xf /ace/ace.tar.xz -C /ace
echo 'export ACE="/ace"' > /etc/profile.d/ace.sh
chmod 0755 /etc/profile.d/ace.sh

# Log in as user.
su - user

# Check out test project.
git clone https://github.com/qis/ace-test ace-test

# Run tests.
cd ace-test && make check ace msvc

# Log out.
exit

# Exit container.
exit

# Stop container.
docker stop ace

# Remove container.
docker rm ace
```

Other useful `docker(1)` commands.

```sh
# Kill container.
docker kill ace

# List containers.
docker container ls -a

# List running containers.
docker ps
```

</details>

## Install
Install toolchain.

```sh
# Update system.
sudo apt update && sudo apt upgrade -y

# Install dependencies.
sudo apt install -y --no-install-recommends \
  ca-certificates git make tzdata wget xz-utils \
  libc6-dev libpfm4 libedit2 liblzma5 libxml2 zlib1g ninja-build wine64

sudo update-alternatives --remove-all wine
sudo update-alternatives --remove-all winedbg
sudo update-alternatives --install /usr/bin/wine wine /usr/bin/wine64-stable 100
sudo update-alternatives --install /usr/bin/winedbg winedbg /usr/bin/winedbg-stable 100

# Install CMake.
sudo rm -rf /opt/cmake; sudo mkdir -p /opt/cmake
wget https://github.com/Kitware/CMake/releases/download/v3.20.0/cmake-3.20.0-Linux-x86_64.tar.gz
sudo tar xf cmake-3.20.0-Linux-x86_64.tar.gz -C /opt/cmake --strip-components=1
echo 'export PATH="/opt/cmake/bin:${PATH}"' | sudo tee /etc/profile.d/cmake.sh >/dev/null
sudo chmod 0755 /etc/profile.d/cmake.sh
. /etc/profile.d/cmake.sh

# Install toolchain.
sudo rm -rf /opt/ace; sudo mkdir -p /opt/ace
sudo chown $(id -u):$(id -g) /opt/ace
git clone . /opt/ace
tar xf ace.tar.xz -C /opt/ace
echo 'export ACE="/opt/ace"' | sudo tee /etc/profile.d/ace.sh >/dev/null
sudo chmod 0755 /etc/profile.d/ace.sh
. /etc/profile.d/ace.sh
```

<details>
<summary><b>Benchmark</b></summary>

Build and install third party libraries to an external location with a different toolchain.

```sh
make download/libs
cmake -E copy_directory cmake /opt/llvm/cmake
make LLVM=/opt/llvm LLVM_TOOLCHAIN=/opt/llvm/toolchain.cmake fmt/llvm lz4/llvm benchmark/llvm doctest/llvm
make clean
```

The corresponding <https://github.com/qis/ace-test> make target is `llvm`.

</details>

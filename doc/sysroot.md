# Sysroot
Choosing a Linux distribution for a development sysroot.

| Distribution                          |     Release    |    Support     |    Extended    | Linux    | GNU libc |
|---------------------------------------|:--------------:|:--------------:|:--------------:|----------|----------|
|   Debian 8 (Jessie)                   |   2015-04-25   |   2020-06-30   |   2025-06-30   |   3.16   |   2.19   |
|   Debian 9 (Stretch)                  |   2017-07-17   |   2022-06-30   |   2027-06-30   |   4.9    |   2.24   |
|   Debian 10 (Buster)                  |   2019-06-06   |   2024-06-30   |   2029-06-30   |   4.19   |   2.28   |
| **Debian 11 (Bullseye)**              | **2021-08-14** | **2026-06-30** | **2031-06-30** | **5.10** | **2.31** |
|   Debian 12 (Bookworm)                |   2023-06-10   |   2028-06-30   |   2033-06-30   |   6.1    |   2.36   |
|   Linux Mint 20 (Ulyana)              |   2020-06-27   |   2025-04-31   |       NA       |   5.4    |   2.31   |
|   Linux Mint 21 (Vanessa)             |   2022-07-31   |   2027-04-31   |       NA       |   5.15   |   2.35   |
|   openSUSE Leap 15.5                  |   2023-06-07   |   2024-12-31   |       NA       |   5.14   |   2.31   |
|   openSUSE Leap 15.6                  |   2024-06-12   |   2025-12-31   |       NA       |   6.4    |   2.38   |
|   Red Hat Enterprise Linux 7          |   2014-06-10   |   2024-06-30   |   2028-06-30   |   3.10   |   2.17   |
|   Red Hat Enterprise Linux 8          |   2019-05-07   |   2029-05-31   |   2031-05-31   |   4.18   |   2.28   |
|   Red Hat Enterprise Linux 9          |   2022-11-08   |   2032-05-31   |   2034-05-31   |   5.14   |   2.34   |
|   Steam Linux Runtime 1.0 (Scout)     |   2019-10-30   |       NA       |       NA       |   3.2    |   2.15   |
|   Steam Linux Runtime 2.0 (Soldier)   |   2020-09-14   |       NA       |       NA       |   4.19   |   2.28   |
|   Steam Linux Runtime 3.0 (Sniper)    |   2021-05-05   |       NA       |       NA       |   5.10   |   2.31   |
|   SteamOS 3.0 (Holo)                  |   2022-03-01   |       NA       |       NA       |   6.1    |   2.37   |
|   Ubuntu 16.04 LTS (Xenial Xerus)     |   2016-04-21   |   2021-04-30   |   2026-04-23   |   4.4    |   2.23   |
|   Ubuntu 18.04 LTS (Bionic Beaver)    |   2018-04-26   |   2023-05-31   |   2028-04-26   |   4.15   |   2.27   |
|   Ubuntu 20.04 LTS (Focal Fossa)      |   2020-04-23   |   2025-05-29   |   2030-04-23   |   5.4    |   2.31   |
|   Ubuntu 22.04 LTS (Jammy Jellyfish)  |   2022-04-21   |   2027-06-01   |   2032-04-21   |   5.15   |   2.35   |
|   Ubuntu 24.04 LTS (Noble Numbat)     |   2024-04-25   |   2029-05-31   |   2034-04-25   |   6.8    |   2.39   |
|                                       |                |                |                |          |          |
|   ALT Linux (Альт Линукс) 9           |   2019-10-28   |   2023-12-31   |       NA       |   4.19   |   2.27   |
|   ALT Linux (Альт Линукс) 10          |   2021-12-30   |   2025-12-31   |       NA       |   5.10   |   2.32   |
|   Simply Linux (Симпли Линукс) 9      |   2020-08-02   |   2023-12-31   |       NA       |   5.4    |   2.27   |
|   Simply Linux (Симпли Линукс) 10     |   2021-12-30   |   2025-12-31   |       NA       |   5.10   |   2.32   |
|   Astra Linux (Астра Линукс) SE 1.7   |   2021-07-27   |       NA       |       NA       |   5.4    |   2.28   |
|   Astra Linux (Астра Линукс) SE 1.8   |   2024-04-24   |       NA       |       NA       |   6.1    |   2.36   |
|   ROSA Linux (РОСА Линукс) 12         |   2021-10-12   |       NA       |       NA       |   5.10   |   2.33   |
|   RED OS (РЕД ОС) 7.3                 |   2021-02-01   |       NA       |       NA       |   5.10   |   2.28   |
|   RED OS (РЕД ОС) 8.0                 |   2024-02-01   |       NA       |       NA       |   6.6    |   2.36   |
|                                       |                |                |                |          |          |
|   Arch Linux                          |   2024-07-01   |       NA       |       NA       |   6.9    |   2.39   |
|   Calculate Linux                     |   2024-07-24   |       NA       |       NA       |   6.6    |   2.39   |
|   Fedora Workstation                  |   2024-04-14   |       NA       |       NA       |   6.8    |   2.39   |
|   Manjaro Linux                       |   2024-07-02   |       NA       |       NA       |   6.9    |   2.39   |
|   openSUSE Tumbleweed                 |   2024-07-23   |       NA       |       NA       |   6.9    |   2.39   |

See [ABI Laboratory][abi] and the [Longterm Release Kernels][lts] list for more information.

1. According to the December 2024 Steam survey, Ubuntu 24.04 and Linux Mint 22 are the most relevant LTS distributions.
2. Less popular distributions are mostly covered by Ubuntu 22.04, which is based on Debian 12.
3. Linux Mint 21.3 and Pop!\_OS 22.04 LTS are based on Ubuntu 22.04.
4. Astra Linux CE 1.8.1 is based on Astra Linux SE 1.8.1.
5. Steam Linux Runtime 3.0 is based on Debian 11.
6. SteamOS 3.0 is based on Arch Linux.
7. Bazzite is based on Fedora Atomic.

## Distributions
This software was tested on the following Linux distributions:

* Arch Linux
* Debian (Testing)
* Debian 11 (Bullseye)
* Gentoo Linux (GNU C Library)
* Steam Linux Runtime 3.0 (Sniper)
* SteamOS 3.0 (Holo)

This software was tested on the following Russian Linux distributions:

* ALT Linux (Альт Линукс) 10
* Simply Linux (Симпли Линукс) 10
* Astra Linux (Астра Линукс) CE 1.8.1
* Calculate Linux (Scratch Edition)
* ROSA Linux (РОСА Линукс) 12
* RED OS (РЕД ОС) 8.0

<!--
This software will not be tested on the following russophobic Linux distributions:

* Ubuntu
* Fedora
* Red Hat
* openSUSE

```sh
# Debian 8 (Jessie)
sudo debootstrap --keyring=/usr/share/keyrings/debian-archive-removed-keys.gpg \
  --arch amd64 jessie ./jessie http://archive.debian.org/debian
sudo chroot jessie /usr/bin/apt show linux-libc-dev libc6

# Debian 9 (Stretch)
sudo debootstrap --keyring=/usr/share/keyrings/debian-archive-removed-keys.gpg \
  --arch amd64 stretch ./stretch http://archive.debian.org/debian
sudo chroot stretch /usr/bin/apt show linux-libc-dev libc6

# Debian 10 (Buster)
sudo debootstrap --arch amd64 buster ./buster http://deb.debian.org/debian/
sudo chroot buster /usr/bin/apt show linux-libc-dev libc6

# Debian 11 (Bullseye)
sudo debootstrap --arch amd64 bullseye ./bullseye http://deb.debian.org/debian/
sudo chroot bullseye /usr/bin/apt show linux-libc-dev libc6

# Debian 12 (Bookworm)
sudo debootstrap --arch amd64 bookworm ./bookworm http://deb.debian.org/debian/
sudo chroot bookworm /usr/bin/apt show linux-libc-dev libc6

# Linux Mint 20 (Ulyana)
wget https://mirrors.edge.kernel.org/linuxmint/stable/20/\
linuxmint-20-cinnamon-64bit.iso -O linux-mint-20.iso
sudo mkdir linux-mint-20 && sudo mount -r linux-mint-20.iso linux-mint-20
sudo mkdir linux-mint-20-fs && sudo unsquashfs -f -d ./linux-mint-20-fs linux-mint-20/casper/filesystem.squashfs
ls -l linux-mint-20-fs/lib/modules
sudo chroot linux-mint-20-fs /lib/x86_64-linux-gnu/libc.so.6
sudo umount linux-mint-20

# Linux Mint 21 (Vanessa)
wget https://mirrors.edge.kernel.org/linuxmint/stable/21/\
linuxmint-21-cinnamon-64bit.iso -O linux-mint-21.iso
sudo mkdir linux-mint-21 && sudo mount -r linux-mint-21.iso linux-mint-21
sudo mkdir linux-mint-21-fs && sudo unsquashfs -f -d ./linux-mint-21-fs linux-mint-21/casper/filesystem.squashfs
sudo chmod +x linux-mint-21-fs/usr/lib/x86_64-linux-gnu/libc.so.6
ls -l linux-mint-21-fs/lib/modules
sudo chroot linux-mint-21-fs /lib/x86_64-linux-gnu/libc.so.6
sudo umount linux-mint-21

# openSUSE Leap 15.5
wget https://download.opensuse.org/distribution/leap/15.5/iso/\
openSUSE-Leap-15.5-DVD-x86_64-Media.iso -O opensuse-leap-15.5.iso
sudo mkdir opensuse-leap-15.5 && sudo mount -r opensuse-leap-15.5.iso opensuse-leap-15.5
ls opensuse-leap-15.5/x86_64/ | grep ^kernel-default-
ls opensuse-leap-15.5/x86_64/ | grep ^glibc-
sudo umount opensuse-leap-15.5

# openSUSE Leap 15.6
wget https://download.opensuse.org/distribution/leap/15.6/iso/\
openSUSE-Leap-15.6-DVD-x86_64-Media.iso -O opensuse-leap-15.6.iso
sudo mkdir opensuse-leap-15.6 && sudo mount -r opensuse-leap-15.6.iso opensuse-leap-15.6
ls opensuse-leap-15.6/x86_64/ | grep ^kernel-default-
ls opensuse-leap-15.6/x86_64/ | grep ^glibc-
sudo umount opensuse-leap-15.6

# Red Hat Enterprise Linux 7
sudo mkdir rhel-7 && sudo mount -r rhel-server-7.0-x86_64-boot.iso rhel-7
sudo mkdir rhel-7-fs && sudo unsquashfs -f -d ./rhel-7-fs rhel-7/LiveOS/squashfs.img
sudo mkdir rhel-7-root && sudo mount -r rhel-7-fs/LiveOS/rootfs.img rhel-7-root
sudo chroot rhel-7-root /usr/lib64/libc.so.6
sudo umount rhel-7-root
sudo umount rhel-7

# Red Hat Enterprise Linux 8
sudo mkdir rhel-8 && sudo mount -r rhel-8.0-x86_64-boot.iso rhel-8
sudo mkdir rhel-8-fs && sudo unsquashfs -f -d ./rhel-8-fs rhel-8/images/install.img
sudo mkdir rhel-8-root && sudo mount -r rhel-8-fs/LiveOS/rootfs.img rhel-8-root
ls -l rhel-8-root/lib/modules
sudo chroot rhel-8-root /usr/lib64/libc.so.6
sudo umount rhel-8-root
sudo umount rhel-8

# Red Hat Enterprise Linux 9
sudo mkdir rhel-9 && sudo mount -r rhel-baseos-9.0-x86_64-boot.iso rhel-9
sudo mkdir rhel-9-fs && sudo unsquashfs -f -d ./rhel-9-fs rhel-9/images/install.img
sudo mkdir rhel-9-root && sudo mount -r rhel-9-fs/LiveOS/rootfs.img rhel-9-root
ls -l rhel-9-root/lib/modules
sudo chroot rhel-9-root /usr/lib64/libc.so.6
sudo umount rhel-9-root
sudo umount rhel-9

# Steam Linux Runtime 1.0 (Scout)
wget https://repo.steampowered.com/steamrt-images-scout/snapshots/0.20200720.0/\
com.valvesoftware.SteamRuntime.Sdk-i386-scout-sysroot.tar.gz -O scout.tar.gz
sudo mkdir scout && sudo tar xpf scout.tar.gz -C scout
# linux=$(sed -En 's/.*LINUX_VERSION_CODE\s+(.*)/\1/p' scout/usr/include/linux/version.h)
# major=$(perl -e "print (${linux} >> 16)")
# minor=$(perl -e "print (${linux} - (${major} << 16) >> 8)")
# patch=$(perl -e "print (${linux} - (${major} << 16) - (${minor} << 8))")
# echo "${major}.${minor}.${patch}"
sudo chroot scout /lib64/libc.so.6

# Steam Linux Runtime 2.0 (Soldier)
wget https://repo.steampowered.com/steamrt-images-soldier/snapshots/0.20200910.0/\
com.valvesoftware.SteamRuntime.Sdk-amd64%2Ci386-soldier-sysroot.tar.gz -O soldier.tar.gz
sudo mkdir soldier && sudo tar xpf soldier.tar.gz -C soldier
sudo chroot soldier /usr/bin/apt show linux-libc-dev libc6

# Steam Linux Runtime 3.0 (Sniper)
wget https://repo.steampowered.com/steamrt-images-sniper/snapshots/0.20220119.0/\
com.valvesoftware.SteamRuntime.Sdk-amd64%2Ci386-sniper-sysroot.tar.gz -O sniper.tar.gz
sudo mkdir sniper && sudo tar xpf sniper.tar.gz -C sniper
sudo chroot sniper /usr/bin/apt show linux-libc-dev libc6

# SteamOS 3.0 (Holo)
7z e -y steamdeck-repair-20231127.10-3.5.7.img -osteamos
sudo mkdir steamos-fs && sudo mount -r steamos/rootfs-A.img steamos-fs
ls -l steamos-fs/lib/modules
sudo chroot steamos-fs /usr/lib/libc.so.6
sudo umount steamos-fs

# Ubuntu 16.04 LTS (Xenial Xerus)
sudo debootstrap --arch amd64 xenial ./xenial http://archive.ubuntu.com/ubuntu/
sudo chroot xenial /usr/bin/apt show linux-libc-dev libc6

# Ubuntu 18.04 LTS (Bionic Beaver)
sudo debootstrap --arch amd64 bionic ./bionic http://archive.ubuntu.com/ubuntu/
sudo chroot bionic /usr/bin/apt show linux-libc-dev libc6

# Ubuntu 20.04 LTS (Focal Fossa)
sudo debootstrap --arch amd64 focal ./focal http://archive.ubuntu.com/ubuntu/
sudo chroot focal /usr/bin/apt show linux-libc-dev libc6

# Ubuntu 22.04 LTS (Jammy Jellyfish)
sudo debootstrap --arch amd64 jammy ./jammy http://archive.ubuntu.com/ubuntu/
sudo chroot jammy /usr/bin/apt show linux-libc-dev libc6

# Ubuntu 24.04 LTS (Noble Numbat)
sudo debootstrap --arch amd64 noble ./noble http://archive.ubuntu.com/ubuntu/ gutsy
sudo chroot noble /usr/bin/apt show linux-libc-dev libc6

# Альт Сервер 9
wget https://download.basealt.ru/pub/distributions/ALTLinux/p9/images/server/x86_64/\
alt-server-9.0-x86_64.iso -O alt-server-9.iso
sudo mkdir alt-server-9 && sudo mount -r alt-server-9.iso alt-server-9
ls alt-server-9/ALTLinux/RPMS.main/ | grep ^kernel-image-
ls alt-server-9/ALTLinux/RPMS.main/ | grep ^glibc-
sudo umount alt-server-9

# Альт Рабочая станция 9
wget https://download.basealt.ru/pub/distributions/ALTLinux/p9/images/workstation/x86_64/\
alt-workstation-9.0-x86_64.iso -O alt-workstation-9.iso
sudo mkdir alt-workstation-9 && sudo mount -r alt-workstation-9.iso alt-workstation-9
ls alt-workstation-9/ALTLinux/RPMS.main/ | grep ^kernel-image-
ls alt-workstation-9/ALTLinux/RPMS.main/ | grep ^glibc-
sudo umount alt-workstation-9

# Simply Linux 9
wget https://download.basealt.ru/pub/distributions/ALTLinux/p9/images/simply/x86_64/\
slinux-9.0-x86_64.iso -O simply-9.iso
sudo mkdir simply-9 && sudo mount -r simply-9.iso simply-9
ls simply-9/ALTLinux/RPMS.main/ | grep ^kernel-image-
ls simply-9/ALTLinux/RPMS.main/ | grep ^glibc-
sudo umount simply-9

# Альт Сервер 10
wget http://ftp.altlinux.org/pub/distributions/ALTLinux/p10/images/server/x86_64/\
alt-server-10.0-x86_64.iso -O alt-server-10.iso
sudo mkdir alt-server-10 && sudo mount -r alt-server-10.iso alt-server-10
ls alt-server-10/ALTLinux/RPMS.main/ | grep ^kernel-image-
ls alt-server-10/ALTLinux/RPMS.main/ | grep ^glibc-
sudo umount alt-server-10

# Альт Рабочая станция 10
wget https://download.basealt.ru/pub/distributions/ALTLinux/p10/images/workstation/x86_64/\
alt-workstation-10.0-x86_64.iso -O alt-workstation-10.iso
sudo mkdir alt-workstation-10 && sudo mount -r alt-workstation-10.iso alt-workstation-10
ls alt-workstation-10/ALTLinux/RPMS.main/ | grep ^kernel-image-
ls alt-workstation-10/ALTLinux/RPMS.main/ | grep ^glibc-
sudo umount alt-workstation-10

# Simply Linux 10
wget https://download.basealt.ru/pub/distributions/ALTLinux/p10/images/simply/x86_64/\
slinux-10.0-x86_64.iso -O simply-10.iso
sudo mkdir simply-10 && sudo mount -r simply-10.iso simply-10
ls simply-10/ALTLinux/RPMS.main/ | grep ^kernel-image-
ls simply-10/ALTLinux/RPMS.main/ | grep ^glibc-
sudo umount simply-10

# Astra Linux SE 1.7
sudo mkdir alse-1.7 && sudo mount -r alse-1.7.iso alse-1.7
ls alse-1.7/pool/main/l/linux/linux-image-*
ls alse-1.7/pool/main/g/glibc
sudo umount alse-1.7

# Astra Linux SE 1.8
sudo mkdir alse-1.8 && sudo mount -r alse-1.8.iso alse-1.8
ls alse-1.8/pool/main/l | grep linux
ls alse-1.8/pool/main/g/glibc
sudo umount alse-1.8

# РОСА Linux 12
wget http://mirror.rosalab.ru/rosa/rosa2021.1/iso/ROSA.FRESH.12/plasma5/\
ROSA.FRESH.PLASMA5.12.iso -O rosa-12.iso
sudo mkdir rosa-12 && sudo mount -r rosa-12.iso rosa-12
sudo mkdir rosa-12-fs && sudo unsquashfs -f -d ./rosa-12-fs rosa-12/LiveOS/squashfs.img
sudo mkdir rosa-12-root && sudo mount -r rosa-12-fs/LiveOS/rootfs.img rosa-12-root
ls -l rosa-12-root/lib/modules
sudo chroot rosa-12-root /lib64/libc.so.6
sudo umount rosa-12-root
sudo umount rosa-12

# РЕД ОС 7.3
wget https://files.red-soft.ru/redos/7.3/x86_64/iso/\
redos-MUROM-7.3-20210412-Everything-x86_64-DVD1.iso -O red-7.3.iso
sudo mkdir red-7.3 && sudo mount -r red-7.3.iso red-7.3
sudo mkdir red-7.3-fs && sudo unsquashfs -f -d ./red-7.3-fs red-7.3/LiveOS/squashfs.img
sudo mkdir red-7.3-root && sudo mount -r red-7.3-fs/LiveOS/rootfs.img red-7.3-root
ls -l red-7.3-root/lib/modules
sudo chroot red-7.3-root /lib64/libc.so.6
sudo umount red-7.3-root
sudo umount red-7.3

# РЕД ОС 8.0
wget https://files.red-soft.ru/redos/8.0/x86_64/iso/\
redos-8-20240410.1-minimal-server-x86_64-DVD1.iso -O red-8.0.iso
sudo mkdir red-8.0 && sudo mount -r red-8.0.iso red-8.0
sudo mkdir red-8.0-fs && sudo unsquashfs -f -d ./red-8.0-fs red-8.0/LiveOS/squashfs.img
sudo mkdir red-8.0-root && sudo mount -r red-8.0-fs/LiveOS/rootfs.img red-8.0-root
ls -l red-8.0-root/lib/modules
sudo chroot red-8.0-root /lib64/libc.so.6
sudo umount red-8.0-root
sudo umount red-8.0

# Calculate Linux
wget https://mirror.calculate-linux.org/release/20240724/\
cld-20240724-x86_64.iso -O calculate.iso
sudo mkdir calculate && sudo mount -r calculate.iso calculate
sudo mkdir calculate-fs && sudo unsquashfs -f -d ./calculate-fs calculate/livecd.squashfs
ls -l calculate-fs/lib/modules
sudo chroot calculate-fs /lib64/libc.so.6
sudo umount calculate

# Arch Linux
wget https://mirrors.edge.kernel.org/archlinux/iso/2024.07.01/\
archlinux-2024.07.01-x86_64.iso -O arch-linux.iso
sudo mkdir arch-linux && sudo mount -r arch-linux.iso arch-linux
sudo mkdir arch-linux-fs && sudo unsquashfs -f -d ./arch-linux-fs arch-linux/arch/x86_64/airootfs.sfs
ls -l arch-linux-fs/lib/modules
sudo chroot arch-linux-fs /usr/lib/libc.so.6
sudo umount arch-linux

# Fedora Workstation
wget https://download.fedoraproject.org/pub/fedora/linux/releases/40/Workstation/x86_64/iso/\
Fedora-Workstation-Live-x86_64-40-1.14.iso -O fedora-workstation.iso
sudo mkdir fedora-workstation && sudo mount -r fedora-workstation.iso fedora-workstation
sudo mkdir fedora-workstation-fs && sudo unsquashfs -f -d ./fedora-workstation-fs fedora-workstation/LiveOS/squashfs.img
sudo mkdir fedora-workstation-root && sudo mount -r fedora-workstation-fs/LiveOS/rootfs.img fedora-workstation-root
ls -l fedora-workstation-root/lib/modules
sudo chroot fedora-workstation-root /usr/lib64/libc.so.6
sudo umount fedora-workstation-root
sudo umount fedora-workstation

# Manjaro Linux
wget https://download.manjaro.org/xfce/24.0.3/\
manjaro-xfce-24.0.3-240702-linux69.iso -O manjaro.iso
sudo mkdir manjaro && sudo mount -r manjaro.iso manjaro
sudo mkdir manjaro-fs && sudo unsquashfs -f -d ./manjaro-fs manjaro/manjaro/x86_64/rootfs.sfs
ls -l manjaro-fs/lib/modules
sudo chroot manjaro-fs /usr/lib/libc.so.6
sudo umount manjaro

# openSUSE Tumbleweed
wget https://download.opensuse.org/tumbleweed/iso/\
openSUSE-Tumbleweed-DVD-x86_64-Current.iso -O opensuse-tumbleweed.iso
sudo mkdir opensuse-tumbleweed && sudo mount -r opensuse-tumbleweed.iso opensuse-tumbleweed
ls opensuse-tumbleweed/x86_64/ | grep ^kernel-default-
ls opensuse-tumbleweed/x86_64/ | grep ^glibc-
sudo umount opensuse-tumbleweed
```
-->

[abi]: https://abi-laboratory.pro/?view=timeline&l=glibc
[lts]: https://www.kernel.org/category/releases.html

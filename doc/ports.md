# Ports
Installation instructions for supported [Vcpkg Packages][pkg].

```sh
# Prevent simdjson from enabling all features.
vcpkg install --triplet=ace-linux simdjson[core,threads]

vcpkg install --triplet=ace-linux \
  benchmark[core] doctest[core] libxml2[core,tools] pugixml[core] \
  zlib[core] bzip2[core] liblzma[core] lz4[core] brotli[core] zstd[core] \
  libdeflate[core,compression,decompression,gzip,zlib] miniz[core] draco[core] \
  libjpeg-turbo[core] libpng[core] aom[core] libyuv[core] libavif[core,aom] \
  lunasvg[core] freetype[core,zlib,bzip2,brotli,png,subpixel-rendering] harfbuzz[core,freetype] \
  glm[core] spirv-headers[core] spirv-tools[core,tools] glslang[core,opt,tools] shaderc[core] \
  vulkan-headers[core] vulkan-utility-libraries[core] vulkan-memory-allocator[core] volk[core] \
  convectionkernels[core] meshoptimizer[core,gltfpack] recastnavigation[core] \
  openfbx[core] ktx[core,vulkan] fastgltf[core] miniaudio[core] \
  sqlite3[core,tool,zlib] openssl[core,tools] asmjit[core] blend2d[core,jit] \
  boost-algorithm[core] boost-container[core] boost-circular-buffer[core] \
  boost-asio[core,ssl] boost-beast[core] boost-url[core] boost-json[core] \
  libffi[core] wayland[core,force-build] wayland-protocols[core,force-build]

# Prevent simdjson from enabling all features.
vcpkg install --triplet=ace-mingw simdjson[core,threads]

vcpkg install --triplet=ace-mingw \
  benchmark[core] doctest[core] libxml2[core,tools] pugixml[core] \
  zlib[core] bzip2[core] liblzma[core] lz4[core] brotli[core] zstd[core] \
  libdeflate[core,compression,decompression,gzip,zlib] miniz[core] draco[core] \
  libjpeg-turbo[core] libpng[core] aom[core] libyuv[core] libavif[core,aom] \
  lunasvg[core] freetype[core,zlib,bzip2,brotli,png,subpixel-rendering] harfbuzz[core,freetype] \
  glm[core] spirv-headers[core] spirv-tools[core,tools] glslang[core,opt,tools] shaderc[core] \
  vulkan-headers[core] vulkan-utility-libraries[core] vulkan-memory-allocator[core] volk[core] \
  convectionkernels[core] meshoptimizer[core,gltfpack] recastnavigation[core] \
  openfbx[core] ktx[core,vulkan] fastgltf[core] miniaudio[core] \
  sqlite3[core,tool,zlib] openssl[core,tools] asmjit[core] blend2d[core,jit] \
  boost-algorithm[core] boost-container[core] boost-circular-buffer[core] \
  boost-asio[core,ssl] boost-beast[core] boost-url[core] boost-json[core]

rm -rf /opt/ace/vcpkg/buildtrees
env --chdir=/opt/ace tar cJf vcpkg.tar.xz vcpkg
# TODO: Export ports and compress with 7-zip.
```

[pkg]: https://vcpkg.io/en/packages

<!--
cd /opt/ace/vcpkg
cd C:\Ace\vcpkg

# =============================================================================

# Linux
vcpkg install benchmark[core]:ace-linux
vcpkg build ace-test-benchmark:ace-linux
cat buildtrees/ace-test-benchmark/build-ace-linux-rel-out.log
ldd buildtrees/ace-test-benchmark/ace-linux-rel/main

vcpkg install benchmark[core]:ace-mingw
vcpkg build ace-test-benchmark:ace-mingw
cat buildtrees/ace-test-benchmark/build-ace-mingw-rel-out.log
readpe -i buildtrees/ace-test-benchmark/ace-mingw-rel/main.exe | grep -E "^ {8}Name:"

# Windows
vcpkg build ace-test-benchmark:ace-mingw
type buildtrees\ace-test-benchmark\build-ace-mingw-rel-out.log

# =============================================================================

# Linux
vcpkg install doctest[core]:ace-linux doctest[core]:ace-mingw
vcpkg build ace-test-doctest:ace-linux
vcpkg build ace-test-doctest:ace-mingw

# Windows
vcpkg build ace-test-doctest:ace-mingw

# =============================================================================

# Linux
vcpkg install libxml2[core,tools]:ace-linux libxml2[core]:ace-mingw
vcpkg build ace-test-libxml2:ace-linux
vcpkg build ace-test-libxml2:ace-mingw

grep "Parsing took" buildtrees/ace-test-libxml2/config-ace-linux-out.log
grep "Parsing took" buildtrees/ace-test-libxml2/config-ace-mingw-out.log

# Windows
vcpkg build ace-test-libxml2:ace-mingw
type buildtrees\ace-test-libxml2\config-ace-mingw-out.log

# =============================================================================

# Linux
vcpkg install pugixml[core]:ace-linux pugixml[core]:ace-mingw
vcpkg build ace-test-pugixml:ace-linux
vcpkg build ace-test-pugixml:ace-mingw

# Windows
vcpkg build ace-test-pugixml:ace-mingw

# =============================================================================

# Linux
vcpkg install zlib[core]:ace-linux zlib[core]:ace-mingw
vcpkg build ace-test-zlib:ace-linux  # 604
vcpkg build ace-test-zlib:ace-mingw  # 604

# Windows
vcpkg build ace-test-zlib:ace-mingw

# =============================================================================

# Linux
vcpkg install bzip2[core]:ace-linux bzip2[core]:ace-mingw
vcpkg build ace-test-bzip2:ace-linux  # 703
vcpkg build ace-test-bzip2:ace-mingw  # 703

# Windows
vcpkg build ace-test-bzip2:ace-mingw

# =============================================================================

# Linux
vcpkg install liblzma[core]:ace-linux liblzma[core]:ace-mingw
vcpkg build ace-test-liblzma:ace-linux  # 680
vcpkg build ace-test-liblzma:ace-mingw  # 680

# Windows
vcpkg build ace-test-liblzma:ace-mingw

# =============================================================================

# Linux
vcpkg install lz4[core]:ace-linux lz4[core]:ace-mingw
vcpkg build ace-test-lz4:ace-linux  # 842
vcpkg build ace-test-lz4:ace-mingw  # 842

# Windows
vcpkg build ace-test-lz4:ace-mingw

# =============================================================================

# Linux
vcpkg install brotli[core]:ace-linux brotli[core]:ace-mingw
vcpkg build ace-test-brotli:ace-linux  # 480
vcpkg build ace-test-brotli:ace-mingw  # 480

# Windows
vcpkg build ace-test-brotli:ace-mingw

# =============================================================================

# Linux
vcpkg install zstd[core]:ace-linux zstd[core]:ace-mingw
vcpkg build ace-test-zstd:ace-linux  # 620
vcpkg build ace-test-zstd:ace-mingw  # 620

# Windows
vcpkg build ace-test-zstd:ace-mingw

# =============================================================================

# Linux
vcpkg install libdeflate[core,compression,decompression,gzip,zlib]:ace-linux
vcpkg install libdeflate[core,compression,decompression,gzip,zlib]:ace-mingw
vcpkg build ace-test-libdeflate:ace-linux  # 594
vcpkg build ace-test-libdeflate:ace-mingw  # 594

# Windows
vcpkg build ace-test-libdeflate:ace-mingw

# =============================================================================

# Linux
vcpkg install miniz[core]:ace-linux miniz[core]:ace-mingw
vcpkg build ace-test-miniz:ace-linux  # 610
vcpkg build ace-test-miniz:ace-mingw  # 610

# Windows
vcpkg build ace-test-miniz:ace-mingw

# =============================================================================

# Linux
vcpkg install libjpeg-turbo[core]:ace-linux libjpeg-turbo[core]:ace-mingw
vcpkg build ace-test-libjpeg-turbo:ace-linux
vcpkg build ace-test-libjpeg-turbo:ace-mingw
vcpkg build ace-test-libjpeg:ace-linux
vcpkg build ace-test-libjpeg:ace-mingw

# Windows
vcpkg build ace-test-libjpeg-turbo:ace-mingw
vcpkg build ace-test-libjpeg:ace-mingw

# =============================================================================

# Linux
vcpkg install libpng[core]:ace-linux libpng[core]:ace-mingw
vcpkg build ace-test-libpng:ace-linux
vcpkg build ace-test-libpng:ace-mingw

# Windows
vcpkg build ace-test-libpng:ace-mingw

# =============================================================================

# Linux
vcpkg install aom[core]:ace-linux aom[core]:ace-mingw
vcpkg install libyuv[core]:ace-linux libyuv[core]:ace-mingw
vcpkg install libavif[core,aom]:ace-linux libavif[core,aom]:ace-mingw
vcpkg build ace-test-libavif:ace-linux
vcpkg build ace-test-libavif:ace-mingw

# Windows
vcpkg build ace-test-libavif:ace-mingw

# =============================================================================

# Linux
vcpkg install lunasvg[core]:ace-linux lunasvg[core]:ace-mingw
vcpkg build ace-test-lunasvg:ace-linux
vcpkg build ace-test-lunasvg:ace-mingw

# Windows
vcpkg build ace-test-lunasvg:ace-mingw

# =============================================================================

# Linux
vcpkg install freetype[core,zlib,bzip2,brotli,png,subpixel-rendering]:ace-linux
vcpkg install freetype[core,zlib,bzip2,brotli,png,subpixel-rendering]:ace-mingw
vcpkg install harfbuzz[core,freetype]:ace-linux harfbuzz[core,freetype]:ace-mingw
vcpkg build ace-test-fonts:ace-linux
vcpkg build ace-test-fonts:ace-mingw

# Windows
vcpkg build ace-test-fonts:ace-mingw

# =============================================================================

# Linux
vcpkg install glm[core]:ace-linux glm[core]:ace-mingw
vcpkg build ace-test-glm:ace-linux
vcpkg build ace-test-glm:ace-mingw

# Windows
vcpkg build ace-test-glm:ace-mingw

# =============================================================================

# Linux
vcpkg install spirv-headers[core]:ace-linux spirv-headers[core]:ace-mingw
vcpkg install spirv-tools[core,tools]:ace-linux spirv-tools[core]:ace-mingw
vcpkg install glslang[core,opt,tools]:ace-linux glslang[core,opt]:ace-mingw
vcpkg install shaderc[core]:ace-linux shaderc[core]:ace-mingw
vcpkg install vulkan-headers[core]:ace-linux vulkan-headers[core]:ace-mingw
vcpkg install vulkan-utility-libraries[core]:ace-linux vulkan-utility-libraries[core]:ace-mingw
vcpkg install vulkan-memory-allocator[core]:ace-linux vulkan-memory-allocator[core]:ace-mingw
vcpkg install volk[core]:ace-linux volk[core]:ace-mingw
vcpkg install convectionkernels[core]:ace-linux convectionkernels[core]:ace-mingw
vcpkg install meshoptimizer[core,gltfpack]:ace-linux meshoptimizer[core]:ace-mingw
vcpkg install recastnavigation[core]:ace-linux recastnavigation[core]:ace-mingw
vcpkg install openfbx[core]:ace-linux openfbx[core]:ace-mingw
vcpkg install ktx[core,vulkan]:ace-linux ktx[core,vulkan]:ace-mingw

vcpkg build ace-test-vulkan:ace-linux
vcpkg build ace-test-vulkan:ace-mingw

# Windows
vcpkg build ace-test-vulkan:ace-mingw

# =============================================================================

# Linux
vcpkg install sqlite3[core,tool,zlib]:ace-linux sqlite3[core]:ace-mingw
vcpkg build ace-test-sqlite3:ace-linux
vcpkg build ace-test-sqlite3:ace-mingw

# Windows
vcpkg build ace-test-sqlite3:ace-mingw

# =============================================================================

# Linux
vcpkg install openssl[core,tools]:ace-linux openssl[core]:ace-mingw
vcpkg build ace-test-openssl:ace-linux
vcpkg build ace-test-openssl:ace-mingw

# Windows
vcpkg build ace-test-openssl:ace-mingw

# =============================================================================

# WSL2
sudo apt install -y foot xterm

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

# Linux
vcpkg install libffi[core]:ace-linux
vcpkg install wayland[core,force-build]:ace-linux
vcpkg install wayland-protocols[core,force-build]:ace-mingw
vcpkg build ace-test-wayland:ace-linux

# =============================================================================

# Linux
vcpkg remove ace-test:ace-linux ace-test-vulkan:ace-linux
vcpkg remove ace-test:ace-mingw ace-test-vulkan:ace-mingw

vcpkg install ace-test:ace-linux
vcpkg install ace-test:ace-mingw

# Windows
vcpkg remove ace-test:ace-mingw ace-test-vulkan:ace-mingw

vcpkg install ace-test:ace-mingw

# =============================================================================

find_package(Boost REQUIRED COMPONENTS
  algorithm
  container
  circular-buffer
  asio
  beast
  url
  json)

target_link_libraries(main PRIVATE
  Boost::algorithm
  Boost::container
  Boost::circular-buffer
  Boost::asio
  Boost::beast
  Boost::url
  Boost::json)

-->

# Ports
Installation instructions for supported Vcpkg ports.

## Linux

```sh
vcpkg install --triplet=ace-linux-shared \
  benchmark[core] doctest[core] libxml2[core,tools] pugixml[core] \
  brotli[core] bzip2[core] liblzma[core] lz4[core] zlib[core] zstd[core] \
  libjpeg-turbo[core] libpng[core] libyuv[core] libavif[core] lunasvg[core] \
  freetype[core,brotli,bzip2,zlib,png,subpixel-rendering,error-strings] harfbuzz[core,freetype] \
  blend2d[core,jit] shaderc[core] glslang[core,opt,rtti] spirv-tools[core,tools] spirv-headers[core] \
  volk[core] vulkan-headers[core] vulkan-utility-libraries[core] vulkan-memory-allocator[core] \
  convectionkernels[core] meshoptimizer[core] recastnavigation[core] openfbx[core] leveldb[core]

vcpkg install --triplet=ace-linux-static \
  benchmark[core] doctest[core] libxml2[core] pugixml[core] \
  brotli[core] bzip2[core] liblzma[core] lz4[core] zlib[core] zstd[core] \
  libjpeg-turbo[core] libpng[core] libyuv[core] libavif[core] lunasvg[core] \
  freetype[core,brotli,bzip2,zlib,png,subpixel-rendering] harfbuzz[core,freetype] \
  blend2d[core,jit] shaderc[core] glslang[core,opt] spirv-tools[core] spirv-headers[core] \
  volk[core] vulkan-headers[core] vulkan-utility-libraries[core] vulkan-memory-allocator[core] \
  convectionkernels[core] meshoptimizer[core] recastnavigation[core] openfbx[core] leveldb[core]

vcpkg install --triplet=ace-mingw-shared \
  benchmark[core] doctest[core] libxml2[core] pugixml[core] \
  brotli[core] bzip2[core] liblzma[core] lz4[core] zlib[core] zstd[core] \
  libjpeg-turbo[core] libpng[core] libyuv[core] libavif[core] lunasvg[core] \
  freetype[core,brotli,bzip2,zlib,png,subpixel-rendering,error-strings] harfbuzz[core,freetype] \
  blend2d[core,jit] shaderc[core] glslang[core,opt,rtti] spirv-tools[core] spirv-headers[core] \
  volk[core] vulkan-headers[core] vulkan-utility-libraries[core] vulkan-memory-allocator[core] \
  convectionkernels[core] meshoptimizer[core] recastnavigation[core] openfbx[core] leveldb[core]

vcpkg install --triplet=ace-mingw-static \
  benchmark[core] doctest[core] libxml2[core] pugixml[core] \
  brotli[core] bzip2[core] liblzma[core] lz4[core] zlib[core] zstd[core] \
  libjpeg-turbo[core] libpng[core] libyuv[core] libavif[core] lunasvg[core] \
  freetype[core,brotli,bzip2,zlib,png,subpixel-rendering] harfbuzz[core,freetype] \
  blend2d[core,jit] shaderc[core] glslang[core,opt] spirv-tools[core] spirv-headers[core] \
  volk[core] vulkan-headers[core] vulkan-utility-libraries[core] vulkan-memory-allocator[core] \
  convectionkernels[core] meshoptimizer[core] recastnavigation[core] openfbx[core] leveldb[core]
```

## Windows

```bat
vcpkg install --triplet=ace-mingw-shared ^
  benchmark[core] doctest[core] libxml2[core,tools] pugixml[core] ^
  brotli[core] bzip2[core] liblzma[core] lz4[core] zlib[core] zstd[core] ^
  libjpeg-turbo[core] libpng[core] libyuv[core] libavif[core] lunasvg[core] ^
  freetype[core,brotli,bzip2,zlib,png,subpixel-rendering,error-strings] harfbuzz[core,freetype] ^
  blend2d[core,jit] shaderc[core] glslang[core,opt,rtti] spirv-tools[core,tools] spirv-headers[core] ^
  volk[core] vulkan-headers[core] vulkan-utility-libraries[core] vulkan-memory-allocator[core] ^
  convectionkernels[core] meshoptimizer[core] recastnavigation[core] openfbx[core] leveldb[core]

vcpkg install --triplet=ace-mingw-static ^
  benchmark[core] doctest[core] libxml2[core] pugixml[core] ^
  brotli[core] bzip2[core] liblzma[core] lz4[core] zlib[core] zstd[core] ^
  libjpeg-turbo[core] libpng[core] libyuv[core] libavif[core] lunasvg[core] ^
  freetype[core,brotli,bzip2,zlib,png,subpixel-rendering] harfbuzz[core,freetype] ^
  blend2d[core,jit] shaderc[core] glslang[core,opt] spirv-tools[core] spirv-headers[core] ^
  volk[core] vulkan-headers[core] vulkan-utility-libraries[core] vulkan-memory-allocator[core] ^
  convectionkernels[core] meshoptimizer[core] recastnavigation[core] openfbx[core] leveldb[core]
```

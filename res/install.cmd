@echo off
for %%I in ("%~dp0..") do set "ACE=%%~fI"
cd "%ACE%"
res\vcpkg.cmd install doctest[core] ^
  zlib[core] bzip2[core] liblzma[core] lz4[core] brotli[core] zstd[core] ^
  libdeflate[core,compression,decompression,gzip,zlib] miniz[core] ^
  expat[core] libxml2[core] pugixml[core] ^
  simdjson[core,deprecated,threads,utf8-validation] ^
  libjpeg-turbo[core] libpng[core] plutovg[core] lunasvg[core] ^
  freetype[core,zlib,bzip2,brotli,png,subpixel-rendering] harfbuzz[core,freetype] ^
  spirv-headers[core] spirv-tools[core] glslang[core,opt] shaderc[core] ^
  vulkan-headers[core] vulkan-utility-libraries[core] vulkan-memory-allocator[core] volk[core] ^
  convectionkernels[core] ktx[core,vulkan] draco[core] fastgltf[core] meshoptimizer[core] openfbx[core] ^
  recastnavigation[core] itlib[core] robin-hood-hashing[core] rmlui[core,freetype,svg] ^
  openssl[core] sqlite3[core,zlib] lua[core,cpp]

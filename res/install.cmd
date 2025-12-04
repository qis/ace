@echo off
for %%I in ("%~dp0..") do set "ACE=%%~fI"
cd "%ACE%"

res\vcpkg.cmd install --triplet=mingw ^
  doctest[core] expat[core] libxml2[core] pugixml[core] lua[core,cpp] ^
  zlib[core] bzip2[core] liblzma[core] lz4[core] brotli[core] zstd[core] ^
  libdeflate[core,compression,decompression,gzip,zlib] miniz[core] ^
  libjpeg-turbo[core] libpng[core] lunasvg[core] plutovg[core] plutosvg[core] ^
  freetype[core,zlib,bzip2,brotli,png,subpixel-rendering] harfbuzz[core,freetype] ^
  egl-registry[core] spirv-headers[core] spirv-tools[core] glslang[core,opt] shaderc[core] ^
  vulkan-headers[core] vulkan-utility-libraries[core] vulkan-memory-allocator[core] volk[core] ^
  simdjson[core,deprecated,threads,utf8-validation] fastgltf[core] ktx[core,vulkan] ^
  convectionkernels[core] draco[core] meshoptimizer[core] recastnavigation[core] ^
  itlib[core] robin-hood-hashing[core] rmlui[core,freetype,svg] ^
  glm[core] sdl3[core] vsg[core]

for /f "delims=" %%F in ('dir "vcpkg\buildtrees\lua\src\lua.hpp" /s /b 2^>nul') do (
  copy "%%F" "vcpkg\installed\mingw\include\lua.hpp" >nul
  goto :eof
)

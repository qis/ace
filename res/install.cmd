@echo off
for %%I in ("%~dp0..") do set "ACE=%%~fI"
cd "%ACE%"

res\vcpkg.cmd install --triplet=mingw --recurse lua[core,cpp] ^
  doctest[core] imath[core] expat[core] libxml2[core] pugixml[core] ^
  zlib[core] bzip2[core] liblzma[core] lz4[core] brotli[core] zstd[core] ^
  libdeflate[core,decompression,gzip,zlib] minizip[core,bzip2] kubazip[core] ^
  miniz[core] rapidjson[core] simdjson[core,deprecated,threads,utf8-validation] ^
  utfcpp[core] lunasvg[core] plutovg[core] plutosvg[core] stb[core] openjph[core] ^
  libjpeg-turbo[core] libpng[core] openexr[core] libyuv[core] aom[core] libavif[core,aom] ^
  freetype[core,zlib,bzip2,brotli,png,subpixel-rendering] harfbuzz[core,freetype] ^
  spirv-headers[core] spirv-tools[core] glslang[core,opt] shaderc[core] volk[core] ^
  vulkan-headers[core] vulkan-utility-libraries[core] vulkan-memory-allocator[core] ^
  convectionkernels[core] meshoptimizer[core] recastnavigation[core] polyclipping[core] ^
  draco[core] fastgltf[core] ktx[core,vulkan] jhasse-poly2tri[core] assimp[core] ^
  glm[core] itlib[core] robin-hood-hashing[core] rmlui[core,freetype,svg] ^
  sdl3[core] vsg[core] vsgxchange[core,assimp,freetype,openexr]

for /f "delims=" %%F in ('dir "vcpkg\buildtrees\lua\src\lua.hpp" /s /b 2^>nul') do (
  copy "%%F" "vcpkg\installed\mingw\include\lua.hpp" >nul
  goto :eof
)

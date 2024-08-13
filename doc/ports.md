# Ports
Installation instructions for supported [Vcpkg Packages][pkg].

## Linux

```sh
vcpkg install --triplet=ace-linux-shared \
  benchmark[core] doctest[core] libxml2[core,tools] pugixml[core] \
  brotli[core] bzip2[core] liblzma[core] lz4[core] zlib[core] zstd[core] \
  libjpeg-turbo[core] libpng[core] libyuv[core] libavif[core] lunasvg[core] \
  freetype[core,brotli,bzip2,zlib,png,subpixel-rendering,error-strings] harfbuzz[core,freetype] \
  blend2d[core,jit] shaderc[core] glslang[core,opt,rtti] spirv-tools[core,tools] spirv-headers[core] \
  volk[core] vulkan-headers[core] vulkan-utility-libraries[core] vulkan-memory-allocator[core] \
  convectionkernels[core] meshoptimizer[core] recastnavigation[core] openfbx[core] leveldb[core] \
  openssl[core] boost-asio[core,ssl] boost-beast[core] boost-json[core] boost-url[core] && \
vcpkg install --triplet=ace-linux-static \
  benchmark[core] doctest[core] libxml2[core] pugixml[core] \
  brotli[core] bzip2[core] liblzma[core] lz4[core] zlib[core] zstd[core] \
  libjpeg-turbo[core] libpng[core] libyuv[core] libavif[core] lunasvg[core] \
  freetype[core,brotli,bzip2,zlib,png,subpixel-rendering] harfbuzz[core,freetype] \
  blend2d[core,jit] shaderc[core] glslang[core,opt] spirv-tools[core] spirv-headers[core] \
  volk[core] vulkan-headers[core] vulkan-utility-libraries[core] vulkan-memory-allocator[core] \
  convectionkernels[core] meshoptimizer[core] recastnavigation[core] openfbx[core] leveldb[core] \
  openssl[core] boost-asio[core,ssl] boost-beast[core] boost-json[core] boost-url[core] && \
vcpkg install --triplet=ace-mingw-shared \
  benchmark[core] doctest[core] libxml2[core] pugixml[core] \
  brotli[core] bzip2[core] liblzma[core] lz4[core] zlib[core] zstd[core] \
  libjpeg-turbo[core] libpng[core] libyuv[core] libavif[core] lunasvg[core] \
  freetype[core,brotli,bzip2,zlib,png,subpixel-rendering,error-strings] harfbuzz[core,freetype] \
  blend2d[core,jit] shaderc[core] glslang[core,opt,rtti] spirv-tools[core] spirv-headers[core] \
  volk[core] vulkan-headers[core] vulkan-utility-libraries[core] vulkan-memory-allocator[core] \
  convectionkernels[core] meshoptimizer[core] recastnavigation[core] openfbx[core] leveldb[core] \
  openssl[core] boost-asio[core,ssl] boost-beast[core] boost-json[core] boost-url[core] && \
vcpkg install --triplet=ace-mingw-static \
  benchmark[core] doctest[core] libxml2[core] pugixml[core] \
  brotli[core] bzip2[core] liblzma[core] lz4[core] zlib[core] zstd[core] \
  libjpeg-turbo[core] libpng[core] libyuv[core] libavif[core] lunasvg[core] \
  freetype[core,brotli,bzip2,zlib,png,subpixel-rendering] harfbuzz[core,freetype] \
  blend2d[core,jit] shaderc[core] glslang[core,opt] spirv-tools[core] spirv-headers[core] \
  volk[core] vulkan-headers[core] vulkan-utility-libraries[core] vulkan-memory-allocator[core] \
  convectionkernels[core] meshoptimizer[core] recastnavigation[core] openfbx[core] leveldb[core] \
  openssl[core] boost-asio[core,ssl] boost-beast[core] boost-json[core] boost-url[core]
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
  convectionkernels[core] meshoptimizer[core] recastnavigation[core] openfbx[core] leveldb[core] ^
  openssl[core] boost-asio[core,ssl] boost-beast[core] boost-json[core] boost-url[core] && ^
vcpkg install --triplet=ace-mingw-static ^
  benchmark[core] doctest[core] libxml2[core] pugixml[core] ^
  brotli[core] bzip2[core] liblzma[core] lz4[core] zlib[core] zstd[core] ^
  libjpeg-turbo[core] libpng[core] libyuv[core] libavif[core] lunasvg[core] ^
  freetype[core,brotli,bzip2,zlib,png,subpixel-rendering] harfbuzz[core,freetype] ^
  blend2d[core,jit] shaderc[core] glslang[core,opt] spirv-tools[core] spirv-headers[core] ^
  volk[core] vulkan-headers[core] vulkan-utility-libraries[core] vulkan-memory-allocator[core] ^
  convectionkernels[core] meshoptimizer[core] recastnavigation[core] openfbx[core] leveldb[core] ^
  openssl[core] boost-asio[core,ssl] boost-beast[core] boost-json[core] boost-url[core]
```

[pkg]: https://vcpkg.io/en/packages

<!--
benchmark provides CMake targets:

  # this is heuristically generated, and may not be correct
  find_package(benchmark CONFIG REQUIRED)
  target_link_libraries(main PRIVATE benchmark::benchmark benchmark::benchmark_main)

benchmark provides pkg-config modules:

  # Google microbenchmark framework
  benchmark

blend2d provides CMake targets:

    find_package(blend2d CONFIG REQUIRED)
    target_link_libraries(main PRIVATE blend2d::blend2d)

brotli provides CMake targets:

    find_package(unofficial-brotli CONFIG REQUIRED)
    # Brotli decoder library
    target_link_libraries(main PRIVATE unofficial::brotli::brotlidec)
    # Brotli encoder library
    target_link_libraries(main PRIVATE unofficial::brotli::brotlienc)

The package bzip2 is compatible with built-in CMake targets:

    find_package(BZip2 REQUIRED)
    target_link_libraries(main PRIVATE BZip2::BZip2)

convectionkernels provides CMake targets:

  # this is heuristically generated, and may not be correct
  find_package(unofficial-convectionkernels CONFIG REQUIRED)
  target_link_libraries(main PRIVATE unofficial::convectionkernels::convectionkernels)

doctest provides CMake targets:

  # this is heuristically generated, and may not be correct
  find_package(doctest CONFIG REQUIRED)
  target_link_libraries(main PRIVATE doctest::doctest)

The package zlib is compatible with built-in CMake targets:

    find_package(ZLIB REQUIRED)
    target_link_libraries(main PRIVATE ZLIB::ZLIB)

The package libpng is compatible with built-in CMake targets:

    find_package(PNG REQUIRED)
    target_link_libraries(main PRIVATE PNG::PNG)

freetype is compatible with built-in CMake targets:

    find_package(Freetype REQUIRED)
    target_link_libraries(main PRIVATE Freetype::Freetype) # since CMake 3.10

spirv-headers is header-only and can be used from CMake via:

  find_path(SPIRV_HEADERS_INCLUDE_DIRS "spirv/1.0/GLSL.std.450.h")
  target_include_directories(main PRIVATE ${SPIRV_HEADERS_INCLUDE_DIRS})

spirv-headers provides pkg-config modules:

  # Header files from the SPIR-V registry
  SPIRV-Headers

spirv-tools provides CMake targets:

    find_package(SPIRV-Tools CONFIG REQUIRED)
    # The static libary is always available.
    # It offers full public symbol visibility.
    target_link_libraries(main PRIVATE SPIRV-Tools-static)
    # In triplets with dynamic library linkage, there is also a shared libary.
    target_link_libraries(main PRIVATE SPIRV-Tools-shared)

    # The following libraries are static and depend on SPIRV-Tools-static.

    find_package(SPIRV-Tools-link CONFIG REQUIRED)
    target_link_libraries(main PRIVATE SPIRV-Tools-link)

    find_package(SPIRV-Tools-lint CONFIG REQUIRED)
    target_link_libraries(main PRIVATE SPIRV-Tools-lint)

    find_package(SPIRV-Tools-opt CONFIG REQUIRED)
    target_link_libraries(main PRIVATE SPIRV-Tools-opt)

    find_package(SPIRV-Tools-reduce CONFIG REQUIRED)
    target_link_libraries(main PRIVATE SPIRV-Tools-reduce)

glslang provides CMake targets:

    find_package(glslang CONFIG REQUIRED)
    target_link_libraries(main PRIVATE glslang::glslang glslang::glslang-default-resource-limits glslang::SPIRV glslang::SPVRemapper)

The harfbuzz package provides CMake targets:

    find_package(harfbuzz CONFIG REQUIRED)
    target_link_libraries(main PRIVATE harfbuzz::harfbuzz harfbuzz::harfbuzz-subset)

leveldb provides CMake targets:

  # this is heuristically generated, and may not be correct
  find_package(leveldb CONFIG REQUIRED)
  target_link_libraries(main PRIVATE leveldb::leveldb)

libjpeg-turbo is compatible with built-in implementation-agnostic CMake targets:

    find_package(JPEG REQUIRED)
    target_include_directories(main PRIVATE JPEG::JPEG)

libjpeg-turbo provides CMake targets for the TurboJPEG C API:

    find_package(libjpeg-turbo CONFIG REQUIRED)
    target_link_libraries(main PRIVATE $<IF:$<TARGET_EXISTS:libjpeg-turbo::turbojpeg>,libjpeg-turbo::turbojpeg,libjpeg-turbo::turbojpeg-static>)

libyuv provides CMake targets:

    find_package(libyuv CONFIG REQUIRED)
    target_link_libraries(main PRIVATE yuv)
libavif provides CMake targets:

  # this is heuristically generated, and may not be correct
  find_package(libavif CONFIG REQUIRED)
  target_link_libraries(main PRIVATE avif)

libavif provides pkg-config modules:

  # Library for encoding and decoding .avif files
  libavif

liblzma is compatible with built-in CMake targets:

    find_package(LibLZMA REQUIRED)
    target_link_libraries(main PRIVATE LibLZMA::LibLZMA)

liblzma provides CMake targets:

    find_package(liblzma CONFIG REQUIRED)
    target_link_libraries(main PRIVATE liblzma::liblzma)

The package libxml2 is compatible with built-in CMake targets:

    find_package(LibXml2 REQUIRED)
    target_link_libraries(main PRIVATE LibXml2::LibXml2)

lunasvg provides CMake targets:

  # this is heuristically generated, and may not be correct
  find_package(unofficial-lunasvg CONFIG REQUIRED)
  target_link_libraries(main PRIVATE unofficial::lunasvg::lunasvg)

lz4 provides CMake targets:

  # this is heuristically generated, and may not be correct
  find_package(lz4 CONFIG REQUIRED)
  target_link_libraries(main PRIVATE lz4::lz4)

lz4 provides pkg-config modules:

  # extremely fast lossless compression algorithm library
  liblz4

meshoptimizer provides CMake targets:

  # this is heuristically generated, and may not be correct
  find_package(meshoptimizer CONFIG REQUIRED)
  target_link_libraries(main PRIVATE meshoptimizer::meshoptimizer)

openfbx provides CMake targets:

  # this is heuristically generated, and may not be correct
  find_package(unofficial-openfbx CONFIG REQUIRED)
  target_link_libraries(main PRIVATE unoffical::openfbx::openfbx)

pugixml provides CMake targets:

  # this is heuristically generated, and may not be correct
  find_package(pugixml CONFIG REQUIRED)
  target_link_libraries(main PRIVATE pugixml::static pugixml::pugixml)

pugixml provides pkg-config modules:

  # Light-weight, simple and fast XML parser for C++ with XPath support.
  pugixml

recastnavigation provides CMake targets:

  # this is heuristically generated, and may not be correct
  find_package(recastnavigation CONFIG REQUIRED)
  # note: 1 additional targets are not displayed.
  target_link_libraries(main PRIVATE RecastNavigation::Detour RecastNavigation::Recast RecastNavigation::DebugUtils RecastNavigation::DetourCrowd)

recastnavigation provides pkg-config modules:

  # RecastNavigation is a cross-platform navigation mesh construction toolset for games
  recastnavigation

shaderc provides CMake targets:

    find_package(unofficial-shaderc CONFIG REQUIRED)
    target_link_libraries(main PRIVATE unofficial::shaderc::shaderc)

Vulkan-Headers provides official find_package support:

    find_package(VulkanHeaders CONFIG)
    target_link_libraries(main PRIVATE Vulkan::Headers)

volk provides CMake targets:

    find_package(volk CONFIG REQUIRED)
    target_link_libraries(main PRIVATE volk::volk volk::volk_headers)

VulkanMemoryAllocator provides official find_package support. However, it requires the user to provide the include directory containing `vulkan/vulkan.h`. There are multiple ways to achieve this and VulkanMemoryAllocator is compatible with all of them.

    find_package(Vulkan) # https://cmake.org/cmake/help/latest/module/FindVulkan.html, CMake 3.21+
    find_package(VulkanMemoryAllocator CONFIG REQUIRED)
    target_link_libraries(main PRIVATE Vulkan::Vulkan GPUOpen::VulkanMemoryAllocator)

or

    find_package(Vulkan) # CMake 3.21+
    find_package(VulkanMemoryAllocator CONFIG REQUIRED)
    target_link_libraries(main PRIVATE Vulkan::Headers GPUOpen::VulkanMemoryAllocator)

or

    find_package(VulkanHeaders CONFIG) # From the vulkan-headers port
    find_package(VulkanMemoryAllocator CONFIG REQUIRED)
    target_link_libraries(main PRIVATE Vulkan::Headers GPUOpen::VulkanMemoryAllocator)

See the documentation for more information on setting up your project: https://gpuopen-librariesandsdks.github.io/VulkanMemoryAllocator/html/index.html

vulkan-utility-libraries provides CMake targets:

  # this is heuristically generated, and may not be correct
  find_package(VulkanUtilityLibraries CONFIG REQUIRED)
  target_link_libraries(main PRIVATE Vulkan::LayerSettings Vulkan::UtilityHeaders Vulkan::CompilerConfiguration)

zstd provides CMake targets:

  find_package(zstd CONFIG REQUIRED)
  target_link_libraries(main PRIVATE zstd::libzstd)

openssl is compatible with built-in CMake targets:

  find_package(OpenSSL REQUIRED)
  target_link_libraries(main PRIVATE OpenSSL::SSL)
  target_link_libraries(main PRIVATE OpenSSL::Crypto)

The package boost-json is compatible with built-in CMake targets of FindBoost.cmake:

    find_package(Boost REQUIRED COMPONENTS json)
    target_link_libraries(main PRIVATE Boost::json)

or the generated cmake configs via:

    find_package(boost_json REQUIRED CONFIG)
    target_link_libraries(main PRIVATE Boost::json)

The package boost-asio is compatible with built-in CMake targets of FindBoost.cmake:

    find_package(Boost REQUIRED COMPONENTS asio)
    target_link_libraries(main PRIVATE Boost::asio)

or the generated cmake configs via:

    find_package(boost_asio REQUIRED CONFIG)
    target_link_libraries(main PRIVATE Boost::asio)

The package boost-beast is compatible with built-in CMake targets of FindBoost.cmake:

    find_package(Boost REQUIRED COMPONENTS beast)
    target_link_libraries(main PRIVATE Boost::beast)

or the generated cmake configs via:

    find_package(boost_beast REQUIRED CONFIG)
    target_link_libraries(main PRIVATE Boost::beast)

The package boost-url is compatible with built-in CMake targets of FindBoost.cmake:

    find_package(Boost REQUIRED COMPONENTS url)
    target_link_libraries(main PRIVATE Boost::url)

or the generated cmake configs via:

    find_package(boost_url REQUIRED CONFIG)
    target_link_libraries(main PRIVATE Boost::url)
-->

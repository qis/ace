# TIFF
# https://cmake.org/cmake/help/latest/module/FindTIFF.html
#
#   find_package(TIFF REQUIRED)
#   target_link_libraries(main PRIVATE TIFF::TIFF TIFF::CXX)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

set(TIFF_VERSION_STRING ${TIFF_VERSION})
set(TIFF_INCLUDE_DIRS)

set(TIFF_LIBRARIES TIFF::TIFF)

include(CMakeFindDependencyMacro)
find_dependency(ZLIB REQUIRED)
find_dependency(LibLZMA REQUIRED)
find_dependency(zstd REQUIRED)
find_dependency(JPEG REQUIRED)
find_dependency(LERC REQUIRED)
find_dependency(WebP REQUIRED)

set(TIFF_LINK_LIBRARIES
  ZLIB::ZLIB
  LibLZMA::LibLZMA
  zstd::zstd
  JPEG::JPEG
  LERC::LERC
  WebP::WebP)

if(UNIX)
  list(APPEND TIFF_LINK_LIBRARIES m)
endif()

include(AceImportLibrary)
ace_import_library(TIFF::TIFF C NAMES tiff HEADERS tiffio.h
  LINK_LIBRARIES ${TIFF_LINK_LIBRARIES})

ace_import_library(TIFF::CXX CXX NAMES tiffxx HEADERS tiffio.hxx
  COMPILE_DEFINITIONS_SHARED TIFF_IMPORT
  LINK_LIBRARIES TIFF::TIFF)

set(TIFF_INCLUDE_DIR "${TIFF_INCLUDE_DIRS}" CACHE STRING "")
set(TIFF_LIBRARY "${TIFF_LIBRARIES}" CACHE STRING "")
set(TIFF_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

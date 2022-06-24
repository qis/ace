# https://cmake.org/cmake/help/v3.20/module/FindZLIB.html
#
#   find_package(ZLIB REQUIRED)
#   target_link_libraries(main PRIVATE ZLIB::ZLIB)
#
#   find_program(GZIP_EXECUTABLE gzip)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

set(ZLIB_VERSION_STRING ${ZLIB_VERSION})
set(ZLIB_INCLUDE_DIRS)

set(ZLIB_LIBRARIES ZLIB::ZLIB)

include(VcpkgImportLibrary)
vcpkg_import_library(ZLIB ZLIB C FILES zlib.h
  NAMES libz.so libz.a zlib.lib zlib1.dll
  REQUIRED ${ZLIB_FIND_REQUIRED})

set(ZLIB_MAJOR_VERSION ${ZLIB_VERSION_MAJOR})
set(ZLIB_MINOR_VERSION ${ZLIB_VERSION_MINOR})
set(ZLIB_PATCH_VERSION ${ZLIB_VERSION_PATCH})

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

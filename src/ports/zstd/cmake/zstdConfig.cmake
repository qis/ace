# Zstandard
#
#   find_package(zstd REQUIRED)
#   target_link_libraries(main PRIVATE zstd::zstd)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

set(ZSTD_VERSION_STRING ${zstd_VERSION})
set(ZSTD_VERSION ${ZSTD_VERSION_STRING})
set(ZSTD_INCLUDE_DIRS)

set(ZSTD_LIBRARIES zstd::zstd)

include(AceImportLibrary)
ace_import_library(zstd::zstd C NAMES zstd HEADERS zstd.h)

if(NOT TARGET zstd::libzstd_shared)
  add_library(zstd::libzstd_shared ALIAS zstd::zstd)
endif()

if(NOT TARGET zstd::libzstd_static)
  add_library(zstd::libzstd_static ALIAS zstd::zstd)
endif()

string(REPLACE "." ";" ZSTD_VERSION_LIST ${ZSTD_VERSION})
list(GET ZSTD_VERSION_LIST 0 ZSTD_VERSION_MAJOR)
list(GET ZSTD_VERSION_LIST 1 ZSTD_VERSION_MINOR)
list(GET ZSTD_VERSION_LIST 2 ZSTD_VERSION_PATCH)
set(ZSTD_VERSION_TWEAK 0)

set(ZSTD_INCLUDE_DIR "${ZSTD_INCLUDE_DIRS}" CACHE STRING "")
set(ZSTD_LIBRARY "${ZSTD_LIBRARIES}" CACHE STRING "")
set(ZSTD_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

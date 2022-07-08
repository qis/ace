# WebP
# https://github.com/WebKit/WebKit/blob/main/Source/cmake/FindWebP.cmake
#
#   find_package(WebP REQUIRED)
#   target_link_libraries(main PRIVATE WebP::WebP)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

set(WebP_VERSION_STRING ${WebP_VERSION})
set(WebP_COMPILE_OPTIONS)
set(WebP_INCLUDE_DIRS)

set(WebP_LIBRARIES WebP::WebP)

include(AceImportLibrary)
ace_import_library(WebP::WebP C NAMES webp HEADERS webp/types.h)

set(WEBP_INCLUDE_DIR "${WebP_INCLUDE_DIRS}" CACHE STRING "")
set(WEBP_LIBRARY "${WebP_LIBRARIES}" CACHE STRING "")
set(WEBP_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

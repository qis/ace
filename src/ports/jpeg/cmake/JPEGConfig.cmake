# TurboJPEG
# https://cmake.org/cmake/help/latest/module/FindJPEG.html
#
#   find_package(JPEG REQUIRED)
#   target_link_libraries(main PRIVATE JPEG::JPEG JPEG::Turbo)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

set(JPEG_VERSION_STRING ${JPEG_VERSION})
set(JPEG_INCLUDE_DIRS)

set(JPEG_LIBRARIES JPEG::JPEG)

include(AceImportLibrary)
ace_import_library(JPEG::JPEG C NAMES jpeg HEADERS jpeglib.h)
ace_import_library(JPEG::Turbo C NAMES turbojpeg HEADERS turbojpeg.h)

set(JPEG_INCLUDE_DIR "${JPEG_INCLUDE_DIRS}" CACHE STRING "")
set(JPEG_LIBRARY "${JPEG_LIBRARIES}" CACHE STRING "")
set(JPEG_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

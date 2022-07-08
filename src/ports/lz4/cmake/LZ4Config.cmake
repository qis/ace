# LZ4
#
#   find_package(LZ4 REQUIRED)
#   target_link_libraries(main PRIVATE LZ4::LZ4)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

set(LZ4_VERSION_STRING ${LZ4_VERSION})
set(LZ4_INCLUDE_DIRS)

set(LZ4_LIBRARIES LZ4::LZ4)

include(AceImportLibrary)
ace_import_library(LZ4::LZ4 C NAMES lz4 HEADERS lz4.h)

set(LZ4_INCLUDE_DIR "${LZ4_INCLUDE_DIRS}" CACHE STRING "")
set(LZ4_LIBRARY "${LZ4_LIBRARIES}" CACHE STRING "")
set(LZ4_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

# Brotli
#
#   find_package(Brotli REQUIRED)
#   target_link_libraries(main PRIVATE Brotli::Brotli)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

set(BROTLI_VERSION_STRING ${Brotli_VERSION})
set(BROTLI_VERSION ${BROTLI_VERSION_STRING})
set(BROTLI_INCLUDE_DIRS)

set(BROTLI_LIBRARIES Brotli::Brotli)

include(AceImportLibrary)

ace_import_library(Brotli::common C
  NAMES brotlicommon HEADERS brotli/types.h)

ace_import_library(Brotli::enc C
  NAMES brotlienc HEADERS brotli/encode.h
  LINK_LIBRARIES Brotli::common)

ace_import_library(Brotli::dec C
  NAMES brotlidec HEADERS brotli/decode.h
  LINK_LIBRARIES Brotli::common)

if(NOT TARGET Brotli::Brotli)
  add_library(Brotli::Brotli INTERFACE IMPORTED)
  set_target_properties(Brotli::Brotli PROPERTIES
    INTERFACE_LINK_LIBRARIES "Brotli::common;Brotli::enc;Brotli::dec")
endif()

string(REPLACE "." ";" BROTLI_VERSION_LIST ${BROTLI_VERSION})
list(GET BROTLI_VERSION_LIST 0 BROTLI_VERSION_MAJOR)
list(GET BROTLI_VERSION_LIST 1 BROTLI_VERSION_MINOR)
list(GET BROTLI_VERSION_LIST 2 BROTLI_VERSION_PATCH)
set(BROTLI_VERSION_TWEAK 0)

set(BROTLI_INCLUDE_DIR "${BROTLI_INCLUDE_DIRS}" CACHE STRING "")
set(BROTLI_LIBRARY "${BROTLI_LIBRARIES}" CACHE STRING "")
set(BROTLI_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

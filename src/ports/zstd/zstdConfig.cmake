cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

enable_language(C)

set(ZSTD_VERSION_STRING ${zstd_VERSION})
set(ZSTD_VERSION ${ZSTD_VERSION_STRING})

set(ZSTD_LIBRARY zstd::zstd)
set(ZSTD_LIBRARIES ${ZSTD_LIBRARY})

get_filename_component(ZSTD_INCLUDE_DIRS ${CMAKE_CURRENT_LIST_DIR} DIRECTORY)
get_filename_component(ZSTD_INCLUDE_DIRS ${ZSTD_INCLUDE_DIRS} DIRECTORY)
set(ZSTD_INCLUDE_DIRS ${ZSTD_INCLUDE_DIRS}/include)

include(CMakeFindDependencyMacro)
find_dependency(Threads REQUIRED)

set(ZSTD_LINK_LIBRARIES Threads::Threads)

if(UNIX)
  list(APPEND ZSTD_LINK_LIBRARIES m)
endif()

find_library(ZSTD_IMPORT_LOCATION NAMES zstd
    PATHS ${CMAKE_CURRENT_LIST_DIR}/../../lib
    NO_DEFAULT_PATH NO_CACHE REQUIRED)

if(NOT TARGET zstd::zstd)
  add_library(zstd::zstd UNKNOWN IMPORTED)
  set_target_properties(zstd::zstd PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${ZSTD_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${ZSTD_LINK_LIBRARIES}"
    IMPORTED_LOCATION "${ZSTD_IMPORT_LOCATION}"
    IMPORTED_LINK_INTERFACE_LANGUAGES "C")
endif()

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

set(ZSTD_INCLUDE_DIR "${ZSTD_INCLUDE_DIRS}" CACHE PATH "")
set(ZSTD_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

# OpenEXR Imath
#
#   find_package(Imath REQUIRED)
#   target_link_libraries(main PRIVATE Imath::Imath)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

set(IMATH_VERSION_STRING ${Imath_VERSION})
set(IMATH_VERSION ${IMATH_VERSION_STRING})

set(IMATH_LIBRARIES Imath::Imath)

include(CMakeFindDependencyMacro)
find_dependency(Threads REQUIRED)

include(AceImportLibrary)
ace_import_library(Imath::ImathConfig C
  HEADERS_LOCATIONS Imath HEADERS ImathConfig.h
  LINK_LIBRARIES Threads::Threads)

get_target_property(IMATH_INCLUDE_DIRS
  Imath::ImathConfig INTERFACE_INCLUDE_DIRECTORIES)

ace_import_library(Imath::Imath CXX NAMES imath
  LINK_LIBRARIES Imath::ImathConfig)

string(REPLACE "." ";" IMATH_VERSION_LIST ${IMATH_VERSION})
list(GET IMATH_VERSION_LIST 0 IMATH_VERSION_MAJOR)
list(GET IMATH_VERSION_LIST 1 IMATH_VERSION_MINOR)
list(GET IMATH_VERSION_LIST 2 IMATH_VERSION_PATCH)
set(IMATH_VERSION_TWEAK 0)

set(IMATH_INCLUDE_DIR "${IMATH_INCLUDE_DIRS}" CACHE STRING "")
set(IMATH_LIBRARY "${IMATH_LIBRARIES}" CACHE STRING "")
set(IMATH_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

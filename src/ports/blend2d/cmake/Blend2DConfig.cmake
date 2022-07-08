# Blend2D
#
#   find_package(Blend2D REQUIRED)
#   target_link_libraries(main PRIVATE Blend2D::Blend2D)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

set(BLEND2D_VERSION_STRING ${Blend2D_VERSION})
set(BLEND2D_VERSION ${BLEND2D_VERSION_STRING})
set(BLEND2D_INCLUDE_DIRS)

set(BLEND2D_LIBRARIES Blend2D::Blend2D)

include(CMakeFindDependencyMacro)
find_dependency(Threads REQUIRED)

set(BLEND2D_LINK_LIBRARIES Threads::Threads)

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  list(APPEND BLEND2D_LINK_LIBRARIES rt)
endif()

include(AceImportLibrary)
ace_import_library(Blend2D::Blend2D CXX NAMES blend2d HEADERS blend2d.h
  COMPILE_DEFINITIONS_STATIC BL_STATIC LINK_LIBRARIES ${BLEND2D_LINK_LIBRARIES})

string(REPLACE "." ";" BLEND2D_VERSION_LIST ${BLEND2D_VERSION})
list(GET BLEND2D_VERSION_LIST 0 BLEND2D_VERSION_MAJOR)
list(GET BLEND2D_VERSION_LIST 1 BLEND2D_VERSION_MINOR)
list(GET BLEND2D_VERSION_LIST 2 BLEND2D_VERSION_PATCH)
set(BLEND2D_VERSION_TWEAK 0)

set(BLEND2D_INCLUDE_DIR "${BLEND2D_INCLUDE_DIRS}" CACHE STRING "")
set(BLEND2D_LIBRARY "${BLEND2D_LIBRARIES}" CACHE STRING "")
set(BLEND2D_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)
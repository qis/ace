# oneAPI Threading Building Blocks
# https://github.com/Kitware/VTK/blob/master/CMake/FindTBB.cmake
#
#   find_package(TBB REQUIRED)
#   target_link_libraries(main PRIVATE TBB::tbb TBB::tbbmalloc)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

enable_language(CXX)

set(TBB_VERSION_STRING ${TBB_VERSION})
set(TBB_INCLUDE_DIRS)

set(TBB_LIBRARIES)
set(TBB_DEFINITIONS "\$<\$<CONFIG:Debug>:TBB_USE_DEBUG>")

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  list(APPEND TBB_DEFINITIONS "__TBB_NO_IMPLICIT_LINKAGE")
endif()

include(CMakeFindDependencyMacro)
find_dependency(Threads REQUIRED)

include(AceImportLibrary)

ace_import_library(TBB::tbb CXX NAMES tbb
  HEADERS oneapi/tbb.h tbb/tbb.h
  COMPILE_DEFINITIONS "${TBB_DEFINITIONS}"
  LINK_LIBRARIES "Threads::Threads")

ace_import_library(TBB::tbbmalloc C NAMES tbbmalloc
  COMPILE_DEFINITIONS "${TBB_DEFINITIONS}"
  LINK_LIBRARIES "Threads::Threads")

if(NOT TARGET TBB::tbbmalloc_proxy AND TARGET TBB::tbbmalloc)
  add_library(TBB::tbbmalloc_proxy ALIAS TBB::tbbmalloc)
endif()

set(TBB_INCLUDE_DIR "${TBB_INCLUDE_DIRS}" CACHE STRING "")
set(TBB_LIBRARY "${TBB_LIBRARIES}" CACHE STRING "")
set(TBB_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

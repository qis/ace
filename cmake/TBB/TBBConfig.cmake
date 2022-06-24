# https://github.com/oneapi-src/oneTBB
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

if(NOT TARGET TBB::tbb_shared)
  add_library(TBB::tbb_shared SHARED IMPORTED)
  set_target_properties(TBB::tbb_shared PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "${TBB_DEFINITIONS}"
    INTERFACE_LINK_LIBRARIES "Threads::Threads"
    IMPORTED_LINK_INTERFACE_LANGUAGES "CXX")
  if(WIN32)
    set_target_properties(TBB::tbb_shared PROPERTIES
      IMPORTED_LOCATION "${CMAKE_SYSROOT}/bin/tbbmalloc.dll"
      IMPORTED_IMPLIB "${CMAKE_SYSROOT}/shared/tbbmalloc.lib")
  else()
    set_target_properties(TBB::tbb_shared PROPERTIES
      IMPORTED_LOCATION "${CMAKE_SYSROOT}/lib/libtbbmalloc.so")
  endif()
endif()

if(NOT TARGET TBB::tbb_static)
  add_library(TBB::tbb_static STATIC IMPORTED)
  set_target_properties(TBB::tbb_static PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "${TBB_DEFINITIONS}"
    INTERFACE_LINK_LIBRARIES "Threads::Threads"
    IMPORTED_LINK_INTERFACE_LANGUAGES "CXX")
  if(WIN32)
    set_target_properties(TBB::tbb_static PROPERTIES
      IMPORTED_LOCATION "${CMAKE_SYSROOT}/static/tbbmalloc.lib")
  else()
    set_target_properties(TBB::tbb_static PROPERTIES
      IMPORTED_LOCATION "${CMAKE_SYSROOT}/lib/libtbbmalloc.a")
  endif()
endif()

if(NOT TARGET TBB::tbb)
  add_library(TBB::tbb INTERFACE IMPORTED)
  if(BUILD_SHARED_LIBS)
    set_target_properties(TBB::tbb PROPERTIES INTERFACE_LINK_LIBRARIES
      "TBB::tbb_shared")
  else()
    set_target_properties(TBB::tbb PROPERTIES INTERFACE_LINK_LIBRARIES
      "TBB::tbb_\$<IF:\$<CONFIG:Release>,static,shared>")
  endif()
endif()

if(NOT TARGET TBB::tbbmalloc_shared)
  add_library(TBB::tbbmalloc_shared SHARED IMPORTED)
  set_target_properties(TBB::tbbmalloc_shared PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "${TBB_DEFINITIONS}"
    INTERFACE_LINK_LIBRARIES "Threads::Threads"
    IMPORTED_LINK_INTERFACE_LANGUAGES "CXX")
  if(WIN32)
    set_target_properties(TBB::tbbmalloc_shared PROPERTIES
      IMPORTED_LOCATION "${CMAKE_SYSROOT}/bin/tbbmalloc.dll"
      IMPORTED_IMPLIB "${CMAKE_SYSROOT}/shared/tbbmalloc.lib")
  else()
    set_target_properties(TBB::tbbmalloc_shared PROPERTIES
      IMPORTED_LOCATION "${CMAKE_SYSROOT}/lib/libtbbmalloc.so")
  endif()
endif()

if(NOT TARGET TBB::tbbmalloc_static)
  add_library(TBB::tbbmalloc_static STATIC IMPORTED)
  set_target_properties(TBB::tbbmalloc_static PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "${TBB_DEFINITIONS}"
    INTERFACE_LINK_LIBRARIES "Threads::Threads"
    IMPORTED_LINK_INTERFACE_LANGUAGES "CXX")
  if(WIN32)
    set_target_properties(TBB::tbbmalloc_static PROPERTIES
      IMPORTED_LOCATION "${CMAKE_SYSROOT}/static/tbbmalloc.lib")
  else()
    set_target_properties(TBB::tbbmalloc_static PROPERTIES
      IMPORTED_LOCATION "${CMAKE_SYSROOT}/lib/libtbbmalloc.a")
  endif()
endif()

if(NOT TARGET TBB::tbbmalloc)
  add_library(TBB::tbbmalloc INTERFACE IMPORTED)
  if(BUILD_SHARED_LIBS)
    set_target_properties(TBB::tbbmalloc PROPERTIES INTERFACE_LINK_LIBRARIES
      "TBB::tbbmalloc_shared")
  else()
    set_target_properties(TBB::tbbmalloc PROPERTIES INTERFACE_LINK_LIBRARIES
      "TBB::tbbmalloc_\$<IF:\$<CONFIG:Release>,static,shared>")
  endif()
endif()

if(NOT TARGET TBB::tbbmalloc_proxy)
  add_library(TBB::tbbmalloc_proxy ALIAS TBB::tbbmalloc)
endif()

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

set(LUAJIT_JIT_DIR ${CMAKE_CURRENT_LIST_DIR}/jit)
if(NOT IS_DIRECTORY ${LUAJIT_JIT_DIR})
  message(FATAL_ERROR "Missing LuaJIT jit directory: ${LUAJIT_JIT_DIR}")
endif()
message(VERBOSE "Found LuaJIT jit directory: ${LUAJIT_JIT_DIR}")

enable_language(CXX)

set(LUAJIT_VERSION_STRING ${LuaJIT_VERSION})
set(LUAJIT_VERSION ${LUAJIT_VERSION_STRING})

set(LUAJIT_LIBRARY LuaJIT::LuaJIT)
set(LUAJIT_LIBRARIES ${LUAJIT_LIBRARY})

get_filename_component(LUAJIT_INCLUDE_DIRS ${CMAKE_CURRENT_LIST_DIR} DIRECTORY)
get_filename_component(LUAJIT_INCLUDE_DIRS ${LUAJIT_INCLUDE_DIRS} DIRECTORY)
set(LUAJIT_INCLUDE_DIRS ${LUAJIT_INCLUDE_DIRS}/include/luajit)

include(CMakeFindDependencyMacro)
find_dependency(Threads REQUIRED)

set(LUAJIT_LINK_LIBRARIES Threads::Threads)

if(UNIX)
  list(APPEND LUAJIT_LINK_LIBRARIES m)
endif()

find_library(LUAJIT_IMPORT_LOCATION NAMES luajit
    PATHS ${CMAKE_CURRENT_LIST_DIR}/../../lib
    NO_DEFAULT_PATH NO_CACHE REQUIRED)

if(NOT TARGET LuaJIT::LuaJIT)
  add_library(LuaJIT::LuaJIT UNKNOWN IMPORTED)
  set_target_properties(LuaJIT::LuaJIT PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${LUAJIT_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${LUAJIT_LINK_LIBRARIES}"
    IMPORTED_LOCATION "${LUAJIT_IMPORT_LOCATION}"
    IMPORTED_LINK_INTERFACE_LANGUAGES "CXX")

  if(WIN32 AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set_target_properties(LuaJIT::LuaJIT PROPERTIES
      INTERFACE_COMPILE_DEFINITIONS "LUA_BUILD_AS_DLL")
  endif()
endif()

string(REPLACE "." ";" LUAJIT_VERSION_LIST ${LUAJIT_VERSION})
list(GET LUAJIT_VERSION_LIST 0 LUAJIT_VERSION_MAJOR)
list(GET LUAJIT_VERSION_LIST 1 LUAJIT_VERSION_MINOR)
list(GET LUAJIT_VERSION_LIST 2 LUAJIT_VERSION_PATCH)
set(LUAJIT_VERSION_TWEAK 0)

set(LUAJIT_INCLUDE_DIR "${LUAJIT_INCLUDE_DIRS}" CACHE PATH "")
set(LUAJIT_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

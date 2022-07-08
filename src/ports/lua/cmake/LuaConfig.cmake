# Lua
# https://cmake.org/cmake/help/latest/module/FindLua.html
#
#   find_package(Lua REQUIRED)
#   target_link_libraries(main PRIVATE Lua::Lua)
#
#   find_program(LUA_EXECUTABLE lua REQUIRED)
#   find_program(LUAC_EXECUTABLE luac REQUIRED)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

set(LUA_VERSION_STRING ${Lua_VERSION})
set(LUA_VERSION ${LUA_VERSION_STRING})
set(LUA_INCLUDE_DIRS)

set(LUA_LIBRARIES Lua::Lua)

include(CMakeFindDependencyMacro)
find_dependency(Threads REQUIRED)

set(LUA_LINK_LIBRARIES Threads::Threads)

if(UNIX)
  list(APPEND LUA_LINK_LIBRARIES m)
endif()

include(AceImportLibrary)
ace_import_library(Lua::Lua C NAMES lua
  HEADERS_LOCATIONS lua HEADERS lua.h
  LINK_LIBRARIES ${LUA_LINK_LIBRARIES})

get_target_property(LUA_INCLUDE_DIRS
  Lua::Lua INTERFACE_INCLUDE_DIRECTORIES)

string(REPLACE "." ";" LUA_VERSION_LIST ${LUA_VERSION})
list(GET LUA_VERSION_LIST 0 LUA_VERSION_MAJOR)
list(GET LUA_VERSION_LIST 1 LUA_VERSION_MINOR)
list(GET LUA_VERSION_LIST 2 LUA_VERSION_PATCH)
set(LUA_VERSION_TWEAK 0)

set(LUA_INCLUDE_DIR "${LUA_INCLUDE_DIRS}" CACHE STRING "")
set(LUA_LIBRARY "${LUA_LIBRARIES}" CACHE STRING "")
set(LUA_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

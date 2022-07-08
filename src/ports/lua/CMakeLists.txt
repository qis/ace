cmake_minimum_required(VERSION 3.22 FATAL_ERROR)
project(lua VERSION 5.3.4 LANGUAGES C)

option(LUA_SKIP_SHARED "Do not build shared library" OFF)
option(LUA_SKIP_STATIC "Do not build static library" OFF)
option(LUA_SKIP_TOOLS "Do not build programs (disables readline dependency)" ${LUA_SKIP_STATIC})
option(LUA_SKIP_HEADERS "Do not install headers" OFF)

# Headers
set(headers
  src/src/lua.h
  src/src/luaconf.h
  src/src/lualib.h
  src/src/lauxlib.h
  src/src/lua.hpp)

# Sources
set(sources
  src/src/lapi.c
  src/src/lcode.c
  src/src/lctype.c
  src/src/ldebug.c
  src/src/ldo.c
  src/src/ldump.c
  src/src/lfunc.c
  src/src/lgc.c
  src/src/llex.c
  src/src/lmem.c
  src/src/lobject.c
  src/src/lopcodes.c
  src/src/lparser.c
  src/src/lstate.c
  src/src/lstring.c
  src/src/ltable.c
  src/src/ltm.c
  src/src/lundump.c
  src/src/lvm.c
  src/src/lzio.c
  src/src/lauxlib.c
  src/src/lbaselib.c
  src/src/lbitlib.c
  src/src/lcorolib.c
  src/src/ldblib.c
  src/src/liolib.c
  src/src/lmathlib.c
  src/src/loslib.c
  src/src/lstrlib.c
  src/src/ltablib.c
  src/src/lutf8lib.c
  src/src/loadlib.c
  src/src/linit.c)

find_package(Threads REQUIRED)

if(NOT LUA_SKIP_SHARED)
  add_library(lua_shared SHARED ${headers} ${sources})
  target_compile_features(lua_shared PRIVATE c_std_11)
  target_compile_options(lua_shared PRIVATE -Wno-string-plus-int)
  target_include_directories(lua_shared PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/src>
    $<INSTALL_INTERFACE:include>)

  if(WIN32)
    target_compile_definitions(lua_shared
      PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN
      PUBLIC LUA_BUILD_AS_DLL)
  endif()

  if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    target_compile_definitions(lua_shared PRIVATE LUA_USE_LINUX)
  elseif(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
    target_compile_definitions(lua_shared PRIVATE LUA_USE_POSIX)
  endif()

  target_link_libraries(lua_shared PRIVATE Threads::Threads)

  set_target_properties(lua_shared PROPERTIES
    MSVC_RUNTIME_LIBRARY MultiThreadedDLL
    ARCHIVE_OUTPUT_DIRECTORY shared
    OUTPUT_NAME lua)

  install(TARGETS lua_shared
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib$<$<PLATFORM_ID:Windows>:/shared>
    LIBRARY DESTINATION lib$<$<PLATFORM_ID:Windows>:/shared>)
endif()

if(NOT LUA_SKIP_STATIC)
  add_library(lua_static STATIC ${headers} ${sources})
  target_compile_features(lua_static PRIVATE c_std_11)
  target_compile_options(lua_static PRIVATE -Wno-string-plus-int)
  target_include_directories(lua_static PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/src>
    $<INSTALL_INTERFACE:include>)

  if(WIN32)
    target_compile_definitions(lua_static PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN)
  endif()

  if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    target_compile_definitions(lua_static PRIVATE LUA_USE_LINUX)
  elseif(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
    target_compile_definitions(lua_static PRIVATE LUA_USE_POSIX)
  endif()

  target_link_libraries(lua_static PUBLIC Threads::Threads)

  set_target_properties(lua_static PROPERTIES
    MSVC_RUNTIME_LIBRARY MultiThreaded
    ARCHIVE_OUTPUT_DIRECTORY static
    OUTPUT_NAME lua)

  install(TARGETS lua_static
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib$<$<PLATFORM_ID:Windows>:/static>
    LIBRARY DESTINATION lib$<$<PLATFORM_ID:Windows>:/static>)

  if(NOT LUA_SKIP_TOOLS)
    # Executables
    add_executable(lua src/src/lua.c)
    add_executable(luac src/src/luac.c)

    target_compile_options(lua PRIVATE -Wno-string-plus-int)
    target_compile_options(luac PRIVATE -Wno-string-plus-int)

    find_package(Editline REQUIRED)
    target_link_libraries(lua PRIVATE Editline::Editline lua_static)
    target_link_libraries(luac PRIVATE Editline::Editline lua_static)

    if(UNIX)
      target_link_libraries(lua PRIVATE m)
      target_link_libraries(luac PRIVATE m)
    endif()

    set_target_properties(lua PROPERTIES
      MSVC_RUNTIME_LIBRARY MultiThreaded
      INSTALL_RPATH "$ORIGIN/../lib")

    set_target_properties(luac PROPERTIES
      MSVC_RUNTIME_LIBRARY MultiThreaded
      INSTALL_RPATH "$ORIGIN/../lib")

    install(TARGETS lua luac
      RUNTIME DESTINATION tools)
  endif()
endif()

if(NOT LUA_SKIP_HEADERS)
  install(FILES ${headers} DESTINATION include/lua)
endif()

# Linux Toolchain
include_guard(GLOBAL)
get_filename_component(ACE ${CMAKE_CURRENT_LIST_DIR} ABSOLUTE CACHE)

# System
set(CMAKE_CROSSCOMPILING ON CACHE BOOL "" FORCE)
set(CMAKE_SYSTEM_NAME Linux CACHE STRING "" FORCE)
set(CMAKE_SYSTEM_VERSION 5.10.0 CACHE STRING "" FORCE)
set(CMAKE_SYSTEM_PROCESSOR AMD64 CACHE STRING "" FORCE)
set(CMAKE_SYSROOT ${ACE}/sys/linux CACHE PATH "" FORCE)

# Search Paths
set(CMAKE_FIND_ROOT_PATH ${ACE} CACHE PATH "" FORCE)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY CACHE STRING "" FORCE)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY CACHE STRING "" FORCE)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY CACHE STRING "" FORCE)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH CACHE STRING "" FORCE)
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG ON CACHE BOOL "" FORCE)

set(ENV{PKG_CONFIG_PATH} ${ACE}/ports/linux/lib/pkgconfig)
set(CMAKE_PREFIX_PATH ${ACE}/ports/linux CACHE PATH "")
list(APPEND CMAKE_MODULE_PATH ${ACE}/cmake)

# Program Paths
file(GLOB ACE_PORTS_TOOLS_PATH
  ${ACE}/ports/linux/tools
  ${ACE}/ports/linux/tools/*
  LIST_DIRECTORIES ON)

set(ACE_PROGRAM_PATH ${ACE}/bin)
foreach(path ${ACE_PORTS_TOOLS_PATH})
  if(IS_DIRECTORY ${path})
    list(APPEND ACE_PROGRAM_PATH ${path})
  endif()
endforeach()
unset(ACE_PORTS_TOOLS_PATH)

set(CMAKE_SYSTEM_PROGRAM_PATH ${ACE_PROGRAM_PATH} CACHE PATH "")
unset(ACE_SYSTEM_PROGRAM_PATH)

# Compiler
find_program(CMAKE_C_COMPILER clang PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_CXX_COMPILER clang++ PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_CXX_COMPILER_CLANG_SCAN_DEPS clang-scan-deps PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_ASM_COMPILER clang PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_ASM_NASM_COMPILER yasm PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)

# Compiler Targets
set(CMAKE_C_COMPILER_TARGET x86_64-pc-linux-gnu CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER_TARGET x86_64-pc-linux-gnu CACHE STRING "" FORCE)
set(CMAKE_ASM_COMPILER_TARGET x86_64-pc-linux-gnu CACHE STRING "" FORCE)
set(CMAKE_ASM_NASM_COMPILER_TARGET x86_64-pc-linux-gnu CACHE STRING "" FORCE)

# Compiler Flags
set(CMAKE_C_EXTENSIONS OFF CACHE BOOL "")
set(CMAKE_CXX_EXTENSIONS OFF CACHE BOOL "")

cmake_policy(SET CMP0063 NEW)
set(CMAKE_C_VISIBILITY_PRESET hidden CACHE STRING "")
set(CMAKE_CXX_VISIBILITY_PRESET hidden CACHE STRING "")

cmake_policy(SET CMP0069 NEW)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF CACHE BOOL "")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_DEBUG OFF CACHE BOOL "")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE ON CACHE BOOL "")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_MINSIZEREL ON CACHE BOOL "")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELWITHDEBINFO OFF CACHE BOOL "")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_COVERAGE OFF CACHE BOOL "")

set(CMAKE_C_FLAGS_INIT "-march=x86-64-v2 -fasm -pthread")
set(CMAKE_C_FLAGS_DEBUG_INIT "")
set(CMAKE_C_FLAGS_RELEASE_INIT "")
set(CMAKE_C_FLAGS_MINSIZEREL_INIT "")
set(CMAKE_C_FLAGS_RELWITHDEBINFO_INIT "")
set(CMAKE_C_FLAGS_COVERAGE_INIT "-g -fprofile-instr-generate -fcoverage-mapping")

set(CMAKE_CXX_FLAGS_INIT "${CMAKE_C_FLAGS_INIT} -fno-rtti -fexperimental-library")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "${CMAKE_C_FLAGS_DEBUG_INIT}")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "${CMAKE_C_FLAGS_RELEASE_INIT}")
set(CMAKE_CXX_FLAGS_MINSIZEREL_INIT "${CMAKE_C_FLAGS_MINSIZEREL_INIT}")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "${CMAKE_C_FLAGS_RELWITHDEBINFO_INIT}")
set(CMAKE_CXX_FLAGS_COVERAGE_INIT "${CMAKE_C_FLAGS_COVERAGE_INIT}")

# Linker
find_program(CMAKE_AR llvm-ar PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_NM llvm-nm PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_LINKER lld PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)

# Linker Flags
cmake_policy(SET CMP0083 NEW)
set(CMAKE_POSITION_INDEPENDENT_CODE ON CACHE BOOL "")

cmake_policy(SET CMP0056 NEW)
foreach(LINKER SHARED MODULE EXE)
  set(CMAKE_${LINKER}_LINKER_FLAGS_INIT "-Wl,--undefined-version")
  set(CMAKE_${LINKER}_LINKER_FLAGS_DEBUG_INIT "")
  set(CMAKE_${LINKER}_LINKER_FLAGS_RELEASE_INIT "-s")
  set(CMAKE_${LINKER}_LINKER_FLAGS_MINSIZEREL_INIT "-s")
  set(CMAKE_${LINKER}_LINKER_FLAGS_RELWITHDEBINFO_INIT "")
  set(CMAKE_${LINKER}_LINKER_FLAGS_COVERAGE_INIT "")
endforeach()

# Ninja
if(CMAKE_GENERATOR MATCHES "^Ninja")
  find_program(CMAKE_MAKE_PROGRAM ninja PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
endif()

# Tools
find_program(CMAKE_RANLIB llvm-ranlib PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_OBJCOPY llvm-objcopy PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_OBJDUMP llvm-objdump PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_STRIP llvm-strip PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_SIZE llvm-size PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)

# Runtime Path
set(CMAKE_BUILD_RPATH_USE_ORIGIN ON CACHE BOOL "")
set(CMAKE_BUILD_RPATH ${ACE}/sys/linux/lib CACHE PATH "")

# Tests
set_property(GLOBAL PROPERTY CTEST_TARGETS_ADDED 1)

# Configurations
set_property(GLOBAL PROPERTY DEBUG_CONFIGURATIONS Debug RelWithDebInfo Coverage)

set(CMAKE_MAP_IMPORTED_CONFIG_DEBUG ";Release" CACHE STRING "")
set(CMAKE_MAP_IMPORTED_CONFIG_MINSIZEREL ";Release" CACHE STRING "")
set(CMAKE_MAP_IMPORTED_CONFIG_RELWITHDEBINFO ";Release" CACHE STRING "")
set(CMAKE_MAP_IMPORTED_CONFIG_COVERAGE ";Release" CACHE STRING "")

# Platform Variables
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES
  BUILD_SHARED_LIBS
  CMAKE_TOOLCHAIN_FILE
  CACHE STRING "")

# Ports
macro(_add_library)
  add_library(${ARGV})
endmacro()

if(NOT DEFINED VCPKG_TARGET_TRIPLET)
  set(VCPKG_TARGET_TRIPLET linux)
  set(VCPKG_INSTALLED_DIR ${ACE}/ports)
  set(_VCPKG_INSTALLED_DIR ${VCPKG_INSTALLED_DIR})
endif()

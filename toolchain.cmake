# Toolchain
include_guard(GLOBAL)
get_filename_component(ACE ${CMAKE_CURRENT_LIST_DIR} ABSOLUTE CACHE)

# Target
set(VCPKG_TARGET_TRIPLET linux-shared CACHE STRING "")
if(NOT ${VCPKG_TARGET_TRIPLET} MATCHES "^(linux|mingw)-(static|shared)$")
  message(FATAL_ERROR "Unsupported target triplet: ${VCPKG_TARGET_TRIPLET}")
endif()

string(REPLACE "-" ";" VCPKG_TARGET_TRIPLET_LIST ${VCPKG_TARGET_TRIPLET})
list(GET VCPKG_TARGET_TRIPLET_LIST 0 VCPKG_TARGET_SYSROOT)
list(GET VCPKG_TARGET_TRIPLET_LIST 1 VCPKG_LIBRARY_LINKAGE)

if(VCPKG_TARGET_SYSROOT STREQUAL "linux")
  set(CMAKE_BUILD_RPATH ${ACE}/lib/x86_64-pc-linux-gnu CACHE PATH "")
  set(CMAKE_BUILD_RPATH_USE_ORIGIN ON CACHE BOOL "")
elseif(VCPKG_TARGET_SYSROOT STREQUAL "mingw")
  set(CMAKE_CROSSCOMPILING ON CACHE BOOL "" FORCE)
  set(CMAKE_SYSTEM_NAME Windows CACHE STRING "" FORCE)
  set(CMAKE_SYSTEM_VERSION 10.0 CACHE STRING "" FORCE)
  set(CMAKE_SYSTEM_PROCESSOR AMD64 CACHE STRING "" FORCE)
  set(CMAKE_SYSROOT ${ACE}/sys/mingw CACHE PATH "")
  set(CMAKE_C_COMPILER_TARGET x86_64-w64-mingw32 CACHE STRING "")
  set(CMAKE_CXX_COMPILER_TARGET x86_64-w64-mingw32 CACHE STRING "")
  set(CMAKE_ASM_COMPILER_TARGET x86_64-w64-mingw32 CACHE STRING "")
  set(CMAKE_ASM_NASM_COMPILER_TARGET x86_64-w64-mingw32 CACHE STRING "")
endif()

# Search Paths
set(CMAKE_FIND_ROOT_PATH ${ACE} CACHE PATH "")
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY CACHE STRING "")
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY CACHE STRING "")
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY CACHE STRING "")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH CACHE STRING "")
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG ON CACHE BOOL "")

set(VCPKG_SYSTEM_PROGRAM_PATH)

file(GLOB VCPKG_INSTALLED_TOOLS_DIRECTORIES
  ${ACE}/vcpkg/installed/linux-shared/tools/*
  ${ACE}/vcpkg/installed/linux-static/tools/*
  LIST_DIRECTORIES true)

foreach(path ${VCPKG_INSTALLED_TOOLS_DIRECTORIES})
  if(IS_DIRECTORY ${path})
    list(APPEND VCPKG_SYSTEM_PROGRAM_PATH ${path})
  endif()
endforeach()

set(CMAKE_SYSTEM_PROGRAM_PATH
  ${ACE}/bin
  ${ACE}/sys/${VCPKG_TARGET_SYSROOT}/bin
  ${VCPKG_SYSTEM_PROGRAM_PATH} CACHE PATH "")

# Modules
list(INSERT CMAKE_MODULE_PATH 0 ${ACE}/src/cmake)

# Configs
if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
  set(CMAKE_PREFIX_PATH ${ACE}/vcpkg/installed/${VCPKG_TARGET_TRIPLET} CACHE PATH "")
endif()

# Compiler
set(CMAKE_C_COMPILER_WORKS ON CACHE BOOL "")
set(CMAKE_CXX_COMPILER_WORKS ON CACHE BOOL "")
set(CMAKE_ASM_COMPILER_WORKS ON CACHE BOOL "")
set(CMAKE_ASM_NASM_COMPILER_WORKS ON CACHE BOOL "")

find_program(CMAKE_C_COMPILER clang PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_CXX_COMPILER clang++ PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_ASM_COMPILER clang PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_ASM_NASM_COMPILER yasm PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)

# Compiler Flags
set(CMAKE_C_EXTENSIONS OFF CACHE BOOL "")
set(CMAKE_CXX_EXTENSIONS OFF CACHE BOOL "")
set(CMAKE_POSITION_INDEPENDENT_CODE ON CACHE BOOL "")

cmake_policy(SET CMP0069 NEW)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF CACHE BOOL "")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_DEBUG OFF CACHE BOOL "")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE ON CACHE BOOL "")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_MINSIZEREL ON CACHE BOOL "")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELWITHDEBINFO OFF CACHE BOOL "")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_COVERAGE OFF CACHE BOOL "")

if(VCPKG_TARGET_SYSROOT STREQUAL "mingw")
  # Embed debug information.
  cmake_policy(SET CMP0141 NEW)
  set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT Embedded CACHE STRING "")

  # Use release runtime library.
  cmake_policy(SET CMP0091 NEW)
  if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded CACHE STRING "")
  else()
    set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreadedDLL CACHE STRING "")
  endif()

  # Disable warnings.
  cmake_policy(SET CMP0092 NEW)
endif()

set(CFLAGS "-march=x86-64-v3 -fasm -mavx2")
set(CFLAGS "${CFLAGS} -fmerge-all-constants")
set(CFLAGS "${CFLAGS} -fdiagnostics-absolute-paths")

# https://github.com/microsoft/STL/wiki/Macro-_MSVC_STL_UPDATE
if(VCPKG_TARGET_SYSROOT STREQUAL "mingw")
  set(CFLAGS "${CFLAGS} -fms-compatibility-version=19.36")
  set(CFLAGS "${CFLAGS} -Wno-language-extension-token")
  set(CFLAGS "${CFLAGS} -DWINVER=0x0A00 -D_WIN32_WINNT=0x0A00")
endif()

set(CMAKE_C_FLAGS_INIT "${CFLAGS} ${VCPKG_C_FLAGS}")
set(CMAKE_C_FLAGS_DEBUG_INIT "${VCPKG_C_FLAGS_DEBUG}")
set(CMAKE_C_FLAGS_RELEASE_INIT "${VCPKG_C_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_MINSIZEREL_INIT "${VCPKG_C_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_RELWITHDEBINFO_INIT "${VCPKG_C_FLAGS_DEBUG}")
set(CMAKE_C_FLAGS_COVERAGE_INIT "${VCPKG_C_FLAGS_DEBUG} -g -fprofile-instr-generate -fcoverage-mapping")

set(CMAKE_CXX_FLAGS_INIT "${CFLAGS} ${VCPKG_CXX_FLAGS}")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "${VCPKG_CXX_FLAGS_DEBUG}")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "${VCPKG_CXX_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_MINSIZEREL_INIT "${VCPKG_CXX_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "${VCPKG_CXX_FLAGS_DEBUG}")
set(CMAKE_CXX_FLAGS_COVERAGE_INIT "${VCPKG_CXX_FLAGS_DEBUG} -g -fprofile-instr-generate -fcoverage-mapping")

unset(CFLAGS)

# Linker
find_program(CMAKE_AR llvm-ar PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_NM llvm-nm PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_LINKER lld PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)

# Linker Flags
if(VCPKG_TARGET_SYSROOT STREQUAL "linux")
  set(LDFLAGS "-ldl")
  set(LDFLAGS_DEBUG "")
  set(LDFLAGS_RELEASE "-s")
elseif(VCPKG_TARGET_SYSROOT STREQUAL "mingw")
  set(LDFLAGS "-Xlinker /MANIFEST:NO")
  set(LDFLAGS_DEBUG "-Xlinker /DEBUG -Xlinker /INCREMENTAL")
  set(LDFLAGS_RELEASE "-Xlinker /OPT:REF -Xlinker /OPT:ICF -Xlinker /INCREMENTAL:NO -s")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  set(LDFLAGS "${LDFLAGS} -static-libstdc++")
endif()

foreach(LINKER SHARED MODULE EXE)
  set(CMAKE_${LINKER}_LINKER_FLAGS_INIT "${LDFLAGS} ${VCPKG_LINKER_FLAGS}")
  set(CMAKE_${LINKER}_LINKER_FLAGS_DEBUG_INIT "${LDFLAGS_DEBUG} ${VCPKG_LINKER_FLAGS_DEBUG}")
  set(CMAKE_${LINKER}_LINKER_FLAGS_RELEASE_INIT "${LDFLAGS_RELEASE} ${VCPKG_LINKER_FLAGS_RELEASE}")
  set(CMAKE_${LINKER}_LINKER_FLAGS_MINSIZEREL_INIT "${LDFLAGS_RELEASE} ${VCPKG_LINKER_FLAGS_RELEASE}")
  set(CMAKE_${LINKER}_LINKER_FLAGS_RELWITHDEBINFO_INIT "${LDFLAGS_DEBUG} ${VCPKG_LINKER_FLAGS_DEBUG}")
  set(CMAKE_${LINKER}_LINKER_FLAGS_COVERAGE_INIT "${LDFLAGS_DEBUG} ${VCPKG_LINKER_FLAGS_DEBUG}")
endforeach()

unset(LDFLAGS_RELEASE)
unset(LDFLAGS_DEBUG)
unset(LDFLAGS)

# Resource Compiler
if(VCPKG_TARGET_SYSROOT STREQUAL "mingw")
  find_program(CMAKE_RC_COMPILER llvm-windres PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
  set(CMAKE_RC_FLAGS_INIT "-I ${ACE}/sys/mingw/include")
endif()

# Tools
find_program(CMAKE_RANLIB llvm-ranlib PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_OBJCOPY llvm-objcopy PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_OBJDUMP llvm-objdump PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_STRIP llvm-strip PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_SIZE llvm-size PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)

if(VCPKG_TARGET_SYSROOT STREQUAL "mingw")
  find_program(CMAKE_DLLTOOL llvm-dlltool PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
endif()

# Configurations
set_property(GLOBAL PROPERTY DEBUG_CONFIGURATIONS Debug RelWithDebInfo)

set(CMAKE_MAP_IMPORTED_CONFIG_DEBUG ";Release" CACHE STRING "" FORCE)
set(CMAKE_MAP_IMPORTED_CONFIG_MINSIZEREL ";Release" CACHE STRING "" FORCE)
set(CMAKE_MAP_IMPORTED_CONFIG_RELWITHDEBINFO ";Release" CACHE STRING "" FORCE)
set(CMAKE_MAP_IMPORTED_CONFIG_COVERAGE ";Release" CACHE STRING "" FORCE)

# Environment
set(ENV{PKG_CONFIG_PATH} "${ACE}/vcpkg/installed/${VCPKG_TARGET_TRIPLET}/lib/pkgconfig")

# Cache
if(ENABLE_CCACHE)
  find_program(CCACHE ccache REQUIRED NO_CACHE)
  set(CMAKE_C_COMPILER_LAUNCHER ${CCACHE} CACHE PATH "")
  set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE} CACHE PATH "")
  unset(CCACHE)
endif()

# Vcpkg
macro(_add_library)
  add_library(${ARGV})
endmacro()

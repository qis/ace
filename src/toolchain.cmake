# Toolchain
if(NOT DEFINED ACE)
  message(FATAL_ERROR "Missing define: ACE")
endif()

# Search Paths
set(CMAKE_FIND_ROOT_PATH ${ACE} CACHE PATH "" FORCE)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY CACHE STRING "" FORCE)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY CACHE STRING "" FORCE)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY CACHE STRING "" FORCE)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH CACHE STRING "" FORCE)
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG ON CACHE BOOL "" FORCE)

# Program Paths
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
  file(GLOB ACE_INSTALLED_TOOLS_DIRECTORIES
    ${ACE}/vcpkg/installed/ace-linux-shared/tools
    ${ACE}/vcpkg/installed/ace-linux-shared/tools/*
    LIST_DIRECTORIES ON)
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
  file(GLOB ACE_INSTALLED_TOOLS_DIRECTORIES
    ${ACE}/vcpkg/installed/ace-mingw-shared/tools
    ${ACE}/vcpkg/installed/ace-mingw-shared/tools/*
    LIST_DIRECTORIES ON)
endif()

set(ACE_SYSTEM_PROGRAM_PATH)
foreach(path ${ACE_INSTALLED_TOOLS_DIRECTORIES})
  if(IS_DIRECTORY ${path})
    list(APPEND ACE_SYSTEM_PROGRAM_PATH ${path})
  endif()
endforeach()
unset(ACE_INSTALLED_TOOLS_DIRECTORIES)

set(CMAKE_SYSTEM_PROGRAM_PATH ${ACE}/bin ${ACE_SYSTEM_PROGRAM_PATH} CACHE PATH "")
unset(ACE_SYSTEM_PROGRAM_PATH)

# Prefix Path
foreach(VAR ACE_INSTALLED_SHARED ACE_INSTALLED_STATIC)
  if(NOT DEFINED ${VAR})
    message(FATAL_ERROR "Missing define: ${VAR}")
  endif()
endforeach()

if(NOT DEFINED VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
  if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" OR BUILD_SHARED_LIBS)
    set(CMAKE_PREFIX_PATH ${ACE_INSTALLED_SHARED} CACHE PATH "")
    set(ENV{PKG_CONFIG_PATH} "${ACE_INSTALLED_SHARED}/lib/pkgconfig")
  else()
    set(CMAKE_PREFIX_PATH ${ACE_INSTALLED_STATIC} CACHE PATH "")
    set(ENV{PKG_CONFIG_PATH} "${ACE_INSTALLED_STATIC}/lib/pkgconfig")
  endif()
endif()

# Compiler
find_program(CMAKE_C_COMPILER clang PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_CXX_COMPILER clang++ PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_CXX_COMPILER_CLANG_SCAN_DEPS clang-scan-deps PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_ASM_COMPILER clang PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_ASM_NASM_COMPILER yasm PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)

# Compiler Flags
set(CMAKE_C_EXTENSIONS OFF CACHE BOOL "")
set(CMAKE_CXX_EXTENSIONS OFF CACHE BOOL "")
set(CMAKE_POSITION_INDEPENDENT_CODE ON CACHE BOOL "")

if(NOT DEFINED VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
  set(CMAKE_CXX_STANDARD 20 CACHE STRING "")
  set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE BOOL "")
endif()

cmake_policy(SET CMP0069 NEW)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF CACHE BOOL "")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_DEBUG OFF CACHE BOOL "")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE ON CACHE BOOL "")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_MINSIZEREL ON CACHE BOOL "")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELWITHDEBINFO OFF CACHE BOOL "")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_COVERAGE OFF CACHE BOOL "")

if(DEFINED ACE_C_FLAGS)
  set(ACE_C_FLAGS "-march=x86-64 -fasm ${ACE_C_FLAGS}")
else()
  set(ACE_C_FLAGS "-march=x86-64 -fasm")
endif()

set(ACE_C_FLAGS "${ACE_C_FLAGS} -fmerge-all-constants")
set(ACE_C_FLAGS "${ACE_C_FLAGS} -fdiagnostics-absolute-paths")

set(CMAKE_C_FLAGS_INIT "${ACE_C_FLAGS} ${VCPKG_C_FLAGS}")
set(CMAKE_C_FLAGS_DEBUG_INIT "${VCPKG_C_FLAGS_DEBUG}")
set(CMAKE_C_FLAGS_RELEASE_INIT "${VCPKG_C_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_MINSIZEREL_INIT "${VCPKG_C_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_RELWITHDEBINFO_INIT "${VCPKG_C_FLAGS_DEBUG}")
set(CMAKE_C_FLAGS_COVERAGE_INIT "${VCPKG_C_FLAGS_DEBUG} -g -fprofile-instr-generate -fcoverage-mapping")

set(ACE_C_FLAGS "${ACE_C_FLAGS} -fno-rtti")
set(ACE_C_FLAGS "${ACE_C_FLAGS} -fexperimental-library")

set(CMAKE_CXX_FLAGS_INIT "${ACE_C_FLAGS} ${VCPKG_CXX_FLAGS}")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "${VCPKG_CXX_FLAGS_DEBUG}")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "${VCPKG_CXX_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_MINSIZEREL_INIT "${VCPKG_CXX_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "${VCPKG_CXX_FLAGS_DEBUG}")
set(CMAKE_CXX_FLAGS_COVERAGE_INIT "${VCPKG_CXX_FLAGS_DEBUG} -g -fprofile-instr-generate -fcoverage-mapping")

# Linker
find_program(CMAKE_AR llvm-ar PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_NM llvm-nm PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_LINKER lld PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)

# Linker Flags
cmake_policy(SET CMP0056 NEW)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR (NOT DEFINED VCPKG_CHAINLOAD_TOOLCHAIN_FILE AND NOT BUILD_SHARED_LIBS))
  set(CMAKE_CXX_STANDARD_LIBRARIES "-static-libstdc++" CACHE STRING "" FORCE)
endif()

foreach(VAR ACE_LINKER_FLAGS ACE_LINKER_FLAGS_DEBUG ACE_LINKER_FLAGS_RELEASE)
  if(NOT DEFINED ${VAR})
    message(FATAL_ERROR "Missing define: ${VAR}")
  endif()
endforeach()

foreach(LINKER SHARED MODULE EXE)
  set(CMAKE_${LINKER}_LINKER_FLAGS_INIT "${ACE_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS}")
  set(CMAKE_${LINKER}_LINKER_FLAGS_DEBUG_INIT "${ACE_LINKER_FLAGS_DEBUG} ${VCPKG_LINKER_FLAGS_DEBUG}")
  set(CMAKE_${LINKER}_LINKER_FLAGS_RELEASE_INIT "${ACE_LINKER_FLAGS_RELEASE} ${VCPKG_LINKER_FLAGS_RELEASE}")
  set(CMAKE_${LINKER}_LINKER_FLAGS_MINSIZEREL_INIT "${ACE_LINKER_FLAGS_RELEASE} ${VCPKG_LINKER_FLAGS_RELEASE}")
  set(CMAKE_${LINKER}_LINKER_FLAGS_RELWITHDEBINFO_INIT "${ACE_LINKER_FLAGS_DEBUG} ${VCPKG_LINKER_FLAGS_DEBUG}")
  set(CMAKE_${LINKER}_LINKER_FLAGS_COVERAGE_INIT "${ACE_LINKER_FLAGS_DEBUG} ${VCPKG_LINKER_FLAGS_DEBUG}")
endforeach()

# Tools
find_program(CMAKE_RANLIB llvm-ranlib PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_OBJCOPY llvm-objcopy PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_OBJDUMP llvm-objdump PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_STRIP llvm-strip PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_SIZE llvm-size PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)

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
  VCPKG_CHAINLOAD_TOOLCHAIN_FILE
  VCPKG_LIBRARY_LINKAGE
  CACHE STRING "")

# Cache & Time
if(ACE_ENABLE_CCACHE)
  find_program(ACE_CCACHE ccache REQUIRED NO_CACHE)
  set(CMAKE_C_COMPILER_LAUNCHER ${ACE_CCACHE} CACHE PATH "")
  set(CMAKE_CXX_COMPILER_LAUNCHER ${ACE_CCACHE} CACHE PATH "")
elseif(ACE_ENABLE_TIME)
  find_program(ACE_TIME time REQUIRED NO_CACHE)
  set(CMAKE_C_COMPILER_LAUNCHER "${ACE_TIME};-f;%e" CACHE STRING "")
  set(CMAKE_CXX_COMPILER_LAUNCHER "${ACE_TIME};-f;%e" CACHE STRING "")
endif()

# Vcpkg Workaround
macro(_add_library)
  add_library(${ARGV})
endmacro()

# Cleanup
unset(ACE_LINKER_FLAGS_RELEASE)
unset(ACE_LINKER_FLAGS_DEBUG)
unset(ACE_LINKER_FLAGS)
unset(ACE_C_FLAGS)
unset(ACE)

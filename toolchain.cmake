# Ace
get_filename_component(ACE "${CMAKE_CURRENT_LIST_DIR}" ABSOLUTE CACHE)

# Target
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
  set(ACE_TARGET x86_64-pc-linux-gnu CACHE STRING "")
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
  set(ACE_TARGET x86_64-pc-windows-msvc CACHE STRING "")
endif()

if(NOT ACE_TARGET)
  if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    set(ACE_TARGET x86_64-pc-linux-gnu CACHE STRING "" FORCE)
  elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set(ACE_TARGET x86_64-pc-windows-msvc CACHE STRING "" FORCE)
  endif()
endif()

# Target Root
set(ACE_TARGET_ROOT ${ACE}/sys/${ACE_TARGET} CACHE PATH "")

# System Root
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
  set(ACE_SYSTEM_ROOT ${ACE}/sys/x86_64-pc-linux-gnu CACHE PATH "")
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
  set(ACE_SYSTEM_ROOT ${ACE}/sys/x86_64-pc-windows-msvc CACHE PATH "")
endif()

# Search Paths
set(CMAKE_FIND_ROOT_PATH ${ACE} CACHE PATH "")
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY CACHE STRING "")
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY CACHE STRING "")
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY CACHE STRING "")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH CACHE STRING "")
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG ON CACHE BOOL "")

set(CMAKE_SYSTEM_PROGRAM_PATH
  ${ACE}/bin
  ${ACE_SYSTEM_ROOT}/tools
  CACHE PATH "")

# Modules
list(INSERT CMAKE_MODULE_PATH 0 ${ACE}/cmake)

# Configs
set(CMAKE_PREFIX_PATH ${ACE_TARGET_ROOT}/cmake CACHE PATH "")

# Compiler
set(CMAKE_C_COMPILER_WORKS ON CACHE BOOL "")
set(CMAKE_CXX_COMPILER_WORKS ON CACHE BOOL "")
set(CMAKE_ASM_COMPILER_WORKS ON CACHE BOOL "")

# Target Toolchain
include("${ACE}/sys/${ACE_TARGET}.cmake")

# Cache
if(ACE_ENABLE_CCACHE)
  find_program(CCACHE ccache REQUIRED NO_CACHE)
  set(CMAKE_C_COMPILER_LAUNCHER ${CCACHE} CACHE PATH "")
  set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE} CACHE PATH "")
  unset(CCACHE)
endif()

# Linux Toolchain
include_guard(GLOBAL)
get_filename_component(ACE ${CMAKE_CURRENT_LIST_DIR} ABSOLUTE CACHE)

# System
set(CMAKE_CROSSCOMPILING ON CACHE BOOL "" FORCE)
set(CMAKE_SYSTEM_NAME Linux CACHE STRING "" FORCE)
set(CMAKE_SYSTEM_VERSION 5.10.0 CACHE STRING "" FORCE)
set(CMAKE_SYSTEM_PROCESSOR AMD64 CACHE STRING "" FORCE)
set(CMAKE_SYSROOT ${ACE}/sys/linux CACHE PATH "" FORCE)

# Installed Path
set(ACE_INSTALLED_PATH "${ACE}/vcpkg/installed/ace-linux")

# Target
set(CMAKE_C_COMPILER_TARGET x86_64-pc-linux-gnu CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER_TARGET x86_64-pc-linux-gnu CACHE STRING "" FORCE)
set(CMAKE_ASM_COMPILER_TARGET x86_64-pc-linux-gnu CACHE STRING "" FORCE)
set(CMAKE_ASM_NASM_COMPILER_TARGET x86_64-pc-linux-gnu CACHE STRING "" FORCE)

# Linker Flags
set(ACE_LINKER_FLAGS "-Wl,--undefined-version")
set(ACE_LINKER_FLAGS_DEBUG "")
set(ACE_LINKER_FLAGS_RELEASE "-s")

# Runtime Path
set(CMAKE_BUILD_RPATH_USE_ORIGIN ON CACHE BOOL "")
set(CMAKE_BUILD_RPATH ${ACE}/vcpkg/installed/ace-linux/lib ${CMAKE_SYSROOT}/lib CACHE PATH "")

# Toolchain
include(${ACE}/src/toolchain.cmake)

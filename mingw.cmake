# MinGW Toolchain
include_guard(GLOBAL)
get_filename_component(ACE ${CMAKE_CURRENT_LIST_DIR} ABSOLUTE CACHE)

# System
set(CMAKE_CROSSCOMPILING ON CACHE BOOL "" FORCE)
set(CMAKE_SYSTEM_NAME Windows CACHE STRING "" FORCE)
set(CMAKE_SYSTEM_VERSION 10.0 CACHE STRING "" FORCE)
set(CMAKE_SYSTEM_PROCESSOR AMD64 CACHE STRING "" FORCE)
set(CMAKE_SYSROOT ${ACE}/sys/mingw CACHE PATH "" FORCE)

# Installed Path
set(ACE_INSTALLED_PATH "${ACE}/vcpkg/installed/ace-mingw")

# Target
set(CMAKE_C_COMPILER_TARGET x86_64-w64-mingw32 CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER_TARGET x86_64-w64-mingw32 CACHE STRING "" FORCE)
set(CMAKE_ASM_COMPILER_TARGET x86_64-w64-mingw32 CACHE STRING "" FORCE)
set(CMAKE_ASM_NASM_COMPILER_TARGET x86_64-w64-mingw32 CACHE STRING "" FORCE)

# Compiler Flags
# Visual Studio 2022 Version 17.10 sets _MSC_VER to 1940.
# https://learn.microsoft.com/cpp/overview/compiler-versions?view=msvc-170
# MinGW is configured to define WINVER=0x0A00 and _WIN32_WINNT=0x0A00.
set(ACE_C_FLAGS "-fms-compatibility-version=19.40")

# Embed debug information.
cmake_policy(SET CMP0141 NEW)
set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT Embedded CACHE STRING "" FORCE)

# Use release runtime library.
cmake_policy(SET CMP0091 NEW)
set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreadedDLL CACHE STRING "" FORCE)

# Disable warnings.
cmake_policy(SET CMP0092 NEW)

# Linker Flags
set(ACE_LINKER_FLAGS "-Xlinker /MANIFEST:NO")
set(ACE_LINKER_FLAGS_DEBUG "-Xlinker /DEBUG -Xlinker /INCREMENTAL")
set(ACE_LINKER_FLAGS_RELEASE "-s -Xlinker /OPT:REF -Xlinker /OPT:ICF -Xlinker /INCREMENTAL:NO")

# Toolchain
include(${ACE}/src/toolchain.cmake)

# Resource Compiler
if(CMAKE_HOST_UNIX)
  find_program(CMAKE_RC_COMPILER windres PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
else()
  find_program(CMAKE_RC_COMPILER llvm-windres PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
  set(CMAKE_RC_FLAGS_INIT "-I ${CMAKE_SYSROOT}/include")
endif()

# DLL Export Table Generator
find_program(CMAKE_DLLTOOL llvm-dlltool PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)

# Manifest Generator
find_program(CMAKE_MT llvm-mt PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)

# Emulator
if(CMAKE_HOST_UNIX)
  find_program(WINE wine PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
  # set(WINEPATH "${ACE}/vcpkg/installed/ace-mingw/bin\\\;${CMAKE_SYSROOT}/bin")
  set(CMAKE_CROSSCOMPILING_EMULATOR "env;WINEPATH=${CMAKE_SYSROOT}/bin;${WINE}" CACHE STRING "")
endif()

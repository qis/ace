# WebAssembly
set(ACE_ARCH wasm32 CACHE STRING "")

# System
set(CMAKE_CROSSCOMPILING ON CACHE BOOL "")
set(CMAKE_SYSTEM_NAME WebAssembly CACHE STRING "")
set(CMAKE_SYSTEM_VERSION 1 CACHE STRING "")
set(CMAKE_SYSTEM_PROCESSOR ${ACE_ARCH} CACHE STRING "")
set(CMAKE_SYSROOT ${ACE_TARGET_ROOT} CACHE PATH "")

# Search Paths
set(CMAKE_SYSTEM_INCLUDE_PATH ${ACE_TARGET_ROOT}/include CACHE PATH "")
set(CMAKE_SYSTEM_LIBRARY_PATH ${ACE_TARGET_ROOT}/lib CACHE PATH "")

# Compiler
find_program(CMAKE_C_COMPILER clang PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_CXX_COMPILER clang++ PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_ASM_COMPILER clang PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)

set(CMAKE_C_COMPILER_TARGET ${ACE_TARGET} CACHE STRING "")
set(CMAKE_CXX_COMPILER_TARGET ${ACE_TARGET} CACHE STRING "")
set(CMAKE_ASM_COMPILER_TARGET ${ACE_TARGET} CACHE STRING "")

# Compiler Flags
set(CMAKE_C_EXTENSIONS OFF CACHE BOOL "")
set(CMAKE_C_STANDARD_DEFAULT 11 CACHE INTERNAL "")

set(CMAKE_CXX_EXTENSIONS OFF CACHE BOOL "")
set(CMAKE_CXX_STANDARD_DEFAULT 20 CACHE INTERNAL "")

set(CMAKE_POSITION_INDEPENDENT_CODE OFF CACHE BOOL "")

set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON CACHE STRING "")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_DEBUG OFF CACHE INTERNAL "" FORCE)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE OFF CACHE INTERNAL "" FORCE)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_MINSIZEREL OFF CACHE INTERNAL "" FORCE)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELWITHDEBINFO OFF CACHE INTERNAL "" FORCE)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_COVERAGE OFF CACHE INTERNAL "" FORCE)

set(CFLAGS_LTO)
if(CMAKE_INTERPROCEDURAL_OPTIMIZATION)
  set(CFLAGS_LTO "-flto=thin -fwhole-program-vtables")
endif()

set(CFLAGS "-mthread-model single -mno-atomics")
set(CFLAGS "${CFLAGS} -fdiagnostics-absolute-paths")
set(CFLAGS "${CFLAGS} -mno-exception-handling")
set(CFLAGS "${CFLAGS} -ftls-model=local-exec")
set(CFLAGS "${CFLAGS} -fmerge-all-constants")
set(CFLAGS "${CFLAGS} -fvisibility=hidden")

set(CMAKE_C_FLAGS_INIT "${CFLAGS}")
set(CMAKE_C_FLAGS_DEBUG "-g" CACHE STRING "")
set(CMAKE_C_FLAGS_RELEASE "-O3 -DNDEBUG ${CFLAGS_LTO}" CACHE STRING "")
set(CMAKE_C_FLAGS_MINSIZEREL "-Oz -DNDEBUG ${CFLAGS_LTO}" CACHE STRING "")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O2 -g -DNDEBUG ${CFLAGS_LTO}" CACHE STRING "")

set(CFLAGS "${CFLAGS} -fno-exceptions")
set(CFLAGS "${CFLAGS} -fno-unwind-tables")
set(CFLAGS "${CFLAGS} -fno-asynchronous-unwind-tables")
set(CFLAGS "${CFLAGS} -fno-rtti")

set(CMAKE_CXX_FLAGS_INIT "${CFLAGS}")
set(CMAKE_CXX_FLAGS_DEBUG "-g" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG ${CFLAGS_LTO}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_MINSIZEREL "-Oz -DNDEBUG ${CFLAGS_LTO}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g -DNDEBUG ${CFLAGS_LTO}" CACHE STRING "")

unset(CFLAGS)
unset(CFLAGS_LTO)

# Include Directories
set(CMAKE_C_STANDARD_INCLUDE_DIRECTORIES ${CMAKE_SYSTEM_INCLUDE_PATH} CACHE STRING "")
set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES ${CMAKE_SYSTEM_INCLUDE_PATH} CACHE STRING "")

# Linker
find_program(CMAKE_AR llvm-ar PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_NM llvm-nm PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_LINKER wasm-ld PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)

# Linker Flags
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
  set(LDFLAGS "-fuse-ld=lld -rtlib=compiler-rt -unwindlib=none -Wl")
else()
  set(LDFLAGS "-Wl")
endif()

set(LDFLAGS "${LDFLAGS},--no-entry,--export-dynamic")
set(LDFLAGS "${LDFLAGS},--unresolved-symbols=ignore-all,--import-undefined")

foreach(LINKER SHARED MODULE EXE)
  set(CMAKE_${LINKER}_LINKER_FLAGS_INIT "-nostartfiles ${LDFLAGS}")
  set(CMAKE_${LINKER}_LINKER_FLAGS_DEBUG "" CACHE STRING "")
  set(CMAKE_${LINKER}_LINKER_FLAGS_RELEASE "-Wl,-S,--compress-relocations" CACHE STRING "")
  set(CMAKE_${LINKER}_LINKER_FLAGS_MINSIZEREL "-Wl,-S,--compress-relocations" CACHE STRING "")
  set(CMAKE_${LINKER}_LINKER_FLAGS_RELWITHDEBINFO "" CACHE STRING "")
endforeach()

unset(LDFLAGS)

# Standard Libraries
set(CMAKE_C_STANDARD_LIBRARIES "-Wno-unused-command-line-argument" CACHE STRING "")

# Tools
find_program(CMAKE_RANLIB llvm-ranlib PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_OBJCOPY llvm-objcopy PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_OBJDUMP llvm-objdump PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_STRIP llvm-strip PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)
find_program(CMAKE_SIZE llvm-size PATHS ${CMAKE_SYSTEM_PROGRAM_PATH} REQUIRED)

# Debug Configurations
set_property(GLOBAL PROPERTY DEBUG_CONFIGURATIONS Debug RelWithDebInfo)

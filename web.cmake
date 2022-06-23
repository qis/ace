set(LLVM_ARCH wasm32 CACHE STRING "")
set(LLVM_ROOT ${CMAKE_CURRENT_LIST_DIR} CACHE PATH "")

# System
set(CMAKE_CROSSCOMPILING ON CACHE BOOL "")
set(CMAKE_SYSTEM_NAME WebAssembly CACHE STRING "")
set(CMAKE_SYSTEM_VERSION 1 CACHE STRING "")
set(CMAKE_SYSTEM_PROCESSOR ${LLVM_ARCH} CACHE STRING "")

# System Root
set(CMAKE_SYSROOT ${LLVM_ROOT}/web CACHE PATH "")
set(CMAKE_FIND_ROOT_PATH ${LLVM_ROOT} CACHE PATH "")
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY CACHE STRING "")
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY CACHE STRING "")
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY CACHE STRING "")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH CACHE STRING "")
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG ON CACHE BOOL "")

set(CMAKE_SYSTEM_PROGRAM_PATH ${LLVM_ROOT}/bin CACHE PATH "")
set(CMAKE_SYSTEM_INCLUDE_PATH ${LLVM_ROOT}/web/include CACHE PATH "")
set(CMAKE_SYSTEM_LIBRARY_PATH ${LLVM_ROOT}/web/lib CACHE PATH "")

# Modules
list(INSERT CMAKE_MODULE_PATH 0 ${LLVM_ROOT}/cmake)

# Configs
set(CMAKE_PREFIX_PATH ${LLVM_ROOT}/cmake CACHE PATH "")

# C Compiler
find_program(CMAKE_C_COMPILER clang PATHS ${LLVM_ROOT}/bin REQUIRED)
set(CMAKE_C_COMPILER_TARGET wasm32-wasi CACHE STRING "")
set(CMAKE_C_EXTENSIONS OFF CACHE BOOL "")

# C++ Compiler
find_program(CMAKE_CXX_COMPILER clang++ PATHS ${LLVM_ROOT}/bin REQUIRED)
set(CMAKE_CXX_COMPILER_TARGET wasm32-wasi CACHE STRING "")
set(CMAKE_CXX_EXTENSIONS OFF CACHE BOOL "")

# ASM Compiler
find_program(CMAKE_ASM_COMPILER clang PATHS ${LLVM_ROOT}/bin REQUIRED)
set(CMAKE_ASM_COMPILER_TARGET wasm32-wasi CACHE STRING "")

# Compiler Flags
set(LLVM_CFLAGS "-mthread-model single -fno-trapping-math -mno-atomics -mno-exception-handling")
set(LLVM_CFLAGS "-ftls-model=local-exec -fmerge-all-constants -fvisibility=hidden")
set(LLVM_CFLAGS "${LLVM_CFLAGS} -fdiagnostics-absolute-paths -fcolor-diagnostics")

set(CMAKE_C_FLAGS "${LLVM_CFLAGS}" CACHE STRING "")
set(CMAKE_C_FLAGS_DEBUG "-O0 -g" CACHE STRING "")
set(CMAKE_C_FLAGS_RELEASE "-O3 -DNDEBUG -flto=thin -fwhole-program-vtables" CACHE STRING "")
set(CMAKE_C_FLAGS_MINSIZEREL "-Oz -DNDEBUG -flto=thin -fwhole-program-vtables" CACHE STRING "")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O2 -g -DNDEBUG -flto=thin -fwhole-program-vtables" CACHE STRING "")

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
  set(LLVM_CFLAGS "${LLVM_CFLAGS} -stdlib=libc++")
endif()

set(LLVM_CFLAGS "${LLVM_CFLAGS} -fno-exceptions")
set(LLVM_CFLAGS "${LLVM_CFLAGS} -fno-unwind-tables -fno-asynchronous-unwind-tables")
set(LLVM_CFLAGS "${LLVM_CFLAGS} -fno-rtti")

set(CMAKE_CXX_FLAGS "${LLVM_CFLAGS}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG -flto=thin -fwhole-program-vtables" CACHE STRING "")
set(CMAKE_CXX_FLAGS_MINSIZEREL "-Oz -DNDEBUG -flto=thin -fwhole-program-vtables" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g -DNDEBUG -flto=thin -fwhole-program-vtables" CACHE STRING "")

unset(LLVM_CFLAGS)

set(CMAKE_POSITION_INDEPENDENT_CODE OFF CACHE BOOL "")

foreach(LANG C CXX)
  set(CMAKE_${LANG}_STANDARD_INCLUDE_DIRECTORIES ${CMAKE_SYSTEM_INCLUDE_PATH} CACHE STRING "")
endforeach()

# Linker
find_program(CMAKE_LINKER wasm-ld PATHS ${LLVM_ROOT}/bin REQUIRED)

# Linker Flags
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
  set(LLVM_LDFLAGS "-fuse-ld=lld -rtlib=compiler-rt -unwindlib=none -Wl")
else()
  set(LLVM_LDFLAGS "-Wl")
endif()

set(LLVM_LDFLAGS "${LLVM_LDFLAGS},--no-entry,--export-dynamic")
set(LLVM_LDFLAGS "${LLVM_LDFLAGS},--unresolved-symbols=ignore-all,--import-undefined")

foreach(LINKER SHARED MODULE EXE)
  set(CMAKE_${LINKER}_LINKER_FLAGS "-nostartfiles ${LLVM_LDFLAGS}" CACHE STRING "")
  set(CMAKE_${LINKER}_LINKER_FLAGS_DEBUG "" CACHE STRING "")
  set(CMAKE_${LINKER}_LINKER_FLAGS_RELEASE "-Wl,-S,--compress-relocations" CACHE STRING "")
  set(CMAKE_${LINKER}_LINKER_FLAGS_MINSIZEREL "-Wl,-S,--compress-relocations" CACHE STRING "")
  set(CMAKE_${LINKER}_LINKER_FLAGS_RELWITHDEBINFO "" CACHE STRING "")
endforeach()

unset(LLVM_LDFLAGS)

set(CMAKE_C_STANDARD_LIBRARIES "-Wno-unused-command-line-argument" CACHE STRING "")

# Tools
find_program(CMAKE_AR llvm-ar PATHS ${LLVM_ROOT}/bin REQUIRED)
find_program(CMAKE_NM llvm-nm PATHS ${LLVM_ROOT}/bin REQUIRED)
find_program(CMAKE_RANLIB llvm-ranlib PATHS ${LLVM_ROOT}/bin REQUIRED)
find_program(CMAKE_OBJCOPY llvm-objcopy PATHS ${LLVM_ROOT}/bin REQUIRED)
find_program(CMAKE_OBJDUMP llvm-objdump PATHS ${LLVM_ROOT}/bin REQUIRED)
find_program(CMAKE_STRIP llvm-strip PATHS ${LLVM_ROOT}/bin REQUIRED)
find_program(CMAKE_SIZE llvm-size PATHS ${LLVM_ROOT}/bin REQUIRED)

if(LLVM_ENABLE_CCACHE)
  find_program(CCACHE ccache REQUIRED NO_CACHE)
  set(CMAKE_C_COMPILER_LAUNCHER ${CCACHE} CACHE PATH "")
  set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE} CACHE PATH "")
  unset(CCACHE)
endif()

# Debug Configurations
set_property(GLOBAL PROPERTY DEBUG_CONFIGURATIONS Debug RelWithDebInfo)

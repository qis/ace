# x86-64: CMOV, CMPXCHG8B, FPU, FXSR, MMX, FXSR, SCE, SSE, SSE2
# x86-64-v2: (close to Nehalem) CMPXCHG16B, LAHF-SAHF, POPCNT, SSE3, SSE4.1, SSE4.2, SSSE3
# x86-64-v3: (close to Haswell) AVX, AVX2, BMI1, BMI2, F16C, FMA, LZCNT, MOVBE, XSAVE
# x86-64-v4: AVX512F, AVX512BW, AVX512CD, AVX512DQ, AVX512VL

set(LLVM_ARCH x86-64-v3 CACHE STRING "")
set(LLVM_ROOT ${CMAKE_CURRENT_LIST_DIR} CACHE PATH "")

# System
if(NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
  set(CMAKE_CROSSCOMPILING ON CACHE BOOL "")
  set(CMAKE_SYSTEM_NAME Linux CACHE STRING "")
  set(CMAKE_SYSTEM_VERSION 5.10 CACHE STRING "")
  set(CMAKE_SYSTEM_PROCESSOR AMD64 CACHE STRING "")
endif()

# System Root
set(CMAKE_SYSROOT ${LLVM_ROOT}/sys CACHE PATH "")
set(CMAKE_FIND_ROOT_PATH ${LLVM_ROOT} CACHE PATH "")
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY CACHE STRING "")
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY CACHE STRING "")
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY CACHE STRING "")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH CACHE STRING "")
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG ON CACHE BOOL "")

set(CMAKE_SYSTEM_PROGRAM_PATH
  ${LLVM_ROOT}/bin
  ${LLVM_ROOT}/sys/bin
  ${LLVM_ROOT}/sys/sbin
  CACHE PATH "")

# Modules
list(INSERT CMAKE_MODULE_PATH 0 ${LLVM_ROOT}/cmake)

# Configs
set(CMAKE_PREFIX_PATH ${LLVM_ROOT}/cmake ${LLVM_ROOT}/sys/lib/cmake CACHE PATH "")

# Runtime Path
set(CMAKE_BUILD_RPATH_USE_ORIGIN ON CACHE BOOL "")

set(CMAKE_BUILD_RPATH
  ${LLVM_ROOT}/sys/lib
  ${LLVM_ROOT}/sys/usr/lib/x86_64-linux-gnu
  CACHE PATH "")

# C Compiler
find_program(CMAKE_C_COMPILER clang PATHS ${LLVM_ROOT}/bin REQUIRED)
set(CMAKE_C_COMPILER_TARGET x86_64-pc-linux-gnu CACHE STRING "")
set(CMAKE_C_EXTENSIONS OFF CACHE BOOL "")

# C++ Compiler
find_program(CMAKE_CXX_COMPILER clang++ PATHS ${LLVM_ROOT}/bin REQUIRED)
set(CMAKE_CXX_COMPILER_TARGET x86_64-pc-linux-gnu CACHE STRING "")
set(CMAKE_CXX_EXTENSIONS OFF CACHE BOOL "")

# ASM Compiler
find_program(CMAKE_ASM_COMPILER clang PATHS ${LLVM_ROOT}/bin REQUIRED)
set(CMAKE_ASM_COMPILER_TARGET x86_64-pc-linux-gnu CACHE STRING "")

# Compiler Flags
set(LLVM_CFLAGS "-march=${LLVM_ARCH} -fasm -fmerge-all-constants")
set(LLVM_CFLAGS "${LLVM_CFLAGS} -fdiagnostics-absolute-paths -fcolor-diagnostics")

set(CMAKE_C_FLAGS "${LLVM_CFLAGS}" CACHE STRING "")
set(CMAKE_C_FLAGS_DEBUG "-O0 -g" CACHE STRING "")
set(CMAKE_C_FLAGS_RELEASE "-O3 -DNDEBUG -flto=thin -fwhole-program-vtables" CACHE STRING "")
set(CMAKE_C_FLAGS_MINSIZEREL "-Oz -DNDEBUG -flto=thin -fwhole-program-vtables" CACHE STRING "")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O2 -g -DNDEBUG -flto=thin -fwhole-program-vtables" CACHE STRING "")
set(CMAKE_C_FLAGS_COVERAGE "-O0 -g -fprofile-instr-generate -fcoverage-mapping" CACHE STRING "")

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
  set(LLVM_CFLAGS "${LLVM_CFLAGS} -stdlib=libc++")
endif()

if(LLVM_DISABLE_EXCEPTIONS OR LLVM_DISABLE_RTTI)
  set(LLVM_CFLAGS "${LLVM_CFLAGS} -fno-exceptions")
  set(LLVM_CFLAGS "${LLVM_CFLAGS} -fno-unwind-tables -fno-asynchronous-unwind-tables")
endif()

if(LLVM_DISABLE_RTTI)
  set(LLVM_CFLAGS "${LLVM_CFLAGS} -fno-rtti")
endif()

set(CMAKE_CXX_FLAGS "${LLVM_CFLAGS}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG -flto=thin -fwhole-program-vtables" CACHE STRING "")
set(CMAKE_CXX_FLAGS_MINSIZEREL "-Oz -DNDEBUG -flto=thin -fwhole-program-vtables" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g -DNDEBUG -flto=thin -fwhole-program-vtables" CACHE STRING "")
set(CMAKE_CXX_FLAGS_COVERAGE "-O0 -g -fprofile-instr-generate -fcoverage-mapping" CACHE STRING "")

unset(LLVM_CFLAGS)

set(CMAKE_POSITION_INDEPENDENT_CODE ON CACHE BOOL "")

# Linker
find_program(CMAKE_LINKER lld PATHS ${LLVM_ROOT}/bin REQUIRED)

# Linker Flags
if(NOT BUILD_SHARED_LIBS AND (NOT "${VCPKG_LIBRARY_LINKAGE}" STREQUAL "dynamic"))
  set(LLVM_CRT_FLAGS "-static-libstdc++")
else()
  set(LLVM_CRT_FLAGS "")
endif()

foreach(LINKER SHARED MODULE EXE)
  set(CMAKE_${LINKER}_LINKER_FLAGS "-ldl" CACHE STRING "")
  set(CMAKE_${LINKER}_LINKER_FLAGS_DEBUG "" CACHE STRING "")
  set(CMAKE_${LINKER}_LINKER_FLAGS_RELEASE "-s ${LLVM_CRT_FLAGS}" CACHE STRING "")
  set(CMAKE_${LINKER}_LINKER_FLAGS_MINSIZEREL "-s" CACHE STRING "")
  set(CMAKE_${LINKER}_LINKER_FLAGS_RELWITHDEBINFO "" CACHE STRING "")
  set(CMAKE_${LINKER}_LINKER_FLAGS_COVERAGE "" CACHE STRING "")
endforeach()

unset(LLVM_CRT_FLAGS)

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
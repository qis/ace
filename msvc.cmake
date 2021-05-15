# Toolchain
set(ARCH x86-64-v3)
set(LLVM ${CMAKE_CURRENT_LIST_DIR})
set(ACE_TOOLCHAIN ON CACHE BOOL "")

# System
set(CMAKE_CROSSCOMPILING ON CACHE BOOL "")
set(CMAKE_SYSTEM_NAME Windows CACHE STRING "")
set(CMAKE_SYSTEM_VERSION 10.0 CACHE STRING "")
set(CMAKE_SYSTEM_PROCESSOR AMD64 CACHE STRING "")

# Settings
set(CMAKE_MSVC_RUNTIME_LIBRARY "" CACHE STRING "")
set(CMAKE_CONFIGURATION_TYPES Debug Release MinSizeRel RelWithDebInfo CACHE STRING "" FORCE)
set_property(GLOBAL PROPERTY DEBUG_CONFIGURATIONS Debug MinSizeRel RelWithDebInfo)

# Tools
find_program(CMAKE_AR llvm-ar PATHS ${LLVM}/bin)
find_program(CMAKE_NM llvm-nm PATHS ${LLVM}/bin)
find_program(CMAKE_LINKER lld-link PATHS ${LLVM}/bin)
find_program(CMAKE_RANLIB llvm-ranlib PATHS ${LLVM}/bin)

find_program(LLVM_CCACHE ccache)
if(LLVM_CCACHE)
  set(CMAKE_C_COMPILER_LAUNCHER ${LLVM_CCACHE} CACHE PATH "")
  set(CMAKE_CXX_COMPILER_LAUNCHER ${LLVM_CCACHE} CACHE PATH "")
endif()
unset(LLVM_CCACHE)

# Include Directories
set(LLVM_INCLUDE_DIRECTORIES ${LLVM}/lib/clang/12.0.0/include ${LLVM}/msvc/include)

# C Compiler
set(CMAKE_C_STANDARD 11 CACHE STRING "")
set(CMAKE_C_EXTENSIONS OFF CACHE BOOL "")
set(CMAKE_C_STANDARD_REQUIRED ON CACHE BOOL "")
set(CMAKE_C_COMPILER_TARGET x86_64-pc-windows-msvc CACHE STRING "")
set(CMAKE_C_STANDARD_INCLUDE_DIRECTORIES ${LLVM_INCLUDE_DIRECTORIES} CACHE PATH "")
find_program(CMAKE_C_COMPILER clang PATHS ${LLVM}/bin)

# C++ Compiler
set(CMAKE_CXX_EXTENSIONS OFF CACHE BOOL "")
set(CMAKE_CXX_STANDARD 20 CACHE STRING "")
set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE BOOL "")
set(CMAKE_CXX_COMPILER_TARGET x86_64-pc-windows-msvc CACHE STRING "")
set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES ${LLVM_INCLUDE_DIRECTORIES} CACHE PATH "")
find_program(CMAKE_CXX_COMPILER clang++ PATHS ${LLVM}/bin)

# Compiler Flags
set(LLVM_MD "-D_MT -D_DLL -Xclang --dependent-lib=msvcrt")
set(LLVM_MT "-D_MT -Xclang --dependent-lib=libcmt -Xclang -flto-visibility-public-std")

set(LLVM_FLAGS "-march=${ARCH} -nostdinc -ffast-math -fmerge-all-constants")
set(LLVM_FLAGS "${LLVM_FLAGS} -fdiagnostics-absolute-paths -fcolor-diagnostics")
set(LLVM_FLAGS "${LLVM_FLAGS} -fms-compatibility-version=19.28 -Wno-language-extension-token")
set(LLVM_FLAGS "${LLVM_FLAGS} -DWIN32 -D_WINDOWS -DWINVER=0x0A00 -D_WIN32_WINNT=0x0A00 -D_CRT_USE_BUILTIN_OFFSETOF=1")

set(CMAKE_C_FLAGS ${LLVM_FLAGS} CACHE STRING "")
set(CMAKE_C_FLAGS_DEBUG "-O0 -g -Xclang -gcodeview ${LLVM_MD}" CACHE STRING "")
set(CMAKE_C_FLAGS_RELEASE "-O3 -DNDEBUG ${LLVM_MT} -flto=full" CACHE STRING "")
set(CMAKE_C_FLAGS_MINSIZEREL "-Os -DNDEBUG ${LLVM_MD}" CACHE STRING "")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O2 -g -Xclang -gcodeview -DNDEBUG ${LLVM_MD}" CACHE STRING "")

if(NOT LLVM_ENABLE_EXCEPTIONS)
  set(LLVM_FLAGS "${LLVM_FLAGS} -fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables -D_HAS_EXCEPTIONS=0")
  set(LLVM_FLAGS "${LLVM_FLAGS} -fno-rtti -D_HAS_STATIC_RTTI=0")
endif()

set(CMAKE_CXX_FLAGS ${LLVM_FLAGS} CACHE STRING "")
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g -Xclang -gcodeview ${LLVM_MD}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG ${LLVM_MT} -flto=full -fwhole-program-vtables" CACHE STRING "")
set(CMAKE_CXX_FLAGS_MINSIZEREL "-Os -DNDEBUG ${LLVM_MD}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g -Xclang -gcodeview -DNDEBUG ${LLVM_MD}" CACHE STRING "")

foreach(LANG C CXX)
  # -lkernel32 -luser32 -lgdi32 -lwinspool -lshell32 -lole32 -loleaut32 -luuid -lcomdlg32 -ladvapi32 -loldnames
  set(CMAKE_${LANG}_STANDARD_LIBRARIES "-lkernel32 -luser32 -lshell32 -lgdi32" CACHE STRING "")
endforeach()

unset(LLVM_FLAGS)
unset(LLVM_MT)
unset(LLVM_MD)

# Definitions
add_compile_definitions(_ATL_SECURE_NO_DEPRECATE _SCL_SECURE_NO_WARNINGS)
add_compile_definitions(_CRT_SECURE_NO_DEPRECATE _CRT_SECURE_NO_WARNINGS)
add_compile_definitions(_CRT_NONSTDC_NO_DEPRECATE)

# Linker Flags
foreach(LINKER SHARED MODULE EXE)
  set(CMAKE_${LINKER}_LINKER_FLAGS "-L${LLVM}/msvc/lib -Wno-unused-command-line-argument" CACHE STRING "")
  set(CMAKE_${LINKER}_LINKER_FLAGS_DEBUG "-Wl,/DEBUG -Wl,/INCREMENTAL" CACHE STRING "")
  set(CMAKE_${LINKER}_LINKER_FLAGS_RELEASE "-Wl,/OPT:REF -Wl,/OPT:ICF -Wl,/INCREMENTAL:NO" CACHE STRING "")
  set(CMAKE_${LINKER}_LINKER_FLAGS_MINSIZEREL "-Wl,/OPT:REF -Wl,/OPT:ICF -Wl,/INCREMENTAL:NO" CACHE STRING "")
  set(CMAKE_${LINKER}_LINKER_FLAGS_RELWITHDEBINFO "-Wl,/DEBUG -Wl,/INCREMENTAL" CACHE STRING "")
endforeach()

# RC Compiler
set(CMAKE_RC_STANDARD_INCLUDE_DIRECTORIES ${LLVM_INCLUDE_DIRECTORIES} CACHE PATH "")
find_program(CMAKE_RC_COMPILER llvm-rc PATHS ${LLVM}/bin)

# CMake Directories
set(CMAKE_PREFIX_PATH ${LLVM} CACHE STRING "")
set(CMAKE_FIND_ROOT_PATH ${LLVM}/msvc CACHE PATH "")
set(CMAKE_SYSTEM_LIBRARY_PATH ${LLVM}/msvc/lib CACHE PATH "")
set(CMAKE_SYSTEM_INCLUDE_PATH ${LLVM}/msvc/include CACHE PATH "")

unset(LLVM_INCLUDE_DIRECTORIES)
unset(LLVM)
unset(ARCH)

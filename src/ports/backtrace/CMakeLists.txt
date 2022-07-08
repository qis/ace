cmake_minimum_required(VERSION 3.22 FATAL_ERROR)
project(backtrace VERSION 1.0.0 LANGUAGES C)

include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckFunctionExists)
include(CheckIncludeFile)
include(CheckLibraryExists)
include(CheckSymbolExists)

# Check if _Unwind_GetIP is present in libc++.
check_library_exists(-l:libc++.a _Unwind_GetIP "unwind.h" HAVE_GETIP_IN_STATIC_LIBCXX)
if(NOT HAVE_GETIP_IN_STATIC_LIBCXX)
  message(FATAL_ERROR "The backtrace port requires _Unwind_GetIP symbol in libc++.a")
endif()
check_library_exists(-l:libc++.so _Unwind_GetIP "unwind.h" HAVE_GETIP_IN_SHARED_LIBCXX)
if(NOT HAVE_GETIP_IN_SHARED_LIBCXX)
  message(FATAL_ERROR "The backtrace port requires _Unwind_GetIP symbol in libc++.so")
endif()

set(BACKTRACE_DEFINITIONS)
set(BACKTRACE_LIBRARIES)
set(BACKTRACE_POSIX_C_SOURCE)

# ELF size: 32 or 64
set(BACKTRACE_ELF_SIZE 64)

# XCOFF size: 32 or 64
set(BACKTRACE_XCOFF_SIZE 64)

# Define to 1 if you have the __atomic functions.
check_c_source_runs("
int main() {
  int i = 0;
  __atomic_store_n(&i, 1, __ATOMIC_RELAXED);
  int j = __atomic_load_n(&i, __ATOMIC_RELAXED);
  return i == j ? 0 : 1;
}
" HAVE_ATOMIC_FUNCTIONS)

# Define to 1 if you have the `clock_gettime' function.
check_symbol_exists(clock_gettime "time.h" HAVE_CLOCK_GETTIME)
if(NOT HAVE_CLOCK_GETTIME)
  unset(HAVE_CLOCK_GETTIME CACHE)
  check_library_exists(rt clock_gettime "time.h" HAVE_CLOCK_GETTIME)
  if(HAVE_CLOCK_GETTIME)
    list(APPEND BACKTRACE_LIBRARIES rt)
  endif()
endif()

# Define to 1 if you have the declaration of `getpagesize', and to 0 if you don't.
check_symbol_exists(getpagesize "unistd.h" HAVE_DECL_GETPAGESIZE)
if(NOT HAVE_DECL_GETPAGESIZE)
  unset(HAVE_DECL_GETPAGESIZE CACHE)
  set(CMAKE_REQUIRED_DEFINITIONS -D_DEFAULT_SOURCE)
  check_symbol_exists(getpagesize "unistd.h" HAVE_DECL_GETPAGESIZE)
  unset(CMAKE_REQUIRED_DEFINITIONS)
  if(HAVE_DECL_GETPAGESIZE)
    list(APPEND BACKTRACE_DEFINITIONS -D_DEFAULT_SOURCE)
  endif()
endif()

# Define to 1 if you have the declaration of `strnlen', and to 0 if you don't.
check_symbol_exists(strnlen "string.h" HAVE_DECL_STRNLEN)
if(NOT HAVE_DECL_STRNLEN)
  unset(HAVE_DECL_STRNLEN CACHE)
  set(CMAKE_REQUIRED_DEFINITIONS -D_POSIX_C_SOURCE=200809L)
  check_symbol_exists(strnlen "string.h" HAVE_DECL_STRNLEN)
  unset(CMAKE_REQUIRED_DEFINITIONS)
  if(HAVE_DECL_STRNLEN AND (NOT BACKTRACE_POSIX_C_SOURCE OR "${BACKTRACE_POSIX_C_SOURCE}" LESS 200809))
      set(BACKTRACE_POSIX_C_SOURCE 200809)
  endif()
endif()

# Define to 1 if you have the <dlfcn.h> header file.
check_include_file("dlfcn.h" HAVE_DLFCN_H)

# Define if dl_iterate_phdr is available.
check_symbol_exists(dl_iterate_phdr "link.h" HAVE_DL_ITERATE_PHDR)
if(NOT HAVE_DL_ITERATE_PHDR)
  unset(HAVE_DL_ITERATE_PHDR CACHE)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(dl_iterate_phdr "link.h" HAVE_DL_ITERATE_PHDR)
  unset(CMAKE_REQUIRED_DEFINITIONS)
  if(HAVE_DL_ITERATE_PHDR)
    list(APPEND BACKTRACE_DEFINITIONS -D_GNU_SOURCE)
  endif()
endif()

# Define to 1 if you have the fcntl function.
check_symbol_exists(fcntl "fcntl.h" HAVE_FCNTL)

# Define if _Unwind_GetIPInfo is available.
check_library_exists(-l:libc++.a _Unwind_GetIPInfo "unwind.h" HAVE_GETIPINFO_IN_STATIC_LIBCXX)
check_library_exists(-l:libc++.so _Unwind_GetIPInfo "unwind.h" HAVE_GETIPINFO_IN_SHARED_LIBCXX)
if(HAVE_GETIPINFO_IN_STATIC_LIBCXX AND HAVE_GETIPINFO_IN_SHARED_LIBCXX)
  set(HAVE_GETIPINFO 1 CACHE STRING "")
endif()

# Define to 1 if you have the <inttypes.h> header file.
check_include_file("inttypes.h" HAVE_INTTYPES_H)

# Define to 1 if you have KERN_PROC and KERN_PROC_PATHNAME in <sys/sysctl.h>.
check_symbol_exists(KERN_PROC "sys/sysctl.h" HAVE_KERN_PROC)
if(HAVE_KERN_PROC)
  check_symbol_exists(KERN_PROC_PATHNAME "sys/sysctl.h" HAVE_KERN_PROC_PATHNAME)
  if(HAVE_KERN_PROC_PATHNAME)
    # Define to 1 if you have KERN_PROCARGS and KERN_PROC_PATHNAME in <sys/sysctl.h>.
    set(HAVE_KERN_PROC_ARGS 1)
  else()
    unset(HAVE_KERN_PROC CACHE)
  endif()
endif()

# Define if -llzma is available (replaced with 'lzma' port).
find_package(LibLZMA CONFIG REQUIRED)
list(APPEND BACKTRACE_LIBRARIES LibLZMA::LibLZMA)
set(HAVE_LIBLZMA 1)

# Define to 1 if you have the <link.h> header file.
check_include_file("link.h" HAVE_LINK_H)

# Define to 1 if you have the `lstat' function.
check_symbol_exists(lstat "sys/stat.h" HAVE_LSTAT)
if(NOT HAVE_LSTAT)
  unset(HAVE_LSTAT CACHE)
  set(CMAKE_REQUIRED_DEFINITIONS -D_POSIX_C_SOURCE=200112L)
  check_symbol_exists(lstat "sys/stat.h" HAVE_LSTAT)
  unset(CMAKE_REQUIRED_DEFINITIONS)
  if(HAVE_LSTAT AND (NOT BACKTRACE_POSIX_C_SOURCE OR "${BACKTRACE_POSIX_C_SOURCE}" LESS 200112))
      set(BACKTRACE_POSIX_C_SOURCE 200112)
  endif()
endif()

# Define to 1 if you have the <memory.h> header file.
check_include_file("memory.h" HAVE_MEMORY_H)

# Define to 1 if you have the `readlink' function.
check_symbol_exists(readlink "unistd.h" HAVE_READLINK)
if(NOT HAVE_READLINK)
  unset(HAVE_READLINK CACHE)
  set(CMAKE_REQUIRED_DEFINITIONS -D_POSIX_C_SOURCE=200112L)
  check_symbol_exists(readlink "unistd.h" HAVE_READLINK)
  unset(CMAKE_REQUIRED_DEFINITIONS)
  if(HAVE_READLINK AND (NOT BACKTRACE_POSIX_C_SOURCE OR "${BACKTRACE_POSIX_C_SOURCE}" LESS 200112))
      set(BACKTRACE_POSIX_C_SOURCE 200112)
  endif()
endif()

# Define to 1 if you have the <stdint.h> header file.
check_include_file("stdint.h" HAVE_STDINT_H)

# Define to 1 if you have the <stdlib.h> header file.
check_include_file("stdlib.h" HAVE_STDLIB_H)

# Define to 1 if you have the <strings.h> header file.
check_include_file("strings.h" HAVE_STRINGS_H)

# Define to 1 if you have the <string.h> header file.
check_include_file("string.h" HAVE_STRING_H)

# Define to 1 if you have the __sync functions
check_c_source_runs("
int main() {
  int i = 0;
  if (!__sync_bool_compare_and_swap(&i, 0, 1)) return 1;
  if (i != 1) return 2;
  if (__sync_lock_test_and_set(&i, 2) != 1) return 3;
  if (i != 2) return 4;
  __sync_lock_release(&i);
  return i == 0 ? 0 : 5;
}
" HAVE_SYNC_FUNCTIONS)

# Define to 1 if you have the <sys/ldr.h> header file.
check_include_file("sys/ldr.h" HAVE_SYS_LDR_H)

# Define to 1 if you have the <sys/mman.h> header file.
check_include_file("sys/mman.h" HAVE_SYS_MMAN_H)

# Define to 1 if you have the <sys/stat.h> header file.
check_include_file("sys/stat.h" HAVE_SYS_STAT_H)

# Define to 1 if you have the <sys/types.h> header file.
check_include_file("sys/types.h" HAVE_SYS_TYPES_H)

# Define to 1 if you have the <unistd.h> header file.
check_include_file("unistd.h" HAVE_UNISTD_H)
if(NOT HAVE_UNISTD_H)
  message(FATAL_ERROR "The backtrace port requires <unistd.h> to be present.")
endif()

# Define if -lz is available (replaced with 'zlib' port).
find_package(ZLIB CONFIG REQUIRED)
list(APPEND BACKTRACE_LIBRARIES ZLIB::ZLIB)
set(HAVE_ZLIB 1)

# Define to 1 if you have the ANSI C header files.
set(STDC_HEADERS 1 CACHE STRING "")

# Number of bits in a file offset, on hosts where this is settable.
set(_FILE_OFFSET_BITS 64)

# Write config file.
configure_file(config.h.in
  ${CMAKE_CURRENT_BINARY_DIR}/src/config.h LF)

# BACKTRACE_SUPPORTED will be #define'd as 1 if the backtrace library
# should work, 0 if it will not. Libraries may #include this to make
# other arrangements.
set(BACKTRACE_SUPPORTED 1)

# BACKTRACE_USES_MALLOC will be #define'd as 1 if the backtrace
# library will call malloc as it works, 0 if it will call mmap
# instead. This may be used to determine whether it is safe to call
# the backtrace functions from a signal handler. In general this
# only applies to calls like backtrace and backtrace_pcinfo. It does
# not apply to backtrace_simple, which never calls malloc. It does
# not apply to backtrace_print, which always calls fprintf and
# therefore malloc.
check_symbol_exists(mmap "sys/mman.h" HAVE_MMAP)
if(HAVE_MMAP)
  set(BACKTRACE_USES_MALLOC 0)
else()
  set(BACKTRACE_USES_MALLOC 1)
endif()

# BACKTRACE_SUPPORTS_THREADS will be #define'd as 1 if the backtrace
# library is configured with threading support, 0 if not. If this is 0,
# the threaded parameter to backtrace_create_state must be passed as 0.
set(BACKTRACE_SUPPORTS_THREADS 1)

# BACKTRACE_SUPPORTS_DATA will be #defined'd as 1 if the backtrace_syminfo
# will work for variables. It will always work for functions.
set(BACKTRACE_SUPPORTS_DATA 1)

# Write backtrace-supported.h.
configure_file(src/backtrace-supported.h.in
  ${CMAKE_CURRENT_BINARY_DIR}/src/backtrace-supported.h LF)

# Add _POSIX_C_SOURCE definition to defines list.
if(BACKTRACE_POSIX_C_SOURCE)
  list(APPEND BACKTRACE_DEFINITIONS "-D_POSIX_C_SOURCE=${BACKTRACE_POSIX_C_SOURCE}L")
endif()

# Add threads support.
find_package(Threads REQUIRED)
list(APPEND BACKTRACE_LIBRARIES Threads::Threads)

# Remove duplicates from defines and libraries lists.
list(REMOVE_DUPLICATES BACKTRACE_DEFINITIONS)
list(REMOVE_DUPLICATES BACKTRACE_LIBRARIES)

set(headers
  src/backtrace.h
  ${CMAKE_CURRENT_BINARY_DIR}/src/backtrace-supported.h)

# Makefile.am: libbacktrace_la_SOURCES
set(sources
  src/internal.h
  ${CMAKE_CURRENT_BINARY_DIR}/src/config.h
  src/atomic.c
  src/dwarf.c
  src/fileline.c)

if(UNIX)
  list(APPEND sources
    src/posix.c)
endif()

list(APPEND sources
  src/print.c
  src/sort.c
  src/state.c)

# Makefile.am: BACKTRACE_FILES
list(APPEND sources
  src/backtrace.c
  src/simple.c
  src/nounwind.c)

# Makefile.am: FORMAT_FILES
list(APPEND sources
  src/elf.c
  #src/macho.c  # OSX
  src/pecoff.c
  src/unknown.c
  src/xcoff.c)

# Makefile.am: VIEW_FILES
list(APPEND sources
  src/read.c)

if(HAVE_MMAP)
  list(APPEND sources
    src/mmapio.c)
endif()

# Makefile.am: ALLOC_FILES
list(APPEND sources
  src/alloc.c)

if(HAVE_MMAP)
  list(APPEND sources
    src/mmap.c)
endif()

add_library(backtrace STATIC ${headers} ${sources})
target_compile_features(backtrace PRIVATE c_std_11)
target_compile_definitions(backtrace PRIVATE ${BACKTRACE_DEFINITIONS})
target_link_libraries(backtrace PUBLIC ${BACKTRACE_LIBRARIES})
target_include_directories(backtrace PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/src>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
  $<INSTALL_INTERFACE:include>)

install(TARGETS backtrace
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib)

install(FILES ${headers} DESTINATION include)

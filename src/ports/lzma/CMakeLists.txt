cmake_minimum_required(VERSION 3.22 FATAL_ERROR)
project(lzma VERSION 5.2.5 LANGUAGES C)

include(CheckCSourceCompiles)
include(CheckIncludeFile)
include(CheckStructHasMember)
include(CheckSymbolExists)
include(CheckTypeSize)

find_package(Threads REQUIRED)
set(CMAKE_REQUIRED_LIBRARIES Threads::Threads)
set(CMAKE_REQUIRED_DEFINITIONS)

if(UNIX)
  set(CMAKE_REQUIRED_DEFINITIONS
    -D_DEFAULT_SOURCE
    -D_POSIX_C_SOURCE=200112L)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  list(APPEND CMAKE_REQUIRED_DEFINITIONS
    -D_GNU_SOURCE)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  list(APPEND CMAKE_REQUIRED_DEFINITIONS
    -DNOMINMAX)
endif()

# Decoders
# Enable at least one.
set(HAVE_DECODER_ARM)
set(HAVE_DECODER_ARMTHUMB)
set(HAVE_DECODER_DELTA 1)
set(HAVE_DECODER_IA64)
set(HAVE_DECODER_LZMA1 1)
set(HAVE_DECODER_LZMA2 1)
set(HAVE_DECODER_POWERPC)
set(HAVE_DECODER_SPARC)
set(HAVE_DECODER_X86 1)

# Encoders
# Enable at least one.
set(HAVE_ENCODER_ARM)
set(HAVE_ENCODER_ARMTHUMB)
set(HAVE_ENCODER_DELTA 1)
set(HAVE_ENCODER_IA64)
set(HAVE_ENCODER_LZMA1 1)
set(HAVE_ENCODER_LZMA2 1)
set(HAVE_ENCODER_POWERPC)
set(HAVE_ENCODER_SPARC)
set(HAVE_ENCODER_X86 1)

check_include_file("byteswap.h" HAVE_BYTESWAP_H)

if(HAVE_BYTESWAP_H)
  check_symbol_exists(bswap_16 "byteswap.h" HAVE_BSWAP_16)
  check_symbol_exists(bswap_32 "byteswap.h" HAVE_BSWAP_32)
  check_symbol_exists(bswap_64 "byteswap.h" HAVE_BSWAP_64)
endif()

check_symbol_exists(clock_gettime "time.h" HAVE_CLOCK_GETTIME)
check_symbol_exists(CLOCK_MONOTONIC "time.h" HAVE_DECL_CLOCK_MONOTONIC)
check_symbol_exists(program_invocation_name "errno.h" HAVE_DECL_PROGRAM_INVOCATION_NAME)

check_include_file("dlfcn.h" HAVE_DLFCN_H)
check_include_file("fcntl.h" HAVE_FCNTL_H)

check_symbol_exists(futimens "sys/stat.h" HAVE_FUTIMENS)
check_include_file("sys/time.h" HAVE_SYS_TIME_H)

if(HAVE_SYS_TIME_H)
  check_symbol_exists(futimes "sys/time.h" HAVE_FUTIMES)
  check_symbol_exists(futimesat "sys/time.h" HAVE_FUTIMESAT)
endif()

check_include_file("getopt.h" HAVE_GETOPT_H)

if(HAVE_GETOPT_H)
  check_symbol_exists(getopt_long "getopt.h" HAVE_GETOPT_LONG)
endif()

check_include_file("immintrin.h" HAVE_IMMINTRIN_H)
check_include_file("inttypes.h" HAVE_INTTYPES_H)
check_include_file("limits.h" HAVE_LIMITS_H)

check_symbol_exists(mbrtowc "wchar.h" HAVE_MBRTOWC)
check_include_file("memory.h" HAVE_MEMORY_H)

if(HAVE_GETOPT_H)
  check_symbol_exists(optreset "getopt.h" HAVE_OPTRESET)
endif()

if(HAVE_FCNTL_H)
  check_symbol_exists(posix_fadvise "fcntl.h" HAVE_POSIX_FADVISE)
endif()

check_symbol_exists(pthread_condattr_setclock "pthread.h"
  HAVE_PTHREAD_CONDATTR_SETCLOCK)

check_c_source_compiles("
#include <pthread.h>
int main() { int i = PTHREAD_PRIO_INHERIT; }
" HAVE_PTHREAD_PRIO_INHERIT)

check_include_file("strings.h" HAVE_STRINGS_H)
check_include_file("sys/stat.h" HAVE_SYS_STAT_H)

if(HAVE_SYS_STAT_H)
  check_struct_has_member("struct stat" st_atimensec "sys/stat.h"
    HAVE_STRUCT_STAT_ST_ATIMENSEC LANGUAGE C)

  if(HAVE_STRUCT_STAT_ST_ATIMENSEC)
    check_struct_has_member("struct stat" st_atimespec.tv_nsec "sys/stat.h"
      HAVE_STRUCT_STAT_ST_ATIMESPEC_TV_NSEC LANGUAGE C)
  endif()

  check_struct_has_member("struct stat" st_atim.st__tim.tv_nsec "sys/stat.h"
    HAVE_STRUCT_STAT_ST_ATIM_ST__TIM_TV_NSEC LANGUAGE C)

  check_struct_has_member("struct stat" st_atim.tv_nsec "sys/stat.h"
    HAVE_STRUCT_STAT_ST_ATIM_TV_NSEC LANGUAGE C)

  check_struct_has_member("struct stat" st_uatime "sys/stat.h"
    HAVE_STRUCT_STAT_ST_UATIME LANGUAGE C)
endif()

check_include_file("sys/byteorder.h" HAVE_SYS_BYTEORDER_H)
check_include_file("sys/capsicum.h" HAVE_SYS_CAPSICUM_H)
check_include_file("sys/endian.h" HAVE_SYS_ENDIAN_H)
check_include_file("sys/param.h" HAVE_SYS_PARAM_H)
check_include_file("sys/types.h" HAVE_SYS_TYPES_H)

check_type_size(uintptr_t HAVE_UINTPTR_SIZE LANGUAGE C)
if(HAVE_UINTPTR_SIZE)
  set(HAVE_UINTPTR_T 1)
endif()

check_include_file("unistd.h" HAVE_UNISTD_H)
check_symbol_exists(utime "utime.h" HAVE_UTIME)

if(HAVE_SYS_TIME_H)
  check_symbol_exists(utimes "sys/time.h" HAVE_UTIMES)
endif()

if(UNIX)
  set(HAVE_VISIBILITY 1)
else()
  set(HAVE_VISIBILITY 0)
endif()

check_symbol_exists(wcwidth "wchar.h" HAVE_WCWIDTH)
check_symbol_exists(_futime "sys/utime.h" HAVE__FUTIME)

if(UNIX)
  set(MYTHREAD_POSIX 1)
elseif(WIN32)
  set(MYTHREAD_VISTA 1)
endif()

set(PACKAGE_VERSION ${PROJECT_VERSION})

check_symbol_exists(sched_getaffinity "sched.h" TUKLIB_CPUCORES_SCHED_GETAFFINITY)

check_c_source_compiles("
#include <unistd.h>
int main() {
#if defined(_SC_NPROCESSORS_ONLN)
  long i = sysconf(_SC_NPROCESSORS_ONLN);
#elif defined(_SC_NPROC_ONLN)
  long i = sysconf(_SC_NPROC_ONLN);
#else
#error _SC_NPROCESSORS_ONLN and _SC_NPROC_ONLN are not available.
#endif
}" TUKLIB_CPUCORES_SYSCONF)

if(UNIX AND NOT TUKLIB_CPUCORES_SYSCONF)
  set(TUKLIB_CPUCORES_SYSCTL 1)
endif()

check_c_source_compiles("
#include <unistd.h>
int main() {
  long p = sysconf(_SC_PAGESIZE);
  long s = sysconf(_SC_PHYS_PAGES);
}" TUKLIB_PHYSMEM_SYSCONF)

if(UNIX AND NOT TUKLIB_PHYSMEM_SYSCONF)
  set(TUKLIB_PHYSMEM_SYSCTL 1)
endif()

check_struct_has_member("struct sysinfo" totalram "sys/sysinfo.h"
  TUKLIB_PHYSMEM_SYSINFO_TOTALRAM LANGUAGE C)

check_struct_has_member("struct sysinfo" mem_unit "sys/sysinfo.h"
  TUKLIB_PHYSMEM_SYSINFO_MEM_UNIT LANGUAGE C)

if(TUKLIB_PHYSMEM_SYSINFO_TOTALRAM AND TUKLIB_PHYSMEM_SYSINFO_MEM_UNIT)
  set(TUKLIB_PHYSMEM_SYSINFO 1)
endif()

# Define WORDS_BIGENDIAN to 1 if your processor stores words with the most
# significant byte first (like Motorola and SPARC, unlike Intel).
set(WORDS_BIGENDIAN)

configure_file(config.h.in ${CMAKE_CURRENT_BINARY_DIR}/src/config.h LF)

# Headers
# grep -r nobase_include_HEADERS src
# src/src/liblzma/api/Makefile.am
set(headers
  src/src/liblzma/api/lzma.h
  src/src/liblzma/api/lzma/base.h
  src/src/liblzma/api/lzma/bcj.h
  src/src/liblzma/api/lzma/block.h
  src/src/liblzma/api/lzma/check.h
  src/src/liblzma/api/lzma/container.h
  src/src/liblzma/api/lzma/delta.h
  src/src/liblzma/api/lzma/filter.h
  src/src/liblzma/api/lzma/hardware.h
  src/src/liblzma/api/lzma/index.h
  src/src/liblzma/api/lzma/index_hash.h
  src/src/liblzma/api/lzma/lzma12.h
  src/src/liblzma/api/lzma/stream_flags.h
  src/src/liblzma/api/lzma/version.h
  src/src/liblzma/api/lzma/vli.h
)

# Sources
# grep -r liblzma_la_SOURCES src
# src/src/liblzma/Makefile.in
set(sources
  src/src/common/tuklib_physmem.c
  src/src/liblzma/common/common.c
  src/src/liblzma/common/common.h
  src/src/liblzma/common/memcmplen.h
  src/src/liblzma/common/block_util.c
  src/src/liblzma/common/easy_preset.c
  src/src/liblzma/common/easy_preset.h
  src/src/liblzma/common/filter_common.c
  src/src/liblzma/common/filter_common.h
  src/src/liblzma/common/hardware_physmem.c
  src/src/liblzma/common/index.c
  src/src/liblzma/common/index.h
  src/src/liblzma/common/stream_flags_common.c
  src/src/liblzma/common/stream_flags_common.h
  src/src/liblzma/common/vli_size.c
  src/src/liblzma/check/check.c
  src/src/liblzma/check/check.h
  src/src/liblzma/check/crc_macros.h
)

# src/src/liblzma/Makefile.am
list(APPEND sources
  src/src/common/tuklib_cpucores.c)

# src/src/liblzma/check/Makefile.inc
list(APPEND sources
  src/src/liblzma/check/check.c
  src/src/liblzma/check/check.h
  src/src/liblzma/check/crc_macros.h
  # COND_CHECK_CRC32 && !COND_SMALL
  src/src/liblzma/check/crc32_table.c
  src/src/liblzma/check/crc32_table_le.h
  src/src/liblzma/check/crc32_table_be.h
  # !COND_ASM_X86
  src/src/liblzma/check/crc32_fast.c
  # COND_CHECK_CRC64 && !COND_SMALL
  src/src/liblzma/check/crc64_table.c
  src/src/liblzma/check/crc64_table_le.h
  src/src/liblzma/check/crc64_table_be.h
  # !COND_ASM_X86
  src/src/liblzma/check/crc64_fast.c
  # COND_CHECK_SHA256 && COND_INTERNAL_SHA256
  src/src/liblzma/check/sha256.c
)

# src/src/liblzma/common/Makefile.inc
list(APPEND sources
  src/src/liblzma/common/common.c
  src/src/liblzma/common/common.h
  src/src/liblzma/common/memcmplen.h
  src/src/liblzma/common/block_util.c
  src/src/liblzma/common/easy_preset.c
  src/src/liblzma/common/easy_preset.h
  src/src/liblzma/common/filter_common.c
  src/src/liblzma/common/filter_common.h
  src/src/liblzma/common/hardware_physmem.c
  src/src/liblzma/common/index.c
  src/src/liblzma/common/index.h
  src/src/liblzma/common/stream_flags_common.c
  src/src/liblzma/common/stream_flags_common.h
  src/src/liblzma/common/vli_size.c
  # COND_THREADS
  src/src/liblzma/common/hardware_cputhreads.c
  # COND_MAIN_ENCODER
  src/src/liblzma/common/alone_encoder.c
  src/src/liblzma/common/block_buffer_encoder.c
  src/src/liblzma/common/block_buffer_encoder.h
  src/src/liblzma/common/block_encoder.c
  src/src/liblzma/common/block_encoder.h
  src/src/liblzma/common/block_header_encoder.c
  src/src/liblzma/common/easy_buffer_encoder.c
  src/src/liblzma/common/easy_encoder.c
  src/src/liblzma/common/easy_encoder_memusage.c
  src/src/liblzma/common/filter_buffer_encoder.c
  src/src/liblzma/common/filter_encoder.c
  src/src/liblzma/common/filter_encoder.h
  src/src/liblzma/common/filter_flags_encoder.c
  src/src/liblzma/common/index_encoder.c
  src/src/liblzma/common/index_encoder.h
  src/src/liblzma/common/stream_buffer_encoder.c
  src/src/liblzma/common/stream_encoder.c
  src/src/liblzma/common/stream_flags_encoder.c
  src/src/liblzma/common/vli_encoder.c
  # COND_MAIN_ENCODER && COND_THREADS
  src/src/liblzma/common/outqueue.c
  src/src/liblzma/common/outqueue.h
  src/src/liblzma/common/stream_encoder_mt.c
  # COND_MAIN_DECODER
  src/src/liblzma/common/alone_decoder.c
  src/src/liblzma/common/alone_decoder.h
  src/src/liblzma/common/auto_decoder.c
  src/src/liblzma/common/block_buffer_decoder.c
  src/src/liblzma/common/block_decoder.c
  src/src/liblzma/common/block_decoder.h
  src/src/liblzma/common/block_header_decoder.c
  src/src/liblzma/common/easy_decoder_memusage.c
  src/src/liblzma/common/filter_buffer_decoder.c
  src/src/liblzma/common/filter_decoder.c
  src/src/liblzma/common/filter_decoder.h
  src/src/liblzma/common/filter_flags_decoder.c
  src/src/liblzma/common/index_decoder.c
  src/src/liblzma/common/index_hash.c
  src/src/liblzma/common/stream_buffer_decoder.c
  src/src/liblzma/common/stream_decoder.c
  src/src/liblzma/common/stream_decoder.h
  src/src/liblzma/common/stream_flags_decoder.c
  src/src/liblzma/common/vli_decoder.c
)

# src/src/liblzma/delta/Makefile.inc
list(APPEND sources
  src/src/liblzma/delta/delta_common.c
  src/src/liblzma/delta/delta_common.h
  src/src/liblzma/delta/delta_private.h
  # COND_ENCODER_DELTA
  src/src/liblzma/delta/delta_encoder.c
  src/src/liblzma/delta/delta_encoder.h
  # COND_DECODER_DELTA
  src/src/liblzma/delta/delta_decoder.c
  src/src/liblzma/delta/delta_decoder.h
)

# src/src/liblzma/lz/Makefile.inc
list(APPEND sources
  # COND_ENCODER_LZ
  src/src/liblzma/lz/lz_encoder.c
  src/src/liblzma/lz/lz_encoder.h
  src/src/liblzma/lz/lz_encoder_hash.h
  src/src/liblzma/lz/lz_encoder_hash_table.h
  src/src/liblzma/lz/lz_encoder_mf.c
  # COND_DECODER_LZ
  src/src/liblzma/lz/lz_decoder.c
  src/src/liblzma/lz/lz_decoder.h
)

# src/src/liblzma/lzma/Makefile.inc
list(APPEND sources
  src/src/liblzma/lzma/lzma_common.h
  # COND_FILTER_LZMA1
  src/src/liblzma/lzma/lzma_encoder_presets.c
  # COND_ENCODER_LZMA1
  src/src/liblzma/lzma/fastpos.h
  src/src/liblzma/lzma/lzma_encoder.h
  src/src/liblzma/lzma/lzma_encoder.c
  src/src/liblzma/lzma/lzma_encoder_private.h
  src/src/liblzma/lzma/lzma_encoder_optimum_fast.c
  src/src/liblzma/lzma/lzma_encoder_optimum_normal.c
  # COND_ENCODER_LZMA1 && !COND_SMALL
  src/src/liblzma/lzma/fastpos_table.c
  # COND_DECODER_LZMA1
  src/src/liblzma/lzma/lzma_decoder.c
  src/src/liblzma/lzma/lzma_decoder.h
  # COND_ENCODER_LZMA2
  src/src/liblzma/lzma/lzma2_encoder.c
  src/src/liblzma/lzma/lzma2_encoder.h
  # COND_DECODER_LZMA2
  src/src/liblzma/lzma/lzma2_decoder.c
  src/src/liblzma/lzma/lzma2_decoder.h
)

# src/src/liblzma/rangecoder/Makefile.inc
list(APPEND sources
  src/src/liblzma/rangecoder/range_common.h
  # COND_ENCODER_LZMA1
  src/src/liblzma/rangecoder/range_encoder.h
  src/src/liblzma/rangecoder/price.h
  src/src/liblzma/rangecoder/price_table.c
  # COND_DECODER_LZMA1
  src/src/liblzma/rangecoder/range_decoder.h
)

# src/src/liblzma/simple/Makefile.inc
list(APPEND sources
  src/src/liblzma/simple/simple_coder.c
  src/src/liblzma/simple/simple_coder.h
  src/src/liblzma/simple/simple_private.h
  # COND_ENCODER_SIMPLE
  src/src/liblzma/simple/simple_encoder.c
  src/src/liblzma/simple/simple_encoder.h
  # COND_DECODER_SIMPLE
  src/src/liblzma/simple/simple_decoder.c
  src/src/liblzma/simple/simple_decoder.h
  # COND_FILTER_X86
  src/src/liblzma/simple/x86.c
  # COND_FILTER_POWERPC
  #src/src/liblzma/simple/powerpc.c
  # COND_FILTER_IA64
  #src/src/liblzma/simple/ia64.c
  # COND_FILTER_ARM
  #src/src/liblzma/simple/arm.c
  # COND_FILTER_ARMTHUMB
  #src/src/liblzma/simple/armthumb.c
  # COND_FILTER_SPARC
  #src/src/liblzma/simple/sparc.c
)

# src/src/liblzma/Makefile.in
set(LZMA_INCLUDE_PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}/src/src/liblzma/api
)

# src/src/liblzma/Makefile.in
set(LZMA_INCLUDE_PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/src/src/liblzma/common
  ${CMAKE_CURRENT_SOURCE_DIR}/src/src/liblzma/check
  ${CMAKE_CURRENT_SOURCE_DIR}/src/src/liblzma/lz
  ${CMAKE_CURRENT_SOURCE_DIR}/src/src/liblzma/rangecoder
  ${CMAKE_CURRENT_SOURCE_DIR}/src/src/liblzma/lzma
  ${CMAKE_CURRENT_SOURCE_DIR}/src/src/liblzma/delta
  ${CMAKE_CURRENT_SOURCE_DIR}/src/src/liblzma/simple
  ${CMAKE_CURRENT_SOURCE_DIR}/src/src/common
)

# src/src/liblzma/api/Makefile.am
list(APPEND CMAKE_REQUIRED_DEFINITIONS
  -DTUKLIB_SYMBOL_PREFIX=lzma_)

# src/configure
list(APPEND CMAKE_REQUIRED_DEFINITIONS
  -DHAVE_CONFIG_H)

# Libraries
add_library(lzma_shared SHARED ${headers} ${sources})
target_compile_features(lzma_shared PRIVATE c_std_11)
target_compile_definitions(lzma_shared PRIVATE DLL_EXPORT)

target_include_directories(lzma_shared
  PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR}/src
    ${LZMA_INCLUDE_PRIVATE}
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
    $<BUILD_INTERFACE:${LZMA_INCLUDE_PUBLIC}>
    $<INSTALL_INTERFACE:include>)

add_library(lzma_static STATIC ${headers} ${sources})
target_compile_features(lzma_static PRIVATE c_std_11)
target_compile_definitions(lzma_static PUBLIC LZMA_API_STATIC)

target_include_directories(lzma_static
  PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR}/src
    ${LZMA_INCLUDE_PRIVATE}
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
    $<BUILD_INTERFACE:${LZMA_INCLUDE_PUBLIC}>
    $<INSTALL_INTERFACE:include>)

target_compile_definitions(lzma_shared PRIVATE ${CMAKE_REQUIRED_DEFINITIONS})
target_compile_definitions(lzma_static PRIVATE ${CMAKE_REQUIRED_DEFINITIONS})

if(HAVE_VISIBILITY)
  set_target_properties(lzma_shared PROPERTIES C_VISIBILITY_PRESET hidden)
endif()

target_link_libraries(lzma_shared PRIVATE ${CMAKE_REQUIRED_LIBRARIES})
target_link_libraries(lzma_static PUBLIC ${CMAKE_REQUIRED_LIBRARIES})

set_target_properties(lzma_shared PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreadedDLL
  ARCHIVE_OUTPUT_DIRECTORY shared
  OUTPUT_NAME lzma)

set_target_properties(lzma_static PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreaded
  ARCHIVE_OUTPUT_DIRECTORY static
  OUTPUT_NAME lzma)

# Install
install(TARGETS lzma_shared
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib$<$<PLATFORM_ID:Windows>:/shared>
  LIBRARY DESTINATION lib$<$<PLATFORM_ID:Windows>:/shared>)

install(TARGETS lzma_static
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib$<$<PLATFORM_ID:Windows>:/static>
  LIBRARY DESTINATION lib$<$<PLATFORM_ID:Windows>:/static>)

install(DIRECTORY ${LZMA_INCLUDE_PUBLIC}/ DESTINATION include
  FILES_MATCHING PATTERN "*.h")

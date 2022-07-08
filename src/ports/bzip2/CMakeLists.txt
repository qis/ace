cmake_minimum_required(VERSION 3.22 FATAL_ERROR)
project(bzip2 VERSION 1.0.8 LANGUAGES C)

# Headers
set(headers src/bzlib.h)

# Sources
set(sources
  src/blocksort.c
  src/huffman.c
  src/crctable.c
  src/randtable.c
  src/compress.c
  src/decompress.c
  src/bzlib.c)

# Libraries
add_library(bz2_shared SHARED ${headers} ${sources})
target_compile_features(bz2_shared PRIVATE c_std_11)
target_include_directories(bz2_shared PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
  $<INSTALL_INTERFACE:include>)

target_compile_definitions(bz2_shared PRIVATE BZ_EXPORT PUBLIC BZ_IMPORT)

add_library(bz2_static STATIC ${headers} ${sources})
target_compile_features(bz2_static PRIVATE c_std_11)
target_include_directories(bz2_static PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
  $<INSTALL_INTERFACE:include>)

if(WIN32)
  target_compile_definitions(bz2_shared PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN)
  target_compile_definitions(bz2_static PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN)
else()
  set_target_properties(bz2_shared PROPERTIES C_VISIBILITY_PRESET hidden)
endif()

find_package(Threads REQUIRED)
target_link_libraries(bz2_shared PRIVATE Threads::Threads)
target_link_libraries(bz2_static PUBLIC Threads::Threads)

set_target_properties(bz2_shared PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreadedDLL
  ARCHIVE_OUTPUT_DIRECTORY shared
  OUTPUT_NAME bz2)

set_target_properties(bz2_static PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreaded
  ARCHIVE_OUTPUT_DIRECTORY static
  OUTPUT_NAME bz2)

# Install
install(TARGETS bz2_shared
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib$<$<PLATFORM_ID:Windows>:/shared>
  LIBRARY DESTINATION lib$<$<PLATFORM_ID:Windows>:/shared>)

install(TARGETS bz2_static
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib$<$<PLATFORM_ID:Windows>:/static>
  LIBRARY DESTINATION lib$<$<PLATFORM_ID:Windows>:/static>)

install(FILES ${headers} DESTINATION include)

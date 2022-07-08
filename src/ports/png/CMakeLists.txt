cmake_minimum_required(VERSION 3.22 FATAL_ERROR)
project(png VERSION 1.6.37 LANGUAGES C)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/src/scripts/pnglibconf.h.prebuilt
  ${CMAKE_CURRENT_BINARY_DIR}/src/pnglibconf.h)

add_definitions(-DPNG_INTEL_SSE_OPT=1)

if(MSVC)
  add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
endif()

set(libpng_intel_sources
  src/intel/intel_init.c
  src/intel/filter_sse2_intrinsics.c)

# Headers
set(headers
  src/png.h
  src/pngconf.h
  ${CMAKE_CURRENT_BINARY_DIR}/src/pnglibconf.h)

# Sources
set(sources
  src/pngpriv.h
  src/pngdebug.h
  src/pnginfo.h
  src/pngstruct.h
  src/png.c
  src/pngerror.c
  src/pngget.c
  src/pngmem.c
  src/pngpread.c
  src/pngread.c
  src/pngrio.c
  src/pngrtran.c
  src/pngrutil.c
  src/pngset.c
  src/pngtrans.c
  src/pngwio.c
  src/pngwrite.c
  src/pngwtran.c
  src/pngwutil.c
  ${libpng_intel_sources})

# Libraries
add_library(png_shared SHARED ${headers} ${sources})
target_compile_features(png_shared PRIVATE c_std_11)
target_include_directories(png_shared PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/src>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
  $<INSTALL_INTERFACE:include>)

if(WIN32)
  target_compile_definitions(png_shared PRIVATE PNG_BUILD_DLL PUBLIC PNG_USE_DLL)
endif()

add_library(png_static STATIC ${headers} ${sources})
target_compile_features(png_static PRIVATE c_std_11)
target_include_directories(png_static PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/src>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
  $<INSTALL_INTERFACE:include>)

if(WIN32)
  target_compile_definitions(png_shared PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN)
  target_compile_definitions(png_static PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN)
endif()

find_package(Threads REQUIRED)
target_link_libraries(png_shared PRIVATE Threads::Threads)
target_link_libraries(png_static PUBLIC Threads::Threads)

find_package(ZLIB REQUIRED)
target_link_libraries(png_shared PRIVATE ZLIB::ZLIB_shared)
target_link_libraries(png_static PUBLIC ZLIB::ZLIB_static)

set_target_properties(png_shared PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreadedDLL
  ARCHIVE_OUTPUT_DIRECTORY shared
  OUTPUT_NAME png)

set_target_properties(png_static PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreaded
  ARCHIVE_OUTPUT_DIRECTORY static
  OUTPUT_NAME png)

# Install
install(TARGETS png_shared
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib$<$<PLATFORM_ID:Windows>:/shared>
  LIBRARY DESTINATION lib$<$<PLATFORM_ID:Windows>:/shared>)

install(TARGETS png_static
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib$<$<PLATFORM_ID:Windows>:/static>
  LIBRARY DESTINATION lib$<$<PLATFORM_ID:Windows>:/static>)

install(FILES ${headers} DESTINATION include)

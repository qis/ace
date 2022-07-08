cmake_minimum_required(VERSION 3.22 FATAL_ERROR)
project(main DESCRIPTION "Library Test" VERSION 0.1.0 LANGUAGES CXX)

configure_file(res/version.h.in ${CMAKE_CURRENT_BINARY_DIR}/src/version.h LF)

add_library(print src/print.hpp src/print.cpp)
target_compile_features(print PUBLIC cxx_std_23)

if(BUILD_SHARED_LIBS)
  target_compile_definitions(print
    PRIVATE PRINT_EXPORT
    PUBLIC PRINT_IMPORT)
endif()

if(WIN32)
  target_compile_definitions(print PUBLIC NOMINMAX WIN32_LEAN_AND_MEAN)
else()
  set_target_properties(print PROPERTIES CXX_VISIBILITY_PRESET hidden)
endif()

target_include_directories(print PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
  $<INSTALL_INTERFACE:include>)

add_executable(main src/main.cpp src/main.manifest src/main.rc)

target_include_directories(main PRIVATE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/src>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>)

target_link_libraries(main PRIVATE print)

find_package(TBB REQUIRED)
target_link_libraries(main PRIVATE TBB::tbb)

set(PORTS tbb zlib bzip2 lz4 lzma brotli zstd icu xml2 ssl boost)

if(UNIX)
  list(APPEND PORTS backtrace)
endif()

include(AceCreateLicense)
ace_create_license(${CMAKE_CURRENT_BINARY_DIR}
  RTF ${CMAKE_CURRENT_SOURCE_DIR}/res/license.rtf
  TXT ${CMAKE_CURRENT_SOURCE_DIR}/res/license.txt
  PORTS ${PORTS})

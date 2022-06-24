cmake_minimum_required(VERSION 3.22 FATAL_ERROR)
project(main DESCRIPTION "Zlib Test" VERSION 0.1.0 LANGUAGES CXX)

configure_file(res/version.h.in ${CMAKE_CURRENT_BINARY_DIR}/src/version.h LF)

add_executable(main src/main.cpp src/main.manifest src/main.rc)
target_compile_features(main PRIVATE cxx_std_23)

if(WIN32)
  target_compile_definitions(main PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN)
endif()

target_include_directories(main PRIVATE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/src>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>)

find_package(ZLIB REQUIRED)
target_link_libraries(main PRIVATE ZLIB::ZLIB)

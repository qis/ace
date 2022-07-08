cmake_minimum_required(VERSION 3.22 FATAL_ERROR)
project(main VERSION 0.1.0 LANGUAGES CXX)

add_executable(main main.cpp main.manifest)
target_compile_features(main PRIVATE cxx_std_23)

if(WIN32)
  target_compile_definitions(main PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN)
endif()

find_package(ZLIB REQUIRED)
target_link_libraries(main PRIVATE ZLIB::ZLIB)

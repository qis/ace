cmake_minimum_required(VERSION 3.22 FATAL_ERROR)
project(main DESCRIPTION "C Test" VERSION 0.1.0 LANGUAGES C)

add_executable(main main.c main.manifest)
target_compile_features(main PRIVATE c_std_11)

if(WIN32)
  target_compile_definitions(main PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN)
endif()

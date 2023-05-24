cmake_minimum_required(VERSION 3.26 FATAL_ERROR)
project(tests VERSION 1.0.0 LANGUAGES CXX)

add_executable(main $ENV{PORT}/main.cpp main.manifest main.rc)

if(WIN32)
  target_compile_definitions(main PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN)
endif()

include($ENV{PORT}/config.cmake)

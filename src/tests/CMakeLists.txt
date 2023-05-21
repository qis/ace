cmake_minimum_required(VERSION 3.26 FATAL_ERROR)
project(tests VERSION 1.0.0 LANGUAGES CXX)

add_executable(main $ENV{PORT}/main.cpp main.manifest main.rc)
target_compile_features(main PRIVATE cxx_std_20)
target_compile_options(main PRIVATE -fexperimental-library)
target_link_options(main PRIVATE -fexperimental-library)

include($ENV{PORT}/config.cmake)

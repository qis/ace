cmake_minimum_required(VERSION 3.22 FATAL_ERROR)
project(main VERSION 0.1.0 LANGUAGES CXX)

add_executable(main main.cpp)
target_compile_features(main PRIVATE cxx_std_23)

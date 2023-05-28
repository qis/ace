cmake_minimum_required(VERSION 3.26 FATAL_ERROR)
project(libc++-std VERSION 17.0.0 LANGUAGES CXX)

set(CMAKE_EXPERIMENTAL_CXX_MODULE_CMAKE_API "2182bf5c-ef0d-489a-91da-49dbc3090d2a")
set(CMAKE_EXPERIMENTAL_CXX_MODULE_DYNDEP 1)

add_library(std)

file(GLOB sources std.cppm std/*.cppm)
target_sources(std PUBLIC FILE_SET cxx_modules TYPE CXX_MODULES FILES ${sources})

target_compile_definitions(std PRIVATE _LIBCPP_ENABLE_EXPERIMENTAL)
target_compile_options(std PUBLIC -Wno-reserved-module-identifier)
target_compile_features(std PUBLIC cxx_std_23)

install(TARGETS std
  ARCHIVE DESTINATION "$<CONFIG>"
  CXX_MODULES_BMI DESTINATION "$<CONFIG>")

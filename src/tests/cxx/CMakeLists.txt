cmake_minimum_required(VERSION 3.22 FATAL_ERROR)
project(main DESCRIPTION "C++ Test" VERSION 0.1.0 LANGUAGES CXX)

add_executable(main main.cpp main.manifest)
target_compile_features(main PRIVATE cxx_std_23)

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  find_package(TBB CONFIG QUIET)
  if(TARGET TBB::tbb)
    target_link_libraries(main PRIVATE TBB::tbb)
  endif()
endif()

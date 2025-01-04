cmake_minimum_required(VERSION 3.28 FATAL_ERROR)
project(ace-test VERSION 0.1.0 LANGUAGES C CXX)

add_executable(main main.cpp main.manifest)
target_compile_features(main PRIVATE cxx_std_26)

# TODO
# 1. GLM supports C++ modules.
# 2. Check, that the library is compiled for x86-64-v1.
# 3. Check, that the header-only test uses x86-64-v3 instructions.

find_package(glm CONFIG REQUIRED)
target_link_libraries(main PRIVATE glm::glm)
#target_link_libraries(main PRIVATE glm::glm-header-only)

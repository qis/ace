cmake_minimum_required(VERSION 3.31 FATAL_ERROR)
project(ace DESCRIPTION "Ace" VERSION 0.1.0 LANGUAGES C CXX)

# Version
set(PROJECT_VENDOR "Vendor")
configure_file(res/version.h.in ${CMAKE_CURRENT_BINARY_DIR}/src/version.h LF)

# Objects
file(GLOB_RECURSE modules CONFIGURE_DEPENDS src/${PROJECT_NAME}/*.ccm)
file(GLOB_RECURSE sources CONFIGURE_DEPENDS src/${PROJECT_NAME}/*.cpp)

add_library(objects OBJECT ${sources})
target_sources(objects PUBLIC FILE_SET CXX_MODULES FILES ${modules})
target_include_directories(objects PRIVATE src PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/src)

if(WIN32)
  target_compile_definitions(objects PUBLIC NOMINMAX WIN32_LEAN_AND_MEAN)
endif()

# Application
add_executable(main src/main.cpp src/main.rc)
set_target_properties(main PROPERTIES OUTPUT_NAME ${PROJECT_NAME})
target_link_libraries(main PRIVATE objects)

# Tests
if(BUILD_TESTING)
  include(CTest)

  find_package(doctest CONFIG REQUIRED)
  add_executable(tests src/test.cpp src/main.rc)
  target_link_libraries(tests PRIVATE objects doctest::doctest)

  include(doctest)
  doctest_discover_tests(tests)
endif()

# Install
install(TARGETS main RUNTIME DESTINATION bin)

# GTest
# https://cmake.org/cmake/help/latest/module/FindGTest.html
# https://cmake.org/cmake/help/latest/module/GoogleTest.html
#
#   enable_testing()
#   include(GoogleTest)
#   find_package(GTest REQUIRED)
#   target_link_libraries(main PRIVATE GTest::gtest GTest::gmock)
#   gtest_discover_tests(main)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

set(GTEST_VERSION_STRING ${GTest_VERSION})
set(GTEST_VERSION ${GTEST_VERSION_STRING})
set(GTEST_INCLUDE_DIRS)

set(GTEST_LIBRARIES GTest::gtest)
set(GTEST_MAIN_LIBRARIES GTest::gtest_main)
set(GTEST_BOTH_LIBRARIES GTest::gtest GTest::gtest_main)

include(CMakeFindDependencyMacro)
find_dependency(Threads REQUIRED)

include(AceImportLibrary)
ace_import_library(GTest::gtest CXX NAMES gtest HEADERS gtest/gtest.h
  COMPILE_DEFINITIONS_SHARED GTEST_LINKED_AS_SHARED_LIBRARY
  LINK_LIBRARIES Threads::Threads)

ace_import_library(GTest::gtest_main CXX NAMES gtest_main
  LINK_LIBRARIES GTest::gtest)

ace_import_library(GTest::gmock CXX NAMES gmock HEADERS gmock/gmock.h
  LINK_LIBRARIES GTest::gtest)

ace_import_library(GTest::gmock_main CXX NAMES gmock_main
  LINK_LIBRARIES GTest::gmock)

add_library(GTest::GTest ALIAS GTest::gtest)
add_library(GTest::Main ALIAS GTest::gtest_main)

set(GTEST_ROOT "" CACHE STRING "")
set(GTEST_INCLUDE_DIR "${GTEST_INCLUDE_DIRS}" CACHE STRING "")
set(GTEST_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

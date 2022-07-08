# Backtrace
# https://cmake.org/cmake/help/latest/module/FindBacktrace.html
#
#   find_package(Backtrace REQUIRED)
#   target_link_libraries(main PRIVATE Backtrace::Backtrace)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

enable_language(CXX)

set(Backtrace_VERSION_STRING ${Backtrace_VERSION})
set(Backtrace_INCLUDE_DIRS)

set(Backtrace_LIBRARIES Backtrace::Backtrace)

include(CMakeFindDependencyMacro)
find_dependency(ZLIB REQUIRED)
find_dependency(LibLZMA REQUIRED)

find_library(Backtrace_LIBRARY
  NAMES libbacktrace.a
  PATHS ${ACE_SYSTEM_ROOT}/lib
  NO_DEFAULT_PATH NO_CACHE REQUIRED)

add_library(Backtrace::Backtrace STATIC IMPORTED)
set_target_properties(Backtrace::Backtrace PROPERTIES
  INTERFACE_LINK_LIBRARIES "ZLIB::ZLIB;LibLZMA::LibLZMA"
  IMPORTED_LOCATION "${Backtrace_LIBRARY}"
  IMPORTED_LINK_INTERFACE_LANGUAGES "C")

set(Backtrace_INCLUDE_DIR "${Backtrace_INCLUDE_DIRS}" CACHE STRING "")
set(Backtrace_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

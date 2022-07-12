# benchmark
#
#   find_package(benchmark REQUIRED)
#   target_link_libraries(main PRIVATE benchmark::benchmark)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

set(benchmark_VERSION_STRING ${benchmark_VERSION})
set(benchmark_INCLUDE_DIRS)

set(benchmark_LIBRARIES benchmark::benchmark)

include(CMakeFindDependencyMacro)
find_dependency(Threads REQUIRED)

if(UNIX)
  find_library(benchmark_LIBRARY
    NAMES libbenchmark.a
    PATHS ${ACE_TARGET_ROOT}/lib
    NO_DEFAULT_PATH NO_CACHE REQUIRED)

  add_library(benchmark::benchmark STATIC IMPORTED)
  set_target_properties(benchmark::benchmark PROPERTIES
    INTERFACE_LINK_LIBRARIES "\$<LINK_ONLY:Threads::Threads>;\$<LINK_ONLY:rt>"
    IMPORTED_LOCATION "${benchmark_LIBRARY}"
    IMPORTED_LINK_INTERFACE_LANGUAGES "CXX")

  find_library(benchmark_main_LIBRARY
    NAMES libbenchmark_main.a
    PATHS ${ACE_TARGET_ROOT}/lib
    NO_DEFAULT_PATH NO_CACHE REQUIRED)

  add_library(benchmark::benchmark_main STATIC IMPORTED)
  set_target_properties(benchmark::benchmark_main PROPERTIES
    INTERFACE_LINK_LIBRARIES "benchmark::benchmark"
    IMPORTED_LOCATION "${benchmark_main_LIBRARY}"
    IMPORTED_LINK_INTERFACE_LANGUAGES "CXX")
elseif(WIN32)
  include(AceImportLibrary)
  ace_import_library(benchmark::benchmark CXX
    HEADERS benchmark/benchmark.h
    NAMES_STATIC benchmark
    LINK_LIBRARIES Threads::Threads shlwapi)
  ace_import_library(benchmark::benchmark_main CXX
    NAMES_STATIC benchmark_main
    LINK_LIBRARIES benchmark::benchmark)
endif()

set(benchmark_INCLUDE_DIR "${benchmark_INCLUDE_DIRS}" CACHE STRING "")
set(benchmark_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

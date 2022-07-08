# PNG
# https://cmake.org/cmake/help/latest/module/FindPNG.html
#
#   find_package(PNG REQUIRED)
#   target_link_libraries(main PRIVATE PNG::PNG)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

set(PNG_VERSION_STRING ${PNG_VERSION})
set(PNG_INCLUDE_DIRS)
set(PNG_DEFINITIONS)

set(PNG_LIBRARIES PNG::PNG)

include(CMakeFindDependencyMacro)
find_dependency(Threads REQUIRED)
find_dependency(ZLIB REQUIRED)

include(AceImportLibrary)
ace_import_library(PNG::PNG C NAMES png HEADERS png.h
  LINK_LIBRARIES Threads::Threads ZLIB::ZLIB
  COMPILE_DEFINITIONS_SHARED PNG_USE_DLL)

set(PNG_INCLUDE_DIR "${PNG_INCLUDE_DIRS}" CACHE STRING "")
set(PNG_LIBRARY "${PNG_LIBRARIES}" CACHE STRING "")
set(PNG_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

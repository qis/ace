# Editline
#
#   find_package(Editline REQUIRED)
#   target_link_libraries(main PRIVATE Editline::Editline)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

set(EDITLINE_VERSION_STRING ${Editline_VERSION})
set(EDITLINE_INCLUDE_DIRS)

set(EDITLINE_LIBRARIES Editline::Editline)

include(AceImportLibrary)
ace_import_library(Editline::Editline C
  NAMES_STATIC edit HEADERS readline.h)

set(EDITLINE_INCLUDE_DIR "${EDITLINE_INCLUDE_DIRS}" CACHE STRING "")
set(EDITLINE_LIBRARY "${EDITLINE_LIBRARIES}" CACHE STRING "")
set(EDITLINE_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

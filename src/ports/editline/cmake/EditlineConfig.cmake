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

find_library(EDITLINE_LIBRARY
  NAMES libedit.a
  PATHS ${ACE_SYSTEM_ROOT}/lib
  NO_DEFAULT_PATH NO_CACHE REQUIRED)

add_library(Editline::Editline STATIC IMPORTED)
set_target_properties(Editline::Editline PROPERTIES
  IMPORTED_LOCATION "${EDITLINE_LIBRARY}"
  IMPORTED_LINK_INTERFACE_LANGUAGES "C")

set(EDITLINE_INCLUDE_DIR "${EDITLINE_INCLUDE_DIRS}" CACHE STRING "")
set(EDITLINE_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

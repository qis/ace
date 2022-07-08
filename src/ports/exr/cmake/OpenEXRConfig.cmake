# OpenEXR
#
#   find_package(OpenEXR REQUIRED)
#   target_link_libraries(main PRIVATE OpenEXR::OpenEXR OpenEXR::OpenEXRUtil)
#
#   find_program(EXR2ACES_EXECUTABLE exr2aces REQUIRED)
#   find_program(EXRENVMAP_EXECUTABLE exrenvmap REQUIRED)
#   find_program(EXRHEADER_EXECUTABLE exrheader REQUIRED)
#   find_program(EXRINFO_EXECUTABLE exrinfo REQUIRED)
#   find_program(EXRMAKEPREVIEW_EXECUTABLE exrmakepreview REQUIRED)
#   find_program(EXRMAKETILED_EXECUTABLE exrmaketiled REQUIRED)
#   find_program(EXRMULTIPART_EXECUTABLE exrmultipart REQUIRED)
#   find_program(EXRMULTIVIEW_EXECUTABLE exrmultiview REQUIRED)
#   find_program(EXRSTDATTR_EXECUTABLE exrstdattr REQUIRED)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

set(OPENEXR_VERSION_STRING ${OpenEXR_VERSION})
set(OPENEXR_VERSION ${OPENEXR_VERSION_STRING})

set(OPENEXR_LIBRARIES OpenEXR::OpenEXR)

include(CMakeFindDependencyMacro)
find_dependency(Threads REQUIRED)
find_dependency(Imath REQUIRED)
find_dependency(ZLIB REQUIRED)

include(AceImportLibrary)
ace_import_library(OpenEXR::OpenEXRConfig C
  HEADERS_LOCATIONS OpenEXR HEADERS OpenEXRConfig.h
  LINK_LIBRARIES Threads::Threads
  REQUIRED ${OpenEXR_FIND_REQUIRED})

get_target_property(OPENEXR_INCLUDE_DIRS
  OpenEXR::OpenEXRConfig INTERFACE_INCLUDE_DIRECTORIES)

add_library(OpenEXR::IexConfig ALIAS OpenEXR::OpenEXRConfig)
add_library(OpenEXR::IlmThreadConfig ALIAS OpenEXR::OpenEXRConfig)

ace_import_library(OpenEXR::Iex CXX NAMES iex
  LINK_LIBRARIES OpenEXR::OpenEXRConfig)

ace_import_library(OpenEXR::IlmThread CXX NAMES ilmthread
  LINK_LIBRARIES OpenEXR::OpenEXRConfig OpenEXR::Iex)

ace_import_library(OpenEXR::OpenEXRCore CXX NAMES exrcore
  LINK_LIBRARIES OpenEXR::OpenEXRConfig Imath::Imath ZLIB::ZLIB)

ace_import_library(OpenEXR::OpenEXR CXX NAMES exr
  LINK_LIBRARIES OpenEXR::OpenEXRConfig Imath::Imath OpenEXR::Iex OpenEXR::IlmThread ZLIB::ZLIB)

ace_import_library(OpenEXR::OpenEXRUtil CXX NAMES exrutil
  LINK_LIBRARIES OpenEXR::OpenEXRConfig OpenEXR::OpenEXR OpenEXR::OpenEXRCore)

string(REPLACE "." ";" OPENEXR_VERSION_LIST ${OPENEXR_VERSION})
list(GET OPENEXR_VERSION_LIST 0 OPENEXR_VERSION_MAJOR)
list(GET OPENEXR_VERSION_LIST 1 OPENEXR_VERSION_MINOR)
list(GET OPENEXR_VERSION_LIST 2 OPENEXR_VERSION_PATCH)
set(OPENEXR_VERSION_TWEAK 0)

set(OPENEXR_INCLUDE_DIR "${OPENEXR_INCLUDE_DIRS}" CACHE STRING "")
set(OPENEXR_LIBRARY "${OPENEXR_LIBRARIES}" CACHE STRING "")
set(OPENEXR_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

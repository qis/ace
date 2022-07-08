# FasTC
#
#   find_package(FasTC REQUIRED)
#   target_link_libraries(main PRIVATE FasTC::Core)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

enable_language(CXX)

set(FasTC_VERSION_STRING ${FasTC_VERSION})
set(FasTC_INCLUDE_DIRS)

set(FasTC_LIBRARIES FasTCCore)

include(CMakeFindDependencyMacro)
find_dependency(PNG REQUIRED)

include(AceImportLibrary)

ace_import_library(FasTCBase CXX
  NAMES_STATIC FasTCBase HEADERS FasTC/Color.h
  REQUIRED ${FasTC_FIND_REQUIRED})

add_library(FasTC::Base ALIAS FasTCBase)

ace_import_library(FasTCCore CXX
  NAMES_STATIC FasTCCore HEADERS FasTC/CompressedImage.h
  LINK_LIBRARIES FasTCBase FasTCIO ASTCEncoder BPTCEncoder DXTEncoder ETCEncoder PVRTCEncoder PNG::PNG)

add_library(FasTC::Core ALIAS FasTCCore)

ace_import_library(FasTCIO CXX
  NAMES_STATIC FasTCIO HEADERS FasTC/FileStream.h
  LINK_LIBRARIES FasTCBase FasTCCore)

add_library(FasTC::IO ALIAS FasTCIO)

ace_import_library(ASTCEncoder CXX
  NAMES_STATIC ASTCEncoder HEADERS FasTC/ASTCCompressor.h
  LINK_LIBRARIES FasTCBase)

add_library(FasTC::ASTCEncoder ALIAS ASTCEncoder)

ace_import_library(BPTCEncoder CXX
  NAMES_STATIC BPTCEncoder HEADERS FasTC/BPTCCompressor.h
  LINK_LIBRARIES FasTCBase)

add_library(FasTC::BPTCEncoder ALIAS BPTCEncoder)

ace_import_library(DXTEncoder CXX
  NAMES_STATIC DXTEncoder HEADERS FasTC/DXTCompressor.h
  LINK_LIBRARIES FasTCBase)

add_library(FasTC::DXTEncoder ALIAS DXTEncoder)

ace_import_library(ETCEncoder CXX
  NAMES_STATIC ETCEncoder HEADERS FasTC/ETCCompressor.h
  LINK_LIBRARIES FasTCBase)

add_library(FasTC::ETCEncoder ALIAS ETCEncoder)

ace_import_library(PVRTCEncoder CXX
  NAMES_STATIC PVRTCEncoder HEADERS FasTC/PVRTCCompressor.h
  LINK_LIBRARIES FasTCBase)

add_library(FasTC::PVRTCEncoder ALIAS PVRTCEncoder)

set(FasTC_INCLUDE_DIR "${FasTC_INCLUDE_DIRS}" CACHE STRING "")
set(FasTC_LIBRARY "${FasTC_LIBRARIES}" CACHE STRING "")
set(FasTC_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

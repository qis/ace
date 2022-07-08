# International Components for Unicode
# https://cmake.org/cmake/help/latest/module/FindICU.html
#
#   find_package(ICU REQUIRED)
#   find_package(ICU REQUIRED COMPONENTS ALL)
#   find_package(ICU REQUIRED COMPONENTS data uc i18n)
#   target_link_libraries(main PRIVATE ICU::data ICU::uc ICU::i18n)
#
#   add_custom_command(OUTPUT icudtl.dat
#     COMMAND ${CMAKE_COMMAND} -E copy_if_different ${ICU_DATA} icudtl.dat
#     MAIN_DEPENDENCY ${ICU_DATA} USES_TERMINAL)
#
#   target_sources(main PRIVATE icudtl.dat)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

if(EXISTS ${ACE_SYSTEM_ROOT}/share/icu/icudtl.dat)
  set(ICU_DATA "${ACE_SYSTEM_ROOT}/share/icu/icudtl.dat" CACHE PATH "")
  message(VERBOSE "Found ICU data file: ${ICU_DATA}")
else()
  message(FATAL_ERROR "Missing ICU data file: ${ACE_SYSTEM_ROOT}/share/icu/icudtl.dat")
  set(ICU_DATA "" CACHE STRING "")
endif()

enable_language(CXX)

set(ICU_VERSION_STRING ${ICU_VERSION})
set(ICU_INCLUDE_DIRS)

set(ICU_DEFINITIONS "U_DISABLE_RENAMING=1")
set(ICU_LIBRARIES)

if(NOT ICU_FIND_COMPONENTS)
  set(ICU_FIND_COMPONENTS ALL)
endif()

if("ALL" IN_LIST ICU_FIND_COMPONENTS)
  set(ICU_FIND_COMPONENTS data uc i18n)
endif()

if("i18n" IN_LIST ICU_FIND_COMPONENTS)
  list(APPEND ICU_FIND_COMPONENTS uc)
endif()

if("uc" IN_LIST ICU_FIND_COMPONENTS)
  list(APPEND ICU_FIND_COMPONENTS data)
endif()

list(REMOVE_DUPLICATES ICU_FIND_COMPONENTS)

include(AceImportLibrary)

if("data" IN_LIST ICU_FIND_COMPONENTS)
  set(ICU_DATA_FOUND OFF)

  ace_import_library(ICU::data CXX NAMES icudata
    COMPILE_DEFINITIONS_STATIC "U_STATIC_IMPLEMENTATION"
    COMPILE_DEFINITIONS "${ICU_DEFINITIONS}"
    FOUND ICU_DATA_FOUND)

  if(ICU_DATA_FOUND)
    list(APPEND ICU_LIBRARIES ICU::data)
    set(ICU_DATA_LIBRARIES ICU::data)
  endif()
endif()

if("uc" IN_LIST ICU_FIND_COMPONENTS)
  set(ICU_UC_FOUND OFF)

  ace_import_library(ICU::uc CXX NAMES icuuc LINK_LIBRARIES ICU::data
    COMPILE_DEFINITIONS_STATIC "U_STATIC_IMPLEMENTATION"
    COMPILE_DEFINITIONS "${ICU_DEFINITIONS}"
    FOUND ICU_UC_FOUND)

  if(ICU_UC_FOUND)
    list(APPEND ICU_LIBRARIES ICU::uc)
    set(ICU_UC_LIBRARIES ICU::uc)
  endif()
endif()

if("i18n" IN_LIST ICU_FIND_COMPONENTS)
  set(ICU_I18N_FOUND OFF)

  ace_import_library(ICU::i18n CXX NAMES icui18n LINK_LIBRARIES ICU::uc
    COMPILE_DEFINITIONS_STATIC "U_STATIC_IMPLEMENTATION"
    COMPILE_DEFINITIONS "${ICU_DEFINITIONS}"
    FOUND ICU_I18N_FOUND)

  if(ICU_I18N_FOUND)
    list(APPEND ICU_LIBRARIES ICU::i18n)
    set(ICU_I18N_LIBRARIES ICU::i18n)
  endif()
endif()

set(ICU_EXECUTABLES ICU-CONFIG GENCNVAL ICUINFO GENBRK GENRB GENDICT DERB
  PKGDATA UCONV GENCFU MAKECONV GENNORM2 GENCCODE GENSPREP ICUPKG GENCMN)

foreach(TOOL ${ICU_EXECUTABLES})
  set(ICU_${TOOL}_EXECUTABLE ICU_${TOOL}_EXECUTABLE-NOTFOUND CACHE INTERNAL "")  
endforeach()

set(ICU_MAKEFILE_INC ICU_PKGDATA_INC-NOTFOUND CACHE INTERNAL "")
set(ICU_PKGDATA_INC ICU_PKGDATA_INC-NOTFOUND CACHE INTERNAL "")

set(ICU_INCLUDE_DIR "${ICU_INCLUDE_DIRS}" CACHE STRING "")
set(ICU_LIBRARY "${ICU_LIBRARIES}" CACHE STRING "")
set(ICU_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)
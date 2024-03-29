cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

set(ICU_DATA "${CMAKE_CURRENT_LIST_DIR}/icudtl.dat" CACHE PATH "")
if(NOT EXISTS ${ICU_DATA})
  message(FATAL_ERROR "Missing ICU data file: ${ICU_DATA}")
endif()
message(VERBOSE "Found ICU data file: ${ICU_DATA}")

enable_language(CXX)

set(ICU_VERSION_STRING ${ICU_VERSION})

get_filename_component(ICU_INCLUDE_DIRS ${CMAKE_CURRENT_LIST_DIR} DIRECTORY)
get_filename_component(ICU_INCLUDE_DIRS ${ICU_INCLUDE_DIRS} DIRECTORY)
set(ICU_INCLUDE_DIRS ${ICU_INCLUDE_DIRS}/include)

set(ICU_DEFINITIONS "U_DISABLE_RENAMING=1")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  list(APPEND ICU_DEFINITIONS "U_STATIC_IMPLEMENTATION")
endif()

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

if("data" IN_LIST ICU_FIND_COMPONENTS)
  find_library(ICU_DATA_LIBRARY NAMES icudata
    PATHS ${CMAKE_CURRENT_LIST_DIR}/../../lib
    NO_DEFAULT_PATH NO_CACHE REQUIRED)

  if(NOT TARGET ICU::data)
    add_library(ICU::data UNKNOWN IMPORTED)
    set_target_properties(ICU::data PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${ICU_INCLUDE_DIRS}"
      INTERFACE_COMPILE_DEFINITIONS "${ICU_DEFINITIONS}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
      IMPORTED_LOCATION "${ICU_DATA_LIBRARY}")
  endif()

  list(APPEND ICU_LIBRARIES ICU::data)
  set(ICU_DATA_LIBRARIES ICU::data)
  set(ICU_DATA_FOUND ON)
endif()

if("uc" IN_LIST ICU_FIND_COMPONENTS)
  find_library(ICU_UC_LIBRARY NAMES icuuc
    PATHS ${CMAKE_CURRENT_LIST_DIR}/../../lib
    NO_DEFAULT_PATH NO_CACHE REQUIRED)

  if(NOT TARGET ICU::uc)
    add_library(ICU::uc UNKNOWN IMPORTED)
    set_target_properties(ICU::uc PROPERTIES
      IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
      IMPORTED_LOCATION "${ICU_UC_LIBRARY}"
      INTERFACE_LINK_LIBRARIES ICU::data)
  endif()

  list(APPEND ICU_LIBRARIES ICU::uc)
  set(ICU_UC_LIBRARIES ICU::uc)
  set(ICU_UC_FOUND ON)
endif()

if("i18n" IN_LIST ICU_FIND_COMPONENTS)
  find_library(ICU_I18N_LIBRARY NAMES icui18n
    PATHS ${CMAKE_CURRENT_LIST_DIR}/../../lib
    NO_DEFAULT_PATH NO_CACHE REQUIRED)

  if(NOT TARGET ICU::i18n)
    add_library(ICU::i18n UNKNOWN IMPORTED)
    set_target_properties(ICU::i18n PROPERTIES
      IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
      IMPORTED_LOCATION "${ICU_I18N_LIBRARY}"
      INTERFACE_LINK_LIBRARIES ICU::uc)
  endif()

  list(APPEND ICU_LIBRARIES ICU::i18n)
  set(ICU_I18N_LIBRARIES ICU::i18n)
  set(ICU_I18N_FOUND ON)
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

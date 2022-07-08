# Imports shared and/or static library and creates an interface target for them.
#
# ace_import_library(<TARGET> <LANGUAGES>
#   [NAMES name1 [name2 ...]]
#   [NAMES_SHARED name1 [name2 ...]]
#   [NAMES_STATIC name1 [name2 ...]]
#   [HEADERS file1 [file2 ...]]
#   [HEADERS_LOCATIONS [path1 ...]]
#   [COMPILE_DEFINITIONS [item1 ...]]
#   [COMPILE_DEFINITIONS_SHARED [item1 ...]]
#   [COMPILE_DEFINITIONS_STATIC [item1 ...]]
#   [LINK_LIBRARIES [item1 ...]]
#   [LINK_LIBRARIES_SHARED [item1 ...]]
#   [LINK_LIBRARIES_STATIC [item1 ...]]
#   [REQUIRED REQUIRED|<BOOL>])
#
# Parameters
#
#   TARGET                      - name of the created target with namespace
#   LANGUAGES                   - IMPORTED_LINK_INTERFACE_LANGUAGES property
#
# Options
#
#   NAMES                       - names for SHARED and STATIC libraries without prefix/suffix
#   NAMES_SHARED                - names for SHARED libraries without prefix/suffix
#   NAMES_STATIC                - names for STATIC libraries without prefix/suffix
#   HEADERS                     - header files with paths, as included in source code
#   HEADERS_LOCATIONS           - header files locations relative to ${ACE_TARGET_ROOT}/include
#   COMPILE_DEFINITIONS         - INTERFACE_COMPILE_DEFINITIONS property for SHARED and STATIC libraries
#   COMPILE_DEFINITIONS_SHARED  - INTERFACE_COMPILE_DEFINITIONS property for SHARED libraries
#   COMPILE_DEFINITIONS_STATIC  - INTERFACE_COMPILE_DEFINITIONS property for STATIC libraries
#   LINK_LIBRARIES              - INTERFACE_LINK_LIBRARIES property for SHARED and STATIC libraries
#   LINK_LIBRARIES_SHARED       - INTERFACE_LINK_LIBRARIES property for SHARED libraries
#   LINK_LIBRARIES_STATIC       - INTERFACE_LINK_LIBRARIES property for STATIC libraries
#   REQUIRED                    - determines of headers and libraries must be found
#
#
# Description
#
# If NAMES or NAMES_SHARED is specified, creates <TARGET>_shared SHARED IMPORTED library target.
# Sets the <TARGET>_shared IMPORTED_LOCATION property to libraries found using NAMES and NAMES_SHARED.
# Sets the <TARGET>_shared IMPORTED_IMPLIB property to import libraries found using NAMES and NAMES_SHARED on Windows.
# Sets the <TARGET>_shared INTERFACE_LINK_LIBRARIES property to LINK_LIBRARIES and LINK_LIBRARIES_SHARED.
# Sets the <TARGET>_shared INTERFACE_COMPILE_DEFINITIONS property to COMPILE_DEFINITIONS and COMPILE_DEFINITIONS_SHARED.
# Sets the <TARGET>_shared IMPORTED_LINK_INTERFACE_LANGUAGES property to LANGUAGES.
#
# If NAMES or NAMES_STATIC is specified, creates <TARGET>_static STATIC IMPORTED library target.
# Sets the <TARGET>_static IMPORTED_LOCATION property to libraries found using NAMES and NAMES_STATIC.
# Sets the <TARGET>_static INTERFACE_LINK_LIBRARIES property to LINK_LIBRARIES and LINK_LIBRARIES_STATIC.
# Sets the <TARGET>_static INTERFACE_COMPILE_DEFINITIONS property to COMPILE_DEFINITIONS and COMPILE_DEFINITIONS_STATIC.
# Sets the <TARGET>_static IMPORTED_LINK_INTERFACE_LANGUAGES property to LANGUAGES.
#
# Creates <TARGET> INTERFACE IMPORTED library target if shared and/or static targets were created.
#
# Sets the <TARGET> INTERFACE_INCLUDE_DIRECTORIES property to paths found using HEADERS and HEADERS_LOCATIONS.
# Sets the <TARGET> INTERFACE_LINK_LIBRARIES property to LINK_LIBRARIES.
#
# Adds <TARGET>_shared to the <TARGET> INTERFACE_LINK_LIBRARIES property if the shared target
# exists and BUILD_SHARED_LIBS evaluates to TRUE or the current CONFIG is not Release.
#
# Adds <TARGET>_static to the <TARGET> INTERFACE_LINK_LIBRARIES property if the shared target does not
# exist or the static target exists, BUILD_SHARED_LIBS evaluates to FALSE and the current CONFIG is Release.
#

function(ace_import_library TARGET LANGUAGES)
  # Parse arguments.
  set(options)
  list(APPEND options NAMES)
  list(APPEND options NAMES_SHARED)
  list(APPEND options NAMES_STATIC)
  list(APPEND options HEADERS)
  list(APPEND options HEADERS_LOCATIONS)
  list(APPEND options LINK_LIBRARIES)
  list(APPEND options LINK_LIBRARIES_SHARED)
  list(APPEND options LINK_LIBRARIES_STATIC)
  list(APPEND options COMPILE_DEFINITIONS)
  list(APPEND options COMPILE_DEFINITIONS_SHARED)
  list(APPEND options COMPILE_DEFINITIONS_STATIC)
  cmake_parse_arguments(PARSE_ARGV 2 IMPORT "" "FOUND;REQUIRED" "${options}")

  # Set REQUIRED flag.
  if(NOT "REQUIRED" IN_LIST IMPORT_KEYWORDS_MISSING_VALUES
     AND (IMPORT_REQUIRED OR NOT DEFINED IMPORT_REQUIRED))
    set(IMPORT_REQUIRED "REQUIRED")
  else()
    set(IMPORT_REQUIRED)
  endif()

  # Check if already found.
  if(TARGET ${TARGET})
    if(IMPORT_FOUND)
      set(${IMPORT_FOUND} 1 PARENT_SCOPE)
    endif()
    return()
  endif()

  # Process arguments.
  if(IMPORT_NAMES)
    list(REMOVE_DUPLICATES IMPORT_NAMES)
    list(INSERT IMPORT_NAMES_SHARED 0 ${IMPORT_NAMES})
    list(INSERT IMPORT_NAMES_STATIC 0 ${IMPORT_NAMES})
  endif()
  list(REMOVE_DUPLICATES IMPORT_NAMES_SHARED)
  list(REMOVE_DUPLICATES IMPORT_NAMES_STATIC)

  if(IMPORT_LINK_LIBRARIES)
    list(REMOVE_DUPLICATES IMPORT_LINK_LIBRARIES)
    list(INSERT IMPORT_LINK_LIBRARIES_SHARED 0 ${IMPORT_LINK_LIBRARIES})
    list(INSERT IMPORT_LINK_LIBRARIES_STATIC 0 ${IMPORT_LINK_LIBRARIES})
  endif()
  list(REMOVE_DUPLICATES IMPORT_LINK_LIBRARIES_SHARED)
  list(REMOVE_DUPLICATES IMPORT_LINK_LIBRARIES_STATIC)

  if(IMPORT_COMPILE_DEFINITIONS)
    list(REMOVE_DUPLICATES IMPORT_COMPILE_DEFINITIONS)
    list(INSERT IMPORT_COMPILE_DEFINITIONS_SHARED 0 ${IMPORT_COMPILE_DEFINITIONS})
    list(INSERT IMPORT_COMPILE_DEFINITIONS_STATIC 0 ${IMPORT_COMPILE_DEFINITIONS})
  endif()
  list(REMOVE_DUPLICATES IMPORT_COMPILE_DEFINITIONS_SHARED)
  list(REMOVE_DUPLICATES IMPORT_COMPILE_DEFINITIONS_STATIC)

  # Set include directories.
  set(IMPORT_INCLUDE_DIRECTORIES)
  if(IMPORT_HEADERS)
    get_filename_component(IMPORT_INCLUDE_DIRECTORY_DEFAULT ${ACE_TARGET_ROOT}/include ABSOLUTE)
    foreach(IMPORT_HEADER ${IMPORT_HEADERS})
      find_path(IMPORT_INCLUDE_DIRECTORY NAMES ${IMPORT_HEADER}
        PATHS ${IMPORT_INCLUDE_DIRECTORY_DEFAULT}
        PATH_SUFFIXES ${IMPORT_HEADERS_LOCATIONS}
        NO_DEFAULT_PATH NO_CACHE ${IMPORT_REQUIRED})
      if(IMPORT_INCLUDE_DIRECTORY)
        get_filename_component(IMPORT_INCLUDE_DIRECTORY ${IMPORT_INCLUDE_DIRECTORY} ABSOLUTE)
        if(NOT "${IMPORT_INCLUDE_DIRECTORY}" STREQUAL "${IMPORT_INCLUDE_DIRECTORY_DEFAULT}")
          list(APPEND IMPORT_INCLUDE_DIRECTORIES ${IMPORT_INCLUDE_DIRECTORY})
        endif()
      endif()
      unset(IMPORT_INCLUDE_DIRECTORY)
    endforeach()
    unset(IMPORT_INCLUDE_DIRECTORY_DEFAULT)
  endif()
  list(REMOVE_DUPLICATES IMPORT_INCLUDE_DIRECTORIES)

  # Set file search names.
  #
  # | VARIABLE NAME               | Linux   | Windows |
  # |-----------------------------|---------|---------|
  # | CMAKE_SHARED_LIBRARY_PREFIX | lib     |         |
  # | CMAKE_SHARED_LIBRARY_SUFFIX | .so     | .dll    |
  # | CMAKE_IMPORT_LIBRARY_PREFIX |         |         |
  # | CMAKE_IMPORT_LIBRARY_SUFFIX |         | .lib    |
  # | CMAKE_STATIC_LIBRARY_PREFIX | lib     |         |
  # | CMAKE_STATIC_LIBRARY_SUFFIX | .a      | .lib    |
  #

  set(IMPORT_IMPLIB_NAMES)
  foreach(NAME ${IMPORT_NAMES_SHARED})
    list(APPEND IMPORT_IMPLIB_NAMES
      ${CMAKE_IMPORT_LIBRARY_PREFIX}${NAME}${CMAKE_IMPORT_LIBRARY_SUFFIX})
  endforeach()

  set(IMPORT_SHARED_NAMES)
  foreach(NAME ${IMPORT_NAMES_SHARED})
    list(APPEND IMPORT_SHARED_NAMES
      ${CMAKE_SHARED_LIBRARY_PREFIX}${NAME}${CMAKE_SHARED_LIBRARY_SUFFIX})
  endforeach()

  set(IMPORT_STATIC_NAMES)
  foreach(NAME ${IMPORT_NAMES_STATIC})
    list(APPEND IMPORT_STATIC_NAMES
      ${CMAKE_STATIC_LIBRARY_PREFIX}${NAME}${CMAKE_STATIC_LIBRARY_SUFFIX})
  endforeach()

  # Import shared library.
  if(IMPORT_NAMES_SHARED AND NOT TARGET ${TARGET}_shared)
    if(WIN32)
      find_library(IMPORT_IMPLIB_LOCATION
        NAMES ${IMPORT_IMPLIB_NAMES}
        PATHS ${ACE_TARGET_ROOT}/lib/shared ${ACE_TARGET_ROOT}/lib
        NO_DEFAULT_PATH NO_CACHE ${IMPORT_REQUIRED})
      find_file(IMPORT_SHARED_LOCATION
        NAMES ${IMPORT_SHARED_NAMES}
        PATHS ${ACE_TARGET_ROOT}/bin
        NO_DEFAULT_PATH NO_CACHE ${IMPORT_REQUIRED})
    else()
      find_library(IMPORT_SHARED_LOCATION
        NAMES ${IMPORT_SHARED_NAMES}
        PATHS ${ACE_TARGET_ROOT}/lib/shared ${ACE_TARGET_ROOT}/lib
        NO_DEFAULT_PATH NO_CACHE ${IMPORT_REQUIRED})
    endif()
    if(IMPORT_IMPLIB_LOCATION OR IMPORT_SHARED_LOCATION)
      add_library(${TARGET}_shared SHARED IMPORTED)
      set_target_properties(${TARGET}_shared PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "${LANGUAGES}")
    endif()
    if(IMPORT_SHARED_LOCATION)
      message(VERBOSE "Found ${TARGET}: ${IMPORT_SHARED_LOCATION}")
      set_target_properties(${TARGET}_shared PROPERTIES
        IMPORTED_LOCATION "${IMPORT_SHARED_LOCATION}")
    endif()
    if(IMPORT_IMPLIB_LOCATION)
      message(VERBOSE "Found ${TARGET}: ${IMPORT_IMPLIB_LOCATION}")
      set_target_properties(${TARGET}_shared PROPERTIES
        IMPORTED_IMPLIB "${IMPORT_IMPLIB_LOCATION}")
    endif()
  elseif(IMPORT_NAMES_STATIC AND NOT TARGET ${TARGET}_shared)
    find_library(IMPORT_SHARED_LOCATION
      NAMES ${IMPORT_STATIC_NAMES}
      PATHS ${ACE_TARGET_ROOT}/lib/shared
      NO_DEFAULT_PATH NO_CACHE ${IMPORT_REQUIRED})
    if(IMPORT_SHARED_LOCATION)
      message(VERBOSE "Found ${TARGET}: ${IMPORT_SHARED_LOCATION}")
      add_library(${TARGET}_shared STATIC IMPORTED)
      set_target_properties(${TARGET}_shared PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "${LANGUAGES}"
        IMPORTED_LOCATION "${IMPORT_SHARED_LOCATION}")
    endif()
  endif()
  unset(IMPORT_IMPLIB_LOCATION)
  unset(IMPORT_SHARED_LOCATION)

  # Import static library.
  if(IMPORT_NAMES_STATIC AND NOT TARGET ${TARGET}_static)
    find_library(IMPORT_STATIC_LOCATION
      NAMES ${IMPORT_STATIC_NAMES}
      PATHS ${ACE_TARGET_ROOT}/lib/static ${ACE_TARGET_ROOT}/lib
      NO_DEFAULT_PATH NO_CACHE ${IMPORT_REQUIRED})
    if(IMPORT_STATIC_LOCATION)
      message(VERBOSE "Found ${TARGET}: ${IMPORT_STATIC_LOCATION}")
      add_library(${TARGET}_static STATIC IMPORTED)
      set_target_properties(${TARGET}_static PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "${LANGUAGES}"
        IMPORTED_LOCATION "${IMPORT_STATIC_LOCATION}")
    endif()
  endif()
  unset(IMPORT_STATIC_LOCATION)

  # Set include directories.
  if(IMPORT_INCLUDE_DIRECTORIES)
    if(TARGET ${TARGET}_shared)
      set_target_properties(${TARGET}_shared PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${IMPORT_INCLUDE_DIRECTORIES}")
    endif()
    if(TARGET ${TARGET}_static)
      set_target_properties(${TARGET}_static PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${IMPORT_INCLUDE_DIRECTORIES}")
    endif()
  endif()

  # Set compile definitions.
  if(IMPORT_COMPILE_DEFINITIONS_SHARED AND TARGET ${TARGET}_shared)
    set_target_properties(${TARGET}_shared PROPERTIES
      INTERFACE_COMPILE_DEFINITIONS "${IMPORT_COMPILE_DEFINITIONS_SHARED}")
  endif()
  if(IMPORT_COMPILE_DEFINITIONS_STATIC AND TARGET ${TARGET}_static)
    set_target_properties(${TARGET}_static PROPERTIES
      INTERFACE_COMPILE_DEFINITIONS "${IMPORT_COMPILE_DEFINITIONS_STATIC}")
  endif()

  # Set link libraries.
  if(IMPORT_LINK_LIBRARIES_SHARED AND TARGET ${TARGET}_shared)
    set_target_properties(${TARGET}_shared PROPERTIES
      INTERFACE_LINK_LIBRARIES "${IMPORT_LINK_LIBRARIES_SHARED}")
  endif()
  if(IMPORT_LINK_LIBRARIES_STATIC AND TARGET ${TARGET}_static)
    set_target_properties(${TARGET}_static PROPERTIES
      INTERFACE_LINK_LIBRARIES "${IMPORT_LINK_LIBRARIES_STATIC}")
  endif()

  if(IMPORT_FOUND)
    if(IMPORT_REQUIRED)
      set(${IMPORT_FOUND} 0 PARENT_SCOPE)
    else()
      unset(${IMPORT_FOUND} PARENT_SCOPE)
    endif()
  endif()

  if(TARGET ${TARGET}_shared AND TARGET ${TARGET}_static AND NOT BUILD_SHARED_LIBS)
    add_library(${TARGET} INTERFACE IMPORTED)
    set_target_properties(${TARGET} PROPERTIES
      INTERFACE_LINK_LIBRARIES "${TARGET}_\$<IF:\$<CONFIG:Release>,static,shared>")
    if(IMPORT_FOUND)
      set(${IMPORT_FOUND} 1 PARENT_SCOPE)
    endif()
  elseif(TARGET ${TARGET}_shared)
    add_library(${TARGET} INTERFACE IMPORTED)
    set_target_properties(${TARGET} PROPERTIES
      INTERFACE_LINK_LIBRARIES "${TARGET}_shared")
    if(IMPORT_FOUND)
      set(${IMPORT_FOUND} 1 PARENT_SCOPE)
    endif()
  elseif(TARGET ${TARGET}_static)
    add_library(${TARGET} INTERFACE IMPORTED)
    set_target_properties(${TARGET} PROPERTIES
      INTERFACE_LINK_LIBRARIES "${TARGET}_static")
    if(IMPORT_FOUND)
      set(${IMPORT_FOUND} 1 PARENT_SCOPE)
    endif()
  elseif(NOT IMPORT_NAMES_SHARED AND NOT IMPORT_NAMES_STATIC)
    message(VERBOSE "Found ${TARGET}: (interface)")
    add_library(${TARGET} INTERFACE IMPORTED)
    if(IMPORT_INCLUDE_DIRECTORIES)
      set_target_properties(${TARGET} PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${IMPORT_INCLUDE_DIRECTORIES}")
    endif()
    if(IMPORT_COMPILE_DEFINITIONS)
      set_target_properties(${TARGET} PROPERTIES
        INTERFACE_COMPILE_DEFINITIONS "${IMPORT_COMPILE_DEFINITIONS}")
    endif()
    if(IMPORT_LINK_LIBRARIES)
      set_target_properties(${TARGET} PROPERTIES
        INTERFACE_LINK_LIBRARIES "${IMPORT_LINK_LIBRARIES}")
    endif()
    if(IMPORT_FOUND)
      set(${IMPORT_FOUND} 1 PARENT_SCOPE)
    endif()
  endif()
endfunction()

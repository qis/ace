# Creates target if the shared and/or static libraries are found in the search locations.
#
#   llvm_import_library(
#     <NAMESPACE>                 # NAMESPACE part of the generated targets
#     <NAME>                      # NAME part or prefix of the generated targets
#     <C|CXX|"C;CXX">             # IMPORTED_LINK_INTERFACE_LANGUAGES list
#     <SHARED_LIBRARY_NAME|SKIP>  # shared library name without prefix or suffix (disabled by SKIP)
#     <STATIC_LIBRARY_NAME|SKIP>  # static library name without prefix or suffix (disabled by SKIP)
#     [REQUIRED|1|0]              # calls find_file and find_library with the REQUIRED parameter set
#   )
#
# Search Locations (Linux)
#
#   ${LLVM_ROOT}/sys/lib/lib${STATIC_LIBRARY_NAME}.so  - shared library
#   ${LLVM_ROOT}/sys/lib/lib${STATIC_LIBRARY_NAME}.a   - static library
#
# Search Locations (Windows)
#
#   ${LLVM_ROOT}/win/bin/${SHARED_LIBRARY_NAME}.dll         - shared library
#   ${LLVM_ROOT}/win/lib/shared/${SHARED_LIBRARY_NAME}.lib  - shared imports
#   ${LLVM_ROOT}/win/lib/static/${STATIC_LIBRARY_NAME}.lib  - static library
#
# Output Variables
#
#   <NAMESPACE>_<NAME>_LIBRARY_SHARED  - shared library location if found and not disabled
#   <NAMESPACE>_<NAME>_LIBRARY_IMPLIB  - shared imports location if found and not disabled
#   <NAMESPACE>_<NAME>_LIBRARY_STATIC  - static library location if found and not disabled
#   <NAMESPACE>_<NAME>_TARGETS         - list with available shared and static targets
#
# Output Targets
#
#   <NAMESPACE>::<NAME>_shared  - shared library import (if found and not disabled)
#   <NAMESPACE>::<NAME>_static  - staitc library import (if found and not disabled)
#   <NAMESPACE>::<NAME>         - interface target that links to the shared and/or static libraries
#
#   The interface target links to the shared library when
#   BUILD_SHARED_LIBS evaluates to TRUE or CONFIG is not Release.
#
#   The interface target links to the static library when
#   BUILD_SHARED_LIBS evaluates to FALSE and CONFIG is Release
#
# Notes
#
#   Skipped SHARED libraries on Windows will result in only Release builds working.
#   Skipped STATIC libraries on Windows might result in only non-Release builds working.
#

macro(llvm_import_library namespace name lang shared static)
  # Set REQUIRED for find_file and find_library.
  set(LLVM_FIND_LIBRARY_REQUIRED)
  if(ARGV5 STREQUAL "REQUIRED" OR "${ARGV5}")
    set(LLVM_FIND_LIBRARY_REQUIRED "REQUIRED")
  endif()

  # Create list with available shared and static targets.
  set(${namespace}_${name}_TARGETS)

  if(NOT TARGET ${namespace}::${name})
    # Create shared library import target.
    if(NOT TARGET ${namespace}::${name}_shared AND (NOT "${shared}" STREQUAL "SKIP"))
      if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
        # Create shared library import target for "${shared}.dll" and "${shared}.lib".
        find_file(${namespace}_${name}_LIBRARY_SHARED
          ${CMAKE_SHARED_LIBRARY_PREFIX}${shared}${CMAKE_SHARED_LIBRARY_SUFFIX}
          PATHS ${CMAKE_SYSROOT}/bin ${LLVM_FIND_LIBRARY_REQUIRED}
          NO_DEFAULT_PATH)
        find_library(${namespace}_${name}_LIBRARY_IMPLIB
          ${CMAKE_IMPORT_LIBRARY_PREFIX}${shared}${CMAKE_IMPORT_LIBRARY_SUFFIX}
          PATHS ${CMAKE_SYSROOT}/lib/shared ${LLVM_FIND_LIBRARY_REQUIRED}
          NO_DEFAULT_PATH)
        if(${namespace}_${name}_LIBRARY_SHARED AND ${namespace}_${name}_LIBRARY_IMPLIB)
          add_library(${namespace}::${name}_shared SHARED IMPORTED)
          set_target_properties(${namespace}::${name}_shared PROPERTIES
            IMPORTED_LOCATION "${${namespace}_${name}_LIBRARY_SHARED}"
            IMPORTED_IMPLIB "${${namespace}_${name}_LIBRARY_IMPLIB}"
            IMPORTED_LINK_INTERFACE_LANGUAGES "${lang}")
          list(APPEND ${namespace}_${name}_TARGETS ${namespace}::${name}_shared)
        endif()
      else()
        # Create shared library import target for "lib${shared}.so".
        find_library(${namespace}_${name}_LIBRARY_SHARED
          ${CMAKE_SHARED_LIBRARY_PREFIX}${shared}${CMAKE_SHARED_LIBRARY_SUFFIX}
          PATHS ${CMAKE_SYSROOT}/lib ${LLVM_FIND_LIBRARY_REQUIRED}
          NO_DEFAULT_PATH)
        if(${namespace}_${name}_LIBRARY_SHARED)
          add_library(${namespace}::${name}_shared SHARED IMPORTED)
          set_target_properties(${namespace}::${name}_shared PROPERTIES
            IMPORTED_LOCATION "${${namespace}_${name}_LIBRARY_SHARED}"
            IMPORTED_LINK_INTERFACE_LANGUAGES "${lang}")
          list(APPEND ${namespace}_${name}_TARGETS ${namespace}::${name}_shared)
        endif()
      endif()
    endif()

    # Create static library import target.
    if(NOT TARGET ${namespace}::${name}_static AND (NOT "${static}" STREQUAL "SKIP"))
      if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
        # Create static library import target for "${shared}.lib".
        find_library(${namespace}_${name}_LIBRARY_STATIC
          ${CMAKE_STATIC_LIBRARY_PREFIX}${static}${CMAKE_STATIC_LIBRARY_SUFFIX}
          PATHS ${CMAKE_SYSROOT}/lib/static ${LLVM_FIND_LIBRARY_REQUIRED}
          NO_DEFAULT_PATH)
      else()
        # Create static library import target for "lib${shared}.a".
        find_library(${namespace}_${name}_LIBRARY_STATIC
          ${CMAKE_STATIC_LIBRARY_PREFIX}${static}${CMAKE_STATIC_LIBRARY_SUFFIX}
          PATHS ${CMAKE_SYSROOT}/lib ${LLVM_FIND_LIBRARY_REQUIRED}
          NO_DEFAULT_PATH)
      endif()
      if(${namespace}_${name}_LIBRARY_STATIC)
        add_library(${namespace}::${name}_static STATIC IMPORTED)
        set_target_properties(${namespace}::${name}_static PROPERTIES
          IMPORTED_LOCATION "${${namespace}_${name}_LIBRARY_STATIC}"
          IMPORTED_LINK_INTERFACE_LANGUAGES "${lang}")
        list(APPEND ${namespace}_${name}_TARGETS ${namespace}::${name}_static)
      endif()
    endif()

    # Create interface target.
    if(${namespace}_${name}_LIBRARY_SHARED OR ${namespace}_${name}_LIBRARY_STATIC)
      add_library(${namespace}::${name} INTERFACE IMPORTED)
      if(TARGET ${namespace}::${name}_shared AND (BUILD_SHARED_LIBS OR NOT TARGET ${namespace}::${name}_static))
        # Select shared library if BUILD_SHARED_LIBS evaluates to TRUE or there is no static library.
        message(VERBOSE "Found SHARED ${namespace}::${name}: ${${namespace}_${name}_LIBRARY_SHARED}")
        set_target_properties(${namespace}::${name} PROPERTIES INTERFACE_LINK_LIBRARIES
          "${namespace}::${name}_shared")
      elseif(TARGET ${namespace}::${name}_shared AND TARGET ${namespace}::${name}_static)
        # Select library based on CONFIG if BUILD_SHARED_LIBS evaluates to FALSE and both libraries are available.
        message(VERBOSE "Found SHARED ${namespace}::${name}: ${${namespace}_${name}_LIBRARY_SHARED}")
        message(VERBOSE "Found STATIC ${namespace}::${name}: ${${namespace}_${name}_LIBRARY_STATIC}")
        set_target_properties(${namespace}::${name} PROPERTIES INTERFACE_LINK_LIBRARIES
          "${namespace}::${name}_\$<IF:\$<CONFIG:Release>,static,shared>")
      elseif(TARGET ${namespace}::${name}_static)
        # Select static library if there is no shared library.
        message(VERBOSE "Found STATIC ${namespace}::${name}: ${${namespace}_${name}_LIBRARY_STATIC}")
        set_target_properties(${namespace}::${name} PROPERTIES INTERFACE_LINK_LIBRARIES
          "${namespace}::${name}_static")
      elseif(LLVM_FIND_LIBRARY_REQUIRED STREQUAL "REQUIRED")
        message(WARNING "Could not find ${namespace}::${name} library.")
        message(VERBOSE "${namespace}_${name}_LIBRARY_SHARED: ${${namespace}_${name}_LIBRARY_SHARED}")
        message(VERBOSE "${namespace}_${name}_LIBRARY_STATIC: ${${namespace}_${name}_LIBRARY_STATIC}")
        message(VERBOSE "BUILD_SHARED_LIBS: ${BUILD_SHARED_LIBS}")
      endif()
    endif()
  endif()
  unset(LLVM_FIND_LIBRARY_REQUIRED)
endmacro()

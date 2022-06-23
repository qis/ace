# llvm_import_library(namespace name lang shared static [REQUIRED|1|0])
#
# Sets variables:
#
# namespace_name_LIBRARY_SHARED  - shared library location
# namespace_name_LIBRARY_STATIC  - static library location
#
# Creates targets (if required or found):
#
# namespace::name_shared  - imports shared library
# namespace::name_static  - imports staitc library
# namespace::name         - interface for shared and static library
#
# The interface links to the shared library when
# BUILD_SHARED_LIBS evaluates to TRUE and CONFIG is not Release.
#
# The interface links to the static library when
# BUILD_SHARED_LIBS evaluates to FALSE and CONFIG is Release
#

macro(llvm_import_library namespace name lang shared static)
  # Set REQUIRED for find_file and find_library.
  set(LLVM_FIND_LIBRARY_REQUIRED)
  if(ARGV5 STREQUAL "REQUIRED" OR "${ARGV5}")
    set(LLVM_FIND_LIBRARY_REQUIRED "REQUIRED")
  endif()

  if(NOT TARGET ${namespace}::${name})
    # Create shared library import target.
    if(NOT TARGET ${namespace}::${name}_shared)
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
        endif()
      endif()
    endif()

    # Create static library import target.
    if(NOT TARGET ${namespace}::${name}_static)
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
      endif()
    endif()

    # Create interface target.
    if(${namespace}_${name}_LIBRARY_SHARED AND ${namespace}_${name}_LIBRARY_STATIC)
      add_library(${namespace}::${name} INTERFACE IMPORTED)
      if(BUILD_SHARED_LIBS)
        set_target_properties(${namespace}::${name} PROPERTIES INTERFACE_LINK_LIBRARIES
          "${namespace}::${name}_shared")
      else()
        set_target_properties(${namespace}::${name} PROPERTIES INTERFACE_LINK_LIBRARIES
          "${namespace}::${name}_\$<IF:\$<CONFIG:Release>,static,shared>")
      endif()
    endif()
  endif()
  unset(LLVM_FIND_LIBRARY_REQUIRED)
endmacro()

# vcpkg_import_library(ZLIB ZLIB C FILES zlib.h
#   NAMES libz.so libz.a zlib.lib zlib1.dll
#   REQUIRED ${ZLIB_FIND_REQUIRED})

function(vcpkg_import_library NAMESPACE NAME LANGUAGES)
  cmake_parse_arguments(PARSE_ARGV 3 VCPKG_IMPORT_LIBRARY "" "REQUIRED" "NAMES;FILES")
  if(VCPKG_IMPORT_LIBRARY_REQUIRED)
    set(VCPKG_IMPORT_LIBRARY_REQUIRED "REQUIRED")
  else()
    set(VCPKG_IMPORT_LIBRARY_REQUIRED)
  endif()

  if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    if(VCPKG_IMPORT_LIBRARY_FILES)
      find_path(VCPKG_IMPORT_INCLUDE_SHARED
        NAMES ${VCPKG_IMPORT_LIBRARY_FILES}
        PATHS ${CMAKE_SYSROOT}/vcpkg/installed/sys-shared/include
        NO_DEFAULT_PATH ${VCPKG_IMPORT_LIBRARY_REQUIRED})
      find_path(VCPKG_IMPORT_INCLUDE_STATIC
        NAMES ${VCPKG_IMPORT_LIBRARY_FILES}
        PATHS ${CMAKE_SYSROOT}/vcpkg/installed/sys-static/include
        NO_DEFAULT_PATH ${VCPKG_IMPORT_LIBRARY_REQUIRED})
    else()
      set(VCPKG_IMPORT_INCLUDE_SHARED)
      set(VCPKG_IMPORT_INCLUDE_STATIC)
    endif()
    if(VCPKG_IMPORT_LIBRARY_NAMES)
      find_library(VCPKG_IMPORT_LIBRARY_SHARED
        NAMES ${VCPKG_IMPORT_LIBRARY_NAMES}
        PATHS ${CMAKE_SYSROOT}/vcpkg/installed/sys-shared/lib
        NO_DEFAULT_PATH ${VCPKG_IMPORT_LIBRARY_REQUIRED})
      find_library(VCPKG_IMPORT_LIBRARY_STATIC
        NAMES ${VCPKG_IMPORT_LIBRARY_NAMES}
        PATHS ${CMAKE_SYSROOT}/vcpkg/installed/sys-static/lib
        NO_DEFAULT_PATH ${VCPKG_IMPORT_LIBRARY_REQUIRED})
    else()
      set(VCPKG_IMPORT_LIBRARY_SHARED)
      set(VCPKG_IMPORT_LIBRARY_STATIC)
    endif()
    set(VCPKG_IMPORT_LIBRARY_IMPLIB)
  elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    if(VCPKG_IMPORT_LIBRARY_FILES)
      find_path(VCPKG_IMPORT_INCLUDE_SHARED
        NAMES ${VCPKG_IMPORT_LIBRARY_FILES}
        PATHS ${CMAKE_SYSROOT}/vcpkg/installed/win-shared/include
        NO_DEFAULT_PATH ${VCPKG_IMPORT_LIBRARY_REQUIRED})
      find_path(VCPKG_IMPORT_INCLUDE_STATIC
        NAMES ${VCPKG_IMPORT_LIBRARY_FILES}
        PATHS ${CMAKE_SYSROOT}/vcpkg/installed/win-static/include
        NO_DEFAULT_PATH ${VCPKG_IMPORT_LIBRARY_REQUIRED})
    else()
      set(VCPKG_IMPORT_INCLUDE_SHARED)
      set(VCPKG_IMPORT_INCLUDE_STATIC)
    endif()
    if(VCPKG_IMPORT_LIBRARY_NAMES)
      find_file(VCPKG_IMPORT_LIBRARY_SHARED
        NAMES ${VCPKG_IMPORT_LIBRARY_NAMES}
        PATHS ${CMAKE_SYSROOT}/vcpkg/installed/win-shared/bin
        NO_DEFAULT_PATH ${VCPKG_IMPORT_LIBRARY_REQUIRED})
      find_library(VCPKG_IMPORT_LIBRARY_IMPLIB
        NAMES ${VCPKG_IMPORT_LIBRARY_NAMES}
        PATHS ${CMAKE_SYSROOT}/vcpkg/installed/win-shared/lib
        NO_DEFAULT_PATH ${VCPKG_IMPORT_LIBRARY_REQUIRED})
      find_library(VCPKG_IMPORT_LIBRARY_STATIC
        NAMES ${VCPKG_IMPORT_LIBRARY_NAMES}
        PATHS ${CMAKE_SYSROOT}/vcpkg/installed/win-static/lib
        NO_DEFAULT_PATH ${VCPKG_IMPORT_LIBRARY_REQUIRED})
    else()
      set(VCPKG_IMPORT_LIBRARY_SHARED)
      set(VCPKG_IMPORT_LIBRARY_IMPLIB)
      set(VCPKG_IMPORT_LIBRARY_STATIC)
    endif()
  else()
    message(FATAL_ERROR "Unsupported system: ${CMAKE_SYSTEM_NAME}")
  endif()

  if(NOT TARGET ${NAMESPACE}::${NAME}_shared AND VCPKG_IMPORT_LIBRARY_SHARED)
    add_library(${NAMESPACE}::${NAME}_shared SHARED IMPORTED)
    set_target_properties(${NAMESPACE}::${NAME}_shared PROPERTIES
      IMPORTED_LOCATION "${VCPKG_IMPORT_LIBRARY_SHARED}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "${LANGUAGES}")
    if(VCPKG_IMPORT_LIBRARY_IMPLIB)
      set_target_properties(${NAMESPACE}::${NAME}_shared PROPERTIES
        IMPORTED_IMPLIB "${VCPKG_IMPORT_LIBRARY_IMPLIB}")
    endif()
    if(VCPKG_IMPORT_INCLUDE_SHARED)
      set_target_properties(${NAMESPACE}::${NAME}_shared PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${VCPKG_IMPORT_INCLUDE_SHARED}")
    endif()
  endif()

  if(NOT TARGET ${NAMESPACE}::${NAME}_static AND VCPKG_IMPORT_LIBRARY_STATIC)
    add_library(${NAMESPACE}::${NAME}_static STATIC IMPORTED)
    set_target_properties(${NAMESPACE}::${NAME}_static PROPERTIES
      IMPORTED_LOCATION "${VCPKG_IMPORT_LIBRARY_STATIC}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "${LANGUAGES}")
    if(VCPKG_IMPORT_INCLUDE_STATIC)
      set_target_properties(${NAMESPACE}::${NAME}_static PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${VCPKG_IMPORT_INCLUDE_STATIC}")
    endif()
  endif()

  if(NOT TARGET ${NAMESPACE}::${NAME})
    add_library(${NAMESPACE}::${NAME} INTERFACE IMPORTED)
    if(TARGET ${NAMESPACE}::${NAME}_shared AND (BUILD_SHARED_LIBS OR NOT TARGET ${NAMESPACE}::${NAME}_static))
      # Select shared library if BUILD_SHARED_LIBS evaluates to TRUE or there is no static library.
      message(VERBOSE "Found SHARED ${NAMESPACE}::${NAME}: ${VCPKG_IMPORT_LIBRARY_SHARED}")
      set_target_properties(${NAMESPACE}::${NAME} PROPERTIES INTERFACE_LINK_LIBRARIES
        "${NAMESPACE}::${NAME}_shared")
    elseif(TARGET ${NAMESPACE}::${NAME}_shared AND TARGET ${NAMESPACE}::${NAME}_static)
      # Select library based on CONFIG if BUILD_SHARED_LIBS evaluates to FALSE and both libraries are available.
      message(VERBOSE "Found SHARED ${NAMESPACE}::${NAME}: ${VCPKG_IMPORT_LIBRARY_SHARED}")
      message(VERBOSE "Found STATIC ${NAMESPACE}::${NAME}: ${VCPKG_IMPORT_LIBRARY_STATIC}")
      set_target_properties(${NAMESPACE}::${NAME} PROPERTIES INTERFACE_LINK_LIBRARIES
        "${NAMESPACE}::${NAME}_\$<IF:\$<CONFIG:Release>,static,shared>")
    elseif(TARGET ${NAMESPACE}::${NAME}_static)
      # Select static library if there is no shared library.
      message(VERBOSE "Found STATIC ${NAMESPACE}::${NAME}: ${VCPKG_IMPORT_LIBRARY_STATIC}")
      set_target_properties(${NAMESPACE}::${NAME} PROPERTIES INTERFACE_LINK_LIBRARIES
        "${NAMESPACE}::${NAME}_static")
    elseif(LLVM_FIND_LIBRARY_REQUIRED STREQUAL "REQUIRED")
      message(WARNING "Could not find ${NAMESPACE}::${NAME} library.")
      message(VERBOSE "VCPKG_IMPORT_LIBRARY_SHARED: ${VCPKG_IMPORT_LIBRARY_SHARED}")
      message(VERBOSE "VCPKG_IMPORT_LIBRARY_STATIC: ${VCPKG_IMPORT_LIBRARY_STATIC}")
      message(VERBOSE "BUILD_SHARED_LIBS: ${BUILD_SHARED_LIBS}")
    endif()
  endif()
endfunction()

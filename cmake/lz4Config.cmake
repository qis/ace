if(NOT TARGET lz4::lz4)
  get_filename_component(LLVM "${CMAKE_CURRENT_LIST_DIR}" PATH)

  add_library(lz4_shared SHARED IMPORTED)
  set_target_properties(lz4_shared PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "LZ4_SHARED"
    IMPORTED_LINK_INTERFACE_LANGUAGES CXX)

  add_library(lz4_static STATIC IMPORTED)
  set_target_properties(lz4_static PROPERTIES
    IMPORTED_LINK_INTERFACE_LANGUAGES CXX)

  if(WIN32)
    set_target_properties(lz4_shared PROPERTIES
      IMPORTED_LOCATION "${LLVM}/msvc/bin/lz4d.dll"
      IMPORTED_IMPLIB   "${LLVM}/msvc/lib/lz4d.lib")

    set_target_properties(lz4_static PROPERTIES
      IMPORTED_LOCATION "${LLVM}/msvc/lib/lz4.lib")
  else()
    set_target_properties(lz4_shared PROPERTIES
      IMPORTED_LOCATION "${LLVM}/lib/liblz4.so")

    set_target_properties(lz4_static PROPERTIES
      IMPORTED_LOCATION "${LLVM}/lib/liblz4.a")
  endif()

  add_library(lz4::lz4 INTERFACE IMPORTED)
  target_link_libraries(lz4::lz4 INTERFACE debug lz4_shared)
  target_link_libraries(lz4::lz4 INTERFACE optimized lz4_static)

  unset(LLVM)
endif()

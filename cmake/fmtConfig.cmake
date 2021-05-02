if(NOT TARGET fmt::fmt)
  get_filename_component(LLVM "${CMAKE_CURRENT_LIST_DIR}" PATH)

  add_library(fmt_shared SHARED IMPORTED)
  set_target_properties(fmt_shared PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "FMT_SHARED"
    IMPORTED_LINK_INTERFACE_LANGUAGES CXX)

  add_library(fmt_static STATIC IMPORTED)
  set_target_properties(fmt_static PROPERTIES
    IMPORTED_LINK_INTERFACE_LANGUAGES CXX)

  if(WIN32)
    set_target_properties(fmt_shared PROPERTIES
      IMPORTED_LOCATION "${LLVM}/msvc/bin/fmtd.dll"
      IMPORTED_IMPLIB   "${LLVM}/msvc/lib/fmtd.lib")

    set_target_properties(fmt_static PROPERTIES
      IMPORTED_LOCATION "${LLVM}/msvc/lib/fmt.lib")
  else()
    set_target_properties(fmt_shared PROPERTIES
      IMPORTED_LOCATION "${LLVM}/lib/libfmt.so")

    set_target_properties(fmt_static PROPERTIES
      IMPORTED_LOCATION "${LLVM}/lib/libfmt.a")
  endif()

  add_library(fmt::fmt INTERFACE IMPORTED)
  target_link_libraries(fmt::fmt INTERFACE debug fmt_shared)
  target_link_libraries(fmt::fmt INTERFACE optimized fmt_static)

  unset(LLVM)
endif()

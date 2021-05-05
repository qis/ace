if(NOT TARGET utf8proc::utf8proc)
  get_filename_component(LLVM "${CMAKE_CURRENT_LIST_DIR}" PATH)

  add_library(utf8proc_shared SHARED IMPORTED)
  set_target_properties(utf8proc_shared PROPERTIES
    IMPORTED_LINK_INTERFACE_LANGUAGES CXX)

  add_library(utf8proc_static STATIC IMPORTED)
  set_target_properties(utf8proc_static PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "UTF8PROC_STATIC"
    IMPORTED_LINK_INTERFACE_LANGUAGES CXX)

  if(WIN32)
    set_target_properties(utf8proc_shared PROPERTIES
      IMPORTED_LOCATION "${LLVM}/msvc/bin/utf8procd.dll"
      IMPORTED_IMPLIB   "${LLVM}/msvc/lib/utf8procd.lib")

    set_target_properties(utf8proc_static PROPERTIES
      IMPORTED_LOCATION "${LLVM}/msvc/lib/utf8proc.lib")
  else()
    set_target_properties(utf8proc_shared PROPERTIES
      IMPORTED_LOCATION "${LLVM}/lib/libutf8proc.so")

    set_target_properties(utf8proc_static PROPERTIES
      IMPORTED_LOCATION "${LLVM}/lib/libutf8proc.a")
  endif()

  add_library(utf8proc::utf8proc INTERFACE IMPORTED)
  target_link_libraries(utf8proc::utf8proc INTERFACE debug utf8proc_shared)
  target_link_libraries(utf8proc::utf8proc INTERFACE optimized utf8proc_static)

  unset(LLVM)
endif()

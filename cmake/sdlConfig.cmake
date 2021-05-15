if(NOT TARGET sdl::sdl)
  get_filename_component(LLVM "${CMAKE_CURRENT_LIST_DIR}" PATH)

  add_library(sdl_shared SHARED IMPORTED)
  set_target_properties(sdl_shared PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES C
  IMPORTED_LOCATION "${LLVM}/lib/libSDL2.so")

  add_library(sdl_static STATIC IMPORTED)
  set_target_properties(sdl_static PROPERTIES
    IMPORTED_LINK_INTERFACE_LANGUAGES C
    IMPORTED_LOCATION "${LLVM}/lib/libSDL2.a")

  add_library(sdl::sdl INTERFACE IMPORTED)
  target_link_libraries(sdl::sdl INTERFACE debug sdl_shared)
  target_link_libraries(sdl::sdl INTERFACE optimized sdl_static)

  unset(LLVM)
endif()

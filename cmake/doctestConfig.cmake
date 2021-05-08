if(NOT TARGET doctest::doctest)
  get_filename_component(LLVM "${CMAKE_CURRENT_LIST_DIR}" PATH)

  include(CTest)

  add_library(doctest::doctest STATIC IMPORTED)
  set_target_properties(doctest::doctest PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "DOCTEST_CONFIG_USE_STD_HEADERS;DOCTEST_CONFIG_COLORS_ANSI;DOCTEST_CONFIG_NO_EXCEPTIONS_BUT_WITH_ALL_ASSERTS"
    IMPORTED_LINK_INTERFACE_LANGUAGES CXX)

  if(WIN32)
    set_target_properties(doctest::doctest PROPERTIES
      IMPORTED_LOCATION "${LLVM}/msvc/lib/doctestd.lib"
      IMPORTED_LOCATION_RELEASE "${LLVM}/msvc/lib/doctest.lib")
    target_link_libraries(doctest::doctest INTERFACE oldnames)
  else()
    set_target_properties(doctest::doctest PROPERTIES
      IMPORTED_LOCATION "${LLVM}/lib/libdoctest.a")
  endif()

  include(CMakeFindDependencyMacro)

  find_dependency(fmt REQUIRED)
  target_link_libraries(doctest::doctest INTERFACE fmt::fmt)

  include(${CMAKE_CURRENT_LIST_DIR}/doctest.cmake)

  unset(LLVM)
endif()

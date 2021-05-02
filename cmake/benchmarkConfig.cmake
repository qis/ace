if(NOT TARGET benchmark::benchmark)
  get_filename_component(LLVM "${CMAKE_CURRENT_LIST_DIR}" PATH)

  add_library(benchmark::benchmark STATIC IMPORTED)
  set_target_properties(benchmark::benchmark PROPERTIES
    IMPORTED_LINK_INTERFACE_LANGUAGES CXX)

  if(WIN32)
    set_target_properties(benchmark::benchmark PROPERTIES
      IMPORTED_LOCATION "${LLVM}/msvc/lib/benchmarkd.lib"
      IMPORTED_LOCATION_RELEASE "${LLVM}/msvc/lib/benchmark.lib")
    target_link_libraries(benchmark::benchmark INTERFACE shlwapi)
  else()
    set_target_properties(benchmark::benchmark PROPERTIES
      IMPORTED_LOCATION "${LLVM}/lib/libbenchmark.a")
  endif()

  unset(LLVM)
endif()

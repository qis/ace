set(VCPKG_CMAKE_CONFIGURE_OPTIONS "-DCMAKE_CXX_STANDARD=20")

if(PORT STREQUAL "tbb")
  set(VCPKG_C_FLAGS "-mwaitpkg")
  set(VCPKG_CXX_FLAGS "-mwaitpkg")
endif()

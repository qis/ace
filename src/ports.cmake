set(VCPKG_CMAKE_CONFIGURE_OPTIONS "-DCMAKE_CXX_STANDARD=20")

if(PORT STREQUAL "tbb")
  set(VCPKG_C_FLAGS "-mwaitpkg")
  set(VCPKG_CXX_FLAGS "-mwaitpkg")
endif()

if(PORT STREQUAL "libxml2")
  set(VCPKG_LINKER_FLAGS "-lc++")
endif()

if(PORT STREQUAL "sqlite3")
  if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(VCPKG_LINKER_FLAGS "-lm")
  endif()
endif()

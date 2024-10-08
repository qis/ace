cmake_minimum_required(VERSION 3.30 FATAL_ERROR)
project(ace DESCRIPTION "Ace" VERSION 0.1.0 LANGUAGES CXX)

# Version
set(PROJECT_VENDOR "Vendor")
configure_file(res/version.h.in ${CMAKE_CURRENT_BINARY_DIR}/src/version.h LF)

# Objects
file(GLOB_RECURSE sources CONFIGURE_DEPENDS src/${PROJECT_NAME}/*.cpp)
file(GLOB_RECURSE headers CONFIGURE_DEPENDS src/${PROJECT_NAME}/*.hpp)

add_library(objects OBJECT ${sources} ${headers})
target_compile_features(objects PUBLIC cxx_std_23)
target_include_directories(objects PUBLIC src ${CMAKE_CURRENT_BINARY_DIR}/src)

if(WIN32)
  target_compile_definitions(objects PUBLIC NOMINMAX WIN32_LEAN_AND_MEAN)
endif()

# Dependencies
find_package(Threads REQUIRED)
target_link_libraries(objects PUBLIC Threads::Threads)

# Application
add_executable(main src/main.cpp src/main.rc)
set_target_properties(main PROPERTIES OUTPUT_NAME ${PROJECT_NAME})
target_link_libraries(main PRIVATE objects)

# Benchmarks
find_package(benchmark CONFIG REQUIRED)
add_executable(benchmarks EXCLUDE_FROM_ALL src/benchmark.cpp src/main.rc)
target_link_libraries(benchmarks PRIVATE objects benchmark::benchmark)

# Tests
include(CTest)
if(BUILD_TESTING)
  find_package(doctest CONFIG REQUIRED)
  add_executable(tests src/test.cpp src/main.rc)
  target_link_libraries(tests PRIVATE objects doctest::doctest)

  include(doctest)
  doctest_discover_tests(tests)
endif()

# Install
if(NOT BUILD_SHARED_LIBS)
  install(TARGETS main RUNTIME DESTINATION bin)

  # Package
  string(UUID PROJECT_GUID TYPE SHA1
    NAMESPACE 6BA7B814-9DAD-11D1-80B4-00C04FD430C8
    NAME "CN=${PROJECT_DESCRIPTION}, O=${PROJECT_VENDOR}")

  set(CPACK_PACKAGE_VENDOR "${PROJECT_VENDOR}")
  set(CPACK_PACKAGE_DESCRIPTION "${PROJECT_DESCRIPTION}")
  set(CPACK_PACKAGE_EXECUTABLES "${PROJECT_NAME}" "${PROJECT_DESCRIPTION}")
  set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${PROJECT_VERSION}")
  set(CPACK_OUTPUT_FILE_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}")
  if(WIN32)
    set(CPACK_GENERATOR "WIX")
    set(CPACK_WIX_UPGRADE_GUID "${PROJECT_GUID}")
    set(CPACK_PACKAGE_NAME "${PROJECT_DESCRIPTION}")
    set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_DESCRIPTION}")
    set(CPACK_WIX_PRODUCT_ICON "${CMAKE_CURRENT_SOURCE_DIR}/src/main.ico")
    set(CPACK_WIX_LICENSE_RTF "${CMAKE_CURRENT_SOURCE_DIR}/res/license.rtf")
    set(CPACK_WIX_UI_BANNER "${CMAKE_CURRENT_SOURCE_DIR}/res/bitmap/banner.bmp")
    set(CPACK_WIX_UI_DIALOG "${CMAKE_CURRENT_SOURCE_DIR}/res/bitmap/dialog.bmp")
    set(CPACK_WIX_PROGRAM_MENU_FOLDER ".")
  else()
    set(CPACK_GENERATOR "DEB")
    set(CPACK_PACKAGING_INSTALL_PREFIX "/opt/${PROJECT_NAME}")
    set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/res/license.txt")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "${CPACK_PACKAGE_VENDOR}")
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6 (>= 2.31), libc6 (< 2.4)")
    set(CPACK_DEBIAN_PACKAGE_SECTION "misc")
  endif()
  include(CPack)
endif()

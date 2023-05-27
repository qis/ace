cmake_policy(PUSH)
cmake_policy(VERSION 3.26)

set(STD_MODULES_PATH "${ACE}/lib/modules/${VCPKG_TARGET_TRIPLET}")

if(NOT TARGET std::std)
  add_library(std::std STATIC IMPORTED)
  set_target_properties(std::std PROPERTIES
    IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
    IMPORTED_CONFIGURATIONS "Debug;Release;MinSizeRel;RelWithDebInfo;Coverage"
    IMPORTED_LOCATION_DEBUG "${STD_MODULES_PATH}/Debug/libstd.a"
    IMPORTED_LOCATION_RELEASE "${STD_MODULES_PATH}/Release/libstd.a"
    IMPORTED_LOCATION_MINSIZEREL "${STD_MODULES_PATH}/MinSizeRel/libstd.a"
    IMPORTED_LOCATION_RELWITHDEBINFO "${STD_MODULES_PATH}/RelWithDebInfo/libstd.a"
    IMPORTED_LOCATION_COVERAGE "${STD_MODULES_PATH}/Coverage/libstd.a"
    INTERFACE_COMPILE_OPTIONS "-fprebuilt-module-path=${STD_MODULES_PATH}/$<CONFIG>")
endif()

set(std_FOUND TRUE)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(std DEFAULT_MSG std_FOUND)

cmake_policy(POP)

cmake_policy(PUSH)
cmake_policy(VERSION 3.26)

set(ACE_MODULES_PATH "${ACE}/lib/modules/${VCPKG_TARGET_TRIPLET}")
set(ACE_COMPILE_OPTIONS "-fprebuilt-module-path=${ACE_MODULES_PATH}/$<CONFIG>;-nostdinc++")
set(ACE_COMPILE_OPTIONS "${ACE_COMPILE_OPTIONS};-isystem;${ACE}/src/modules/include")

if(NOT TARGET ACE::STD)
  add_library(ACE::STD STATIC IMPORTED)
  set_target_properties(ACE::STD PROPERTIES
    IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
    IMPORTED_CONFIGURATIONS "Debug;Release;MinSizeRel;RelWithDebInfo;Coverage"
    IMPORTED_LOCATION_DEBUG "${ACE_MODULES_PATH}/Debug/libstd.a"
    IMPORTED_LOCATION_RELEASE "${ACE_MODULES_PATH}/Release/libstd.a"
    IMPORTED_LOCATION_MINSIZEREL "${ACE_MODULES_PATH}/MinSizeRel/libstd.a"
    IMPORTED_LOCATION_RELWITHDEBINFO "${ACE_MODULES_PATH}/RelWithDebInfo/libstd.a"
    IMPORTED_LOCATION_COVERAGE "${ACE_MODULES_PATH}/Coverage/libstd.a"
    INTERFACE_COMPILE_OPTIONS "${ACE_COMPILE_OPTIONS}"
    INTERFACE_COMPILE_FEATURES "cxx_std_23")
endif()

set(ACE_FOUND TRUE)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(ACE DEFAULT_MSG ACE_FOUND)

cmake_policy(POP)

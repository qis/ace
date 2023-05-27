set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)

vcpkg_from_github(
  REPO oneapi-src/oneTBB
  REF v${VERSION}
  SHA512 2ece7f678ad7c8968c0ad5cda9f987e4b318c6d9735169e1039beb0ff8dfca18815835875211acc6c7068913d9b0bdd4c9ded22962b0bb48f4a0ce0f7b78f31c
  OUT_SOURCE_PATH SOURCE_PATH
  HEAD_REF onetbb_2021
  PATCHES
    0001-tchar-fixes.patch)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DTBB_TEST=OFF
    -DTBB_STRICT=OFF)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/TBB")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

set(arch_suffix "")
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
  set(arch_suffix "32")
endif()

file(REMOVE_RECURSE
  "${CURRENT_PACKAGES_DIR}/share/doc"
  "${CURRENT_PACKAGES_DIR}/debug/include"
  "${CURRENT_PACKAGES_DIR}/debug/share"
  "${CURRENT_PACKAGES_DIR}/lib/tbb.lib"
  "${CURRENT_PACKAGES_DIR}/debug/lib/tbb_debug.lib")

file(READ "${CURRENT_PACKAGES_DIR}/share/tbb/TBBConfig.cmake" _contents)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/tbb/TBBConfig.cmake" "
include(CMakeFindDependencyMacro)
find_dependency(Threads)
${_contents}")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

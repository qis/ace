vcpkg_from_github(
  REPO facebook/zstd
  REF "v${VERSION}"
  SHA512 356994e0d8188ce97590bf86b602eb50cbcb2f951594afb9c2d6e03cc68f966862505afc4a50e76efd55e4cfb11dbc9b15c7837b7827a961a1311ef72cd23505
  OUT_SOURCE_PATH SOURCE_PATH
  HEAD_REF dev
  PATCHES
    0001-no-static-suffix.patch)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ZSTD_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ZSTD_BUILD_SHARED)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}/build/cmake"
  OPTIONS
    -DZSTD_BUILD_SHARED=${ZSTD_BUILD_SHARED}
    -DZSTD_BUILD_STATIC=${ZSTD_BUILD_STATIC}
    -DZSTD_LEGACY_SUPPORT=1
    -DZSTD_BUILD_PROGRAMS=0
    -DZSTD_BUILD_TESTS=0
    -DZSTD_BUILD_CONTRIB=0
    -DZSTD_MULTITHREAD_SUPPORT=1)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/zstd)
vcpkg_fixup_pkgconfig()

file(READ "${CURRENT_PACKAGES_DIR}/share/zstd/zstdTargets.cmake" targets)
if(targets MATCHES "-pthread")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libzstd.pc" " -lzstd" " -lzstd -pthread")
  if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libzstd.pc" " -lzstd" " -lzstd -pthread")
  endif()
endif()

file(REMOVE_RECURSE
  "${CURRENT_PACKAGES_DIR}/debug/include"
  "${CURRENT_PACKAGES_DIR}/debug/share"
  "${CURRENT_PACKAGES_DIR}/share/zstdConfig.cmake"
  "${CURRENT_PACKAGES_DIR}/share/zstdConfigVersion.cmake"
  "${CURRENT_PACKAGES_DIR}/share/zstdTargets.cmake"
  "${CURRENT_PACKAGES_DIR}/share/zstdTargets-debug.cmake"
  "${CURRENT_PACKAGES_DIR}/share/zstdTargets-release.cmake")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/zstdConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/zstdConfig-version.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  foreach(HEADER IN ITEMS zdict.h zstd.h zstd_errors.h)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/${HEADER}" "defined(ZSTD_DLL_IMPORT) && (ZSTD_DLL_IMPORT==1)" "1" )
  endforeach()
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(
  COMMENT "ZSTD is dual licensed under BSD and GPLv2."
  FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/COPYING")

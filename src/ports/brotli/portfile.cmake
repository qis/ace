vcpkg_from_github(
  REPO google/brotli
  REF e61745a6b7add50d380cfd7d3883dd6c62fc2c71
  SHA512 303444695600b70ce59708e06bf21647d9b8dd33d772c53bbe49320f2f8f95ca8a7d6df2d29b7f36ff99001967e2d28380e0e305d778031940a3a5c6585f9a4f
  OUT_SOURCE_PATH SOURCE_PATH
  HEAD_REF master
  PATCHES
    0001-install.patch
    0002-pkgconfig.patch)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBROTLI_DISABLE_TESTS=ON
    -DBROTLI_EMSCRIPTEN=OFF)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
  "${CURRENT_PACKAGES_DIR}/debug/tools"
  "${CURRENT_PACKAGES_DIR}/tools")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/brotli-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/brotli")
vcpkg_cmake_config_fixup(CONFIG_PATH share/brotli PACKAGE_NAME brotli)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

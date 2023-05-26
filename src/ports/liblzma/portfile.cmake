vcpkg_from_sourceforge(
  REPO lzmautils
  FILENAME "xz-${VERSION}.tar.xz"
  SHA512 f890ee5207799fbc7bb9ae031f444d39d82275b0e1b8cc7f01fdb9270050e38849bd1269db2a2f12fe87b5e23e03f9e809a5c3456d066c0a56e6f98d728553ea
  OUT_SOURCE_PATH SOURCE_PATH
  PATCHES
    0001-config-include.patch
    0002-windows-output-name.patch
    0003-build-tools.patch)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_TESTING=OFF
    -DCREATE_XZ_SYMLINKS=OFF
    -DCREATE_LZMA_SYMLINKS=OFF
  MAYBE_UNUSED_VARIABLES
    CREATE_XZ_SYMLINKS
    CREATE_LZMA_SYMLINKS
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")
set(PACKAGE_URL https://tukaani.org/xz/)
set(PACKAGE_VERSION 5.2.5)
if(NOT VCPKG_TARGET_IS_WINDOWS)
  set(PTHREAD_CFLAGS -pthread)
endif()

set(prefix "${CURRENT_INSTALLED_DIR}")
configure_file("${SOURCE_PATH}/src/liblzma/liblzma.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/liblzma.pc" @ONLY)

if (NOT VCPKG_BUILD_TYPE)
  set(prefix "${CURRENT_INSTALLED_DIR}/debug")
  configure_file("${SOURCE_PATH}/src/liblzma/liblzma.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/liblzma.pc" @ONLY)
endif()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/liblzma)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/lzma.h" "defined(LZMA_API_STATIC)" "1")
else()
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/lzma.h" "defined(LZMA_API_STATIC)" "0")
endif()

file(REMOVE_RECURSE
  "${CURRENT_PACKAGES_DIR}/debug/include"
  "${CURRENT_PACKAGES_DIR}/debug/share"
  "${CURRENT_PACKAGES_DIR}/share/man"
  "${CURRENT_PACKAGES_DIR}/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

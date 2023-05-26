vcpkg_from_github(
  REPO madler/zlib
  REF v${VERSION}
  SHA512 44b834fbfb50cca229209b8dbe1f96b258f19a49f5df23b80970b716371d856a4adf525edb4c6e0e645b180ea949cb90f5365a1d896160f297f56794dd888659
  OUT_SOURCE_PATH SOURCE_PATH
  HEAD_REF master
  PATCHES
    0001-prevent-invalid-inclusions.patch
    0002-skip-building-examples.patch
    0003-build-static-or-shared.patch
    0004-android-and-mingw-fixes.patch
    0005-mingw-fixes.patch)

file(REMOVE "${SOURCE_PATH}/zconf.h")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DSKIP_INSTALL_FILES=ON
  OPTIONS_DEBUG
    -DSKIP_INSTALL_HEADERS=ON)

vcpkg_cmake_install()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
  if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/zlib.pc" "-lz" "-lzlib")
  endif()
  file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/zlib.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/zlib.pc" "-lz" "-lzlibd")
  endif()
  file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/zlib.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/zconf.h" "ifdef ZLIB_DLL" "if 0")
else()
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/zconf.h" "ifdef ZLIB_DLL" "if 1")
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

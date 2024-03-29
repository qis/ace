if(EXISTS "${CURRENT_INSTALLED_DIR}/share/libressl/copyright" OR EXISTS "${CURRENT_INSTALLED_DIR}/share/boringssl/copyright")
  message(FATAL_ERROR "Can't build openssl if libressl/boringssl is installed. Please remove libressl/boringssl, and try install openssl again if you need it.")
endif()

if (NOT "${VERSION}" MATCHES [[^([0-9]+)\.([0-9]+)\.([0-9]+)$]])
  message(FATAL_ERROR "Version regex did not match.")
endif()
set(OPENSSL_VERSION_MAJOR "${CMAKE_MATCH_1}")
set(OPENSSL_VERSION_MINOR "${CMAKE_MATCH_2}")
set(OPENSSL_VERSION_FIX "${CMAKE_MATCH_3}")

vcpkg_from_github(
  REPO openssl/openssl
  REF "openssl-${VERSION}"
  SHA512 877b4bc4b59126bdaf626b01322c8ac5325945234acd14907e4a23019f1fd38ec17b5fae9ff60aa9b6b0089c29b0e4255a19cd2a1743c3db82a616286c60d3b9
  OUT_SOURCE_PATH SOURCE_PATH
  PATCHES
    disable-apps.patch
    disable-install-docs.patch
    script-prefix.patch
    unix/android-cc.patch
    unix/move-openssldir.patch
    unix/no-empty-dirs.patch
    unix/no-static-libs-for-shared.patch)

vcpkg_list(SET CONFIGURE_OPTIONS
  enable-static-engine
  enable-capieng
  no-ssl3
  no-weak-ssl-ciphers
  no-tests)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  vcpkg_list(APPEND CONFIGURE_OPTIONS shared)
else()
  vcpkg_list(APPEND CONFIGURE_OPTIONS no-shared no-module)
endif()

vcpkg_list(APPEND CONFIGURE_OPTIONS no-apps)

if(DEFINED OPENSSL_USE_NOPINSHARED)
  vcpkg_list(APPEND CONFIGURE_OPTIONS no-pinshared)
endif()

if(OPENSSL_NO_AUTOLOAD_CONFIG)
  vcpkg_list(APPEND CONFIGURE_OPTIONS no-autoload-config)
endif()

include("${CMAKE_CURRENT_LIST_DIR}/unix/portfile.cmake")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

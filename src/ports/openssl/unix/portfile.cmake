find_program(MAKE make)
if(NOT MAKE)
  message(FATAL_ERROR "Could not find make. Please install it through your package manager.")
endif()

vcpkg_find_acquire_program(PERL)
set(INTERPRETER "${PERL}")

execute_process(
  COMMAND "${PERL}" -e "use IPC::Cmd;"
  RESULT_VARIABLE perl_ipc_cmd_result)
if(NOT perl_ipc_cmd_result STREQUAL "0")
  message(FATAL_ERROR "\nPerl cannot find IPC::Cmd. Please install it through your system package manager.\n")
endif()

# Ideally, OpenSSL should use `CC` from vcpkg as is (absolute path).
# But in reality, OpenSSL expects to locate the compiler via `PATH`,
# and it makes its own choices e.g. for Android.
vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

cmake_path(GET VCPKG_DETECTED_CMAKE_C_COMPILER PARENT_PATH compiler_path)
cmake_path(GET VCPKG_DETECTED_CMAKE_C_COMPILER FILENAME compiler_name)

find_program(compiler_in_path NAMES "${compiler_name}" PATHS ENV PATH NO_DEFAULT_PATH)
if(NOT compiler_in_path)
  vcpkg_host_path_list(APPEND ENV{PATH} "${compiler_path}")
elseif(NOT compiler_in_path STREQUAL VCPKG_DETECTED_CMAKE_C_COMPILER)
  vcpkg_host_path_list(PREPEND ENV{PATH} "${compiler_path}")
endif()

vcpkg_list(SET MAKEFILE_OPTIONS)
if(VCPKG_TARGET_IS_ANDROID)
  set(ENV{ANDROID_NDK_ROOT} "${VCPKG_DETECTED_CMAKE_ANDROID_NDK}")
  set(OPENSSL_ARCH "android-${VCPKG_DETECTED_CMAKE_ANDROID_ARCH}")
  if(VCPKG_DETECTED_CMAKE_ANDROID_ARCH STREQUAL "arm" AND NOT VCPKG_DETECTED_CMAKE_ANDROID_ARM_NEON)
    vcpkg_list(APPEND CONFIGURE_OPTIONS no-asm)
  endif()
elseif(VCPKG_TARGET_IS_LINUX)
  if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
    set(OPENSSL_ARCH linux-aarch64)
  elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
    set(OPENSSL_ARCH linux-armv4)
  elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
    set(OPENSSL_ARCH linux-x86_64)
  elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    set(OPENSSL_ARCH linux-x86)
  else()
    set(OPENSSL_ARCH linux-generic32)
  endif()
elseif(VCPKG_TARGET_IS_IOS)
  if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
    set(OPENSSL_ARCH ios64-xcrun)
  elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
    set(OPENSSL_ARCH ios-xcrun)
  elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x86" OR VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
    set(OPENSSL_ARCH iossimulator-xcrun)
  else()
    message(FATAL_ERROR "Unknown iOS target architecture: ${VCPKG_TARGET_ARCHITECTURE}")
  endif()
  list(APPEND CONFIGURE_OPTIONS no-ui no-asm)
elseif(VCPKG_TARGET_IS_OSX)
  if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
    set(OPENSSL_ARCH darwin64-arm64)
  else()
    set(OPENSSL_ARCH darwin64-x86_64)
  endif()
elseif(VCPKG_TARGET_IS_FREEBSD OR VCPKG_TARGET_IS_OPENBSD)
  set(OPENSSL_ARCH BSD-generic64)
elseif(VCPKG_TARGET_IS_MINGW)
  if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(OPENSSL_ARCH mingw64)
  else()
    set(OPENSSL_ARCH mingw)
  endif()
elseif(VCPKG_TARGET_IS_EMSCRIPTEN)
  vcpkg_list(APPEND CONFIGURE_OPTIONS
    threads
    no-engine
    no-asm
    no-sse2
    no-srtp
    --cross-compile-prefix=)
else()
  message(FATAL_ERROR "Unknown platform")
endif()

file(MAKE_DIRECTORY "${SOURCE_PATH}/vcpkg")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/configure" DESTINATION "${SOURCE_PATH}/vcpkg"
  FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

vcpkg_configure_make(
  SOURCE_PATH "${SOURCE_PATH}"
  PROJECT_SUBPATH "vcpkg"
  NO_ADDITIONAL_PATHS
  OPTIONS
  "${INTERPRETER}"
  "${SOURCE_PATH}/Configure"
  ${OPENSSL_ARCH}
  ${CONFIGURE_OPTIONS}
  "--openssldir=/etc/ssl"
  "--libdir=lib"
  OPTIONS_DEBUG
  --debug)

vcpkg_install_make(
  ${MAKEFILE_OPTIONS}
  BUILD_TARGET build_sw)

vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_LINUX OR VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/etc/ssl/misc")

file(TOUCH "${CURRENT_PACKAGES_DIR}/etc/ssl/certs/.keep")
file(TOUCH "${CURRENT_PACKAGES_DIR}/etc/ssl/private/.keep")

file(REMOVE_RECURSE
  "${CURRENT_PACKAGES_DIR}/debug/etc"
  "${CURRENT_PACKAGES_DIR}/debug/include"
  "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB engines "${CURRENT_PACKAGES_DIR}/lib/ossl-modules/*.dll")
if(NOT engines STREQUAL "")
  file(COPY ${engines} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/ossl-modules")
endif()

file(GLOB engines "${CURRENT_PACKAGES_DIR}/debug/lib/ossl-modules/*.dll")
if(NOT engines STREQUAL "")
  file(COPY ${engines} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/ossl-modules")
endif()

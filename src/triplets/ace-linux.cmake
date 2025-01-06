set(VCPKG_CMAKE_SYSTEM_NAME Linux)
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_BUILD_TYPE release)

set(VCPKG_ENV_PASSTHROUGH_UNTRACKED "PATH")
set(VCPKG_FIXUP_ELF_RPATH ON)

set(X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES ON)

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/../toolchain.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/../ports.cmake")

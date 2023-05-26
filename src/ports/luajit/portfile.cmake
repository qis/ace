vcpkg_from_github(
  REPO LuaJIT/LuaJIT
  REF 8271c643c21d1b2f344e339f559f2de6f3663191  # v2.1.0-beta3
  SHA512 a136f15a87f92c5cab40d49dcc2441f04c14575fa31aba5bd413313ee904d3abc4ebb8f413124781d101f793058c15a07f0a47d50d4fc5a74e7b150a1d1459cf
  OUT_SOURCE_PATH SOURCE_PATH
  HEAD_REF master)

if(NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
  message(FATAL_ERROR "Unsupported host system: ${CMAKE_HOST_SYSTEM_NAME}")
endif()

set(LUAJIT_CC "${VCPKG_ROOT_DIR}/../bin/clang")
set(LUAJIT_AR "${VCPKG_ROOT_DIR}/../bin/llvm-ar")
set(LUAJIT_STRIP "${VCPKG_ROOT_DIR}/../bin/llvm-strip")

set(LUAJIT_CFLAGS "-march=x86-64-v3 -fasm -mavx2 -fmerge-all-constants -fdiagnostics-absolute-paths -DNDEBUG -flto=thin")
set(LUAJIT_LDFLAGS "-s")
set(LUAJIT_LIBS "-lc++")

set(LUAJIT_HOST_SYS "Linux")
set(LUAJIT_HOST_CFLAGS "-fPIC")
set(LUAJIT_HOST_LDFALGS "-fPIE")
set(LUAJIT_HOST_LIBS "")

if(VCPKG_TARGET_IS_LINUX)
  set(LUAJIT_TARGET_SYS "${LUAJIT_HOST_SYS}")
  set(LUAJIT_TARGET_CFLAGS "${LUAJIT_HOST_CFLAGS}")
  set(LUAJIT_TARGET_LDFLAGS "${LUAJIT_HOST_LDFALGS}")
  set(LUAJIT_TARGET_SHFLAGS "")
  set(LUAJIT_TARGET_LIBS "${LUAJIT_HOST_LIBS}")
  set(LUAJIT_DLLNAME "libluajit.so")
  set(LUAJIT_LIBNAME "libluajit.a")
  set(LUAJIT_EXENAME "luajit")
  set(LUAJIT_DLLPATH "lib")
elseif(VCPKG_TARGET_IS_MINGW)
  set(LUAJIT_TARGET_SYS "Windows")
  set(LUAJIT_TARGET_CFLAGS "--target=x86_64-w64-mingw32 --sysroot=${VCPKG_ROOT_DIR}/../sys/mingw")
  set(LUAJIT_TARGET_CFLAGS "${LUAJIT_TARGET_CFLAGS} -fms-compatibility-version=19.36 -DWINVER=0x0A00 -D_WIN32_WINNT=0x0A00")
  set(LUAJIT_TARGET_LDFLAGS "-Xlinker /MANIFEST:NO -Xlinker /OPT:REF -Xlinker /OPT:ICF -Xlinker /INCREMENTAL:NO")
  set(LUAJIT_TARGET_SHFLAGS "-Wl,--out-implib,luajit.dll.a")
  set(LUAJIT_TARGET_LIBS "-lkernel32")
  if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(LUAJIT_DLLNAME "libluajit.dll")
    set(LUAJIT_LIBNAME "libluajit.a")
  else()
    set(LUAJIT_DLLNAME "luajit.dll")
    set(LUAJIT_LIBNAME "luajit.dll.a")
  endif()
  set(LUAJIT_EXENAME "luajit.exe")
  set(LUAJIT_DLLPATH "bin")
else()
  message(FATAL_ERROR "Unsupported target platform.")
endif()

set(LUAJIT_PREFIX "${CURRENT_PACKAGES_DIR}")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/configure" DESTINATION "${SOURCE_PATH}"
  FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)

vcpkg_configure_make(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
    "SOURCE_PATH=${SOURCE_PATH}")

vcpkg_build_make(
  MAKEFILE "Makefile"
  BUILD_TARGET "install"
  OPTIONS
                  # Build
                 "Q="
          "LDCONFIG=echo"

                  # Common
                "CC=${LUAJIT_CC}"
            "CFLAGS=${LUAJIT_CFLAGS}"
           "LDFLAGS=${LUAJIT_CFLAGS} ${LUAJIT_LDFLAGS}"
              "LIBS=${LUAJIT_LIBS}"
             "CROSS="

                  # Host Flags
           "HOST_CC=${LUAJIT_CC}"
       "HOST_CFLAGS=${LUAJIT_HOST_CFLAGS}"
      "HOST_LDFLAGS=${LUAJIT_HOST_CFLAGS} ${LUAJIT_HOST_LDFALGS}"
         "HOST_LIBS=${LUAJIT_HOST_LIBS}"
          "HOST_SYS=${LUAJIT_HOST_SYS}"

                  # Target Flags
         "TARGET_CC=${LUAJIT_CC}"
         "TARGET_LD=${LUAJIT_CC}"
         "TARGET_AR=${LUAJIT_AR} rcus 2>/dev/null"
      "TARGET_STRIP=${LUAJIT_STRIP}"
     "TARGET_CFLAGS=${LUAJIT_TARGET_CFLAGS}"
    "TARGET_LDFLAGS=${LUAJIT_TARGET_CFLAGS} ${LUAJIT_TARGET_LDFLAGS}"
  "TARGET_SHLDFLAGS=${LUAJIT_TARGET_CFLAGS} ${LUAJIT_TARGET_LDFLAGS} ${LUAJIT_TARGET_SHFLAGS}"
       "TARGET_LIBS=${LUAJIT_TARGET_LIBS}"
        "TARGET_SYS=${LUAJIT_TARGET_SYS}"

                  # Target Filenames
    "TARGET_DLLNAME=${LUAJIT_DLLNAME}"
     "TARGET_SONAME=${LUAJIT_DLLNAME}"
           "FILE_SO=${LUAJIT_DLLNAME}"
            "FILE_A=${LUAJIT_LIBNAME}"
            "FILE_T=${LUAJIT_EXENAME}"
    "INSTALL_SONAME=${LUAJIT_DLLNAME}"
     "INSTALL_ANAME=${LUAJIT_LIBNAME}"
     "INSTALL_TNAME=${LUAJIT_EXENAME}"

                  # Destination
            "PREFIX=${LUAJIT_PREFIX}"
       "INSTALL_INC=${LUAJIT_PREFIX}/include/luajit"
       "INSTALL_DYN=${LUAJIT_PREFIX}/${LUAJIT_DLLPATH}/${LUAJIT_DLLNAME}"
    "INSTALL_JITLIB=${LUAJIT_PREFIX}/share/luajit/jit"
         "BUILDMODE=${VCPKG_LIBRARY_LINKAGE}")

file(REMOVE_RECURSE
  "${CURRENT_PACKAGES_DIR}/debug/include"
  "${CURRENT_PACKAGES_DIR}/debug/lib/libluajit-5.1.so"
  "${CURRENT_PACKAGES_DIR}/debug/lib/libluajit-5.1.so.2"
  "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig"
  "${CURRENT_PACKAGES_DIR}/debug/lib/lua"
  "${CURRENT_PACKAGES_DIR}/debug/share"
  "${CURRENT_PACKAGES_DIR}/lib/libluajit-5.1.so"
  "${CURRENT_PACKAGES_DIR}/lib/libluajit-5.1.so.2"
  "${CURRENT_PACKAGES_DIR}/lib/pkgconfig"
  "${CURRENT_PACKAGES_DIR}/lib/lua"
  "${CURRENT_PACKAGES_DIR}/share/lua"
  "${CURRENT_PACKAGES_DIR}/share/man")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/LuaJITConfig-version.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/LuaJITConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

if(VCPKG_TARGET_IS_LINUX)
  vcpkg_copy_tools(TOOL_NAMES luajit AUTO_CLEAN)
elseif(VCPKG_TARGET_IS_WINDOWS)
  file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/bin/luajit.exe"
    "${CURRENT_PACKAGES_DIR}/bin/luajit.exe")
  if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE
      "${CURRENT_PACKAGES_DIR}/debug/bin"
      "${CURRENT_PACKAGES_DIR}/bin")
  endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")

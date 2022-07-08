cmake_minimum_required(VERSION 3.22 FATAL_ERROR)
project(icu VERSION 71.1 LANGUAGES C CXX)

# Disable exceptions.
if(MSVC)
  set(CXXFLAGS "/EHs-c- /D_HAS_EXCEPTIONS=0")
  string(REPLACE "/EHsc" "${CXXFLAGS}" CXXFLAGS "${CMAKE_CXX_FLAGS}")
  set(CMAKE_CXX_FLAGS "${CXXFLAGS}" CACHE STRING "" FORCE)
else()
  set(CXXFLAGS "${CMAKE_CXX_FLAGS} -fno-exceptions")
  set(CMAKE_CXX_FLAGS "${CXXFLAGS}" CACHE STRING "" FORCE)
endif()

# Set compile definitions.
set(ICU_COMPILE_DEFINITIONS
  -D_SILENCE_ALL_CXX20_DEPRECATION_WARNINGS
  -D_LIBCPP_DISABLE_DEPRECATION_WARNINGS
  -DICU_DATA_DIR="${CMAKE_INSTALL_PREFIX}/share/icu"
  -DICU_NO_USER_DATA_OVERRIDE=1
  -DICUDATA_NAME=icudtl
  -DU_ATTRIBUTE_DEPRECATED=
  -DU_HAVE_STD_ATOMICS
  -DU_DISABLE_RENAMING)

if(WIN32)
  list(APPEND ICU_COMPILE_DEFINITIONS
    -DU_PLATFORM_USES_ONLY_WIN32_API=1
    -D_CRT_SECURE_NO_DEPRECATE)
else()
  list(APPEND ICU_COMPILE_DEFINITIONS
    -DU_HAVE_XLOCALE_H=0
    -DU_HAVE_STRTOD_L=1
    -DU_HAVE_ELF_H=1
    -D_REENTRANT)
endif()

# Set big endian flag.
include(TestBigEndian)
test_big_endian(U_IS_BIG_ENDIAN)
if(U_IS_BIG_ENDIAN)
  list(APPEND ICU_COMPILE_DEFINITIONS
    -DU_IS_BIG_ENDIAN=1)
endif()

# Set include directories.
set(ICU_INCLUDE_DIRECTORIES
  ${CMAKE_CURRENT_SOURCE_DIR}/src/source/common)

# Find dependencies.
find_package(Threads REQUIRED)

# ==========================================================================
# DATA
# ==========================================================================

file(GLOB data_headers
  src/source/stubdata/*.h)

file(GLOB data_sources
  src/source/data/misc/icudata.rc
  src/source/stubdata/*.cpp)

add_library(data_shared SHARED ${data_headers} ${data_sources})
target_compile_features(data_shared PRIVATE cxx_std_20)
target_link_libraries(data_shared PUBLIC Threads::Threads)

if(UNIX)
  set_target_properties(data_shared PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    C_VISIBILITY_PRESET hidden)
endif()

add_library(data_static STATIC ${data_headers} ${data_sources})
target_compile_features(data_static PRIVATE cxx_std_20)
target_link_libraries(data_static PUBLIC Threads::Threads)

target_compile_definitions(data_shared
  PRIVATE ${ICU_COMPILE_DEFINITIONS} -DSTUBDATA_BUILD)

target_compile_definitions(data_static PUBLIC -DU_STATIC_IMPLEMENTATION
  PRIVATE ${ICU_COMPILE_DEFINITIONS} -DSTUBDATA_BUILD)

target_include_directories(data_shared
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/source/stubdata
  PUBLIC $<BUILD_INTERFACE:${ICU_INCLUDE_DIRECTORIES}>
         $<INSTALL_INTERFACE:include>)

target_include_directories(data_static
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/source/stubdata
  PUBLIC $<BUILD_INTERFACE:${ICU_INCLUDE_DIRECTORIES}>
         $<INSTALL_INTERFACE:include>)

set_target_properties(data_shared PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreadedDLL
  ARCHIVE_OUTPUT_DIRECTORY shared
  OUTPUT_NAME icudata)

set_target_properties(data_static PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreaded
  ARCHIVE_OUTPUT_DIRECTORY static
  OUTPUT_NAME icudata)

install(TARGETS data_shared
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib$<$<PLATFORM_ID:Windows>:/shared>
  LIBRARY DESTINATION lib$<$<PLATFORM_ID:Windows>:/shared>)

install(TARGETS data_static
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib$<$<PLATFORM_ID:Windows>:/static>
  LIBRARY DESTINATION lib$<$<PLATFORM_ID:Windows>:/static>)

# ==========================================================================
# COMMON
# ==========================================================================

file(GLOB uc_headers
  src/source/common/unicode/*.h
  src/source/common/*.h)

file(GLOB uc_sources
  src/source/common/common.rc
  src/source/common/*.cpp)

add_library(uc_shared SHARED ${uc_headers} ${uc_sources})
target_compile_features(uc_shared PRIVATE cxx_std_20)
target_link_libraries(uc_shared PRIVATE data_shared)

if(UNIX)
  set_target_properties(uc_shared PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    C_VISIBILITY_PRESET hidden)
endif()

add_library(uc_static STATIC ${uc_headers} ${uc_sources})
target_compile_features(uc_static PRIVATE cxx_std_20)
target_link_libraries(uc_static PUBLIC data_static)

target_compile_definitions(uc_shared
  PRIVATE ${ICU_COMPILE_DEFINITIONS} -DU_COMMON_IMPLEMENTATION)

target_compile_definitions(uc_static PUBLIC -DU_STATIC_IMPLEMENTATION
  PRIVATE ${ICU_COMPILE_DEFINITIONS} -DU_COMMON_IMPLEMENTATION)

target_include_directories(uc_shared
  PUBLIC $<BUILD_INTERFACE:${ICU_INCLUDE_DIRECTORIES}>
         $<INSTALL_INTERFACE:include>)

target_include_directories(uc_static
  PUBLIC $<BUILD_INTERFACE:${ICU_INCLUDE_DIRECTORIES}>
         $<INSTALL_INTERFACE:include>)

set_target_properties(uc_shared PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreadedDLL
  ARCHIVE_OUTPUT_DIRECTORY shared
  OUTPUT_NAME icuuc)

set_target_properties(uc_static PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreaded
  ARCHIVE_OUTPUT_DIRECTORY static
  OUTPUT_NAME icuuc)

install(TARGETS uc_shared
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib$<$<PLATFORM_ID:Windows>:/shared>
  LIBRARY DESTINATION lib$<$<PLATFORM_ID:Windows>:/shared>)

install(TARGETS uc_static
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib$<$<PLATFORM_ID:Windows>:/static>
  LIBRARY DESTINATION lib$<$<PLATFORM_ID:Windows>:/static>)

# ==========================================================================
# I18N
# ==========================================================================

file(GLOB i18n_headers
  src/source/i18n/unicode/*.h
  src/source/i18n/*.h)

file(GLOB i18n_sources
  src/source/i18n/i18n.rc
  src/source/i18n/*.cpp)

add_library(i18n_shared SHARED ${i18n_headers} ${i18n_sources})
target_compile_features(i18n_shared PRIVATE c_std_11 cxx_std_20)
target_link_libraries(i18n_shared PUBLIC uc_shared)

if(UNIX)
  set_target_properties(i18n_shared PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    C_VISIBILITY_PRESET hidden)
endif()

add_library(i18n_static STATIC ${i18n_headers} ${i18n_sources})
target_compile_features(i18n_static PRIVATE cxx_std_20)
target_link_libraries(i18n_static PUBLIC uc_static)

target_compile_definitions(i18n_shared
  PRIVATE ${ICU_COMPILE_DEFINITIONS} -DU_I18N_IMPLEMENTATION)

target_compile_definitions(i18n_static PUBLIC -DU_STATIC_IMPLEMENTATION
  PRIVATE ${ICU_COMPILE_DEFINITIONS} -DU_I18N_IMPLEMENTATION)

target_include_directories(i18n_shared
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/source/i18n
  PUBLIC $<BUILD_INTERFACE:${ICU_INCLUDE_DIRECTORIES}>
         $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/source/i18n>
         $<INSTALL_INTERFACE:include>)

target_include_directories(i18n_static
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/source/i18n
  PUBLIC $<BUILD_INTERFACE:${ICU_INCLUDE_DIRECTORIES}>
         $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/source/i18n>
         $<INSTALL_INTERFACE:include>)

set_target_properties(i18n_shared PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreadedDLL
  ARCHIVE_OUTPUT_DIRECTORY shared
  OUTPUT_NAME icui18n)

set_target_properties(i18n_static PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreaded
  ARCHIVE_OUTPUT_DIRECTORY static
  OUTPUT_NAME icui18n)

install(TARGETS i18n_shared
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib$<$<PLATFORM_ID:Windows>:/shared>
  LIBRARY DESTINATION lib$<$<PLATFORM_ID:Windows>:/shared>)

install(TARGETS i18n_static
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib$<$<PLATFORM_ID:Windows>:/static>
  LIBRARY DESTINATION lib$<$<PLATFORM_ID:Windows>:/static>)

# ==========================================================================
# TOOLUTIL
# ==========================================================================

file(GLOB tu_headers
  src/source/tools/toolutil/*.h)

file(GLOB tu_sources
  src/source/tools/toolutil/*.cpp)

add_library(tu_static STATIC ${tu_headers} ${tu_sources})
target_compile_features(tu_static PRIVATE cxx_std_20)
target_link_libraries(tu_static PUBLIC i18n_static)

target_compile_definitions(tu_static PUBLIC -DU_STATIC_IMPLEMENTATION
  PRIVATE ${ICU_COMPILE_DEFINITIONS} -DU_TOOLUTIL_IMPLEMENTATION)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  target_compile_definitions(tu_static PRIVATE
    -DUNISTR_FROM_STRING_EXPLICIT=explicit
    -DUNISTR_FROM_CHAR_EXPLICIT=explicit
    -DU_BUILD="x86_64-pc-windows-msvc"
    -DU_HOST="x86_64-pc-windows-msvc"
    -DU_CXX="clang-cl.exe"
    -DU_CC="clang-cl.exe")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  target_compile_definitions(tu_static PRIVATE
    -DUNISTR_FROM_STRING_EXPLICIT=explicit
    -DUNISTR_FROM_CHAR_EXPLICIT=explicit
    -DU_BUILD="x86_64-pc-linux-gnu"
    -DU_HOST="x86_64-pc-linux-gnu"
    -DU_CXX="clang++"
    -DU_CC="clang")
else()
  message(FATAL_ERROR "Unsupported system: ${CMAKE_SYSTEM_NAME}")
endif()

target_include_directories(tu_static
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/source/tools/toolutil
  PUBLIC $<BUILD_INTERFACE:${ICU_INCLUDE_DIRECTORIES}>)

set_target_properties(tu_static PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreaded
  ARCHIVE_OUTPUT_DIRECTORY static
  OUTPUT_NAME icutu)

# ==========================================================================
# TOOL: icupkg
# ==========================================================================

add_executable(icupkg src/source/tools/icupkg/icupkg.cpp)
target_compile_features(icupkg PRIVATE cxx_std_20)
target_link_libraries(icupkg PUBLIC tu_static)

target_compile_definitions(icupkg PRIVATE ${ICU_COMPILE_DEFINITIONS})

target_include_directories(icupkg
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/source/tools/toolutil
  PUBLIC $<BUILD_INTERFACE:${ICU_INCLUDE_DIRECTORIES}>)

set_target_properties(icupkg PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreaded
  ARCHIVE_OUTPUT_DIRECTORY static
  INSTALL_RPATH "$ORIGIN/../lib")

install(TARGETS icupkg RUNTIME DESTINATION tools)

# ==========================================================================
# TOOL: pkgdata
# ==========================================================================

add_executable(pkgdata src/source/tools/pkgdata/pkgdata.cpp)
target_sources(pkgdata PRIVATE src/source/tools/pkgdata/pkgtypes.c)
target_compile_features(pkgdata PRIVATE c_std_11 cxx_std_20)
target_link_libraries(pkgdata PUBLIC tu_static)

target_compile_definitions(pkgdata PRIVATE ${ICU_COMPILE_DEFINITIONS})

target_include_directories(pkgdata
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/source/tools/toolutil
  PUBLIC $<BUILD_INTERFACE:${ICU_INCLUDE_DIRECTORIES}>)

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  target_compile_definitions(pkgdata PRIVATE
    -DUDATA_SO_SUFFIX=".so"
    -DSTATIC_O="ao")
endif()

set_target_properties(pkgdata PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreaded
  ARCHIVE_OUTPUT_DIRECTORY static
  INSTALL_RPATH "$ORIGIN/../lib")

install(TARGETS pkgdata RUNTIME DESTINATION tools)

# ==========================================================================
# HEADERS
# ==========================================================================

install(DIRECTORY src/source/common/unicode DESTINATION include
  FILES_MATCHING PATTERN "*.h")

install(DIRECTORY src/source/i18n/unicode DESTINATION include
  FILES_MATCHING PATTERN "*.h")

# ==========================================================================
# DATA
# ==========================================================================

set(DATA_FILE ${CMAKE_CURRENT_SOURCE_DIR}/src/source/data/in/icudt71l.dat)
set(DATA_PATH ${CMAKE_CURRENT_BINARY_DIR}/data)

if(WIN32)
  set(ICU_EXTRACT_OPTIONS -d data/src --list
    -x "*" "${DATA_FILE}" -o data/icudtl.lst)
  set(ICU_PACKAGE_OPTIONS -q -c -s data/src -d data
    -e icudt${PROJECT_VERSION_MAJOR} -T data -p icudtl -m common
    -r ${PROJECT_VERSION} data/icudtl.lst)
else()
  set(ICU_EXTRACT_OPTIONS -d data/src --list
    -x "\\*" "${DATA_FILE}" -o data/icudtl.lst)
  set(ICU_PACKAGE_OPTIONS -O data/icupkg.inc -q -c -s data/src -d data
    -e icudt${PROJECT_VERSION_MAJOR} -T data -p icudtl -m common
    -r ${PROJECT_VERSION} data/icudtl.lst)
endif()

add_custom_command(OUTPUT ${DATA_PATH}/icudtl.lst
  COMMENT "Extracting data ..."
  COMMAND ${CMAKE_COMMAND} -E make_directory data/src
  COMMAND ${CMAKE_COMMAND} -E touch data/icupkg.inc
  COMMAND $<TARGET_FILE:icupkg> ${ICU_EXTRACT_OPTIONS}
  MAIN_DEPENDENCY ${DATA_FILE}
  DEPENDS icupkg
  USES_TERMINAL)

add_custom_command(OUTPUT ${DATA_PATH}/icudtl.dat
  COMMENT "Packaging data ..."
  COMMAND $<TARGET_FILE:pkgdata> ${ICU_PACKAGE_OPTIONS}
  MAIN_DEPENDENCY ${DATA_PATH}/icudtl.lst
  DEPENDS pkgdata
  USES_TERMINAL)

add_custom_target(data ALL DEPENDS ${DATA_PATH}/icudtl.dat)
install(FILES ${DATA_PATH}/icudtl.dat DESTINATION share/icu)

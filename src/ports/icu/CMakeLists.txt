cmake_minimum_required(VERSION 3.26 FATAL_ERROR)
project(icu VERSION 72.1 LANGUAGES C CXX)

# Wine
if(WIN32)
  set(WINE wine)
else()
  set(WINE)
endif()

# Disable exceptions.
set(CXXFLAGS "${CMAKE_CXX_FLAGS} -fno-exceptions")
set(CMAKE_CXX_FLAGS "${CXXFLAGS}" CACHE STRING "" FORCE)

# Set compile definitions.
set(ICU_COMPILE_DEFINITIONS
  -D_SILENCE_ALL_CXX20_DEPRECATION_WARNINGS
  -D_LIBCPP_DISABLE_DEPRECATION_WARNINGS
  -DICU_DATA_DIR="${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/icu"
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
  ${CMAKE_CURRENT_SOURCE_DIR}/source/common)

# Find dependencies.
find_package(Threads REQUIRED)

# ==========================================================================
# DATA
# ==========================================================================

file(GLOB data_headers
  source/stubdata/*.h)

file(GLOB data_sources
  source/data/misc/icudata.rc
  source/stubdata/*.cpp)

add_library(data ${data_headers} ${data_sources})
set_target_properties(data PROPERTIES OUTPUT_NAME icudata)
target_link_libraries(data PUBLIC Threads::Threads)
target_compile_features(data PRIVATE cxx_std_20)

if(UNIX)
  set_target_properties(data PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    C_VISIBILITY_PRESET hidden)
endif()

target_compile_definitions(data
  PRIVATE -DSTUBDATA_BUILD ${ICU_COMPILE_DEFINITIONS})

if(NOT BUILD_SHARED_LIBS)
  target_compile_definitions(data
    PUBLIC -DU_STATIC_IMPLEMENTATION)
endif()

target_include_directories(data
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/source/stubdata
  PUBLIC $<BUILD_INTERFACE:${ICU_INCLUDE_DIRECTORIES}>
         $<INSTALL_INTERFACE:include>)

install(TARGETS data
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib)

# ==========================================================================
# COMMON
# ==========================================================================

file(GLOB uc_headers
  source/common/unicode/*.h
  source/common/*.h)

file(GLOB uc_sources
  source/common/common.rc
  source/common/*.cpp)

add_library(uc ${uc_headers} ${uc_sources})
set_target_properties(uc PROPERTIES OUTPUT_NAME icuuc)
target_compile_features(uc PRIVATE cxx_std_20)
target_link_libraries(uc PRIVATE data)

if(UNIX)
  set_target_properties(uc PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    C_VISIBILITY_PRESET hidden)
endif()

target_compile_definitions(uc
  PRIVATE -DU_COMMON_IMPLEMENTATION ${ICU_COMPILE_DEFINITIONS})

if(NOT BUILD_SHARED_LIBS)
  target_compile_definitions(uc
    PUBLIC -DU_STATIC_IMPLEMENTATION)
endif()

target_include_directories(uc
  PUBLIC $<BUILD_INTERFACE:${ICU_INCLUDE_DIRECTORIES}>
         $<INSTALL_INTERFACE:include>)

install(TARGETS uc
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib)

# ==========================================================================
# I18N
# ==========================================================================

file(GLOB i18n_headers
  source/i18n/unicode/*.h
  source/i18n/*.h)

file(GLOB i18n_sources
  source/i18n/i18n.rc
  source/i18n/*.cpp)

add_library(i18n ${i18n_headers} ${i18n_sources})
set_target_properties(i18n PROPERTIES OUTPUT_NAME icui18n)
target_compile_features(i18n PRIVATE c_std_11 cxx_std_20)
target_link_libraries(i18n PUBLIC uc)

if(UNIX)
  set_target_properties(i18n PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    C_VISIBILITY_PRESET hidden)
endif()

target_compile_definitions(i18n
  PRIVATE -DU_I18N_IMPLEMENTATION ${ICU_COMPILE_DEFINITIONS})

if(NOT BUILD_SHARED_LIBS)
  target_compile_definitions(i18n
    PUBLIC -DU_STATIC_IMPLEMENTATION)
endif()

target_include_directories(i18n
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/source/i18n
  PUBLIC $<BUILD_INTERFACE:${ICU_INCLUDE_DIRECTORIES}>
         $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/source/i18n>
         $<INSTALL_INTERFACE:include>)

install(TARGETS i18n
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib)

# ==========================================================================
# TOOLUTIL
# ==========================================================================

file(GLOB tu_headers
  source/tools/toolutil/*.h)

file(GLOB tu_sources
  source/tools/toolutil/*.cpp)

add_library(tu ${tu_headers} ${tu_sources})
set_target_properties(tu PROPERTIES OUTPUT_NAME icutu)
target_compile_features(tu PRIVATE cxx_std_20)
target_link_libraries(tu PUBLIC i18n)

target_compile_definitions(tu
  PRIVATE -DU_TOOLUTIL_IMPLEMENTATION ${ICU_COMPILE_DEFINITIONS})

if(NOT BUILD_SHARED_LIBS)
  target_compile_definitions(tu
    PUBLIC -DU_STATIC_IMPLEMENTATION)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  target_compile_definitions(tu PRIVATE
    -DUNISTR_FROM_STRING_EXPLICIT=explicit
    -DUNISTR_FROM_CHAR_EXPLICIT=explicit
    -DU_BUILD="x86_64-w64-mingw32"
    -DU_HOST="x86_64-w64-mingw32"
    -DU_CXX="clang++"
    -DU_CC="clang")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  target_compile_definitions(tu PRIVATE
    -DUNISTR_FROM_STRING_EXPLICIT=explicit
    -DUNISTR_FROM_CHAR_EXPLICIT=explicit
    -DU_BUILD="x86_64-pc-linux-gnu"
    -DU_HOST="x86_64-pc-linux-gnu"
    -DU_CXX="clang++"
    -DU_CC="clang")
else()
  message(FATAL_ERROR "Unsupported system: ${CMAKE_SYSTEM_NAME}")
endif()

target_include_directories(tu
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/source/tools/toolutil
  PUBLIC $<BUILD_INTERFACE:${ICU_INCLUDE_DIRECTORIES}>)

# ==========================================================================
# TOOL: icupkg
# ==========================================================================

add_executable(icupkg source/tools/icupkg/icupkg.cpp)
target_compile_features(icupkg PRIVATE cxx_std_20)

target_link_libraries(icupkg PUBLIC tu)

target_compile_definitions(icupkg PRIVATE ${ICU_COMPILE_DEFINITIONS})

target_include_directories(icupkg
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/source/tools/toolutil
  PUBLIC $<BUILD_INTERFACE:${ICU_INCLUDE_DIRECTORIES}>)

set_target_properties(icupkg PROPERTIES
  INSTALL_RPATH "$ORIGIN/../lib")

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  install(TARGETS icupkg RUNTIME DESTINATION bin)
endif()

# ==========================================================================
# TOOL: pkgdata
# ==========================================================================

add_executable(pkgdata source/tools/pkgdata/pkgdata.cpp)
target_sources(pkgdata PRIVATE source/tools/pkgdata/pkgtypes.c)
target_compile_features(pkgdata PRIVATE c_std_11 cxx_std_20)
target_link_libraries(pkgdata PUBLIC tu)

target_compile_definitions(pkgdata PRIVATE ${ICU_COMPILE_DEFINITIONS})

target_include_directories(pkgdata
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/source/tools/toolutil
  PUBLIC $<BUILD_INTERFACE:${ICU_INCLUDE_DIRECTORIES}>)

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  target_compile_definitions(pkgdata PRIVATE
    -DUDATA_SO_SUFFIX=".so"
    -DSTATIC_O="ao")
endif()

set_target_properties(pkgdata PROPERTIES
  INSTALL_RPATH "$ORIGIN/../lib")

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  install(TARGETS pkgdata RUNTIME DESTINATION bin)
endif()

# ==========================================================================
# HEADERS
# ==========================================================================

install(DIRECTORY source/common/unicode DESTINATION include
  FILES_MATCHING PATTERN "*.h")

install(DIRECTORY source/i18n/unicode DESTINATION include
  FILES_MATCHING PATTERN "*.h")

# ==========================================================================
# DATA
# ==========================================================================

set(DATA_FILE ${CMAKE_CURRENT_SOURCE_DIR}/source/data/in/icudt72l.dat)
set(DATA_PATH ${CMAKE_CURRENT_BINARY_DIR}/data)

add_custom_command(OUTPUT ${DATA_PATH}/icudtl.lst
  COMMENT "Extracting data ..."
  COMMAND ${CMAKE_COMMAND} -E make_directory data/src
  COMMAND ${CMAKE_COMMAND} -E touch data/icupkg.inc
  COMMAND ${WINE} $<TARGET_FILE:icupkg>
    -d data/src --list -x "\\*" "${DATA_FILE}"
    -o data/icudtl.lst
  MAIN_DEPENDENCY ${DATA_FILE}
  DEPENDS icupkg
  USES_TERMINAL)

add_custom_command(OUTPUT ${DATA_PATH}/icudtl.dat
  COMMENT "Packaging data ..."
  COMMAND ${WINE} $<TARGET_FILE:pkgdata>
    -q -c -s data/src -d data -e icudt${PROJECT_VERSION_MAJOR} -T data
    -p icudtl -m common -r ${PROJECT_VERSION} data/icudtl.lst
  MAIN_DEPENDENCY ${DATA_PATH}/icudtl.lst
  DEPENDS pkgdata
  USES_TERMINAL)

add_custom_target(dtl ALL DEPENDS ${DATA_PATH}/icudtl.dat)
install(FILES ${DATA_PATH}/icudtl.dat DESTINATION share/icu)

# LibreSSL
# https://cmake.org/cmake/help/latest/module/FindOpenSSL.html
#
#   find_package(OpenSSL REQUIRED)
#   find_package(OpenSSL REQUIRED ALL)
#   find_package(OpenSSL REQUIRED COMPONENTS Crypto SSL TLS)
#   target_link_libraries(main PRIVATE OpenSSL::Crypto OpenSSL::SSL OpenSSL::TLS)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

set(OPENSSL_VERSION_STRING ${OpenSSL_VERSION})
set(OPENSSL_VERSION ${OPENSSL_VERSION_STRING})
set(OPENSSL_INCLUDE_DIRS)

set(OPENSSL_LIBRARIES)

if(NOT OpenSSL_FIND_COMPONENTS)
  set(OpenSSL_FIND_COMPONENTS ALL)
endif()

if("ALL" IN_LIST OpenSSL_FIND_COMPONENTS)
  set(OpenSSL_FIND_COMPONENTS Crypto SSL TLS)
endif()

if("TLS" IN_LIST OpenSSL_FIND_COMPONENTS)
  list(APPEND OpenSSL_FIND_COMPONENTS SSL)
endif()

if("SSL" IN_LIST OpenSSL_FIND_COMPONENTS)
  list(APPEND OpenSSL_FIND_COMPONENTS Crypto)
endif()

list(REMOVE_DUPLICATES OpenSSL_FIND_COMPONENTS)

include(CMakeFindDependencyMacro)
find_dependency(Threads REQUIRED)

if(WIN32)
  set(OPENSSL_LINK_LIBRARIES Threads::Threads bcrypt ws2_32)
else()
  set(OPENSSL_LINK_LIBRARIES Threads::Threads)
endif()

include(AceImportLibrary)

if("Crypto" IN_LIST OpenSSL_FIND_COMPONENTS)
  set(OPENSSL_CRYPTO_FOUND OFF)

  ace_import_library(OpenSSL::Crypto C NAMES crypto
    HEADERS openssl/crypto.h LINK_LIBRARIES ${OPENSSL_LINK_LIBRARIES})

  if(TARGET OpenSSL::Crypto)
    list(APPEND OPENSSL_LIBRARIES OpenSSL::Crypto)
    set(OPENSSL_CRYPTO_LIBRARIES OpenSSL::Crypto)
    set(OPENSSL_CRYPTO_LIBRARY OpenSSL::Crypto)
    set(OPENSSL_CRYPTO_FOUND ON)
  endif()
endif()

if("SSL" IN_LIST OpenSSL_FIND_COMPONENTS)
  set(OPENSSL_SSL_FOUND OFF)

  ace_import_library(OpenSSL::SSL C NAMES ssl
    HEADERS openssl/ssl.h LINK_LIBRARIES OpenSSL::Crypto)

  if(TARGET OpenSSL::SSL)
    list(APPEND OPENSSL_LIBRARIES OpenSSL::SSL)
    set(OPENSSL_SSL_LIBRARIES OpenSSL::SSL)
    set(OPENSSL_SSL_LIBRARY OpenSSL::SSL)
    set(OPENSSL_SSL_FOUND ON)
  endif()
endif()

if("TLS" IN_LIST OpenSSL_FIND_COMPONENTS)
  set(OPENSSL_TLS_FOUND OFF)

  ace_import_library(OpenSSL::TLS C NAMES tls
    HEADERS tls.h LINK_LIBRARIES OpenSSL::TLS)

  if(TARGET OpenSSL::SSL)
    list(APPEND OPENSSL_LIBRARIES OpenSSL::TLS)
    set(OPENSSL_TLS_LIBRARIES OpenSSL::TLS)
    set(OPENSSL_TLS_LIBRARY OpenSSL::TLS)
    set(OPENSSL_TLS_FOUND ON)
  endif()
endif()

set(OPENSSL_INCLUDE_DIR "${OPENSSL_INCLUDE_DIRS}" CACHE STRING "")
set(OPENSSL_LIBRARY "${OPENSSL_LIBRARIES}" CACHE STRING "")
set(OPENSSL_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

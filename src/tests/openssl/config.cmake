find_package(OpenSSL REQUIRED)
target_link_libraries(main PRIVATE OpenSSL::Crypto OpenSSL::SSL)

find_package(Threads REQUIRED)
target_link_libraries(main PRIVATE Threads::Threads)

if(WIN32)
  target_link_libraries(main PRIVATE bcrypt crypt32 ws2_32)
endif()

find_program(OPENSSL_EXECUTABLE openssl REQUIRED)
message(STATUS "Found openssl: ${OPENSSL_EXECUTABLE}")

find_program(C_REHASH_EXECUTABLE c_rehash REQUIRED)
message(STATUS "Found c_rehash: ${C_REHASH_EXECUTABLE}")

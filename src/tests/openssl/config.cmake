find_package(OpenSSL REQUIRED)
target_link_libraries(main PRIVATE OpenSSL::Crypto OpenSSL::SSL)

if(WIN32)
  find_package(Threads REQUIRED)
  target_link_libraries(main PRIVATE Threads::Threads bcrypt crypt32 ws2_32)
endif()

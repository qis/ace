find_package(lz4 CONFIG REQUIRED)
target_link_libraries(main PRIVATE lz4::lz4)

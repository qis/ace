find_package(zstd CONFIG REQUIRED)
target_link_libraries(main PRIVATE zstd::zstd)

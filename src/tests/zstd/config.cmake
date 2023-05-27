find_package(zstd CONFIG REQUIRED)
target_link_libraries(main PRIVATE zstd::zstd)

find_program(ZSTD_EXECUTABLE zstd REQUIRED)
message(STATUS "Found zstd: ${ZSTD_EXECUTABLE}")

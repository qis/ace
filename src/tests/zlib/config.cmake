find_package(ZLIB REQUIRED)
target_link_libraries(main PRIVATE ZLIB::ZLIB)

find_program(GZIP_EXECUTABLE gzip REQUIRED)
message(STATUS "Found gzip: ${GZIP_EXECUTABLE}")

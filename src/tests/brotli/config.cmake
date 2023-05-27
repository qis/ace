find_package(brotli CONFIG REQUIRED)
target_link_libraries(main PRIVATE brotli::brotlidec)
target_link_libraries(main PRIVATE brotli::brotlienc)

find_program(BROTLI_EXECUTABLE brotli REQUIRED)
message(STATUS "Found brotli: ${BROTLI_EXECUTABLE}")

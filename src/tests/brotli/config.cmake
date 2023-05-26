find_package(brotli CONFIG REQUIRED)
target_link_libraries(main PRIVATE brotli::brotlidec)
target_link_libraries(main PRIVATE brotli::brotlienc)

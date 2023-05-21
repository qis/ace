find_package(unofficial-brotli CONFIG REQUIRED)
target_link_libraries(main PRIVATE unofficial::brotli::brotlidec)
target_link_libraries(main PRIVATE unofficial::brotli::brotlienc)

find_package(liblzma CONFIG REQUIRED)
target_link_libraries(main PRIVATE liblzma::liblzma)

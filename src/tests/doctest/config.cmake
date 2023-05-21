find_package(doctest CONFIG REQUIRED)
target_link_libraries(main PRIVATE doctest::doctest)
target_sources(main PRIVATE ${CMAKE_CURRENT_LIST_DIR}/test.cpp)

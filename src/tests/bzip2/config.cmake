find_package(BZip2 REQUIRED)
target_link_libraries(main PRIVATE BZip2::BZip2)

find_program(BZIP2_EXECUTABLE bzip2 REQUIRED)
message(STATUS "Found bzip2: ${BZIP2_EXECUTABLE}")

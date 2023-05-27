find_package(LibLZMA REQUIRED)
target_link_libraries(main PRIVATE LibLZMA::LibLZMA)

find_program(XZ_EXECUTABLE xz REQUIRED)
message(STATUS "Found xz: ${XZ_EXECUTABLE}")

find_program(XZDEC_EXECUTABLE xzdec REQUIRED)
message(STATUS "Found xzdec: ${XZDEC_EXECUTABLE}")

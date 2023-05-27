find_package(LibXml2 REQUIRED)
target_link_libraries(main PRIVATE LibXml2::LibXml2)
target_link_libraries(main PRIVATE ${CMAKE_DL_LIBS})

find_program(XMLLINT_EXECUTABLE xmllint REQUIRED)
message(STATUS "Found xmllint: ${XMLLINT_EXECUTABLE}")

find_program(XMLCATALOG_EXECUTABLE xmlcatalog REQUIRED)
message(STATUS "Found xmlcatalog: ${XMLCATALOG_EXECUTABLE}")

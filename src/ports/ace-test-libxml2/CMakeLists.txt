cmake_minimum_required(VERSION 3.28 FATAL_ERROR)
project(ace-test VERSION 0.1.0 LANGUAGES C CXX)

add_executable(main main.cpp main.manifest)
target_compile_features(main PRIVATE cxx_std_26)

find_package(LibXml2 REQUIRED)
target_link_libraries(main PRIVATE LibXml2::LibXml2)

find_program(XMLLINT xmllint REQUIRED)
execute_process(COMMAND ${XMLLINT} --noout --nonet --timing main.manifest
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  COMMAND_ERROR_IS_FATAL ANY
  COMMAND_ECHO STDOUT)

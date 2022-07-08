get_filename_component(ACE ${CMAKE_CURRENT_LIST_DIR}/.. ABSOLUTE)

if(CMAKE_ARGC LESS 4)
  message(FATAL_ERROR "usage: cmake -P ${CMAKE_CURRENT_LIST_FILE} <triplet>")
endif()

macro(find_program)
endmacro()

cmake_policy(SET CMP0011 NEW)
set(ACE_TARGET "${CMAKE_ARGV3}")
include("${ACE}/toolchain.cmake")
message("${ACE_ARCH}")

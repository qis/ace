get_filename_component(ACE ${CMAKE_CURRENT_LIST_DIR}/.. ABSOLUTE)
set(ACE_TARGET "${CMAKE_ARGV3}")
include("${ACE}/sys/arch.cmake")
message("${ACE_ARCH}")

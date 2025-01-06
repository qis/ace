get_filename_component(ACE ${CMAKE_CURRENT_LIST_DIR} ABSOLUTE)
get_filename_component(ACE ${ACE} DIRECTORY)

include(${ACE}/build/src/llvm/cmake/Modules/LLVMVersion.cmake)

if(NOT DEFINED LLVM_VERSION_MAJOR)
  message(FATAL_ERROR "Missing define: LLVM_VERSION_MAJOR")
endif()

execute_process(COMMAND ${CMAKE_COMMAND} -E echo "${LLVM_VERSION_MAJOR}")

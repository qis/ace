get_filename_component(LLVM_ROOT ${CMAKE_CURRENT_LIST_DIR}/.. ABSOLUTE)

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
  set(CLANG_FORMAT_PROGRAM_PATH ${LLVM_ROOT}/win/bin)
else()
  set(CLANG_FORMAT_PROGRAM_PATH ${LLVM_ROOT}/bin)
endif()

find_program(clang_format clang-format PATHS ${CLANG_FORMAT_PROGRAM_PATH} REQUIRED NO_DEFAULT_PATH)
if(NOT clang_format)
  message(FATAL_ERROR "error: could not find program: clang-format")
endif()

if(CMAKE_ARGC LESS 4)
  message(FATAL_ERROR "usage: cmake -P ${LLVM_ROOT}/cmake/format.cmake include src")
endif()

set(sources)

math(EXPR ARGC "${CMAKE_ARGC} - 1")
foreach(N RANGE 3 ${ARGC})
  set(directory ${CMAKE_ARGV${N}})

  if(NOT IS_DIRECTORY ${directory})
    message(FATAL_ERROR "error: not a directory: \"${directory}\"")
  endif()

  file(GLOB_RECURSE directory_sources
    ${directory}/*.h
    ${directory}/*.c
    ${directory}/*.hpp
    ${directory}/*.cpp)

  list(APPEND sources ${directory_sources})
endforeach()

foreach(file_absolute ${sources})
  file(RELATIVE_PATH file_relative ${CMAKE_CURRENT_SOURCE_DIR} ${file_absolute})
  file(TIMESTAMP "${file_relative}" file_timestamp_original UTC)
  execute_process(COMMAND "${clang_format}" -i ${file_relative})
  file(TIMESTAMP "${file_relative}" file_timestamp_modified UTC)
  if(NOT file_timestamp_original STREQUAL file_timestamp_modified)
    message(STATUS "${file_relative}")
  endif()
endforeach()

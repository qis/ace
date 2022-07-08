# Vulkan
# https://cmake.org/cmake/help/latest/module/FindVulkan.html
#
#   find_package(Vulkan REQUIRED COMPONENTS glslc)
#   target_link_libraries(main PRIVATE Vulkan::Headers)
#
#   function(add_shaders TARGET)
#     cmake_parse_arguments(PARSE_ARGV 1 GLSLC "" "ENV" "SRC")
#     set(GLSLC_SUPPORTED_EXTENSIONS .vert .frag .tesc .tese .geom .comp)
#     foreach(SRC ${GLSLC_SRC})
#       get_filename_component(SRC_PATH ${SRC} PATH)
#       get_filename_component(SRC_NAME ${SRC} NAME_WE)
#       get_filename_component(SRC_TYPE ${SRC} LAST_EXT)
#       set(SRC_FILE ${CMAKE_CURRENT_SOURCE_DIR}/${SRC})
#       if(NOT EXISTS ${SRC_FILE})
#         message(FATAL_ERROR "Missing file: ${SRC_FILE}")
#       endif()
#       if(NOT "${SRC_TYPE}" IN_LIST GLSLC_SUPPORTED_EXTENSIONS)
#         message(FATAL_ERROR "Unsupported file extension: ${SRC_FILE}")
#       endif()
#       string(SUBSTRING "${SRC_TYPE}" 1 -1 SRC_TYPE)
#       add_custom_command(OUTPUT ${SRC_PATH}/${SRC_NAME}/${SRC_TYPE}.spv
#         COMMENT "Compiling shader: ${SRC_PATH}/${SRC_NAME}/${SRC_TYPE}.spv"
#         COMMAND Vulkan::glslc $<$<BOOL:${GLSLC_ENV}>:--target-env=${GLSLC_ENV}>
#           -MD -MF ${SRC_TYPE}.dep -o ${SRC_TYPE}.spv ${SRC_FILE}
#         WORKING_DIRECTORY ${SRC_PATH}/${SRC_NAME}
#         DEPENDS ${SRC_FILE}
#         USES_TERMINAL)
#       target_sources(${TARGET} PRIVATE
#         ${SRC_PATH}/${SRC_NAME}/${SRC_TYPE}.spv)
#     endforeach()
#   endfunction()
#
#   add_shaders(main
#     ENV vulkan1.3 SRC
#     shaders/core.vert
#     shaders/core.frag
#     shaders/core.tesc
#     shaders/core.tese
#     shaders/core.geom
#     shaders/core.comp)
#
#   find_program(SPIRV_AS_EXECUTABLE spirv-as REQUIRED)
#   find_program(SPIRV_DIS_EXECUTABLE spirv-dis REQUIRED)
#   find_program(SPIRV_VAL_EXECUTABLE spirv-val REQUIRED)
#   find_program(SPIRV_OPT_EXECUTABLE spirv-opt REQUIRED)
#   find_program(SPIRV_CFG_EXECUTABLE spirv-cfg REQUIRED)
#   find_program(SPIRV_LINK_EXECUTABLE spirv-link REQUIRED)
#   find_program(SPIRV_LINT_EXECUTABLE spirv-lint REQUIRED)
#   find_program(SPIRV_REDUCE_EXECUTABLE spirv-reduce REQUIRED)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

set(Vulkan_VERSION_STRING ${Vulkan_VERSION})
set(Vulkan_VERSION ${Vulkan_VERSION_STRING})
set(Vulkan_INCLUDE_DIRS)

set(Vulkan_LIBRARIES Vulkan::Headers)

if(NOT Vulkan_FIND_COMPONENTS)
  set(Vulkan_FIND_COMPONENTS ALL)
endif()

if("ALL" IN_LIST Vulkan_FIND_COMPONENTS)
  set(Vulkan_FIND_COMPONENTS glslc glslangValidator)
endif()

include(AceImportLibrary)
ace_import_library(Vulkan::Headers C HEADERS vulkan/vulkan.h)

add_library(Vulkan::Vulkan ALIAS Vulkan::Headers)

if("glslc" IN_LIST Vulkan_FIND_COMPONENTS)
  find_program(Vulkan_GLSLC_EXECUTABLE glslc REQUIRED)
  if(Vulkan_GLSLC_EXECUTABLE)
    add_executable(Vulkan::glslc IMPORTED)
    set_property(TARGET Vulkan::glslc PROPERTY
      IMPORTED_LOCATION ${Vulkan_GLSLC_EXECUTABLE})
    set(Vulkan_glslc_FOUND 1)
  endif()
endif()

if("glslangValidator" IN_LIST Vulkan_FIND_COMPONENTS)
  find_program(Vulkan_GLSLANG_VALIDATOR_EXECUTABLE glslangValidator REQUIRED)
  if(Vulkan_GLSLANG_VALIDATOR_EXECUTABLE)
    add_executable(Vulkan::glslangValidator IMPORTED)
    set_property(TARGET Vulkan::glslangValidator PROPERTY
      IMPORTED_LOCATION ${Vulkan_GLSLANG_VALIDATOR_EXECUTABLE})
    set(Vulkan_glslangValidator_FOUND 1)
  endif()
endif()

set(Vulkan_INCLUDE_DIR "${Vulkan_INCLUDE_DIRS}" CACHE STRING "")
set(Vulkan_LIBRARY "${Vulkan_LIBRARIES}" CACHE STRING "")
set(Vulkan_FOUND 1)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

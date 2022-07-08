cmake_minimum_required(VERSION 3.22 FATAL_ERROR)
project(main VERSION 0.1.0 LANGUAGES CXX)

add_executable(main main.cpp main.manifest)
target_compile_features(main PRIVATE cxx_std_23)

if(WIN32)
  target_compile_definitions(main PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN)
endif()

find_package(Vulkan REQUIRED COMPONENTS glslc)
target_link_libraries(main PRIVATE Vulkan::Headers)

function(add_shaders TARGET)
  cmake_parse_arguments(PARSE_ARGV 1 GLSLC "" "ENV" "SRC")
  set(GLSLC_SUPPORTED_EXTENSIONS .vert .frag .tesc .tese .geom .comp)
  foreach(SRC ${GLSLC_SRC})
    get_filename_component(SRC_PATH ${SRC} PATH)
    get_filename_component(SRC_NAME ${SRC} NAME_WE)
    get_filename_component(SRC_TYPE ${SRC} LAST_EXT)
    set(SRC_FILE ${CMAKE_CURRENT_SOURCE_DIR}/${SRC})
    if(NOT EXISTS ${SRC_FILE})
      message(FATAL_ERROR "Missing file: ${SRC_FILE}")
    endif()
    if(NOT "${SRC_TYPE}" IN_LIST GLSLC_SUPPORTED_EXTENSIONS)
      message(FATAL_ERROR "Unsupported file extension: ${SRC_FILE}")
    endif()
    string(SUBSTRING "${SRC_TYPE}" 1 -1 SRC_TYPE)
    add_custom_command(OUTPUT ${SRC_PATH}/${SRC_NAME}/${SRC_TYPE}.spv
      COMMENT "Compiling shader: ${SRC_PATH}/${SRC_NAME}/${SRC_TYPE}.spv"
      COMMAND Vulkan::glslc $<$<BOOL:${GLSLC_ENV}>:--target-env=${GLSLC_ENV}>
        -MD -MF ${SRC_TYPE}.dep -o ${SRC_TYPE}.spv ${SRC_FILE}
      WORKING_DIRECTORY ${SRC_PATH}/${SRC_NAME}
      DEPENDS ${SRC_FILE}
      USES_TERMINAL)
    target_sources(${TARGET} PRIVATE
      ${SRC_PATH}/${SRC_NAME}/${SRC_TYPE}.spv)
  endforeach()
endfunction()

add_shaders(main
  ENV vulkan1.3 SRC
  shaders/core.vert
  shaders/core.frag
  shaders/core.tesc
  shaders/core.tese
  shaders/core.geom
  shaders/core.comp)

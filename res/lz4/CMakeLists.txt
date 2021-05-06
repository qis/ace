cmake_minimum_required(VERSION 3.0)
project(lz4 C)

file(GLOB headers lib/*.h)
list(REMOVE_ITEM headers ${CMAKE_CURRENT_SOURCE_DIR}/lib/xxhash.h)

add_library(lz4
  ${headers}
  lib/lz4.c
  lib/lz4frame.c
  lib/lz4hc.c
  lib/xxhash.c)

target_compile_definitions(lz4 PRIVATE XXH_NAMESPACE=LZ4_)
target_include_directories(lz4 PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/lib>
  $<INSTALL_INTERFACE:include>)

if(BUILD_SHARED_LIBS)
  set_target_properties(lz4 PROPERTIES DEFINE_SYMBOL LZ4LIB_EXPORTS)
  target_compile_definitions(lz4 PUBLIC LZ4LIB_SHARED)
  if(NOT WIN32)
    target_compile_options(lz4 PRIVATE -fvisibility=hidden)
  endif()
endif()

install(TARGETS lz4
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib)

install(FILES ${headers} DESTINATION include)

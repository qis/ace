cmake_minimum_required(VERSION 3.22 FATAL_ERROR)
project(editline VERSION 1.17.1 LANGUAGES C)

# Headers
set(headers
  src/src/editline/readline.h
  src/src/editline/wineditline.h
  src/src/el_globals.h
  src/src/histedit.h)

# Sources
set(sources
  src/src/editline.c
  src/src/fn_complete.c
  src/src/history.c)

# Libraries
add_library(edit STATIC ${headers} ${sources})
target_compile_features(edit PRIVATE c_std_11)
target_compile_definitions(edit PRIVATE ${CMAKE_REQUIRED_DEFINITIONS})
target_link_libraries(edit PRIVATE ${CMAKE_REQUIRED_LIBRARIES})

target_include_directories(edit PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/src>
  $<INSTALL_INTERFACE:include>)

# Install
install(TARGETS edit
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/src/editline/readline.h
  DESTINATION include)

cmake_minimum_required(VERSION 3.22 FATAL_ERROR)
project(editline VERSION 1.17.1 LANGUAGES C)

include(CheckIncludeFile)
include(CheckSymbolExists)

find_package(Threads REQUIRED)
set(CMAKE_REQUIRED_LIBRARIES Threads::Threads)
set(CMAKE_REQUIRED_DEFINITIONS)

if(UNIX)
  set(CMAKE_REQUIRED_DEFINITIONS
    -D_DEFAULT_SOURCE
    -D_POSIX_C_SOURCE=200112L)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  list(APPEND CMAKE_REQUIRED_DEFINITIONS
    -D_GNU_SOURCE)
endif()

check_include_file("dlfcn.h" HAVE_DLFCN_H)

# Define to 1 if you have the `ncurses' library (-lncurses).
#cmakedefine HAVE_LIBNCURSES @HAVE_LIBNCURSES@
set(HAVE_LIBNCURSES)

check_include_file("sgtty.h" HAVE_SGTTY_H)
check_symbol_exists(strdup "string.h" HAVE_STRDUP)
check_include_file("strings.h" HAVE_STRINGS_H)
check_symbol_exists(strrchr "string.h" HAVE_STRRCHR)
check_include_file("sys/dir.h" HAVE_SYS_DIR_H)
check_include_file("sys/stat.h" HAVE_SYS_STAT_H)
check_include_file("sys/types.h" HAVE_SYS_TYPES_H)
check_symbol_exists(tcgetattr "termios.h" HAVE_TCGETATTR)
check_include_file("termcap.h" HAVE_TERMCAP_H)
check_include_file("termios.h" HAVE_TERMIOS_H)
check_include_file("termio.h" HAVE_TERMIO_H)
check_include_file("unistd.h" HAVE_UNISTD_H)

configure_file(config.h.in ${CMAKE_CURRENT_BINARY_DIR}/src/config.h LF)

# Headers
set(headers
  src/src/editline.h
  src/src/unix.h)

# Sources
set(sources
  src/src/editline.c
  src/src/complete.c
  src/src/sysunix.c)

# Libraries
add_library(edit STATIC ${headers} ${sources})
target_compile_features(edit PRIVATE c_std_11)
target_compile_definitions(edit PRIVATE ${CMAKE_REQUIRED_DEFINITIONS})
target_link_libraries(edit PRIVATE ${CMAKE_REQUIRED_LIBRARIES})

target_include_directories(edit PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/src PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/src>
  $<INSTALL_INTERFACE:include>)

# Install
install(TARGETS edit
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/include/editline.h
  DESTINATION include RENAME readline.h)

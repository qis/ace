# https://cmake.org/cmake/help/v3.20/module/FindThreads.html
#
#   find_package(Threads REQUIRED)
#   target_link_libraries(main PRIVATE Threads::Threads)
#

cmake_policy(PUSH)
cmake_policy(VERSION 3.20)

set(CMAKE_HP_PTHREADS_INIT OFF)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(CMAKE_THREAD_LIBS_INIT "")
  set(CMAKE_USE_PTHREADS_INIT 0)
  set(CMAKE_USE_WIN32_THREADS_INIT 1)
else()
  set(CMAKE_THREAD_LIBS_INIT "-pthread")
  set(CMAKE_USE_PTHREADS_INIT 1)
  set(CMAKE_USE_WIN32_THREADS_INIT 0)
endif()

if(NOT TARGET Threads::Threads)
  add_library(Threads::Threads INTERFACE IMPORTED)
  if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set_target_properties(Threads::Threads PROPERTIES
      INTERFACE_COMPILE_OPTIONS "\$<IF:\$<COMPILE_LANG_AND_ID:CUDA,NVIDIA>,SHELL:-Xcompiler -pthread,-pthread>"
      INTERFACE_LINK_OPTIONS "${CMAKE_THREAD_LIBS_INIT}")
  endif()
endif()

set(Threads_FOUND TRUE)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Threads DEFAULT_MSG Threads_FOUND)

cmake_policy(POP)

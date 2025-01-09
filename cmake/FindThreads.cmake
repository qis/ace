set(Threads_FOUND TRUE)
set(CMAKE_THREAD_LIBS_INIT "-pthread")

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(CMAKE_USE_WIN32_THREADS_INIT 1)
else()
  set(CMAKE_USE_PTHREADS_INIT 1)
endif()

if(NOT TARGET Threads::Threads)
  add_library(Threads::Threads INTERFACE IMPORTED)
  set_property(TARGET Threads::Threads PROPERTY INTERFACE_COMPILE_OPTIONS
    "$<$<COMPILE_LANG_AND_ID:CUDA,NVIDIA>:SHELL:-Xcompiler -pthread>"
    "$<$<AND:$<NOT:$<COMPILE_LANG_AND_ID:CUDA,NVIDIA>>,$<NOT:$<COMPILE_LANGUAGE:Swift>>>:-pthread>")
  set_property(TARGET Threads::Threads PROPERTY INTERFACE_LINK_LIBRARIES "${CMAKE_THREAD_LIBS_INIT}")
endif()

if(CMAKE_CXX_COMPILER_ID AND CMAKE_CXX_MODULE_STD AND NOT CMAKE_TRY_COMPILE)
  if(NOT TARGET "__CMAKE::CXX23")
    if(NOT TARGET "__cmake_cxx23")
      add_library(__cmake_cxx23 STATIC)
      target_sources(__cmake_cxx23 INTERFACE
        "$<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,STATIC_LIBRARY>:$<TARGET_OBJECTS:__cmake_cxx23>>")
      set_property(TARGET __cmake_cxx23 PROPERTY EXCLUDE_FROM_ALL 1)
      set_property(TARGET __cmake_cxx23 PROPERTY CXX_SCAN_FOR_MODULES 1)
      set_property(TARGET __cmake_cxx23 PROPERTY CXX_MODULE_STD 0)
      target_compile_features(__cmake_cxx23 PUBLIC cxx_std_23)
      target_compile_options(__cmake_cxx23 PRIVATE -Wno-reserved-module-identifier)
      target_include_directories(__cmake_cxx23 PRIVATE "${ACE}/share/libc++/v1")
      target_sources(__cmake_cxx23 PUBLIC
        FILE_SET std TYPE CXX_MODULES
        BASE_DIRS "${ACE}/share/libc++/v1"
        FILES "${ACE}/share/libc++/v1/std.cppm"
              "${ACE}/share/libc++/v1/std.compat.cppm")
    endif()
    add_library(__CMAKE::CXX23 ALIAS __cmake_cxx23)
  endif()
  if(NOT TARGET "__CMAKE::CXX26")
    if(NOT TARGET "__cmake_cxx26")
      add_library(__cmake_cxx26 STATIC)
      target_sources(__cmake_cxx26 INTERFACE
        "$<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,STATIC_LIBRARY>:$<TARGET_OBJECTS:__cmake_cxx26>>")
      set_property(TARGET __cmake_cxx26 PROPERTY EXCLUDE_FROM_ALL 1)
      set_property(TARGET __cmake_cxx26 PROPERTY CXX_SCAN_FOR_MODULES 1)
      set_property(TARGET __cmake_cxx26 PROPERTY CXX_MODULE_STD 0)
      target_compile_features(__cmake_cxx26 PUBLIC cxx_std_26)
      target_compile_options(__cmake_cxx26 PRIVATE -Wno-reserved-module-identifier)
      target_include_directories(__cmake_cxx26 PRIVATE "${ACE}/share/libc++/v1")
      target_sources(__cmake_cxx26 PUBLIC FILE_SET std TYPE CXX_MODULES
        BASE_DIRS "${ACE}/share/libc++/v1"
        FILES "${ACE}/share/libc++/v1/std.cppm"
              "${ACE}/share/libc++/v1/std.compat.cppm")
    endif()
    add_library(__CMAKE::CXX26 ALIAS __cmake_cxx26)
  endif()
endif()

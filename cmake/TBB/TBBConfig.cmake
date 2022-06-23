# https://github.com/oneapi-src/oneTBB
#
#   find_package(TBB REQUIRED)
#   target_link_libraries(main PRIVATE TBB::tbb TBB::tbbmalloc)
#

cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

enable_language(CXX)

set(TBB_VERSION_STRING ${TBB_VERSION})
set(TBB_INCLUDE_DIRS)

set(TBB_LIBRARIES)
set(TBB_DEFINITIONS "\$<\$<CONFIG:Debug>:TBB_USE_DEBUG>")

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  list(APPEND TBB_DEFINITIONS "__TBB_NO_IMPLICIT_LINKAGE")
endif()

include(LLVM/ImportLibrary)
include(CMakeFindDependencyMacro)
find_dependency(Threads REQUIRED)

foreach(c tbb tbbmalloc)
  string(TOUPPER "${c}" cu)

  llvm_import_library(TBB ${c} CXX ${c} ${c} ${TBB_FIND_REQUIRED})

  if(TARGET TBB::${c})
    set_target_properties(TBB::${c}_shared TBB::${c}_static PROPERTIES
      INTERFACE_COMPILE_DEFINITIONS "${TBB_DEFINITIONS}"
      INTERFACE_LINK_LIBRARIES "Threads::Threads")

    list(APPEND TBB_LIBRARIES TBB::${c})
    set(TBB_${cu}_LIBRARY TBB::${c})
    set(TBB_${cu}_FOUND ON)
  endif()
endforeach()

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

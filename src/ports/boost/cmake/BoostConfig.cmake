# Boost
# https://cmake.org/cmake/help/latest/module/FindBoost.html
#
#   find_package(Boost 1.79.0 REQUIRED)
#   find_package(Boost 1.79.0 REQUIRED COMPONENTS ALL)
#   find_package(Boost 1.79.0 REQUIRED COMPONENTS headers chrono ...)
#
#   target_link_libraries(main PRIVATE
#     optimized Boost::stacktrace_noop
#     ${Boost_LIBRARIES})
# 
#   if(WIN32 AND TARGET Boost::stacktrace_windbg)
#     target_link_libraries(main PRIVATE
#       debug Boost::stacktrace_windbg)
#   elseif(TARGET Boost::stacktrace_backtrace)
#     target_link_libraries(main PRIVATE
#       debug Boost::stacktrace_backtrace)
#   elseif(TARGET Boost::stacktrace_basic)
#     target_link_libraries(main PRIVATE
#       debug Boost::stacktrace_basic)
#   else()
#     target_link_libraries(main PRIVATE
#       debug Boost::stacktrace_noop)
#   endif()
#
#   target_compile_definitions(main PRIVATE
#     BOOST_MATH_STANDALONE=1
#     BOOST_MP_STANDALONE=1)
#
cmake_policy(PUSH)
cmake_policy(VERSION 3.20)
set(CMAKE_IMPORT_FILE_VERSION 1)

enable_language(CXX)

set(Boost_VERSION_STRING ${Boost_VERSION})
set(Boost_VERSION_COUNT 3)

set(Boost_INCLUDE_DIRS)
set(Boost_LIBRARY_DIRS)
set(Boost_LIBRARIES Boost::headers)

if(NOT TARGET Boost::boost)
  add_library(Boost::boost INTERFACE IMPORTED)
endif()

if(NOT TARGET Boost::headers)
  add_library(Boost::headers ALIAS Boost::boost)
endif()

if(NOT TARGET Boost::diagnostic_definitions)
  add_library(Boost::diagnostic_definitions INTERFACE IMPORTED)
  set_target_properties(Boost::diagnostic_definitions PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "BOOST_LIB_DIAGNOSTIC")
endif()

if(NOT TARGET Boost::disable_autolinking)
  add_library(Boost::disable_autolinking INTERFACE IMPORTED)
  if(MSVC)
    set_target_properties(Boost::disable_autolinking PROPERTIES
      INTERFACE_COMPILE_DEFINITIONS "BOOST_ALL_NO_LIB")
  endif()
endif()

if(NOT TARGET Boost::dynamic_linking)
  add_library(Boost::dynamic_linking INTERFACE IMPORTED)
  if(MSVC)
    set_target_properties(Boost::dynamic_linking PROPERTIES
      INTERFACE_COMPILE_DEFINITIONS "BOOST_ALL_DYN_LINK")
  endif()
endif()

if(NOT Boost_FIND_COMPONENTS OR "${Boost_FIND_COMPONENTS}" STREQUAL "ALL")
  set(Boost_FIND_COMPONENTS
    atomic
    chrono
    container
    context
    contract
    coroutine
    date_time
    fiber
    fiber_numa
    filesystem
    graph
    iostreams
    json
    locale
    log
    log_setup
    nowide
    prg_exec_monitor
    program_options
    random
    serialization
    stacktrace_noop
    stacktrace_basic
    thread
    timer
    type_erasure
    unit_test_framework
    wave
    wserialization)
  if(WIN32)
    list(APPEND Boost_FIND_COMPONENTS stacktrace_windbg)
  else()
    list(APPEND Boost_FIND_COMPONENTS stacktrace_backtrace)
  endif()
endif()

if("contract" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "thread")
endif()

if("fiber_numa" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "fiber;filesystem;container")
endif()

if("fiber" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "context")
endif()

if("graph" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "random;serialization")
endif()

if("iostreams" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "random")
endif()

if("json" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "container")
endif()

if("locale" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "thread")
endif()

if("log_setup" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "log;serialization")
endif()

if("log" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "filesystem;random;thread;coroutine;context")
endif()

if("prg_exec_monitor" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "container")
endif()

if("program_options" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "container")
endif()

if("timer" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "chrono")
endif()

if("type_erasure" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "thread")
endif()

if("unit_test_framework" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "container")
endif()

if("wave" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "filesystem;serialization")
endif()

if("filesystem" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "atomic")
endif()

if("wserialization" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "serialization")
endif()

if("serialization" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "thread")
endif()

if("thread" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "atomic;chrono;date_time;container")
endif()

if("date_time" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "container")
endif()

if("coroutine" IN_LIST Boost_FIND_COMPONENTS)
  list(APPEND Boost_FIND_COMPONENTS "context")
endif()

list(REMOVE_DUPLICATES Boost_FIND_COMPONENTS)

include(AceImportLibrary)

foreach(c ${Boost_FIND_COMPONENTS})
  set(Boost_${cu}_FOUND OFF)
  string(TOUPPER "${c}" cu)

  ace_import_library(Boost::${c} CXX NAMES boost_${c}
    FOUND Boost_${cu}_FOUND REQUIRED ${Boost_FIND_REQUIRED_${c}})

  if(Boost_${cu}_FOUND)
    set(Boost_${cu}_LIBRARY Boost::${c})
    if(NOT c MATCHES "^stacktrace" AND NOT c STREQUAL "prg_exec_monitor" AND NOT c STREQUAL "unit_test_framework")
      list(APPEND Boost_LIBRARIES Boost::${c})
    endif()
  endif()
endforeach()

include(CMakeFindDependencyMacro)

if(TARGET Boost::contract_shared)
  set_target_properties(Boost::contract_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::thread_shared")
endif()

if(TARGET Boost::contract_static)
  set_target_properties(Boost::contract_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::thread_static")
endif()

if(TARGET Boost::coroutine_shared)
  set_target_properties(Boost::coroutine_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::context_shared")
endif()

if(TARGET Boost::coroutine_static)
  set_target_properties(Boost::coroutine_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::context_static")
endif()

if(TARGET Boost::date_time_shared)
  set_target_properties(Boost::date_time_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::container_shared")
endif()

if(TARGET Boost::date_time_static)
  set_target_properties(Boost::date_time_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::container_static")
endif()

if(TARGET Boost::fiber_shared)
  set_target_properties(Boost::fiber_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::context_shared")
endif()

if(TARGET Boost::fiber_static)
  set_target_properties(Boost::fiber_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::context_static")
endif()

if(TARGET Boost::fiber_numa_shared)
  set_target_properties(Boost::fiber_numa_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::fiber_shared;Boost::filesystem_shared;Boost::container_shared")
endif()

if(TARGET Boost::fiber_numa_static)
  set_target_properties(Boost::fiber_numa_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::fiber_static;Boost::filesystem_static;Boost::container_static")
endif()

if(TARGET Boost::filesystem_shared)
  set_target_properties(Boost::filesystem_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::atomic_shared")
endif()

if(TARGET Boost::filesystem_static)
  set_target_properties(Boost::filesystem_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::atomic_static")
endif()

if(TARGET Boost::graph_shared)
  set_target_properties(Boost::graph_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::random_shared;Boost::serialization_shared")
endif()

if(TARGET Boost::graph_static)
  set_target_properties(Boost::graph_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::random_static;Boost::serialization_static")
endif()

if(TARGET Boost::iostreams_shared)
  if(NOT TARGET ZLIB::ZLIB)
    find_dependency(ZLIB REQUIRED)
  endif()
  if(NOT TARGET BZip2::BZip2)
    find_dependency(BZip2 REQUIRED)
  endif()
  if(NOT TARGET LibLZMA::LibLZMA)
    find_dependency(LibLZMA REQUIRED)
  endif()
  if(NOT TARGET zstd::zstd)
    find_dependency(zstd REQUIRED)
  endif()
  set_target_properties(Boost::iostreams_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::random_shared;ZLIB::ZLIB;BZip2::BZip2;LibLZMA::LibLZMA;zstd::zstd")
endif()

if(TARGET Boost::iostreams_static)
  if(NOT TARGET ZLIB::ZLIB)
    find_dependency(ZLIB REQUIRED)
  endif()
  if(NOT TARGET BZip2::BZip2)
    find_dependency(BZip2 REQUIRED)
  endif()
  if(NOT TARGET LibLZMA::LibLZMA)
    find_dependency(LibLZMA REQUIRED)
  endif()
  if(NOT TARGET zstd::zstd)
    find_dependency(zstd REQUIRED)
  endif()
  set_target_properties(Boost::iostreams_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::random_static;ZLIB::ZLIB;BZip2::BZip2;LibLZMA::LibLZMA;zstd::zstd")
endif()

if(TARGET Boost::json_shared)
  set_target_properties(Boost::json_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::container_shared")
endif()

if(TARGET Boost::json_static)
  set_target_properties(Boost::json_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::container_static")
endif()

if(TARGET Boost::locale_shared)
  if(NOT TARGET ICU::i18n)
    find_dependency(ICU REQUIRED COMPONENTS data uc i18n)
  endif()
  set_target_properties(Boost::locale_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::thread_shared;ICU::i18n;ICU::uc;ICU::data")
endif()

if(TARGET Boost::locale_static)
  if(NOT TARGET ICU::i18n)
    find_dependency(ICU REQUIRED COMPONENTS data uc i18n)
  endif()
  set_target_properties(Boost::locale_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::thread_static;ICU::i18n;ICU::uc;ICU::data")
endif()

if(TARGET Boost::log_shared)
  set_target_properties(Boost::log_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::filesystem_shared;Boost::random_shared;Boost::thread_shared;Boost::coroutine_shared;Boost::context_shared")
endif()

if(TARGET Boost::log_static)
  set_target_properties(Boost::log_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::filesystem_static;Boost::random_static;Boost::thread_static;Boost::coroutine_static;Boost::context_static")
endif()

if(TARGET Boost::log_setup_shared)
  set_target_properties(Boost::log_setup_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::log_shared;Boost::serialization_shared")
endif()

if(TARGET Boost::log_setup_static)
  set_target_properties(Boost::log_setup_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::log_static;Boost::serialization_static")
endif()

if(TARGET Boost::prg_exec_monitor_shared)
  set_target_properties(Boost::prg_exec_monitor_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::container_shared")
endif()

if(TARGET Boost::prg_exec_monitor_static)
  set_target_properties(Boost::prg_exec_monitor_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::container_static")
endif()

if(TARGET Boost::program_options_shared)
  set_target_properties(Boost::program_options_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::container_shared")
endif()

if(TARGET Boost::program_options_static)
  set_target_properties(Boost::program_options_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::container_static")
endif()

if(TARGET Boost::serialization_shared)
  set_target_properties(Boost::serialization_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::thread_shared")
endif()

if(TARGET Boost::serialization_static)
  set_target_properties(Boost::serialization_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::thread_static")
endif()

if(TARGET Boost::stacktrace_noop_shared)
  set_target_properties(Boost::stacktrace_noop_shared PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "BOOST_STACKTRACE_LINK=1")
endif()

if(TARGET Boost::stacktrace_noop_static)
  set_target_properties(Boost::stacktrace_noop_static PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "BOOST_STACKTRACE_LINK=1")
endif()

if(TARGET Boost::stacktrace_basic_shared)
  set_target_properties(Boost::stacktrace_basic_shared PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "BOOST_STACKTRACE_LINK=1")
endif()

if(TARGET Boost::stacktrace_basic_static)
  set_target_properties(Boost::stacktrace_basic_static PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "BOOST_STACKTRACE_LINK=1")
endif()

if(TARGET Boost::stacktrace_backtrace_shared)
  if(NOT TARGET Backtrace::Backtrace)
    find_dependency(Backtrace REQUIRED)
  endif()
  set_target_properties(Boost::stacktrace_backtrace_shared PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "BOOST_STACKTRACE_LINK=1"
    INTERFACE_LINK_LIBRARIES "Backtrace::Backtrace")
endif()

if(TARGET Boost::stacktrace_backtrace_static)
  if(NOT TARGET Backtrace::Backtrace)
    find_dependency(Backtrace REQUIRED)
  endif()
  set_target_properties(Boost::stacktrace_backtrace_static PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "BOOST_STACKTRACE_LINK=1"
    INTERFACE_LINK_LIBRARIES "Backtrace::Backtrace")
endif()

if(TARGET Boost::stacktrace_windbg_shared)
  set_target_properties(Boost::stacktrace_windbg_shared PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "BOOST_STACKTRACE_LINK=1")
endif()

if(TARGET Boost::stacktrace_windbg_static)
  set_target_properties(Boost::stacktrace_windbg_static PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "BOOST_STACKTRACE_LINK=1")
endif()

if(TARGET Boost::thread_shared)
  if(NOT TARGET Threads::Threads)
    find_dependency(Threads REQUIRED)
  endif()
  set_target_properties(Boost::thread_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::atomic_shared;Boost::chrono_shared;Boost::date_time_shared;Boost::container_shared;Threads::Threads")
endif()

if(TARGET Boost::thread_static)
  if(NOT TARGET Threads::Threads)
    find_dependency(Threads REQUIRED)
  endif()
  set_target_properties(Boost::thread_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::atomic_static;Boost::chrono_static;Boost::date_time_static;Boost::container_static;Threads::Threads")
endif()

if(TARGET Boost::timer_shared)
  set_target_properties(Boost::timer_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::chrono_shared")
endif()

if(TARGET Boost::timer_static)
  set_target_properties(Boost::timer_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::chrono_static")
endif()

if(TARGET Boost::type_erasure_shared)
  set_target_properties(Boost::type_erasure_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::thread_shared")
endif()

if(TARGET Boost::type_erasure_static)
  set_target_properties(Boost::type_erasure_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::thread_static")
endif()

if(TARGET Boost::unit_test_framework_shared)
  set_target_properties(Boost::unit_test_framework_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::container_shared")
endif()

if(TARGET Boost::unit_test_framework_static)
  set_target_properties(Boost::unit_test_framework_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::container_static")
endif()

if(TARGET Boost::wave_shared)
  set_target_properties(Boost::wave_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::filesystem_shared;Boost::serialization_shared")
endif()

if(TARGET Boost::wave_static)
  set_target_properties(Boost::wave_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::filesystem_static;Boost::serialization_static")
endif()

if(TARGET Boost::wserialization_shared)
  set_target_properties(Boost::wserialization_shared PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::serialization_shared")
endif()

if(TARGET Boost::wserialization_static)
  set_target_properties(Boost::wserialization_static PROPERTIES
    INTERFACE_LINK_LIBRARIES "Boost::serialization_static")
endif()

set(Boost_MAJOR_VERSION ${Boost_VERSION_MAJOR})
set(Boost_MINOR_VERSION ${Boost_VERSION_MINOR})
set(Boost_SUBMINOR_VERSION ${Boost_VERSION_PATCH})
set(Boost_VERSION_MACRO)

set(Boost_INCLUDE_DIR "${Boost_INCLUDE_DIRS}" CACHE STRING "")
set(Boost_LIBRARY_DIR_DEBUG "" CACHE STRING "")
set(Boost_LIBRARY_DIR_RELEASE "" CACHE STRING "")

set(Boost_LIB_DIAGNOSTIC_DEFINITIONS)
set(Boost_LIB_VERSION)

set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

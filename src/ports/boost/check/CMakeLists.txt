cmake_minimum_required(VERSION 3.22 FATAL_ERROR)
project(main VERSION 0.1.0 LANGUAGES CXX)

add_executable(main main.cpp main.manifest)
target_compile_features(main PRIVATE cxx_std_23)

if(WIN32)
  target_compile_definitions(main PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN)
endif()

find_package(Boost 1.79.0 REQUIRED)
target_link_libraries(main PRIVATE
  optimized Boost::stacktrace_noop
  ${Boost_LIBRARIES})

if(WIN32 AND TARGET Boost::stacktrace_windbg)
  target_link_libraries(main PRIVATE
    debug Boost::stacktrace_windbg)
elseif(TARGET Boost::stacktrace_backtrace)
  target_link_libraries(main PRIVATE
    debug Boost::stacktrace_backtrace)
elseif(TARGET Boost::stacktrace_basic)
  target_link_libraries(main PRIVATE
    debug Boost::stacktrace_basic)
else()
  target_link_libraries(main PRIVATE
    debug Boost::stacktrace_noop)
endif()

target_compile_definitions(main PRIVATE
  BOOST_MATH_STANDALONE=1
  BOOST_MP_STANDALONE=1)

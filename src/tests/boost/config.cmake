find_package(Boost REQUIRED)
target_link_libraries(main PRIVATE Boost::headers)

find_package(Boost REQUIRED COMPONENTS iostreams stacktrace_noop stacktrace_backtrace)
target_link_libraries(main PRIVATE
  Boost::iostreams
  optimized Boost::stacktrace_noop
  debug Boost::stacktrace_backtrace)

target_compile_definitions(main PRIVATE
  BOOST_MATH_STANDALONE=1
  BOOST_MP_STANDALONE=1)

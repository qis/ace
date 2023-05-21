find_package(TBB CONFIG REQUIRED)
target_link_libraries(main PRIVATE TBB::tbb TBB::tbbmalloc)

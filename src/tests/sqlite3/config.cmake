find_package(SQLite3 REQUIRED)
target_link_libraries(main PRIVATE SQLite::SQLite3)

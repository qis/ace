cmake_minimum_required(VERSION 3.28 FATAL_ERROR)
project(ace-test VERSION 0.1.0 LANGUAGES C CXX)

add_executable(main main.cpp main.manifest)
target_compile_features(main PRIVATE cxx_std_26)

find_package(SQLite3 REQUIRED)
target_link_libraries(main PRIVATE SQLite::SQLite3)

# find_package(unofficial-sqlite3 CONFIG REQUIRED)
# target_link_libraries(main PRIVATE unofficial::sqlite3::sqlite3)

find_program(SQLITE3 sqlite3 REQUIRED)

find_package(LuaJIT REQUIRED)
target_link_libraries(main PRIVATE LuaJIT::LuaJIT)

file(COPY ${LUAJIT_JIT_DIR} DESTINATION ${CMAKE_BINARY_DIR})

find_program(LUAJIT_EXECUTABLE luajit REQUIRED)
message(STATUS "Found luajit: ${LUAJIT_EXECUTABLE}")

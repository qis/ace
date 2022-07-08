#include <lua.hpp>
#include <iostream>
#include <cstdlib>

int main(int argc, char *argv[]) {
  const auto state = luaL_newstate();
  if (!state) {
    std::cerr << "error: luaL_newstate return null" << std::endl;
    return EXIT_FAILURE;
  }
  lua_close(state);
  std::cout << "lua: " << LUA_VERSION << std::endl;
  return EXIT_SUCCESS;
}

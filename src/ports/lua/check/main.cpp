#include <lua.hpp>
#include <iostream>
#include <cstdlib>

int main(int argc, char *argv[]) {
  const auto state = luaL_newstate();
  if (!state) {
    std::cerr << "error: luaL_newstate return null" << std::endl;
    return EXIT_FAILURE;
  }
  int ret = EXIT_SUCCESS;
  if (const auto version = lua_version(state)) {
    std::cout << "lua: " << *version << std::endl;
  } else {
    std::cerr << "error: lua_version returned null" << std::endl;
    ret = EXIT_FAILURE;
  }
  lua_close(state);
  return ret;
}

#include <lua.hpp>
#include <iostream>
#include <string>
#include <cstdlib>

static int wrap_exceptions(lua_State* state, lua_CFunction function)
{
  try {
    return function(state);
  }
  catch (const char* e) {
    lua_pushstring(state, e);
  }
  catch (std::exception& e) {
    lua_pushstring(state, e.what());
  }
  catch (...) {
    lua_pushliteral(state, "caught (...)");
  }
  return lua_error(state);
}

int main(int argc, char* argv[])
{
  const auto state = luaL_newstate();
  if (!state) {
    std::cerr << "error: luaL_newstate return null" << std::endl;
    return EXIT_FAILURE;
  }

  lua_pushlightuserdata(state, (void*)wrap_exceptions);
  if (!luaJIT_setmode(state, -1, LUAJIT_MODE_WRAPCFUNC | LUAJIT_MODE_ON)) {
    std::cerr << "error: could not set luajit mode" << std::endl;
    return EXIT_FAILURE;
  }
  lua_pop(state, 1);

  std::string script = R"script(
    -- error("test")
    io.write(jit.version)
  )script";

  luaL_openlibs(state);
  if (const auto ec = luaL_loadbuffer(state, script.data(), script.size(), "script")) {
    std::cerr << "error: luaL_loadbuffer failed: " << lua_tostring(state, -1) << std::endl;
    return EXIT_FAILURE;
  }

  std::cout << "lua: " << std::flush;
  if (const auto ec = lua_pcall(state, 0, 0, 0)) {
    std::cout << "error" << std::endl;
    std::cerr << "luaL_pcall returned " << ec << std::endl;
    std::cerr << lua_tostring(state, -1) << std::endl;
    return EXIT_FAILURE;
  }
  std::cout << " (" << LUA_VERSION << ')' << std::endl;

  lua_close(state);
  return EXIT_SUCCESS;
}

#define DOCTEST_CONFIG_IMPLEMENT
#include "doctest/doctest.h"
#include <ace/random.hpp>

TEST_CASE("ace::random")
{
  REQUIRE(!ace::random().empty());
}

int main(int argc, char* argv[])
{
  doctest::Context context;
  context.applyCommandLine(argc, argv);
  context.setOption("no-intro", 1);
  return context.run();
}

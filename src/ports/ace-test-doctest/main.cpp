#define DOCTEST_CONFIG_IMPLEMENT
#include "doctest/doctest.h"
#include <chrono>
#include <format>

TEST_CASE("random")
{
  const auto tp = std::chrono::system_clock::now();
  const auto str = std::format("{}", tp.time_since_epoch().count());
  REQUIRE(!str.empty());
}

int main(int argc, char* argv[])
{
  doctest::Context context;
  context.applyCommandLine(argc, argv);
  context.setOption("no-version", 1);
  return context.run();
}

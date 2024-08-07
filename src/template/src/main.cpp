#include <ace/random.hpp>
#include <print>
#include <cstdio>
#include <cstdlib>

int main()
{
  try {
    std::println("{}", ace::random());
  }
  catch (const std::exception& e) {
    std::println(stderr, "error: {}", e.what());
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}

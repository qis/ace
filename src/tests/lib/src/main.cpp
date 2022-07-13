#include "print.hpp"
#include <boost/iterator/counting_iterator.hpp>
#include <oneapi/tbb.h>
#include <algorithm>
#include <charconv>
#include <chrono>
#include <execution>
#include <iostream>
#include <string_view>
#include <thread>
#include <cstdlib>

auto test(std::size_t size)
{
  const auto tp0 = std::chrono::steady_clock::now();
  tbb::parallel_for(
    tbb::blocked_range<std::size_t>{ 0, size },
    [&](tbb::blocked_range<std::size_t> range) {
    for (auto i = range.begin(), end = range.end(); i < end; i++) {
      std::this_thread::sleep_for(std::chrono::milliseconds{ 10 });
    }
    });
  return std::chrono::steady_clock::now() - tp0;
}

template <class Execution>
auto test(Execution&& execution, std::size_t size)
{
  const auto tp0 = std::chrono::steady_clock::now();
  const auto beg = boost::counting_iterator{ 0uz };
  const auto end = boost::counting_iterator{ size };
  std::for_each(std::forward<Execution>(execution), beg, end, [&](std::size_t i) {
    std::this_thread::sleep_for(std::chrono::milliseconds{ 10 });
  });
  return std::chrono::steady_clock::now() - tp0;
}

int main(int argc, char* argv[])
{
  if (argc < 2) {
    std::cerr << "error: missing size parameter" << std::endl;
    return EXIT_FAILURE;
  }

  std::size_t size = 0;
  std::string_view arg{ argv[1] };
  auto [ptr, ec]{ std::from_chars(arg.data(), arg.data() + arg.size(), size) };
  if (ec == std::errc::invalid_argument) {
    std::cerr << "error: size is not a number" << std::endl;
    return EXIT_FAILURE;
  } else if (ec == std::errc::result_out_of_range) {
    std::cerr << "error: size is out of range" << std::endl;
    return EXIT_FAILURE;
  } else if (size == 0 || size % 16 != 0) {
    std::cerr << "error: size is not a multiple of 16" << std::endl;
    return EXIT_FAILURE;
  }

  print(test(std::execution::seq, size), "seq");
  print(test(std::execution::par, size), "par");
  print(test(std::execution::par_unseq, size), "par_unseq");
  print(test(size), "tbb");

  return EXIT_SUCCESS;
}

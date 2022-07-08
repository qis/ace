#include <boost/stacktrace.hpp>
#include <boost/version.hpp>
#include <iostream>
#include <cstdio>
#include <cstdlib>

void inner() {
  std::cout << boost::stacktrace::stacktrace();
  std::cout.flush();
}

void outer() {
  inner();
}

int main(int argc, char* argv[]) {
  outer();

  const auto major = BOOST_VERSION / 100000;
  const auto minor = BOOST_VERSION / 100 % 1000;
  const auto patch = BOOST_VERSION % 100;

  std::cout << "boost: "
    << major << '.'
    << minor << '.'
    << patch << std::endl;

  return EXIT_SUCCESS;
}

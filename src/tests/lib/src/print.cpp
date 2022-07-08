#include "print.hpp"
#include <iostream>

void print(std::chrono::steady_clock::duration duration, std::string_view comment) {
  const auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(duration);
  std::cout << ms.count() << " ms [" << comment << "]" << std::endl;
}

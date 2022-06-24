#include <zlib.h>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[]) {
  std::cout << "zlib: " << zlibVersion() << std::endl;
  return EXIT_SUCCESS;
}

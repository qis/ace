#include <zstd.h>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[]) {
  std::cout << "zstd: " << ZSTD_versionString() << std::endl;
  return EXIT_SUCCESS;
}

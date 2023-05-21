#include <lz4.h>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[])
{
  std::cout << "lz4: " << LZ4_versionString() << std::endl;
  return EXIT_SUCCESS;
}

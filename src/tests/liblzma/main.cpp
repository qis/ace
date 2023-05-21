#include <lzma.h>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[])
{
  std::cout << "liblzma: " << lzma_version_string() << std::endl;
  return EXIT_SUCCESS;
}

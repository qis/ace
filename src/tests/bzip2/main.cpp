#include <bzlib.h>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[])
{
  std::cout << "bzip2: " << BZ2_bzlibVersion() << std::endl;
  return EXIT_SUCCESS;
}

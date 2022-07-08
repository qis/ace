#include <png.h>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[]) {
  std::cout << "png: " << png_access_version_number() << std::endl;
  return EXIT_SUCCESS;
}

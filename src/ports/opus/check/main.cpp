#include <opus/opus.h>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[]) {
  std::cout << "opus: " << opus_get_version_string() << std::endl;
  return EXIT_SUCCESS;
}

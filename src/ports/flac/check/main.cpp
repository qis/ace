#include <FLAC/all.h>
#include <FLAC++/all.h>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[]) {
  FLAC::Metadata::Application application;
  std::cout << "flac: " << FLAC__VERSION_STRING << std::endl;
  return EXIT_SUCCESS;
}

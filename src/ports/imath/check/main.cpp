#include <ImathRandom.h>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[]) {
  (void)Imath::drand48();
  std::cout << "imath: " << IMATH_VERSION_STRING << std::endl;
  return EXIT_SUCCESS;
}

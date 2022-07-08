#include <ogg/ogg.h>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[]) {
  oggpack_buffer buffer{};
  oggpack_writeinit(&buffer);
  oggpack_writeclear(&buffer);
  std::cout << "ogg: 1.3.5" << std::endl;
  return EXIT_SUCCESS;
}

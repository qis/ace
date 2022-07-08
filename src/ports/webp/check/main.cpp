#include <webp/decode.h>
#include <webp/encode.h>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[]) {
  std::cout << "webp: "
    << WebPGetDecoderVersion() << " / "
    << WebPGetEncoderVersion() << std::endl;
  return EXIT_SUCCESS;
}

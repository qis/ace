#include <jpeglib.h>
#include <turbojpeg.h>
#include <iostream>
#include <cstdlib>

#define STRINGIFY_IMPL(v) #v
#define STRINGIFY(v) STRINGIFY_IMPL(v)

int main(int argc, char* argv[]) {
  struct jpeg_error_mgr jerr{};
  jpeg_std_error(&jerr);

  const auto handle = tjInitTransform();
  tjDestroy(handle);

  std::cout << "jpeg: " << STRINGIFY(LIBJPEG_TURBO_VERSION) << std::endl;
  return EXIT_SUCCESS;
}

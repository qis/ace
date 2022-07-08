#include <aom/aom.h>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[]) {
  const auto major = aom_codec_version_major();
  const auto minor = aom_codec_version_minor();
  const auto patch = aom_codec_version_patch();

  std::cout << "aom: "
    << major << '.'
    << minor << '.'
    << patch << std::endl;

  return EXIT_SUCCESS;
}

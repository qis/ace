#include <tiffio.h>
#include <tiffio.hxx>
#include <iostream>
#include <sstream>
#include <string_view>
#include <cstdlib>

int main(int argc, char* argv[]) {
  std::ostringstream oss;
  if (const auto tiff = TIFFStreamOpen("", &oss)) {
    TIFFClose(tiff);
  }
  auto version = std::string_view{ TIFFGetVersion() };
  if (const auto pos = version.find('\n')) {
    version = version.substr(0, pos);
  }
  if (const auto pos = version.find("Version ")) {
    version = version.substr(pos + 8);
  }
  std::cout << "tiff: " << version << std::endl;
  return EXIT_SUCCESS;
}

#include <openexr.h>
#include <iostream>
#include <string_view>
#include <cstdlib>

int main(int argc, char* argv[]) {
  int major = 0;
  int minor = 0;
  int patch = 0;
  const char* extra = nullptr;
  exr_get_library_version(&major, &minor, &patch, &extra);
  std::cout << "exr: " << major << '.' << minor << '.' << patch;
  if (extra && !std::string_view{ extra }.empty()) {
    std::cout << " (" << extra << ')';
  }
  std::cout << std::endl;
  return EXIT_SUCCESS;
}

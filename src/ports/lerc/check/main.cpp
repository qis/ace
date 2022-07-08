#include <Lerc_c_api.h>
#include <iostream>
#include <vector>
#include <cstdlib>

int main(int argc, char* argv[]) {
  int dim = 3;
  int col = 2;
  int row = 2;
  int bands = 1;
  int masks = 0;
  unsigned int size = 0;
  std::vector<char> data;
  data.resize(dim * col * row * bands);
  const auto status = lerc_computeCompressedSize(
    data.data(), 0, dim, col, row, bands, masks, nullptr, 1.0, &size);
  if (status != 0) {
    std::cout << "lerc_computeCompressedSize returned " << status << std::endl;
    return EXIT_FAILURE;
  }
  std::cout << "lerc: "
    << LERC_VERSION_MAJOR << '.'
    << LERC_VERSION_MINOR << '.'
    << LERC_VERSION_PATCH << std::endl;
  return EXIT_SUCCESS;
}

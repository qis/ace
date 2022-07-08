#include <vulkan/vulkan.hpp>
#include <iostream>
#include <cstdlib>

static_assert(VULKAN_HPP_CPP_VERSION >= 20);

int main(int argc, char* argv[]) {
  std::cout << "vulkan: "
    << VK_VERSION_MAJOR(VK_HEADER_VERSION_COMPLETE) << '.'
    << VK_VERSION_MINOR(VK_HEADER_VERSION_COMPLETE) << '.'
    << VK_VERSION_PATCH(VK_HEADER_VERSION_COMPLETE) << std::endl;
  return EXIT_SUCCESS;
}

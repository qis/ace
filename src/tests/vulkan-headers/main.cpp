#include <vulkan/vulkan.h>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[])
{
  const auto major = VK_API_VERSION_MAJOR(VK_HEADER_VERSION_COMPLETE);
  const auto minor = VK_API_VERSION_MINOR(VK_HEADER_VERSION_COMPLETE);
  const auto patch = VK_API_VERSION_PATCH(VK_HEADER_VERSION_COMPLETE);
  std::cout << "vulkan: " << major << '.' << minor << '.' << patch << std::endl;
  return EXIT_SUCCESS;
}

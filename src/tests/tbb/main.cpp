#include <oneapi/tbb.h>
#include <oneapi/tbb/scalable_allocator.h>
#include <iostream>
#include <cstdlib>

int main()
{
  const auto p = scalable_aligned_malloc(sizeof(std::string), alignof(std::string));
  if (!p) {
    return EXIT_FAILURE;
  }
  const auto s = new (p) std::string{ TBB_runtime_version() };
  std::cout << "tbb: " << *s << std::endl;
  s->std::string::~string();
  scalable_aligned_free(p);
  return EXIT_SUCCESS;
}

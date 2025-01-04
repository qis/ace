#include <lunasvg.h>
#include <print>
#include <stdexcept>

int main(int argc, char* argv[])
{
  try {
    auto document = lunasvg::Document::loadFromFile("main.svg");
    if (!document) {
      throw std::runtime_error{ "Could not load file: main.svg" };
    }

    auto bitmap = document->renderToBitmap(400, 400, 0x00000000);
    if (!bitmap.valid()) {
      throw std::runtime_error{ "Could not render vector graphic." };
    }
    if (bitmap.stride() != 400 * 4) {
      throw std::runtime_error{ "Unexpected stride." };
    }
    bitmap.convertToRGBA();
    const auto get = [&bitmap](std::size_t x, std::size_t y) -> std::uint32_t {
      return *reinterpret_cast<const std::uint32_t*>(bitmap.data() + y * 400 * 4 + x * 4);
    };
    if (get(0, 0)) {
      throw std::runtime_error{ "Unexpected color at 0, 0." };
    }
    if (!get(200, 200)) {
      throw std::runtime_error{ "Unexpected color at 200, 200." };
    }
  }
  catch (const std::exception& e) {
    std::println(stderr, "Error: {}", e.what());
    return 1;
  }
}

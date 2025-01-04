#include <png.h>
#include <print>
#include <memory>
#include <print>
#include <stdexcept>
#include <vector>

int main(int argc, char* argv[])
{
  std::unique_ptr<FILE, decltype(&fclose)> file{
    fopen("main.png", "rb"),
    fclose,
  };
  if (!file) {
    std::println(stderr, "Could nopt open file: main.png");
    return 1;
  }

  auto png = png_create_read_struct(PNG_LIBPNG_VER_STRING, nullptr, nullptr, nullptr);
  if (!png) {
    std::println(stderr, "Could not create libpng handle.");
    return 1;
  }

  auto info = png_create_info_struct(png);
  if (!info) {
    std::println(stderr, "Could not create libpng info.");
    png_destroy_read_struct(&png, nullptr, nullptr);
    return 1;
  }

  png_init_io(png, file.get());
  png_read_info(png, info);

  auto success = true;
  try {
    const auto cx = png_get_image_width(png, info);
    const auto cy = png_get_image_height(png, info);
    const auto ct = png_get_color_type(png, info);
    const auto bd = png_get_bit_depth(png, info);
    if (cx != 800 || cy != 800) {
      throw std::runtime_error{ "Unexpected image size." };
    }
    if (ct != PNG_COLOR_TYPE_RGB) {
      throw std::runtime_error{ "Unexpected color type." };
    }
    if (bd != 8) {
      throw std::runtime_error{ "Unexpected bit depth." };
    }
    const auto stride = png_get_rowbytes(png, info);
    if (stride != 800 * 3) {
      throw std::runtime_error{ "Unexpected stride." };
    }

    std::vector<png_byte> rgb(cy * stride, '\0');
    std::vector<png_bytep> rows(cy, nullptr);
    for (auto i = 0u; i < 800u; i++) {
      rows[i] = rgb.data() + i * stride;
    }
    png_read_image(png, rows.data());
    png_read_end(png, nullptr);
    auto success = true;
    for (auto x = 0u; x < 800u; x++) {
      for (auto y = 0u; y < 800u; y++) {
        const auto p = rgb.data() + y * 800 * 3 + x * 3;
        if ((static_cast<unsigned>(p[0]) << 16) + (static_cast<unsigned>(p[1]) << 8) + p[2] == 0) {
          std::println(stderr, "Black pixel at: {}x{}", x, y);
          success = false;
        }
      }
    }
  }
  catch (const std::exception& e) {
    std::println(stderr, "Error: {}", e.what());
    success = false;
  }
  png_destroy_read_struct(&png, &info, nullptr);
  return success ? 0 : 1;
}

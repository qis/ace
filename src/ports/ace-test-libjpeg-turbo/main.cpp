#include <turbojpeg.h>
#include <format>
#include <memory>
#include <fstream>
#include <print>
#include <stdexcept>
#include <vector>

std::vector<unsigned char> read_file(const std::string& filename)
{
  std::vector<unsigned char> data;
  std::ifstream file{ filename, std::ios::ate | std::ios::binary };
  if (!file) {
    throw std::runtime_error{ "Missing file: " + filename };
  }
  file.exceptions(std::ios::badbit);
  data.resize(static_cast<std::size_t>(file.tellg()));
  file.seekg(0, std::ios::beg);
  file.read(reinterpret_cast<char*>(data.data()), data.size());
  file.close();
  if (data.empty()) {
    throw std::runtime_error{ "Empty file: " + filename };
  }
  return data;
}

int main(int argc, char* argv[])
{
  try {
    const auto filename = "main.jpg";
    const auto src = read_file(filename);

    std::shared_ptr<void> handle{
      tj3Init(TJINIT_DECOMPRESS),
      [](auto handle) { tj3Destroy(handle); }
    };
    if (!handle) {
      throw std::runtime_error{ "Could not initialize libjpeg-turbo decompress handle." };
    }

    if (tj3DecompressHeader(handle.get(), src.data(), src.size())) {
      throw std::runtime_error{ "Could not decompress header." };
    }

    const auto cx = tj3Get(handle.get(), TJPARAM_JPEGWIDTH);
    const auto cy = tj3Get(handle.get(), TJPARAM_JPEGHEIGHT);
    const auto cs = tj3Get(handle.get(), TJPARAM_COLORSPACE);
    if (cx != 800 || cy != 800) {
      throw std::runtime_error{ std::format("Unexpected image size: {}x{}", cx, cy) };
    }
    if (cs != TJCS_YCbCr) {
      throw std::runtime_error{ std::format("Unexpected image color space: {}", cs) };
    }
    if (tjPixelSize[TJPF_RGB] != 3) {
      throw std::runtime_error{ std::format("Unexpected image format size: {}", tjPixelSize[TJPF_RGB]) };
    }

    std::vector<unsigned char> tmp(cx * cy * tjPixelSize[TJPF_RGB], 0u);
    if (tj3Decompress8(handle.get(), src.data(), src.size(), tmp.data(), 0, TJPF_RGB)) {
      throw std::runtime_error{ "Could not decompress image." };
    }
    handle.reset();

    auto success = true;
    for (auto x = 0u; x < 800u; x++) {
      for (auto y = 0u; y < 800u; y++) {
        const auto p = tmp.data() + y * 800 * 3 + x * 3;
        if ((static_cast<unsigned>(p[0]) << 16) + (static_cast<unsigned>(p[1]) << 8) + p[2] == 0) {
          std::println(stderr, "Black pixel at: {}x{}", x, y);
          success = false;
        }
      }
    }
    if (!success) {
      return 1;
    }
  }
  catch (const std::exception& e) {
    std::println(stderr, "Error: {}", e.what());
    return 1;
  }
}

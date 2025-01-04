#include <libdeflate.h>
#include <fstream>
#include <memory>
#include <print>
#include <stdexcept>
#include <string>

std::string read_file(const std::string& filename)
{
  std::string data;
  std::ifstream file{ filename, std::ios::ate | std::ios::binary };
  if (!file) {
    throw std::runtime_error{ "Missing file: " + filename };
  }
  file.exceptions(std::ios::badbit);
  data.resize(static_cast<std::size_t>(file.tellg()));
  file.seekg(0, std::ios::beg);
  file.read(data.data(), data.size());
  file.close();
  if (data.empty()) {
    throw std::runtime_error{ "Empty file: " + filename };
  }
  return data;
}

int main(int argc, char* argv[])
{
  try {
    const auto filename = "main.manifest";
    const auto src = read_file(filename);

    std::unique_ptr<libdeflate_compressor, decltype(&libdeflate_free_compressor)> compressor{
      libdeflate_alloc_compressor(9),
      libdeflate_free_compressor,
    };
    if (!compressor) {
      throw std::runtime_error{ "Could not create compressor." };
    }

    std::string tmp;
    tmp.resize(src.size());

    auto size = libdeflate_deflate_compress(
      compressor.get(),
      src.data(), src.size(),
      tmp.data(), tmp.size());
    if (!size) {
      throw std::runtime_error{ "Could not compress data." };
    }
    tmp.resize(size);

    std::unique_ptr<libdeflate_decompressor, decltype(&libdeflate_free_decompressor)> decompressor{
      libdeflate_alloc_decompressor(),
      libdeflate_free_decompressor,
    };
    if (!decompressor) {
      throw std::runtime_error{ "Could not create decompressor." };
    }

    std::string dst;
    dst.resize(src.size());

    const auto result = libdeflate_deflate_decompress(
      decompressor.get(),
      tmp.data(), tmp.size(),
      dst.data(), dst.size(),
      &size
    );
    if (result != LIBDEFLATE_SUCCESS) {
      throw std::runtime_error{ "Could not decompress data." };
    }
    dst.resize(size);

    if (src != dst) {
      throw std::runtime_error{ "Roundtrip failed." };
    }

    std::println("{} ({} bytes) compressed to {} bytes", filename, src.size(), tmp.size());
  }
  catch (const std::exception& e) {
    std::println(stderr, "Error: {}", e.what());
    return 1;
  }
}

#include <lz4.h>
#include <fstream>
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

    std::string tmp;
    tmp.resize(src.size());

    auto size = LZ4_compress_default(src.data(), tmp.data(),
      static_cast<int>(src.size()), static_cast<int>(tmp.size()));
    if (size <= 0) {
      throw std::runtime_error{ "Could not compress data." };
    }
    tmp.resize(static_cast<std::size_t>(size));

    std::string dst;
    dst.resize(src.size());

    size = LZ4_decompress_safe(tmp.data(), dst.data(),
      static_cast<int>(tmp.size()), static_cast<int>(dst.size()));
    if (size <= 0) {
      throw std::runtime_error{ "Could not decompress data." };
    }
    dst.resize(static_cast<std::size_t>(size));

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

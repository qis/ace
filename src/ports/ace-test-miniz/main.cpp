#include <miniz.h>
#include <fstream>
#include <memory>
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
    const auto filename = "main.manifest";
    const auto src = read_file(filename);

    auto size = compressBound(src.size());

    std::vector<unsigned char> tmp;
    tmp.resize(size);

    if (compress(tmp.data(), &size, src.data(), src.size()) != Z_OK) {
      throw std::runtime_error{ "Could not compress data." };
    }
    tmp.resize(size);

    std::vector<unsigned char> dst;
    dst.resize(src.size());
    size = static_cast<decltype(size)>(dst.size());

    if (uncompress(dst.data(), &size, tmp.data(), tmp.size()) != Z_OK) {
      throw std::runtime_error{ "Could not uncompress data." };
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

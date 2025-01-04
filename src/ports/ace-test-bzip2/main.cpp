#include <bzlib.h>
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

    unsigned int size = 0;

    std::string tmp;
    tmp.resize(src.size());
    size = static_cast<unsigned int>(tmp.size());
    const auto compress = BZ2_bzBuffToBuffCompress(
      tmp.data(), &size,
      const_cast<char*>(src.data()), static_cast<unsigned int>(src.size()),
      9, 0, 0);
    if (compress != BZ_OK) {
      throw std::runtime_error{ "Compression failed." };
    }
    tmp.resize(size);

    std::string dst;
    dst.resize(src.size());
    size = static_cast<unsigned int>(dst.size());
    const auto decompress = BZ2_bzBuffToBuffDecompress(
      dst.data(), &size,
      tmp.data(), static_cast<unsigned int>(tmp.size()),
      0, 0);
    if (decompress != BZ_OK) {
      throw std::runtime_error{ "Decompression failed." };
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

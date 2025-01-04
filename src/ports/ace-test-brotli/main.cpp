#include <brotli/decode.h>
#include <brotli/encode.h>
#include <fstream>
#include <print>
#include <stdexcept>
#include <vector>

std::vector<uint8_t> read_file(const std::string& filename)
{
  std::vector<uint8_t> data;
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

    std::size_t size = 0;

    std::vector<uint8_t> tmp;
    tmp.resize(src.size());
    size = tmp.size();
    const auto compress = BrotliEncoderCompress(
      BROTLI_MAX_QUALITY, BROTLI_DEFAULT_WINDOW, BROTLI_MODE_TEXT,
      src.size(), src.data(), &size, tmp.data());
    if (!compress) {
      throw std::runtime_error{ "Compression failed." };
    }
    tmp.resize(size);

    std::vector<uint8_t> dst;
    dst.resize(src.size());
    size = dst.size();
    const auto decompress = BrotliDecoderDecompress(
      tmp.size(), tmp.data(), &size, dst.data());
    if (!decompress) {
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

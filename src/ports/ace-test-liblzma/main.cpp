#include <lzma.h>
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

    lzma_stream strm = LZMA_STREAM_INIT;
    if (lzma_easy_encoder(&strm, 9, LZMA_CHECK_CRC64) != LZMA_OK) {
      throw std::runtime_error{ "Could not initialize easy encoder." };
    }

    strm.next_in = src.data();
    strm.avail_in = src.size();

    std::vector<uint8_t> tmp;
    tmp.resize(src.size());

    strm.next_out = tmp.data();
    strm.avail_out = tmp.size();

    const auto encode = lzma_code(&strm, LZMA_FINISH);
    lzma_end(&strm);

    if (encode != LZMA_STREAM_END) {
      throw std::runtime_error{ "Could not encode data." };
    }

    tmp.resize(strm.total_out);

    strm = LZMA_STREAM_INIT;
    if (lzma_auto_decoder(&strm, UINT64_MAX, LZMA_FAIL_FAST) != LZMA_OK) {
      throw std::runtime_error{ "Could not initialize easy decoder." };
    }

    strm.next_in = tmp.data();
    strm.avail_in = tmp.size();

    std::vector<uint8_t> dst;
    dst.resize(src.size());

    strm.next_out = dst.data();
    strm.avail_out = dst.size();

    const auto decode = lzma_code(&strm, LZMA_FINISH);
    lzma_end(&strm);

    if (decode != LZMA_STREAM_END) {
      throw std::runtime_error{ "Could not decode data." };
    }

    dst.resize(strm.total_out);

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

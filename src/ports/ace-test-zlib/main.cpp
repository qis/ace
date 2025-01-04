#include <zlib.h>
#include <fstream>
#include <print>
#include <stdexcept>
#include <vector>

std::vector<Bytef> read_file(const std::string& filename)
{
  std::vector<Bytef> data;
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

    std::vector<Bytef> tmp;
    tmp.resize(src.size());

    z_stream strm{};
    strm.avail_in = static_cast<uInt>(src.size());
    strm.next_in = const_cast<Bytef*>(src.data());
    strm.avail_out = static_cast<uInt>(tmp.size());
    strm.next_out = tmp.data();

    if (deflateInit(&strm, Z_BEST_COMPRESSION) != Z_OK) {
      throw std::runtime_error{ "Could not initialize compression." };
    }

    const auto compress = deflate(&strm, Z_FINISH);
    deflateEnd(&strm);

    if (compress != Z_STREAM_END) {
      throw std::runtime_error{ "Could not compress data." };
    }

    tmp.resize(static_cast<std::size_t>(strm.total_out));

    std::vector<Bytef> dst;
    dst.resize(src.size());

    strm = {};
    strm.avail_in = static_cast<uInt>(tmp.size());
    strm.next_in = tmp.data();
    strm.avail_out = static_cast<uInt>(dst.size());
    strm.next_out = dst.data();

    if (inflateInit(&strm) != Z_OK) {
      throw std::runtime_error{ "Could not initialize decompression." };
    }

    const auto decompress = inflate(&strm, Z_NO_FLUSH);
    inflateEnd(&strm);

    if (decompress != Z_STREAM_END) {
      throw std::runtime_error{ "Could not decompress data." };
    }

    dst.resize(static_cast<std::size_t>(strm.total_out));

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

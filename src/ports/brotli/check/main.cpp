#include <brotli/decode.h>
#include <brotli/encode.h>
#include <format>
#include <iostream>
#include <cstdlib>

std::string parse(uint32_t version) {
  // 0x01'000'009: (MAJOR << 24) | (MINOR << 12) | PATCH
  const auto major = version >> 24 & 0x0FF;
  const auto minor = version >> 12 & 0xFFF;
  const auto patch = version & 0xFFF;
  return std::format("{}.{}.{}", major, minor, patch);
}

int main(int argc, char* argv[]) {
  std::cout << "brotli: "
    << parse(BrotliDecoderVersion()) << " / "
    << parse(BrotliEncoderVersion()) << std::endl;
  return EXIT_SUCCESS;
}

#include <avif/avif.h>
#include <memory>
#include <format>
#include <fstream>
#include <print>
#include <stdexcept>
#include <vector>

std::vector<std::uint8_t> read_file(const std::string& filename)
{
  std::vector<std::uint8_t> data;
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
    // https://youtu.be/UaIOYh8srvE
    // https://docs.krita.org/en/general_concepts/colors/color_managed_workflow.html
    // https://registry.khronos.org/vulkan/specs/latest/man/html/VkColorSpaceKHR.html
    // main.kra: 16-bit (float) Rec2020-elle-V4-g10.icc
    // main.avif: 12-bit
    // * Chroma: 444
    // * Quality: Lossless
    // * Color Space: Rec 2100 PQ
    const auto filename = "main.avif";
    const auto src = read_file(filename);

    std::unique_ptr<avifDecoder, decltype(&avifDecoderDestroy)> decoder{
      avifDecoderCreate(),
      avifDecoderDestroy,
    };
    if (!decoder) {
      throw std::runtime_error{ "Could not create decoder." };
    }

    if (avifDecoderSetIOMemory(decoder.get(), src.data(), src.size()) != AVIF_RESULT_OK) {
      throw std::runtime_error{ "Could not set decoder memory." };
    }

    if (avifDecoderParse(decoder.get()) != AVIF_RESULT_OK) {
      throw std::runtime_error{ "Could not decode image." };
    }
    const auto cx = decoder->image->width;
    const auto cy = decoder->image->height;
    if (cx != 800 || cy != 800) {
      throw std::runtime_error{ std::format("Unexpected image size: {}x{}", cx, cy) };
    }
    const auto bd = decoder->image->depth;
    if (bd != 12) {
      throw std::runtime_error{ std::format("Unexpected image bit depth: {}", bd) };
    }
    const auto format = decoder->image->yuvFormat;
    if (format != AVIF_PIXEL_FORMAT_YUV444) {
      throw std::runtime_error{
        std::format("Unexpected image YUV format: {}", static_cast<int>(format))
      };
    }
    const auto range = decoder->image->yuvRange;
    if (range != AVIF_RANGE_FULL) {
      throw std::runtime_error{
        std::format("Unexpected image YUV range: {}", static_cast<int>(range))
      };
    }
    const auto color = decoder->image->colorPrimaries;
    if (color != AVIF_COLOR_PRIMARIES_BT2100) {
      throw std::runtime_error{
        std::format("Unexpected color primaries: {}", static_cast<int>(color))
      };
    }
    const auto transfer = decoder->image->transferCharacteristics;
    if (transfer != AVIF_TRANSFER_CHARACTERISTICS_PQ) {
      throw std::runtime_error{
        std::format("Unexpected transfer characteristics: {}", static_cast<int>(transfer))
      };
    }
  }
  catch (const std::exception& e) {
    std::println(stderr, "Error: {}", e.what());
    return 1;
  }
}

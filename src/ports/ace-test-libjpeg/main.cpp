#include <stdio.h>
#include <jpeglib.h>
#include <fstream>
#include <functional>
#include <memory>
#include <print>

class scope_exit {
public:
  scope_exit(std::function<void()> call) : call_(std::move(call)) {}

  scope_exit(scope_exit&& other) : call_(std::move(other.call_))
  {
    other.call_ = {};
  }

  scope_exit(const scope_exit& other) = delete;

  scope_exit& operator=(scope_exit&& other)
  {
    call_ = std::move(other.call_);
    other.call_ = {};
    return *this;
  }

  scope_exit& operator=(const scope_exit& other) = delete;

  ~scope_exit()
  {
    if (call_) {
      call_();
    }
  }

private:
  std::function<void()> call_;
};

scope_exit on_scope_exit(std::function<void()> call)
{
  return { std::move(call) };
}

int main(int argc, char* argv[])
{
  std::unique_ptr<FILE, decltype(&fclose)> file{
    fopen("main.jpg", "rb"),
    fclose,
  };
  if (!file) {
    std::println(stderr, "Could nopt open file: main.jpg");
    return 1;
  }

  jpeg_error_mgr jerr{};
  jpeg_decompress_struct cinfo{};
  cinfo.err = jpeg_std_error(&jerr);
  jpeg_create_decompress(&cinfo);
  jpeg_stdio_src(&cinfo, file.get());
  jpeg_read_header(&cinfo, TRUE);
  jpeg_start_decompress(&cinfo);

  const auto se = on_scope_exit([&]() {
    jpeg_finish_decompress(&cinfo);
    jpeg_destroy_decompress(&cinfo);
  });

  const auto cx = cinfo.output_width;
  const auto cy = cinfo.output_height;
  if (cx != 800 || cy != 800) {
    std::println(stderr, "Unexpected image size: {}x{}", cx, cy);
    return 1;
  }
  if (cinfo.output_components != 3) {
    std::println(stderr, "Unexpected number of color components: {}", cinfo.output_components);
    return 1;
  }

  const auto stride = cinfo.output_width * cinfo.output_components;
  JSAMPARRAY buffer = (*cinfo.mem->alloc_sarray)
		(reinterpret_cast<j_common_ptr>(&cinfo), JPOOL_IMAGE, stride, 1);

  auto y = 0u;
  auto success = true;
  while (cinfo.output_scanline < cinfo.output_height) {
    std::memset(buffer[0], 0, stride);
    jpeg_read_scanlines(&cinfo, buffer, 1);
    for (auto x = 0u; x < cx; x++) {
      const auto p = buffer[0] + x * 3;
      if ((static_cast<unsigned>(p[0]) << 16) + (static_cast<unsigned>(p[1]) << 8) + p[2] == 0) {
        std::println(stderr, "Black pixel at: {}x{}", x, y);
        success = false;
      }
    }
    y++;
  }
  return success ? 0 : 1;
}

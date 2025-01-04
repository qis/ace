// http://www.publicdomainfiles.com/show_file.php?id=13949893148456
// https://github.com/harfbuzz/harfbuzz-tutorial/blob/master/hello-harfbuzz-freetype.c
#include <hb.h>
#include <hb-ft.h>
#include <print>
#include <memory>
#include <stdexcept>
#include <type_traits>

void test(const std::string filename)
{
  constexpr auto font_size = 36;
  constexpr auto margin = font_size * 0.5;

  std::unique_ptr<std::remove_pointer_t<FT_Library>, decltype(&FT_Done_FreeType)> ft_library{
    nullptr, FT_Done_FreeType
  };

  if (FT_Library handle = nullptr; FT_Init_FreeType(&handle)) {
    throw std::runtime_error{ filename + ": Could not initialize the freetype library." };
  } else {
    ft_library.reset(handle);
  }

  std::unique_ptr<std::remove_pointer_t<FT_Face>, decltype(&FT_Done_Face)> ft_face{
    nullptr, FT_Done_Face
  };

  if (FT_Face handle = nullptr; FT_New_Face(ft_library.get(), filename.data(), 0, &handle)) {
    throw std::runtime_error{ filename + ": Could not loat font." };
  } else {
    ft_face.reset(handle);
  }

  if (FT_Set_Char_Size(ft_face.get(), font_size * 64, font_size * 64, 0, 0)) {
    throw std::runtime_error{ filename + ": Could not set font character size." };
  }

  std::unique_ptr<hb_font_t, decltype(&hb_font_destroy)> hb_font{
    hb_ft_font_create(ft_face.get(), nullptr), hb_font_destroy
  };

  if (!hb_font) {
    throw std::runtime_error{ filename + ": Could not create harfbuzz font." };
  }

  std::unique_ptr<hb_buffer_t, decltype(&hb_buffer_destroy)> hb_buffer{
    hb_buffer_create(), hb_buffer_destroy
  };

  if (!hb_buffer) {
    throw std::runtime_error{ filename + ": Could not create harfbuzz buffer." };
  }

  hb_buffer_add_utf8(hb_buffer.get(), "1Ю", -1, 0, -1);
  hb_buffer_guess_segment_properties(hb_buffer.get());
  hb_shape(hb_font.get(), hb_buffer.get(), nullptr, 0);
  const auto length = hb_buffer_get_length(hb_buffer.get());
  if (length != 2) {
    throw std::runtime_error{ filename + ": String codepoint count mismatch." };
  }
  const auto info = hb_buffer_get_glyph_infos(hb_buffer.get(), nullptr);
  const auto gid = info[0].codepoint;

  std::string glyphname(64, '\0');
  hb_font_get_glyph_name(hb_font.get(), gid, glyphname.data(), glyphname.size());
  std::println("{}: {} ({:08X}) {}", filename, length, gid, glyphname);
}

int main(int argc, char* argv[])
{
  try {
    test("main.ttf");
    test("main.otf");
  }
  catch (const std::exception& e) {
    std::println(stderr, "Error: {}", e.what());
    return 1;
  }
}

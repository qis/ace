#include <blend2d.h>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[]) {
  BLImage img(480, 480, BL_FORMAT_PRGB32);
  BLContext ctx(img);

  ctx.setCompOp(BL_COMP_OP_SRC_COPY);
  ctx.fillAll();

  BLPath path;
  path.moveTo(26, 31);
  path.cubicTo(642, 132, 587, -136, 25, 464);
  path.cubicTo(882, 404, 144, 267, 27, 31);

  ctx.setCompOp(BL_COMP_OP_SRC_OVER);
  ctx.setFillStyle(BLRgba32(0xFFFFFFFF));
  ctx.fillPath(path);
  ctx.end();

  BLImageCodec codec;
  codec.findByName("PNG");
  img.writeToFile("build/test.png", codec);

  BLRuntimeBuildInfo info{};
  if (const auto result = BLRuntime::queryBuildInfo(&info); result != BL_SUCCESS) {
    std::cerr << "BLRuntime::queryBuildInfo returned " << result << std::endl;
    return EXIT_FAILURE;
  }
  
  std::cout << "blend2d: "
    << info.majorVersion << '.'
    << info.minorVersion << '.'
    << info.patchVersion << std::endl;

  return EXIT_SUCCESS;
}

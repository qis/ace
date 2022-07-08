#include <EGL/egl.h>
#include <GLES3/gl3.h>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[]) {
  std::cout << "angle: " << GL_VERSION << " (" << EGL_VERSION << ')' << std::endl;
  return EXIT_SUCCESS;
}

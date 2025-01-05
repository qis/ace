#include <wayland-client.h>
#include <wayland/xdg-shell.h>
#include <print>

int main(int argc, char* argv[])
{
  const auto display = wl_display_connect(nullptr);
  if (!display) {
    std::println(stderr, "Could not connect to display.");
    return 1;
  }
  wl_display_disconnect(display);
}

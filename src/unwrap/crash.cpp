#include "test.hpp"

static int g_argc = 0;

enum class errc {
  unknown = 0,
  failure = 1,
  success_never_reached = 100,
  failure_never_reached = 101,
  move_not_initialized = 1000,
};

constexpr auto error_type = ice::make_error_type(2);
consteval ice::error_type get_error_type(errc) noexcept { return error_type; }

constexpr ice::result<long> long_success() noexcept {
  if (g_argc < 0)
    return ice::error{ errc::failure };
  return 33;
}

constexpr ice::result<long> long_failure() noexcept {
  if (g_argc < 0)
    return -1;
  return ice::error{ errc::failure };
}

constexpr ice::result<void> test() noexcept {
  auto r0 = long_success();
  auto r1 = long_failure();
  const auto v0 = __unwrap__ std::move(r0);
  const auto v1 = __unwrap__ std::move(r1);
  return {};
}

int main(int argc, char* argv[]) {
  g_argc = argc;
  test();
}

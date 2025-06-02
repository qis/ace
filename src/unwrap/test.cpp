#include <stdio.h>
#include <utility>

#define CONSTEVAL 0

#if CONSTEVAL
#define puts(...)
#endif

enum class error {
  success = 0,  // returned value
  unknown = 1,  // returned error instead of value
  failure = 2,  // return error
  success_never_reached = 1000,
  failure_never_reached = 1002,
  move_not_initialized  = 2000,
};

template <class T>
struct result {
  using value_type = T;
  using error_type = error;

  consteval result() noexcept = default;
  constexpr result(error_type error) noexcept : error_(error) {}
  constexpr result(value_type value) noexcept : error_(error::success), value_(value) { puts("value constructed"); }

  constexpr explicit operator bool() const noexcept { return error_ == error::success; }
  constexpr value_type& value() & noexcept { puts("value_type& value() & [T]"); return value_; }
  constexpr value_type&& value() && noexcept { puts("value_type&& value() && [T]"); return std::move(value_); }
  constexpr const value_type& value() const & noexcept { puts("const value_type& value() const & [T]"); return value_; }
  constexpr error_type error() const noexcept { puts("error_type error() [T]"); return error_; }

private:
  error_type error_{ error::unknown };
  value_type value_{};
};

template <>
struct result<void> {
  using value_type = void;
  using error_type = error;

  consteval result() noexcept = default;
  constexpr result(error_type error) noexcept : error_(error) {}

  constexpr explicit operator bool() const noexcept { return error_ == error::success; }
  constexpr error_type error() const noexcept { puts("error_type error() const [void]"); return error_; }
  constexpr value_type value() const noexcept { puts("value_type value() const [void]"); }

private:
  error_type error_{ error::success };
};

static int g_argc = 0;

#if CONSTEVAL

consteval result<void> void_success() noexcept {
  return {};
}

consteval result<void> void_failure() noexcept {
  return error::failure;
}

consteval result<long> long_success() noexcept {
  return 100;
}

consteval result<long> long_failure() noexcept {
  return error::failure;
}

#else

constexpr result<void> void_success() noexcept {
  if (g_argc < 0) return error::success_never_reached;
  return {};
}

constexpr result<void> void_failure() noexcept {
  if (g_argc < 0) return error::failure_never_reached;
  return error::failure;
}

constexpr result<long> long_success() noexcept {
  if (g_argc < 0) return error::success_never_reached;
  return 100;
}

constexpr result<long> long_failure() noexcept {
  if (g_argc < 0) return error::failure_never_reached;
  return error::failure;
}

#endif

constexpr result<void> test_void() noexcept {
  __unwrap void_success();
  __unwrap void_failure();
  return {};
}

constexpr result<long> test_long() noexcept {
  if (__unwrap long_success()) puts("unwrap success works as expected");
  if (__unwrap long_failure()) puts("unwrap failure should not have worked");
  return {};
  //return __unwrap long_success() + __unwrap long_success();
  //return __unwrap long_success() + __unwrap long_failure();
  //const auto i0 = __unwrap long_success();
  //const auto i1 = __unwrap long_failure();
  //return i0 + i1;
}

class move {
public:
  consteval move() noexcept = default;
  consteval move(int) noexcept : initialized_(true) {}

  constexpr move(move&& other) noexcept : initialized_(other.initialized_) { puts("move ctor"); }
  constexpr move(const move& other) noexcept : initialized_(other.initialized_) { puts("copy ctor"); }
  constexpr move& operator=(move&& other) noexcept { initialized_ = other.initialized_; puts("move ctor"); return *this; }
  constexpr move& operator=(const move& other) noexcept { initialized_ = other.initialized_; puts("copy ctor"); return *this; }

  constexpr bool initialized() const noexcept { puts("testing move"); return initialized_; }

private:
  bool initialized_ = false;
};

constexpr result<move> move_success() noexcept {
  return move{ 1 };
}

constexpr result<void> test_move() noexcept {
  const auto v = __unwrap move_success();
  if (!v.initialized()) {
    return error::move_not_initialized;
  }
  return {};
}

int main(int argc, char* argv[]) {
  g_argc = argc;
  if (const auto rv = test_void(); !rv) {
    printf("void error: %d\n", static_cast<int>(rv.error()));
  }
  if (const auto rv = test_long(); !rv) {
    printf("long error: %d\n", static_cast<int>(rv.error()));
  } else {
    printf("long value: %d\n", static_cast<int>(rv.value()));
  }
  if (const auto rv = test_move(); !rv) {
    printf("move error: %d\n", static_cast<int>(rv.error()));
  }
}

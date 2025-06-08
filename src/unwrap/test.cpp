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

template <bool Consteval>
class move {
public:
  consteval move() noexcept = default;
  consteval move(int) noexcept : initialized_(true) {}

  constexpr move(move&& other) noexcept : initialized_(other.initialized_) {
    if constexpr (!Consteval) puts("move ctor");
  }

  constexpr move(const move& other) noexcept : initialized_(other.initialized_) {
    if constexpr (!Consteval) puts("copy ctor");
  }

  constexpr move& operator=(move&& other) noexcept {
    initialized_ = other.initialized_;
    if constexpr (!Consteval) puts("move op");
    return *this;
  }

  constexpr move& operator=(const move& other) noexcept {
    initialized_ = other.initialized_;
    if constexpr (!Consteval) puts("copy op");
    return *this;
  }

  constexpr bool initialized() const noexcept {
    return initialized_;
  }

private:
  bool initialized_ = false;
};

class consteval_move {
public:
  consteval consteval_move() noexcept = default;
  constexpr consteval_move(int) noexcept : initialized_(true) {}

  constexpr bool initialized() const noexcept { return initialized_; }

private:
  bool initialized_ = false;
};



consteval ice::result<void> void_success() noexcept {
  return {};
}

static_assert(void_success());

consteval ice::result<void> void_failure() noexcept {
  return ice::error{ errc::failure };
}

static_assert(!void_failure());
static_assert(void_failure().error() == errc::failure);

consteval ice::result<long> long_success() noexcept {
  return 33;
}

static_assert(long_success());
//static_assert(*long_success() == 33);

constexpr ice::result<long> long_failure() noexcept {
  return ice::error{ errc::failure };
}

static_assert(!long_failure());
static_assert(long_failure().error() == errc::failure);

consteval ice::result<consteval_move> consteval_move_success() noexcept {
  return 33;
}

static_assert(consteval_move_success());
//static_assert((*consteval_move_success()).initialized());

constexpr ice::result<consteval_move> consteval_move_failure() noexcept {
  return ice::error{ errc::failure };
}

static_assert(!consteval_move_failure());
static_assert(consteval_move_failure().error() == errc::failure);

consteval ice::result<move<false>> move_success() noexcept {
  return 33;
}

static_assert(move_success());
//static_assert((*move_success()).initialized());

consteval ice::result<move<false>> move_failure() noexcept {
  return ice::error{ errc::failure };
}

static_assert(!move_failure());
static_assert(move_failure().error() == errc::failure);

#if 1
consteval ice::result<int> func() noexcept {
  //return ice::error{ errc::failure };
  return 137;
}
#else
ice::result<int> func() noexcept {
  return g_argc < 0 ? 137 : 138;
}
#endif

#define TEST 0
constexpr ice::result<void> test() noexcept {
#if TEST == 0
  #if 1
  ice::result<int> v = func();
  const ice::result<int> c = func();
  const auto a0 = __unwrap__ func();
  const auto a1 = __unwrap__ v;
  const auto a2 = __unwrap__ c;
  const auto a3 = __unwrap__ std::move(v);
  const auto a4 = __unwrap__ std::move(c);
  #else
  const auto uuuuuuu = __unwrap__ func();
  const auto mmmmmmm = ({ auto&& __rv = func(); if (!__rv) return __rv.error(); *__rv; });
  #endif
#elif TEST == 1
  constexpr auto r = long_success();
  // XXX: Append the letter r to the next line to crash clangd.
  const auto v = __unwrap__ std::move(
#elif TEST == 2
  const auto v0 = __unwrap__ void_success();  // error: variable has incomplete type
  const auto v1 = __unwrap__ void_failure();  // error: variable has incomplete type
#elif TEST == 3
  __unwrap__ void_success();
  __unwrap__ void_failure();
#elif TEST == 4
  __unwrap__ long_success();
  __unwrap__ long_failure();
#elif TEST == 5
  constexpr auto r0 = long_success();
  const auto r1 = long_failure();
  const auto v0 = __unwrap__ r0;
  const auto v1 = __unwrap__ r1;
#elif TEST == 6
  auto r0 = long_success();
  const auto v0 = __unwrap__ r0;
  //auto r1 = long_failure();
  //const auto v1 = __unwrap__ r1;
#elif TEST == 7
  auto r0 = long_success();
  auto r1 = long_failure();
  const auto v0 = __unwrap__ std::move(r0);
  const auto v1 = __unwrap__ std::move(r1);
#elif TEST == 8
  __unwrap__ move_success();
  __unwrap__ move_failure();
#elif TEST == 9
  const auto m0 = __unwrap__ move_success();
  const auto m1 = __unwrap__ move_failure();
#elif TEST == 10
  const auto i0 = __unwrap__ long_success(); printf("i0: %ld\n", i0);
  const auto i1 = __unwrap__ long_success() + __unwrap__ long_success(); printf("i0: %ld\n", i1);
  const auto v0 = __unwrap__ move_success(); printf("v0: %d\n", v0.initialized() ? 1 : 0);
  const auto v1 = __unwrap__ move_failure(); printf("v1: %d\n", v1.initialized() ? 1 : 0);
#endif
  puts("unreachable");
  return {};
}

int main(int argc, char* argv[]) {
  g_argc = argc;
  if (const auto rv = test(); !rv) {
    printf("void error: %d\n", static_cast<int>(rv.error().code()));
  }
  //if (const auto rv = test_long(); !rv) {
  //  printf("long error: %d\n", static_cast<int>(rv.error().code()));
  //} else {
  //  printf("long value: %d\n", static_cast<int>(*rv));
  //}
}

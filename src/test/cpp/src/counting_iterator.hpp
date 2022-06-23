// This is a random access iterator similar to boost::counting_iterator for use with
// parallel algorithms. It's probably not necessary to have random access or overflow
// checking. More testing needed, but useful as a snippet.

#include <compare>
#include <concepts>
#include <exception>
#include <iterator>
#include <cstddef>

class counting_iterator_overflow : std::exception {
public:
  const char* what() const noexcept override {
    return "counting iterator overflow";
  }
};

template <class T>
requires std::integral<T>
class counting_iterator {
public:
  using iterator_category = std::random_access_iterator_tag;
  using difference_type   = std::ptrdiff_t;
  using value_type        = T;
  using pointer           = value_type*;
  using reference         = value_type&;

  constexpr counting_iterator() noexcept = default;

  constexpr counting_iterator(value_type value) noexcept :
    value_(value), start_(value)
  {}

  constexpr counting_iterator(value_type value, value_type start) noexcept :
    value_(value), start_(start)
  {}

  constexpr counting_iterator(counting_iterator&& other) noexcept = default;
  constexpr counting_iterator& operator=(counting_iterator&& other) noexcept = default;

  constexpr counting_iterator(const counting_iterator& other) noexcept = default;
  constexpr counting_iterator& operator=(const counting_iterator& other) noexcept = default;

  constexpr ~counting_iterator() noexcept = default;

  constexpr value_type operator*() const noexcept {
    return value_;
  }

  constexpr value_type operator[](value_type index) const {
    value_type value;
    if (__builtin_add_overflow(start_, index, &value)) {
      throw counting_iterator_overflow();
    }
    return value;
  }

  constexpr counting_iterator& operator++() {
    if (__builtin_add_overflow(value_, 1, &value_)) {
      throw counting_iterator_overflow();
    }
    return *this;
  }

  constexpr counting_iterator operator++(int) {
    const auto it{ *this };
    ++(*this);
    return it;
  }

  constexpr counting_iterator& operator--() {
    if (__builtin_sub_overflow(value_, 1, &value_)) {
      throw counting_iterator_overflow();
    }
    return *this;
  }

  constexpr counting_iterator operator--(int) {
    const auto it{ *this };
    --(*this);
    return it;
  }

  constexpr difference_type operator-(const counting_iterator& rhs) const {
    difference_type difference;
    if (__builtin_sub_overflow(value_, rhs.value_, &difference)) {
      throw counting_iterator_overflow();
    }
    return difference;
  }

  constexpr counting_iterator operator+(difference_type difference) const {
    value_type value;
    if (__builtin_add_overflow(value_, difference, &value)) {
      throw counting_iterator_overflow();
    }
    return { value, start_ };
  }

  constexpr counting_iterator& operator+=(difference_type difference) {
    if (__builtin_add_overflow(value_, difference, &value_)) {
      throw counting_iterator_overflow();
    }
    return *this;
  }

  constexpr counting_iterator operator-(difference_type difference) const {
    value_type value;
    if (__builtin_sub_overflow(value_, difference, &value)) {
      throw counting_iterator_overflow();
    }
    return { value, start_ };
  }

  constexpr counting_iterator& operator-=(difference_type difference) {
    if (__builtin_sub_overflow(value_, difference, &value_)) {
      throw counting_iterator_overflow();
    }
    return *this;
  }

  friend constexpr counting_iterator operator+(difference_type difference, const counting_iterator& it) {
    value_type value;
    if (__builtin_add_overflow(difference, it.value_, &value)) {
      throw counting_iterator_overflow();
    }
    return { value, it.start_ };
  }

  friend constexpr counting_iterator operator-(difference_type difference, const counting_iterator& it) {
    value_type value;
    if (__builtin_sub_overflow(difference, it.value_, &value)) {
      throw counting_iterator_overflow();
    }
    return { value, it.start_ };
  }

  friend constexpr bool operator<(const counting_iterator& lhs, const counting_iterator& rhs) noexcept {
    return lhs.value_ < rhs.value_;
  }

  friend constexpr bool operator==(const counting_iterator& lhs, const counting_iterator& rhs) noexcept {
    return lhs.value_ == rhs.value_;
  }

  friend constexpr auto operator<=>(const counting_iterator& lhs, const counting_iterator& rhs) noexcept = default;

private:
  value_type value_{ 0 };
  value_type start_{ 0 };
};

static_assert(std::random_access_iterator<counting_iterator<int>>);
static_assert(std::random_access_iterator<counting_iterator<unsigned>>);

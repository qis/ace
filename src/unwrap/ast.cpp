enum class errc;

template <class T>
class result {
public:
  result() noexcept = default;
  result(T value) noexcept;
  result(errc error) noexcept;
  result(result&& other) noexcept;
  result(const result& other) = delete;
  result& operator=(result&& other) noexcept;
  result& operator=(const result& other) = delete;
  ~result();

  operator bool() const noexcept;

  T& operator*() & noexcept;
  T&& operator*() && noexcept;

  const T& operator*() const& noexcept;
  const T&& operator*() const&& noexcept;

  errc error() const;
};

result<int> test() {
  result<long> v0;
  result<long> v1;
  const auto r0 = ({
    result<long>&& __rv = static_cast<result<long>&&>(v0);
    if (!__rv)
      return __rv.error();
    *static_cast<result<long>&&>(__rv);
  });
  const auto r1 = __unwrap__ static_cast<result<long>&&>(v1);
  return {};
}

/*
class resource {
public:
  resource() = default;
  resource(resource&& other) = default;
  resource(const resource& other) = delete;
  resource& operator=(resource&& other) = default;
  resource& operator=(const resource& other) = delete;

  static result<resource> create();

private:
  int handle_{ 0 };
};
*/

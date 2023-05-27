// -*- C++ -*-
//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

module;
#include <ctime>

export module std.ctime;
export namespace std {
  using std::clock_t;
  using std::size_t;
  using std::time_t;

  using std::timespec;
  using std::tm;

  using std::asctime;
  using std::clock;
  constexpr char* ctime(const std::time_t* time) noexcept { return ::ctime(time); }
  constexpr double difftime(std::time_t time_end, std::time_t time_beg) noexcept { return ::difftime(time_end, time_beg); }
  constexpr std::tm* gmtime(const std::time_t* time) noexcept { return ::gmtime(time); }
  constexpr std::tm* localtime(const std::time_t *time) noexcept { return ::localtime(time); }
  constexpr std::time_t mktime(std::tm* time) noexcept { return ::mktime(time); }
  using std::strftime;
  constexpr std::time_t time(std::time_t* arg) noexcept { return ::time(arg); }
  constexpr int timespec_get(std::timespec* ts, int base) noexcept { return ::timespec_get(ts, base); }
} // namespace std

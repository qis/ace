// -*- C++ -*-
//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

module;
#include <cstddef>

export module std.cstddef;
export namespace std {
  using std::max_align_t;
  using std::nullptr_t;
  using std::ptrdiff_t;
  using std::size_t;

  using std::byte;

  // [support.types.byteops], byte type operations
  using std::operator<<=;
  using std::operator<<;
  using std::operator>>=;
  using std::operator>>;
  using std::operator|=;
  using std::operator|;
  using std::operator&=;
  using std::operator&;
  using std::operator^=;
  using std::operator^;
  using std::operator~;
  using std::to_integer;
} // namespace std

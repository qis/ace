// -*- C++ -*-
//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

module;
#include <bitset>

export module std.bitset;
export namespace std {
  using std::bitset;

  // [bitset.operators], bitset operators
  using std::operator&;
  using std::operator|;
  using std::operator^;
  using std::operator>>;
  using std::operator<<;

  // [bitset.hash], hash support
  using std::hash;

} // namespace std

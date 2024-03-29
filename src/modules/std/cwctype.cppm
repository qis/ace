// -*- C++ -*-
//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

module;
#include <__config>
#ifndef _LIBCPP_HAS_NO_WIDE_CHARACTERS
#  include <cwctype>
#endif

export module std.cwctype;
#ifndef _LIBCPP_HAS_NO_WIDE_CHARACTERS
export namespace std {
  using std::wctrans_t;
  using std::wctype_t;
  using std::wint_t;

  using std::iswalnum;
  using std::iswalpha;
  using std::iswblank;
  using std::iswcntrl;
  using std::iswctype;
  using std::iswdigit;
  using std::iswgraph;
  using std::iswlower;
  using std::iswprint;
  using std::iswpunct;
  using std::iswspace;
  using std::iswupper;
  using std::iswxdigit;
  using std::towctrans;
  using std::towlower;
  using std::towupper;
  using std::wctrans;
  using std::wctype;
} // namespace std
#endif // _LIBCPP_HAS_NO_WIDE_CHARACTERS

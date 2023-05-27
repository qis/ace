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
#  include <cwchar>
#endif

#ifdef __MINGW32__
#include <cstdarg>
#endif

export module std.cwchar;
#ifndef _LIBCPP_HAS_NO_WIDE_CHARACTERS
export namespace std {
  using std::mbstate_t;
  using std::size_t;
  using std::wint_t;

  using std::tm;

  using std::btowc;
  using std::fgetwc;
  using std::fgetws;
  using std::fputwc;
  using std::fputws;
  using std::fwide;

#ifdef __MINGW32__
  inline int fwprintf(std::FILE* stream, const wchar_t* format, ...) noexcept {
    va_list vlist;
    va_start(vlist, format);
    const auto ret = ::vfwprintf(stream, format, vlist);
    va_end(vlist);
    return ret;
  }

  inline int fwscanf(std::FILE* stream, const wchar_t* format, ...) noexcept {
    va_list vlist;
    va_start(vlist, format);
    const auto ret = ::vfwscanf(stream, format, vlist);
    va_end(vlist);
    return ret;
  }

  inline int swprintf(wchar_t* buffer, std::size_t size, const wchar_t *format, ...) noexcept {
    va_list vlist;
    va_start(vlist, format);
    const auto ret = ::vswprintf(buffer, size, format, vlist);
    va_end(vlist);
    return ret;
  }

  inline int swscanf(const wchar_t* buffer, const wchar_t* format, ...) noexcept {
    va_list vlist;
    va_start(vlist, format);
    const auto ret = ::vswscanf(buffer, format, vlist);
    va_end(vlist);
    return ret;
  }

  inline int vfwprintf(std::FILE* stream, const wchar_t* format, va_list vlist) noexcept {
    return ::vfwprintf(stream, format, vlist);
  }

  inline int vfwscanf(std::FILE* stream, const wchar_t* format, va_list vlist) noexcept {
    return ::vfwscanf(stream, format, vlist);
  }

  inline int vswprintf(wchar_t* buffer, std::size_t size, const wchar_t* format, va_list vlist) noexcept {
    return ::vswprintf(buffer, size, format, vlist);
  }

  inline int vswscanf(const wchar_t* buffer, const wchar_t* format, va_list vlist) noexcept {
    return ::vswscanf(buffer, format, vlist);
  }

  inline int vwprintf(const wchar_t* format, va_list vlist) noexcept {
    return ::vwprintf(format, vlist);
  }

  inline int vwscanf(const wchar_t* format, va_list vlist) noexcept {
    return ::vwscanf(format, vlist);
  }

  inline int wprintf(const wchar_t* format, ...) noexcept {
    va_list vlist;
    va_start(vlist, format);
    const auto ret = ::vwprintf(format, vlist);
    va_end(vlist);
    return ret;
  }

  inline int wscanf(const wchar_t* format, ...) noexcept {
    va_list vlist;
    va_start(vlist, format);
    const auto ret = ::vwscanf(format, vlist);
    va_end(vlist);
    return ret;
  }

  constexpr int mbsinit(const std::mbstate_t* ps) noexcept {
    return ::mbsinit(ps);
  }
#else
  using std::fwprintf;
  using std::fwscanf;
  using std::swprintf;
  using std::swscanf;
  using std::vfwprintf;
  using std::vfwscanf;
  using std::vswprintf;
  using std::vswscanf;
  using std::vwprintf;
  using std::vwscanf;
  using std::wprintf;
  using std::wscanf;
  using std::mbsinit;
#endif

  using std::getwc;
  using std::getwchar;
  using std::putwc;
  using std::putwchar;
  using std::ungetwc;
  using std::wcscat;
  using std::wcschr;
  using std::wcscmp;
  using std::wcscoll;
  using std::wcscpy;
  using std::wcscspn;
  using std::wcsftime;
  using std::wcslen;
  using std::wcsncat;
  using std::wcsncmp;
  using std::wcsncpy;
  using std::wcspbrk;
  using std::wcsrchr;
  using std::wcsspn;
  using std::wcsstr;
  using std::wcstod;
  using std::wcstof;
  using std::wcstok;
  using std::wcstol;
  using std::wcstold;
  using std::wcstoll;
  using std::wcstoul;
  using std::wcstoull;
  using std::wcsxfrm;
  using std::wctob;
  using std::wmemchr;
  using std::wmemcmp;
  using std::wmemcpy;
  using std::wmemmove;
  using std::wmemset;

  // [c.mb.wcs], multibyte / wide string and character conversion functions
  using std::mbrlen;
  using std::mbrtowc;
  using std::mbsrtowcs;
  using std::wcrtomb;
  using std::wcsrtombs;

} // namespace std
#endif // _LIBCPP_HAS_NO_WIDE_CHARACTERS

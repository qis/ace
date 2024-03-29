// -*- C++ -*-
//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

module;
#include <csignal>

export module std.csignal;
export namespace std {
  using std::sig_atomic_t;

  // [support.signal], signal handlers
  using std::signal;

  using std::raise;

} // namespace std

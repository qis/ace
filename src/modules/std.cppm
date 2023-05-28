// -*- C++ -*-
//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

export module std;

// The headers of Table 24: C++ library headers [tab:headers.cpp]
// and the headers of Table 25: C++ headers for C library facilities [tab:headers.cpp.c]
export import std.__new; // Note new is a keyword and not a valid identifier
export import std.algorithm;
export import std.any;
export import std.array;
export import std.atomic;
export import std.barrier;
export import std.bit;
export import std.bitset;
export import std.cassert;
export import std.cctype;
export import std.cerrno;
export import std.cfenv;
export import std.cfloat;
export import std.charconv;
export import std.chrono;
export import std.cinttypes;
export import std.climits;
export import std.clocale;
export import std.cmath;
export import std.codecvt;
export import std.compare;
export import std.complex;
export import std.concepts;
export import std.condition_variable;
export import std.coroutine;
export import std.csetjmp;
export import std.csignal;
export import std.cstdarg;
export import std.cstddef;
export import std.cstdio;
export import std.cstdlib;
export import std.cstdint;
export import std.cstring;
export import std.ctime;
export import std.cuchar;
export import std.cwchar;
export import std.cwctype;
export import std.deque;
export import std.exception;
export import std.execution;
export import std.expected;
export import std.filesystem;
export import std.flat_map;
export import std.flat_set;
export import std.format;
export import std.forward_list;
export import std.fstream;
export import std.functional;
export import std.future;
export import std.generator;
export import std.initializer_list;
export import std.iomanip;
export import std.ios;
export import std.iosfwd;
export import std.iostream;
export import std.istream;
export import std.iterator;
export import std.latch;
export import std.limits;
export import std.list;
export import std.locale;
export import std.map;
export import std.mdspan;
export import std.memory;
export import std.memory_resource;
export import std.mutex;
export import std.numbers;
export import std.numeric;
export import std.optional;
export import std.ostream;
export import std.print;
export import std.queue;
export import std.random;
export import std.ranges;
export import std.ratio;
export import std.regex;
export import std.scoped_allocator;
export import std.semaphore;
export import std.set;
export import std.shared_mutex;
export import std.source_location;
export import std.span;
export import std.spanstream;
export import std.sstream;
export import std.stack;
export import std.stacktrace;
export import std.stdexcept;
export import std.stdfloat;
export import std.stop_token;
export import std.streambuf;
export import std.string;
export import std.string_view;
export import std.strstream;
export import std.syncstream;
export import std.system_error;
export import std.thread;
export import std.tuple;
export import std.type_traits;
export import std.typeindex;
export import std.typeinfo;
export import std.unordered_map;
export import std.unordered_set;
export import std.utility;
export import std.valarray;
export import std.variant;
export import std.vector;
export import std.version;

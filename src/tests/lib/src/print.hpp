#pragma once
#include <chrono>
#include <string_view>

#ifdef _WIN32
#  define PRINT_EXPORT __declspec(dllexport)
#  define PRINT_IMPORT __declspec(dllimport)
#else
#  define PRINT_EXPORT __attribute__((__visibility__("default")))
#  define PRINT_IMPORT
#endif

#ifdef PRINT_SHARED
#  ifdef PRINT_EXPORTS
#    define PRINT_API PRINT_EXPORT
#  else
#    define PRINT_API PRINT_IMPORT
#  endif
#else
#  define PRINT_API
#endif

PRINT_API void print(std::chrono::steady_clock::duration duration, std::string_view comment);

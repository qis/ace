#pragma once
#include <chrono>
#include <string_view>

#ifdef PRINT_IMPORT
#  ifdef PRINT_EXPORT
#    ifdef _WIN32
#      define PRINT_API __declspec(dllexport)
#    else
#      define PRINT_API __attribute__((visibility("default")))
#    endif
#  else
#    ifdef _WIN32
#      define PRINT_API __declspec(dllimport)
#    else
#      define PRINT_API
#    endif
#  endif
#else
#  define PRINT_API
#endif

PRINT_API void print(std::chrono::steady_clock::duration duration, std::string_view comment);

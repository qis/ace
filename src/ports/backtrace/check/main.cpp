#include <backtrace.h>
#include <backtrace-supported.h>
#include <iostream>
#include <cstdio>
#include <cstdlib>

void error_callback_create(void* data, const char* msg, int errnum) {
  fprintf(stderr, "%s", msg);
  if (errnum > 0) {
    fprintf(stderr, ": %s", strerror(errnum));
  }
  fprintf(stderr, "\n");
  exit(EXIT_FAILURE);
}

void print_stack_trace() {
  const auto state = backtrace_create_state(nullptr,
    BACKTRACE_SUPPORTS_THREADS, error_callback_create, nullptr);
  backtrace_print(state, 1, stdout);
}

void inner() {
  print_stack_trace();
}

void outer() {
  inner();
}

int main(int argc, char* argv[]) {
  outer();
  std::cout << "backtrace: 1.0.0" << std::endl;
  return EXIT_SUCCESS;
}

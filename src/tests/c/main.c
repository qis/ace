#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[]) {
  fputs("command:", stdout);
  for (int i = 0; i < argc; i++) {
    printf(" %s", argv[i]);
  }
  putc('\n', stdout);
  fflush(stdout);
  return EXIT_SUCCESS;
}

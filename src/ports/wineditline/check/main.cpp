#include <readline.h>
#include <iostream>
#include <string_view>
#include <cstdio>
#include <cstdlib>

int main(int argc, char* argv[]) {
  std::cout << "editline: 1.17.1" << std::endl;
  if (argc > 1 && std::string_view{ argv[1] } == "cli") {
    char* s = nullptr;
    while ((s = readline("CLI> ")) != NULL) {
      puts(s);
      free(s);
    }
  }
  return EXIT_SUCCESS;
}

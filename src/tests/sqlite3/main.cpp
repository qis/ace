#include <sqlite3.h>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[])
{
  std::cout << "sqlite3: " << sqlite3_libversion() << std::endl;
  return EXIT_SUCCESS;
}

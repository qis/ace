#include <sqlite3.h>
#include <print>

int main(int argc, char* argv[])
{
  std::println("SQLite3 Version: {}", sqlite3_libversion());
}

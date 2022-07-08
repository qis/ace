#include <libxml/xmlversion.h>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[]) {
  xmlCheckVersion(LIBXML_VERSION);
  std::cout << "xml2: " << LIBXML_DOTTED_VERSION << std::endl;
  return EXIT_SUCCESS;
}

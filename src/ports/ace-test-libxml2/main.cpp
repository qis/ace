#include <libxml/parser.h>
#include <memory>
#include <print>

int main(int argc, char* argv[])
{
  const auto filename = "main.manifest";
  std::unique_ptr<xmlDoc, decltype(&xmlFreeDoc)> doc{
    xmlReadFile(filename, nullptr, XML_PARSE_NONET),
    xmlFreeDoc,
  };
  if (!doc) {
    std::println(stderr, "Could not parse XML file: {}", filename);
    return 1;
  }
}

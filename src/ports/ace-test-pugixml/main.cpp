#include <pugixml.hpp>
#include <print>

int main(int argc, char* argv[])
{
  pugi::xml_document doc;
  const auto filename = "main.manifest";
  if (const auto result = doc.load_file(filename); !result) {
    std::println(stderr, "Could not parse XML file: {}", filename);
    std::println(stderr, "Error: {}", result.description());
    return 1;
  }
  const auto value = doc.child("assembly").attribute("xmlns").value();
  std::println("{} assembly xmlns: {}", filename, value);
}

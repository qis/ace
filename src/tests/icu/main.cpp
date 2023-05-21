#include <unicode/errorcode.h>
#include <unicode/putil.h>
#include <unicode/stringoptions.h>
#include <unicode/uchar.h>
#include <unicode/uclean.h>
#include <unicode/ucpmap.h>
#include <unicode/utypes.h>
#include <unicode/uversion.h>
#include <filesystem>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[])
{
  icu::ErrorCode ec;
  u_init(ec);
  if (ec.isFailure() && ec != U_FILE_ACCESS_ERROR) {
    auto path = u_getDataDirectory();
    if (!path) {
      path = "/opt/ace/vcpkg/installed/<triplet>/share/icu";
    }
    std::cerr << "Could not load " << path << "/icudtl.dat" << std::endl;
    std::cerr << "u_init: " << ec.errorName() << std::endl;
    return EXIT_FAILURE;
  }
  u_cleanup();

  const auto data_directory = std::filesystem::current_path();
  u_setDataDirectory(data_directory.string().data());

  u_init(ec);
  if (ec.isFailure() && ec != U_FILE_ACCESS_ERROR) {
    const auto path = data_directory.string();
    std::cerr << "Could not load " << path << "/icudtl.dat" << std::endl;
    std::cerr << "u_init: " << ec.errorName() << std::endl;
    return EXIT_FAILURE;
  }
  std::atexit(u_cleanup);

  ec.reset();
  std::string name;
  name.resize(1024);
  constexpr UChar32 code = 0x1F643;
  auto size =
    u_charName(code, U_UNICODE_CHAR_NAME, name.data(), static_cast<int32_t>(name.size()), ec);
  if (size > static_cast<int32_t>(name.size())) {
    ec.reset();
    name.resize(static_cast<std::size_t>(size) + 1);
    size = u_charName(code, U_UNICODE_CHAR_NAME, name.data(), static_cast<int32_t>(name.size()), ec);
  }
  if (ec.isFailure()) {
    std::cerr << "Missing 0x1F643 entry: " << ec.errorName() << std::endl;
    return EXIT_FAILURE;
  }
  name.resize(static_cast<std::size_t>(size));
  if (name != "UPSIDE-DOWN FACE") {
    std::cerr << "Invalid 0x1F643 name: \"" << name << '"' << std::endl;
    return EXIT_FAILURE;
  }

  UVersionInfo va;
  u_getVersion(va);
  std::cout << "icu: " << static_cast<unsigned>(va[0]) << '.' << static_cast<unsigned>(va[1])
            << std::endl;

  u_cleanup();
  return EXIT_SUCCESS;
}

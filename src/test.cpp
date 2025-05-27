#ifdef _WIN32
#include <windows.h>
#endif
#include <filesystem>
#include <iostream>
#include <sstream>
#include <cstdlib>

const std::filesystem::path& executable() noexcept {
  static const auto executable = []() noexcept -> std::filesystem::path {
    std::string file;
#ifdef _WIN32
    DWORD size = 0;
    const HINSTANCE instance = GetModuleHandle(nullptr);
    do {
      file.resize(file.size() + MAX_PATH);
      size = GetModuleFileNameA(instance, file.data(), static_cast<DWORD>(file.size()));
    } while (GetLastError() == ERROR_INSUFFICIENT_BUFFER);
    file.resize(size);
#else
    if (const auto s = realpath("/proc/self/exe", nullptr)) {
      file.assign(s);
      free(s);  // NOLINT(cppcoreguidelines-no-malloc)
    }
#endif
    std::error_code ec;
    auto path = std::filesystem::canonical(file, ec);
    if (ec) {
      path.assign(file);
    }
    return path;
  }();
  return executable;
}

int main(int argc, char* argv[]) {
  const auto path = executable().string();
  std::cerr << path << std::endl;
#ifdef _WIN32
  MessageBoxA(nullptr, path.data(), "Executable", MB_OK | MB_SETFOREGROUND);
#endif
  for (auto i = 0; i < argc; i++) {
    std::cout << i << ": " << argv[i] << std::endl;
  }
  return EXIT_SUCCESS;
}

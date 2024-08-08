module;
#ifdef _WIN32
#include <windows.h>
#else
#include <sys/sysmacros.h>
#endif
export module ace.random;
import std;

namespace ace {

export std::string random();

}  // namespace ace

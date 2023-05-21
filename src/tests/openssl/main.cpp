#include <openssl/crypto.h>
#include <openssl/ssl.h>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[])
{
  // SSL Symbols
  SSL_load_error_strings();
  SSL_library_init();

  // Crypto Symbols
  std::cout << "openssl: " << SSLeay_version(SSLEAY_VERSION) << std::endl;
  return EXIT_SUCCESS;
}

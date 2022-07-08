#include <openssl/crypto.h>
#include <openssl/ssl.h>
#include <tls.h>
#include <iostream>
#include <cstdlib>

int main(int argc, char* argv[]) {
  // SSL Symbols
  SSL_load_error_strings();
  SSL_library_init();

  // TLS Symbols
  if (tls_init() != 0) {
    std::cerr << "error: could not initialize libtls" << std::endl;
    return EXIT_FAILURE;
  }

  // Crypto Symbols
  std::cout << "ssl: " << SSLeay_version(SSLEAY_VERSION) << std::endl;
  return EXIT_SUCCESS;
}

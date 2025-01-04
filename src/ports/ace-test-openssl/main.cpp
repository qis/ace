#include <openssl/crypto.h>
#include <openssl/ssl.h>
#include <print>

int main(int argc, char* argv[])
{
  std::println("OpenSSL Version: {}", OpenSSL_version(OPENSSL_FULL_VERSION_STRING));
  const auto context = SSL_CTX_new(TLS_server_method());
  if (!context) {
    std::println(stderr, "Could not create SSL context.");
    return 1;
  }
  SSL_CTX_free(context);
}

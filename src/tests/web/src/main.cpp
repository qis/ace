#include "counting_iterator.hpp"
#include <algorithm>
#include <execution>
#include <format>
#include <string>
#include <vector>
#include <cerrno>
#include <cstdlib>

namespace js {

__attribute__((import_name("print"))) void print(const char* data, size_t size);

__attribute__((export_name("get_errno"))) int get_errno()
{
  return errno;
}

__attribute__((export_name("set_errno"))) void set_errno(int value)
{
  errno = value;
}

}  // namespace js

__attribute__((visibility("default"))) int main()
{
  std::vector<int> data{ 9, 1, 1, 8 };
  std::sort(std::execution::par_unseq, std::begin(data), std::end(data));

  const auto beg = counting_iterator{ 0uz };
  const auto end = counting_iterator{ data.size() - 1 };
  std::for_each(beg, end, [&](std::size_t i) {
    if (data[i] > data[i + 1]) {
      std::abort();
    }
  });

  const auto text = std::format("errno: {} ({} {} {} {})", errno, data[0], data[1], data[2], data[3]);
  js::print(text.data(), text.size());

  return EXIT_SUCCESS;
}

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

// close(2) closes the file descriptor 'fd'.
//
// - On success, returns '0'.
// - On failure, returns '-1' and sets 'errno'.
//
// close: (fd) => {
//   exports.set_errno(errno.EBADF);
//   return -1;
// },
//
// extern "C" int close(int fd) {
//  errno = EBADF;
//  return -1;
//}

// isatty(3) tests whether the file descriptor 'fd' is referring to a terminal.
//
// - On success, returns '1'.
// - On failure, returns '0' and sets 'errno'.
// __isatty: (fd) => {
//   exports.set_errno((fd !== files.stdout && fd !== files.stderr) ?
//   errno.EBADF : errno.ENOTTY); return 0;
// },
//
// extern "C" int __isatty(FILE* fd) {
//  errno = (fd != stdout && fd != stderr) ? EBADF : ENOTTY;
//  return 0;
//}

// lseek(2) repositions the file descriptor 'fd' offset to 'offset' according to
// the directive 'whence'.
//
// - On success, returns the resulting offset location in bytes from the
// beginning of the file.
// - On failure, returns '-1' and sets 'errno'.
//
// __lseek: (fd, offset, whence) => {
//   exports.set_errno((fd !== files.stdout && fd !== files.stderr) ?
//   errno.EBADF : errno.ESPIPE); return -1;
// },
//
// extern "C" off_t __lseek(FILE* fd, off_t offset, int whence) {
//  errno = (fd != stdout && fd != stderr) ? EBADF : ESPIPE;
//  return -1;
//}

// writev(2) writes 'iovcnt' buffers described by 'iov' to the file descriptor
// 'fd'.
//
// - On success, returns the resulting offset location in bytes from the
// beginning of the file.
// - On failure, returns '-1' and sets 'errno'.
//
// struct iovec {
//   void*  iov_base;  // starting address
//   size_t iov_len;   // number of bytes to transfer
// };
//
// writev: (fd, iov, iovcnt) => {
//   if (fd !== files.stdout && fd !== files.stderr) {
//     this.exports.set_errno(errno.EBADF);
//     return -1;
//   }
//   let size = 0;
//   let text = "";
//   const iov_size = 2;
//   const iov_data = new Uint32Array(this.exports.memory.buffer, iov, iovcnt *
//   iov_size); for (var i = 0; i < iovcnt; i++) {
//     const iov_base = iov_data[i * iov_size + 0];
//     const iov_size = iov_data[i * iov_size + 1];
//     if (iov_size > 0) {
//       const iov_data = new Uint8Array(this.exports.memory.buffer, iov_base,
//       iov_size); try {
//         text += decoder.decode(iov_data, { stream: i + 1 < iovcnt });
//       }
//       catch (e) {
//         console.error('writev:', e, iov_data);
//       }
//       size += iov_size;
//     }
//   }
//   if (text.length) {
//     (fd === files.stdout ? console.log : console.error)(text);
//   }
//   return size;
// },
//
// extern "C" ssize_t writev(int fd, const struct iovec* iov, int iovcnt) {
//  ssize_t size = 0;
//  for (int i = 0; i < iovcnt; i++) {
//    size += (ssize_t)iov[i].iov_len;
//  }
//  return size;
//}

// wasi-libc/libc-bottom-half/sources/__wasilibc_initialize_environ.c
// extern "C" char** __wasilibc_environ __attribute__((weak)) = (char **)-1;
// extern "C" void __wasilibc_ensure_environ() {}

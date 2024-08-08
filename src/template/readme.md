# Template
C++ project template for the [Ace][ace] toolchain.

## Ports
Install [Vcpkg][pkg] ports.

```sh
# Linux
vcpkg install --triplet=ace-linux-shared benchmark doctest
vcpkg install --triplet=ace-linux-static benchmark doctest

# Linux & Windows
vcpkg install --triplet=ace-mingw-shared benchmark doctest
vcpkg install --triplet=ace-mingw-static benchmark doctest
```

## CMake
Configure project.

```sh
# Linux
cmake --preset linux-shared
cmake --preset linux-static

# Linux & Windows
cmake --preset mingw-shared
cmake --preset mingw-static
```

Build target.

```sh
# cmake --build build/<preset> --config <config> --target <target1> [target2]...
```

<details>

```sh
# Linux
cmake --build build/linux-shared --config Debug --target main tests
cmake --build build/linux-static --config Release --target main tests benchmarks
cmake --build build/linux-shared --config RelWithDebInfo --target main tests
cmake --build build/linux-static --config MinSizeRel --target main tests benchmarks
cmake --build build/linux-shared --config Coverage --target tests

# Linux & Windows
cmake --build build/mingw-shared --config Debug --target main tests
cmake --build build/mingw-static --config Release --target main tests benchmarks
cmake --build build/mingw-shared --config RelWithDebInfo --target main tests
cmake --build build/mingw-static --config MinSizeRel --target main tests benchmarks
cmake --build build/mingw-shared --config Coverage --target tests
```

Run application.

```sh
# Linux
build/linux-shared/Debug/ace

# Linux Emulator
WINEPATH="/opt/ace/sys/mingw/bin;/opt/ace/vcpkg/installed/ace-mingw-shared/bin" \
wine build/mingw-shared/Debug/ace.exe

# Windows WSL2
build/mingw-shared/Debug/ace.exe

# Windows
build\mingw-shared\Debug\ace.exe
```

Run benchmarks.

```sh
# Linux
build/linux-static/Release/benchmarks

# Linux Emulator
wine build/mingw-static/Release/benchmarks.exe

# Windows WSL2
build/mingw-static/Release/benchmarks.exe

# Windows
build\mingw-static\Release\benchmarks.exe
```

Run tests.

```sh
# Linux
ctest --test-dir build/linux-shared -C Debug

# Linux & Windows
ctest --test-dir build/mingw-shared -C Debug
```

Analyze [Code Coverage][cov].

```sh
# Linux
ctest --test-dir build/linux-shared -C Coverage
llvm-profdata merge -sparse build/linux-shared/default.profraw -o build/linux-shared/default.profdata
llvm-cov show build/linux-shared/Coverage/tests -instr-profile=build/linux-shared/default.profdata

# Linux & Windows
ctest --test-dir build/mingw-shared -C Coverage
llvm-profdata merge -sparse build/mingw-shared/default.profraw -o build/mingw-shared/default.profdata
llvm-cov show build/mingw-shared/Coverage/tests.exe -instr-profile=build/mingw-shared/default.profdata
```

Create package.

```sh
# Linux
cmake --build build/linux-static --config Release --target package

# Windows
cmake --build build/mingw-static --config Release --target package
```

</details>

## Editor
1. Configure editor according to [doc/editor.md](../../doc/editor.md).
2. Open project directory in editor.

## Template
Modify the project template.

1. Update this readme file.
2. Update `project` in [CMakeLists.txt](CMakeLists.txt).
3. Update `Project Headers` in [.clang-format](.clang-format).
4. Update sources and icon in [src](src).
5. Rename [src/ace](src/ace) to project namespace.
6. Add project and dependency licenses to resource files:
   - [res/license.txt](res/license.txt) for Linux
   - [res/license.rtf](res/license.rtf) for Windows

[ace]: https://github.com/qis/ace
[cov]: https://clang.llvm.org/docs/SourceBasedCodeCoverage.html
[pkg]: https://vcpkg.io/

# Template
C++ project template for the [Ace][ace] toolchain with modules support.

## CMake
Configure project.

```sh
# Linux
cmake --preset linux

# Linux & Windows
cmake --preset mingw
```

Build target.

```sh
# cmake --build build/<preset> --config <config> --target <target1> [target2]...
```

<details>

```sh
# Linux
cmake --build build/linux --config Debug --target main tests
cmake --build build/linux --config Release --target main tests benchmarks
cmake --build build/linux --config RelWithDebInfo --target main tests
cmake --build build/linux --config MinSizeRel --target main tests benchmarks
cmake --build build/linux --config Coverage --target tests

# Linux & Windows
cmake --build build/mingw --config Debug --target main tests
cmake --build build/mingw --config Release --target main tests benchmarks
cmake --build build/mingw --config RelWithDebInfo --target main tests
cmake --build build/mingw --config MinSizeRel --target main tests benchmarks
cmake --build build/mingw --config Coverage --target tests
```

Run application.

```sh
# Linux
build/linux/Debug/ace

# Linux Emulator
WINEDEBUG=-all \
WINEPATH=${ACE}/sys/mingw/bin \
wine build/mingw/Debug/ace.exe

# Windows
build\mingw\Debug\ace.exe
```

Run benchmarks.

```sh
# Linux
build/linux/Release/benchmarks

# Linux Emulator
WINEDEBUG=-all \
wine build/mingw/Release/benchmarks.exe

# Windows
build\mingw\Release\benchmarks.exe
```

Run tests.

```sh
# Linux
ctest --test-dir build/linux -C Debug

# Linux & Windows
ctest --test-dir build/mingw -C Debug
```

Analyze [Code Coverage][cov].

```sh
# Linux
ctest --test-dir build/linux -C Coverage
${ACE}/bin/llvm-profdata merge -sparse build/linux/default.profraw -o build/linux/default.profdata
${ACE}/bin/llvm-cov show build/linux/Coverage/tests -instr-profile=build/linux/default.profdata

# Linux Emulator
ctest --test-dir build/mingw -C Coverage
${ACE}/bin/llvm-profdata merge -sparse build/mingw/default.profraw -o build/mingw/default.profdata
${ACE}/bin/llvm-cov show build/mingw/Coverage/tests.exe -instr-profile=build/mingw/default.profdata

# Windows
ctest --test-dir build/mingw -C Coverage
%ACE%\bin\llvm-profdata.exe merge -sparse build/mingw/default.profraw -o build/mingw/default.profdata
%ACE%\bin\llvm-cov.exe show build/mingw/Coverage/tests.exe -instr-profile=build/mingw/default.profdata
```

Create package.

```sh
# Linux
cmake --build build/linux --config Release --target package

# Windows
cmake --build build/mingw --config Release --target package
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
[vsc]: https://code.visualstudio.com/
[cov]: https://clang.llvm.org/docs/SourceBasedCodeCoverage.html
[pkg]: https://vcpkg.io/

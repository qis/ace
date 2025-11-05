# Template
C++ project template for the [Ace][ace] toolchain with modules support.

## CMake
Build project and [coverage][cov] test.

```sh
res/build.sh
```

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

[ace]: https://github.com/qis/ace
[cov]: https://clang.llvm.org/docs/SourceBasedCodeCoverage.html

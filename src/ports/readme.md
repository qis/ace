# Ports
This documents describes the process of adding a new port.

Create a new directory in `src/ports`.

```sh
mkdir src/ports/portname && cd src/ports/portname
```

Create a `makefile` file with one of the following entries:
- A `src` target that checks out the source code into the `src` subdirectory.
- A `SRC` variable with a URL to a `.tar.gz` archive.

Download source code.

```sh
make src
```

Create a snapshot of the original source code.

```sh
cmake -E remove_directory src/.git
git -C src init && git -C src add . && git -C src commit -m original
```

Create the `share/license.txt` file with the name and license of the port.<br/>
Create the `share/license.rtf` file with the name and license of the port in RTF format.

1. The TXT file should be reformatted to 76 characters line width.
2. The RTF file should start with the exact contents of [cmake/Ace/license.rtf][head].
3. All trailing and double spaces in the middle a line should be removed.
4. If the license mentions a `CONTRIBUTORS` file or something similar, append it.

Create files in the `cmake` subdirectory (see other ports for examples).<br/>
Create a test project in the `check` subdirectory (see other ports for examples).

Modify original source code (checklist).

1. If there is no CMakeLists.txt, create one in the ports root directory.
   See [bzip2/CMakeLists.txt](bzip2/CMakeLists.txt) for an example.
2. If the CMakeLists.txt script supports building static and shared libraries
   in one go, make sure it respects the sysroot structure and STL linkage.
   Configure the project with `-DBUILD_SHARED_LIBS=ON`.

```cmake
set_target_properties(name_shared PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreadedDLL
  ARCHIVE_OUTPUT_DIRECTORY shared
  OUTPUT_NAME name)

set_target_properties(name_static PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreaded
  ARCHIVE_OUTPUT_DIRECTORY static
  OUTPUT_NAME name)

install(TARGETS name_shared
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib$<$<PLATFORM_ID:Windows>:/shared>
  LIBRARY DESTINATION lib$<$<PLATFORM_ID:Windows>:/shared>)

install(TARGETS name_static
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib$<$<PLATFORM_ID:Windows>:/static>
  LIBRARY DESTINATION lib$<$<PLATFORM_ID:Windows>:/static>)
```

3. If the CMakeLists.txt script supports building a shared or static library
   at once, make sure it respects the sysroot structure and STL linkage and
   configure the shared library project with `-DBUILD_SHARED_LIBS=ON`.

```cmake
if(BUILD_SHARED_LIBS)
  set(INSTALL_LIBDIR_SUFFIX $<$<PLATFORM_ID:Windows>:/shared>)
  set_target_properties(name PROPERTIES
    MSVC_RUNTIME_LIBRARY MultiThreadedDLL)
else()
  set(INSTALL_LIBDIR_SUFFIX $<$<PLATFORM_ID:Windows>:/static>)
  set_target_properties(name PROPERTIES
    MSVC_RUNTIME_LIBRARY MultiThreaded)
endif()

install(TARGETS name
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib${INSTALL_LIBDIR_SUFFIX}
  LIBRARY DESTINATION lib${INSTALL_LIBDIR_SUFFIX})
```

4. Remove everything that tries to create versioned libraries or rename them.

```cmake
# set_target_properties(name PROPERTIES
#   OUTPUT_NAME "name${BINARY_VERSION}"
#   VERSION ${BINARY_VERSION}.${BINARY_VERSION_MINOR}
#   SOVERSION ${BINARY_VERSION} ...)
# install(FILES $<TARGET_LINKER_FILE:name>
#   RENAME tbb_debug.lib ...)
```

5. Remove everything that tries to install CMake config files (after reproducing them).
6. Remove everything that tries to install pkgconfig files.
7. If tools are installed, make them link to the static library, change the
   installation path to `tools` and add a manifest file that switches
   non-wide APIs to UTF-8 mode.

```cmake
target_link_libraries(tool name_static)
set_target_properties(tool PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreaded)
install(TARGETS tool RUNTIME DESTINATION tools)
```

Install into the `test` subdirectory until the file structure is correct.

```sh
make test
tree test
```

Install port and build the test project.

```sh
make register
make check
```

Create patches if the original source code was modified.

```sh
git -C src diff CMakeLists.txt > patch-cmake.diff
git -C src diff generate.cmd generate.sh > patch-generate.diff
```

Add patches as dependencies to the `install` make target after `src`.

```make
build/build.ninja: src src/patch-cmake.diff src/patch-generate.diff
	@cmake -GNinja -Wno-dev \
	...
```

[head]: ../../cmake/Ace/license.rtf

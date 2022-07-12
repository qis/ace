@echo off

rem Bootstrap sysroot.
cmake -P src/stage.cmake

if %errorlevel% neq 0 exit /b %errorlevel%

rem Create tools archive.
make tools

if %errorlevel% neq 0 exit /b %errorlevel%

rem Create clang-format archive.
make clang-format

if %errorlevel% neq 0 exit /b %errorlevel%

rem Create sysroot archive.
make sys

if %errorlevel% neq 0 exit /b %errorlevel%

rem Register toolchain.
set PATH=C:\Ace\sys\x86_64-pc-windows-msvc\bin;%PATH%

rem Install ports.
make -C src/ports install

if %errorlevel% neq 0 exit /b %errorlevel%

rem Check ports linkage.
make -C src/ports check

if %errorlevel% neq 0 exit /b %errorlevel%

rem Create ports archive.
make ports

exit /b %errorlevel%

@echo off

rem Create tools archive.
make tools

if not exist tools-windows.tar.gz exit /b 1

rem Create clang-format archive.
make clang-format

if not exist tools-windows-clang-format.tar.gz exit /b 1

rem Create sysroot archive.
make sys

if not exist sys-x86_64-pc-windows-msvc.tar.gz exit /b 1

rem Register toolchain.
set PATH=C:\Ace\sys\x86_64-pc-windows-msvc\bin;%PATH%

rem Install ports.
make ports

if not exist sys-x86_64-pc-windows-msvc-ports.tar.gz exit /b 1

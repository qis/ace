@echo off

rem Create tools archive.
if not exist tools-windows.tar.gz cmd /C make tools
if not exist tools-windows.tar.gz exit /b 1

rem Create clang-format archive.
if not exist tools-windows-clang-format.tar.gz cmd /C make clang-format
if not exist tools-windows-clang-format.tar.gz exit /b 1

rem Create sysroot archive.
if not exist sys-x86_64-pc-windows-msvc.tar.gz cmd /C make sys
if not exist sys-x86_64-pc-windows-msvc.tar.gz exit /b 1

rem Install ports.
set PATH=%CD%\sys\x86_64-pc-windows-msvc\bin;%PATH%
if not exist sys-x86_64-pc-windows-msvc-ports.tar.gz make ports
if not exist sys-x86_64-pc-windows-msvc-ports.tar.gz exit /b 1

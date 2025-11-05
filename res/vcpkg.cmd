@echo off
for %%I in ("%~dp0..") do set "ACE=%%~fI"
set "VCPKG_ROOT=%ACE%\vcpkg"
set "VCPKG_DEFAULT_TRIPLET=mingw"
set "VCPKG_DEFAULT_HOST_TRIPLET=mingw"
set "VCPKG_OVERLAY_PORTS=%ACE%\res\ports"
set "VCPKG_OVERLAY_TRIPLETS=%ACE%\res\triplets"
set "VCPKG_FEATURE_FLAGS=-binarycaching"
set "VCPKG_FORCE_SYSTEM_BINARIES=1"
set "VCPKG_WORKS_SYSTEM_BINARIES=1"
set "VCPKG_DISABLE_METRICS=1"
"%ACE%\vcpkg\vcpkg.exe" %*

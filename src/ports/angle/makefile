include ../common.mk

ifeq ($(OS),Windows_NT)

# https://www.nuget.org/packages/ANGLE.WindowsStore
SRC := https://www.nuget.org/api/v2/package/ANGLE.WindowsStore/2.1.13

update: src
	@cmake -E make_directory "$(PREFIX)/bin" "$(PREFIX)/include"
	@cmake -E copy_directory src/EGL "$(PREFIX)/include/EGL"
	@cmake -E copy_directory src/GLES2 "$(PREFIX)/include/GLES2"
	@cmake -E copy_directory src/GLES3 "$(PREFIX)/include/GLES3"
	@cmake -E copy_directory src/KHR "$(PREFIX)/include/KHR"
	@cmake -E copy src/UAP/x64/libGLESv2.dll "$(PREFIX)/bin"
	@cmake -E copy src/UAP/x64/libEGL.dll "$(PREFIX)/bin"

register:
	@$(MAKE) share/angle

endif

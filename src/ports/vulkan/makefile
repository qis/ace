DISABLE_DOWNLOAD := 1
include ../common.mk

# https://github.com/KhronosGroup/Vulkan-Headers
src/headers:
	@git clone -c advice.detachedHead=false -b v1.3.219 \
	  --depth 1 --recurse-submodules --shallow-submodules \
	  https://github.com/KhronosGroup/Vulkan-Headers src/headers

# https://github.com/KhronosGroup/SPIRV-Headers
src/spirv-headers:
	@git clone -c advice.detachedHead=false -b sdk-1.3.216.0 \
	  --depth 1 --recurse-submodules --shallow-submodules \
	  https://github.com/KhronosGroup/SPIRV-Headers src/spirv-headers

# https://github.com/KhronosGroup/SPIRV-Tools
src/spirv-tools:
	@git clone -c advice.detachedHead=false -b v2022.2 \
	  --depth 1 --recurse-submodules --shallow-submodules \
	  https://github.com/KhronosGroup/SPIRV-Tools src/spirv-tools

# https://github.com/KhronosGroup/glslang
src/glslang:
	@git clone -c advice.detachedHead=false -b master-tot \
	  --depth 1 --recurse-submodules --shallow-submodules \
	  https://github.com/KhronosGroup/glslang src/glslang

# https://github.com/google/shaderc
src/shaderc:
	@git clone -c advice.detachedHead=false -b v2022.1 \
	  --depth 1 --recurse-submodules --shallow-submodules \
	  https://github.com/google/shaderc src/shaderc

src: src/headers src/spirv-headers src/spirv-tools src/glslang src/shaderc

build/headers/build.ninja: src src/patch-cmake.diff
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -B build/headers src/headers

build/shaderc/build.ninja: src src/patch-cmake.diff
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
	  -DCMAKE_TOOLCHAIN_FILE="$(TOOLCHAIN)" \
	  -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
	  -DCMAKE_INSTALL_RPATH="\$$ORIGIN/../lib" \
	  -DCMAKE_INSTALL_BINDIR="tools" \
	  -DSPIRV-Headers_SOURCE_DIR="$(CURDIR)/src/spirv-headers" \
	  -DSKIP_SPIRV_TOOLS_INSTALL=ON \
	  -DSPIRV_SKIP_TESTS=ON \
	  -DSPIRV_WERROR=OFF \
	  -DSKIP_GLSLANG_INSTALL=ON \
	  -DOVERRIDE_MSVCCRT=OFF \
	  -DSHADERC_SPIRV_TOOLS_DIR="$(CURDIR)/src/spirv-tools" \
	  -DSHADERC_GLSLANG_DIR="$(CURDIR)/src/glslang" \
	  -DSHADERC_SKIP_TESTS=ON \
	  -DSHADERC_SKIP_INSTALL=ON \
	  -DSHADERC_SKIP_EXAMPLES=ON \
	  -DSHADERC_ENABLE_WERROR_COMPILE=OFF \
	  -DSHADERC_ENABLE_SHARED_CRT=ON \
	  -B build/shaderc src/shaderc

GLSLANG_OUTPUT := build/shaderc/third_party/glslang/StandAlone
SPIRV_OUTPUT := build/shaderc/third_party/spirv-tools/tools

update: clean build/headers/build.ninja build/shaderc/build.ninja
	@ninja -C build/headers install
	@ninja -C build/shaderc
	@cmake -E make_directory "$(PREFIX)/tools"
	@cmake -E copy build/shaderc/glslc/glslc$(EXE) "$(PREFIX)/tools"
	@cmake -E copy $(GLSLANG_OUTPUT)/glslangValidator$(EXE) "$(PREFIX)/tools"
	@cmake -E copy $(GLSLANG_OUTPUT)/spirv-remap$(EXE) "$(PREFIX)/tools"
	@cmake -E copy $(SPIRV_OUTPUT)/spirv-as$(EXE) "$(PREFIX)/tools"
	@cmake -E copy $(SPIRV_OUTPUT)/spirv-dis$(EXE) "$(PREFIX)/tools"
	@cmake -E copy $(SPIRV_OUTPUT)/spirv-val$(EXE) "$(PREFIX)/tools"
	@cmake -E copy $(SPIRV_OUTPUT)/spirv-opt$(EXE) "$(PREFIX)/tools"
	@cmake -E copy $(SPIRV_OUTPUT)/spirv-cfg$(EXE) "$(PREFIX)/tools"
	@cmake -E copy $(SPIRV_OUTPUT)/spirv-link$(EXE) "$(PREFIX)/tools"
	@cmake -E copy $(SPIRV_OUTPUT)/spirv-lint$(EXE) "$(PREFIX)/tools"
	@cmake -E copy $(SPIRV_OUTPUT)/spirv-reduce$(EXE) "$(PREFIX)/tools"
	@cmake -E copy_directory src/spirv-headers/include/spirv "$(PREFIX)/include/spirv"

register:
	@$(MAKE) cmake/Vulkan
	@$(MAKE) share/vulkan

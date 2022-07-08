cmake_minimum_required(VERSION 3.22 FATAL_ERROR)
project(luajit VERSION 2.0.5 LANGUAGES C ASM)

set(LUA_DEFINITIONS)

if(WIN32)
  list(APPEND LUA_DEFINITIONS
    _CRT_SECURE_NO_WARNINGS)
endif()

if(UNIX)
  list(APPEND LUA_DEFINITIONS
    _DEFAULT_SOURCE
    _POSIX_C_SOURCE=200112L
    _FILE_OFFSET_BITS=64
    _LARGEFILE_SOURCE)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  list(APPEND LUA_DEFINITIONS
    _GNU_SOURCE)
endif()

set(LJLIB_S
  src/src/lib_base.c
  src/src/lib_math.c
  src/src/lib_bit.c
  src/src/lib_string.c
  src/src/lib_table.c
  src/src/lib_io.c
  src/src/lib_os.c
  src/src/lib_package.c
  src/src/lib_debug.c
  src/src/lib_jit.c
  src/src/lib_ffi.c)

set(LJVMCORE_S
  src/src/lj_gc.c
  src/src/lj_err.c
  src/src/lj_char.c
  src/src/lj_bc.c
  src/src/lj_obj.c
  src/src/lj_str.c
  src/src/lj_tab.c
  src/src/lj_func.c
  src/src/lj_udata.c
  src/src/lj_meta.c
  src/src/lj_debug.c
  src/src/lj_state.c
  src/src/lj_dispatch.c
  src/src/lj_vmevent.c
  src/src/lj_vmmath.c
  src/src/lj_strscan.c
  src/src/lj_api.c
  src/src/lj_lex.c
  src/src/lj_parse.c
  src/src/lj_bcread.c
  src/src/lj_bcwrite.c
  src/src/lj_load.c
  src/src/lj_ir.c
  src/src/lj_opt_mem.c
  src/src/lj_opt_fold.c
  src/src/lj_opt_narrow.c
  src/src/lj_opt_dce.c
  src/src/lj_opt_loop.c
  src/src/lj_opt_split.c
  src/src/lj_opt_sink.c
  src/src/lj_mcode.c
  src/src/lj_snap.c
  src/src/lj_record.c
  src/src/lj_crecord.c
  src/src/lj_ffrecord.c
  src/src/lj_asm.c
  src/src/lj_trace.c
  src/src/lj_gdbjit.c
  src/src/lj_ctype.c
  src/src/lj_cdata.c
  src/src/lj_cconv.c
  src/src/lj_ccall.c
  src/src/lj_ccallback.c
  src/src/lj_carith.c
  src/src/lj_clib.c
  src/src/lj_cparse.c
  src/src/lj_lib.c
  src/src/lj_alloc.c
  src/src/lib_aux.c
  src/src/lib_init.c
  ${LJLIB_S})

set(BUILDVM_S
  src/src/host/buildvm.c
  src/src/host/buildvm_asm.c
  src/src/host/buildvm_peobj.c
  src/src/host/buildvm_lib.c
  src/src/host/buildvm_fold.c)

set(BUILDVM_H
  ${CMAKE_CURRENT_BINARY_DIR}/src/buildvm_arch.h)

set(HEADERS
  ${CMAKE_CURRENT_BINARY_DIR}/src/lj_bcdef.h
  ${CMAKE_CURRENT_BINARY_DIR}/src/lj_ffdef.h
  ${CMAKE_CURRENT_BINARY_DIR}/src/lj_libdef.h
  ${CMAKE_CURRENT_BINARY_DIR}/src/lj_recdef.h
  ${CMAKE_CURRENT_BINARY_DIR}/src/lj_folddef.h)

set(VMDEF_SCRIPT
  ${CMAKE_CURRENT_BINARY_DIR}/jit/vmdef.lua)

# minilua
add_executable(minilua src/src/host/minilua.c)

if(MSVC)
  target_compile_definitions(minilua PRIVATE _CRT_SECURE_NO_WARNINGS)
  set_target_properties(minilua PROPERTIES MSVC_RUNTIME_LIBRARY MultiThreaded)
endif()

if(UNIX)
  target_link_libraries(minilua PRIVATE m)
endif()

set(DASM_FLAGS -D P64 -D JIT -D FPU)

if(WIN32)
  list(APPEND DASM_FLAGS -D WIN)
endif()

# src/buildvm_arch.h
add_custom_command(OUTPUT ${BUILDVM_H}
  COMMAND $<TARGET_FILE:minilua> src/dynasm/dynasm.lua
    ${DASM_FLAGS} -o ${BUILDVM_H} src/src/vm_x86.dasc
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  DEPENDS minilua
  USES_TERMINAL)

# buildvm
add_executable(buildvm ${BUILDVM_S}
  ${CMAKE_CURRENT_BINARY_DIR}/src/buildvm_arch.h)

target_include_directories(buildvm PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/src/src/host
  ${CMAKE_CURRENT_SOURCE_DIR}/src/src
  ${CMAKE_CURRENT_BINARY_DIR}/src)

if(MSVC)
  target_compile_definitions(buildvm PRIVATE _CRT_SECURE_NO_WARNINGS)
  set_target_properties(buildvm PROPERTIES MSVC_RUNTIME_LIBRARY MultiThreaded)
endif()

# jit/vmdef.lua
add_custom_command(OUTPUT ${VMDEF_SCRIPT}
  COMMAND $<TARGET_FILE:buildvm> -m vmdef -o ${VMDEF_SCRIPT} ${LJLIB_S}
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  DEPENDS buildvm
  USES_TERMINAL)

if(WIN32)
  set(JVM_MODE peobj)
  set(LJVM_O ${CMAKE_CURRENT_BINARY_DIR}/src/lj_vm.o)
elseif(UNIX)
  set(JVM_MODE elfasm)
  set(LJVM_O ${CMAKE_CURRENT_BINARY_DIR}/src/lj_vm.s)
endif()

# src/lj_vm.s
add_custom_command(OUTPUT ${LJVM_O}
  COMMAND $<TARGET_FILE:buildvm> -m ${JVM_MODE} -o ${LJVM_O}
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  DEPENDS buildvm
  USES_TERMINAL)

# src/lj_bcdef.h
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/src/lj_bcdef.h
  COMMAND $<TARGET_FILE:buildvm> -m bcdef -o
    ${CMAKE_CURRENT_BINARY_DIR}/src/lj_bcdef.h ${LJLIB_S}
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  DEPENDS buildvm
  USES_TERMINAL)

# src/lj_ffdef.h
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/src/lj_ffdef.h
  COMMAND $<TARGET_FILE:buildvm> -m ffdef -o
    ${CMAKE_CURRENT_BINARY_DIR}/src/lj_ffdef.h ${LJLIB_S}
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  DEPENDS buildvm
  USES_TERMINAL)

# src/lj_libdef.h
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/src/lj_libdef.h
  COMMAND $<TARGET_FILE:buildvm> -m libdef -o
    ${CMAKE_CURRENT_BINARY_DIR}/src/lj_libdef.h ${LJLIB_S}
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  DEPENDS buildvm
  USES_TERMINAL)

# src/lj_recdef.h
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/src/lj_recdef.h
  COMMAND $<TARGET_FILE:buildvm> -m recdef -o
    ${CMAKE_CURRENT_BINARY_DIR}/src/lj_recdef.h ${LJLIB_S}
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  DEPENDS buildvm
  USES_TERMINAL)

# src/lj_folddef.h
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/src/lj_folddef.h
  COMMAND $<TARGET_FILE:buildvm> -m folddef -o
    ${CMAKE_CURRENT_BINARY_DIR}/src/lj_folddef.h ${LJLIB_S}
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  DEPENDS buildvm
  USES_TERMINAL)

# luajit (shared)
add_library(luajit_shared SHARED ${HEADERS} ${LJVMCORE_S} ${LJVM_O})
target_include_directories(luajit_shared PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/src PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/src>
  $<INSTALL_INTERFACE:include>)

if(MSVC)
  target_compile_definitions(luajit_shared PRIVATE ${LUA_DEFINITIONS})
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  target_compile_definitions(luajit_shared PRIVATE LUAJIT_OS=LUAJIT_OS_LINUX ${LUA_DEFINITIONS})
  target_compile_options(luajit_shared PRIVATE -fomit-frame-pointer -fno-stack-protector)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  target_compile_definitions(luajit_shared PRIVATE LUAJIT_OS=LUAJIT_OS_WINDOWS WIN NOMINMAX)
endif()

if(WIN32)
  target_compile_definitions(luajit_shared PUBLIC LUA_BUILD_AS_DLL)
endif()

target_compile_definitions(luajit_shared PRIVATE LJ_ARCH_HASFPU=1)
target_compile_options(luajit_shared PRIVATE -Wno-unused-command-line-argument)

set_target_properties(luajit_shared PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreadedDLL
  ARCHIVE_OUTPUT_DIRECTORY shared
  OUTPUT_NAME luajit)

install(TARGETS luajit_shared
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib$<$<PLATFORM_ID:Windows>:/shared>
  LIBRARY DESTINATION lib$<$<PLATFORM_ID:Windows>:/shared>)

# luajit (static)
add_library(luajit_static STATIC ${HEADERS} ${LJVMCORE_S} ${LJVM_O})
target_include_directories(luajit_static PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/src PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/src>
  $<INSTALL_INTERFACE:include>)

if(MSVC)
  target_compile_definitions(luajit_static PRIVATE ${LUA_DEFINITIONS})
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  target_compile_definitions(luajit_static PRIVATE LUAJIT_OS=LUAJIT_OS_LINUX ${LUA_DEFINITIONS})
  target_compile_options(luajit_static PRIVATE -fomit-frame-pointer -fno-stack-protector)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  target_compile_definitions(luajit_static PRIVATE LUAJIT_OS=LUAJIT_OS_WINDOWS WIN NOMINMAX)
endif()

target_compile_definitions(luajit_static PRIVATE LJ_ARCH_HASFPU=1)
target_compile_options(luajit_static PRIVATE -Wno-unused-command-line-argument)

set_target_properties(luajit_static PROPERTIES
  MSVC_RUNTIME_LIBRARY MultiThreaded
  ARCHIVE_OUTPUT_DIRECTORY static
  OUTPUT_NAME luajit)

install(TARGETS luajit_static
  ARCHIVE DESTINATION lib$<$<PLATFORM_ID:Windows>:/static>
  LIBRARY DESTINATION lib$<$<PLATFORM_ID:Windows>:/static>)

# luajit (executable)
add_executable(luajit src/src/luajit.c ${VMDEF_SCRIPT})
target_link_libraries(luajit PRIVATE luajit_static)

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  target_link_libraries(luajit PRIVATE -l:libc++.a -lm)
endif()

target_compile_options(luajit PRIVATE -Wno-deprecated-declarations)

target_include_directories(luajit PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/src/src
  ${CMAKE_CURRENT_BINARY_DIR}/src)

if(MSVC)
  target_compile_definitions(luajit PRIVATE _CRT_SECURE_NO_WARNINGS)
  set_target_properties(luajit PROPERTIES MSVC_RUNTIME_LIBRARY MultiThreaded)
endif()

set_target_properties(luajit PROPERTIES INSTALL_RPATH "$ORIGIN/../lib")

install(TARGETS luajit RUNTIME DESTINATION tools)

install(FILES
  src/src/lua.h
  src/src/luaconf.h
  src/src/lauxlib.h
  src/src/luajit.h
  src/src/lualib.h
  src/src/lua.hpp
  DESTINATION include/luajit)

file(GLOB JIT_SCRIPTS src/src/jit/*.lua)
install(FILES ${JIT_SCRIPTS} ${VMDEF_SCRIPT} DESTINATION share/luajit/jit)

get_filename_component(ACE ${CMAKE_CURRENT_LIST_DIR}/.. ABSOLUTE)
set(ACE_ROOT "${ACE}/sys/x86_64-pc-windows-msvc")

# Set download URLs.
set(MAKE_URL "https://community.chocolatey.org/api/v2/package/make/4.3")
set(NINJA_URL "https://github.com/ninja-build/ninja/releases/download/v1.11.0/ninja-win.zip")

# Find executables.
find_program(P7Z_EXECUTABLE 7z.exe REQUIRED)
find_program(CURL_EXECUTABLE curl.exe REQUIRED)

# Find VS 2022 installation.
set(VS2022_ROOT "$ENV{ProgramFiles}/Microsoft Visual Studio/2022")
if(NOT IS_DIRECTORY ${VS2022_ROOT})
  message(FATAL_ERROR "Could not find VS 2022 installation in ${VS2022_ROOT}")
endif()

# Find VS 2022 MSVC directory.
if(IS_DIRECTORY ${VS2022_ROOT}/Enterprise/VC/Tools/MSVC)
  set(MSVC_ROOT ${VS2022_ROOT}/Enterprise/VC/Tools/MSVC)
elseif(IS_DIRECTORY ${VS2022_ROOT}/Professional/VC/Tools/MSVC)
  set(MSVC_ROOT ${VS2022_ROOT}/Professional/VC/Tools/MSVC)
elseif(IS_DIRECTORY ${VS2022_ROOT}/Community/VC/Tools/MSVC)
  set(MSVC_ROOT ${VS2022_ROOT}/Community/VC/Tools/MSVC)
else()
  message(FATAL_ERROR "Could not find VS 2022 edition in ${VS2022_ROOT}")
endif()

# Find VS 2022 MSVC CRT directory.
file(GLOB CRT_DIRECTORIES ${MSVC_ROOT}/*)
if(NOT CRT_DIRECTORIES)
  message(FATAL_ERROR "Could not find MSVC version in ${MSVC_ROOT}")
endif()

set(CRT_VERSION)
foreach(CRT_DIRECTORY_PATH ${CRT_DIRECTORIES})
  get_filename_component(CRT_DIRECTORY_NAME "${CRT_DIRECTORY_PATH}" NAME)
  if(NOT CRT_VERSION OR CRT_DIRECTORY_NAME VERSION_GREATER "${CRT_VERSION}")
    set(CRT_VERSION ${CRT_DIRECTORY_NAME})
  endif()
endforeach()
set(CRT_ROOT "${MSVC_ROOT}/${CRT_VERSION}")

# Create list of VS 2022 MSVC CRT installation files.
set(CRT_INSTALL_FILES)
file(GLOB CRT_FILES ${CRT_ROOT}/lib/x64/*)
foreach(CRT_FILE_PATH ${CRT_FILES})
  if(IS_DIRECTORY ${CRT_FILE_PATH})
    continue()
  endif()
  get_filename_component(CRT_FILE_NAME ${CRT_FILE_PATH} NAME)
  if(CRT_FILE_NAME MATCHES "^clang_rt")
    continue()
  endif()
  get_filename_component(CRT_FILE_EXTENSION ${CRT_FILE_NAME} LAST_EXT)
  if(NOT CRT_FILE_EXTENSION STREQUAL ".lib" AND
    NOT CRT_FILE_EXTENSION STREQUAL ".pdb" AND
    NOT CRT_FILE_EXTENSION STREQUAL ".obj")
    continue()
  endif()
  list(APPEND CRT_INSTALL_FILES ${CRT_FILE_PATH})
endforeach()

# Find lib.exe (required for libxml2 from conan).
find_program(LIB_EXECUTABLE lib.exe PATHS ${CRT_ROOT}/bin/Hostx64/x64 REQUIRED)

# Copy VS 2022 assembler executable.
if(NOT EXISTS ${ACE_ROOT}/bin/ml64.exe)
  message(STATUS "Copying VS 2022 assembler executable ...")
  file(COPY ${CRT_ROOT}/bin/Hostx64/x64/ml64.exe DESTINATION ${ACE_ROOT}/bin)
endif()

# Copy VS 2022 MSVC CRT files.
if(NOT EXISTS ${ACE_ROOT}/crt/lib/libcpmt.lib)
  message(STATUS "Copying VS 2022 MSVC CRT include files ...")
  file(COPY ${CRT_ROOT}/include DESTINATION ${ACE_ROOT}/crt)

  message(STATUS "Copying VS 2022 MSVC CRT lib files ...")
  file(COPY ${CRT_INSTALL_FILES} DESTINATION ${ACE_ROOT}/crt/lib)

  message(STATUS "Writing ${ACE_ROOT}/crt/version.txt ...")
  file(WRITE ${ACE_ROOT}/crt/version.txt "${CRT_VERSION}\n")
endif()

# Copy Windows 11 SDK files.
if(NOT EXISTS ${ACE_ROOT}/sdk/lib/um/kernel32.Lib)
  # Find Windows 11 SDK directory.
  set(PROGRAM_FILES_X86 "ProgramFiles(x86)")
  set(SDK_ROOT "$ENV{${PROGRAM_FILES_X86}}/Windows Kits/10")
  if(NOT IS_DIRECTORY ${SDK_ROOT})
    message(FATAL_ERROR "Could not find Windows 11 SDK installation in ${SDK_ROOT}")
  endif()

  file(GLOB SDK_DIRECTORIES ${SDK_ROOT}/Include/* ${SDK_ROOT}/Lib/*)
  if(NOT SDK_DIRECTORIES)
    message(FATAL_ERROR "Could not find Windows 11 SDK version in ${SDK_ROOT}")
  endif()

  # Find Windows 11 SDK version.
  set(SDK_VERSIONS)
  foreach(SDK_DIRECTORY_PATH ${SDK_DIRECTORIES})
    get_filename_component(SDK_DIRECTORY_NAME "${SDK_DIRECTORY_PATH}" NAME)
    list(APPEND SDK_VERSIONS ${SDK_DIRECTORY_NAME})
  endforeach()
  list(REMOVE_DUPLICATES SDK_VERSIONS)

  set(SDK_VERSION)
  foreach(SDK_VERSION_STRING ${SDK_VERSIONS})
    if(NOT EXISTS ${SDK_ROOT}/Include/${SDK_VERSION_STRING}/ucrt/assert.h OR
      NOT EXISTS ${SDK_ROOT}/Lib/${SDK_VERSION_STRING}/ucrt/x64/libucrt.lib)
      continue()
    endif()
    if(NOT SDK_VERSION OR SDK_VERSION_STRING VERSION_GREATER "${SDK_VERSION}")
      set(SDK_VERSION ${SDK_VERSION_STRING})
    endif()
  endforeach()
  if(NOT SDK_VERSION)
    message(FATAL_ERROR "Could not find Windows 11 SDK version with ucrt in ${SDK_ROOT}")
  endif()

  message(STATUS "Copying Windows 11 SDK bin files ...")
  file(COPY ${SDK_ROOT}/bin/${SDK_VERSION}/x64 DESTINATION ${ACE_ROOT}/sdk)
  file(RENAME ${ACE_ROOT}/sdk/x64 ${ACE_ROOT}/sdk/bin)

  message(STATUS "Copying Windows 11 SDK include files ...")
  file(COPY ${SDK_ROOT}/Include/${SDK_VERSION}/shared DESTINATION ${ACE_ROOT}/sdk/include)
  file(COPY ${SDK_ROOT}/Include/${SDK_VERSION}/ucrt DESTINATION ${ACE_ROOT}/sdk/include)
  file(COPY ${SDK_ROOT}/Include/${SDK_VERSION}/um DESTINATION ${ACE_ROOT}/sdk/include)

  message(STATUS "Copying Windows 11 SDK lib files ...")
  file(COPY ${SDK_ROOT}/Lib/${SDK_VERSION}/ucrt/x64 DESTINATION ${ACE_ROOT}/sdk/lib)
  file(RENAME ${ACE_ROOT}/sdk/lib/x64 ${ACE_ROOT}/sdk/lib/ucrt)

  file(COPY ${SDK_ROOT}/Lib/${SDK_VERSION}/um/x64 DESTINATION ${ACE_ROOT}/sdk/lib)
  file(RENAME ${ACE_ROOT}/sdk/lib/x64 ${ACE_ROOT}/sdk/lib/um)

  message(STATUS "Writing ${ACE_ROOT}/sdk/version.txt ...")
  file(APPEND ${ACE_ROOT}/sdk/version.txt "${SDK_VERSION}\n")
endif()

# Copy Windows 11 SDK manifest compiler.
if(NOT EXISTS ${ACE_ROOT}/bin/mt.exe)
  message(STATUS "Copying Windows 11 SDK manifest compiler ...")
  file(COPY
    ${SDK_ROOT}/bin/${SDK_VERSION}/x64/mt.exe
    ${SDK_ROOT}/bin/${SDK_VERSION}/x64/mt.exe.config
    ${SDK_ROOT}/bin/${SDK_VERSION}/x64/midlrtmd.dll
    DESTINATION ${ACE_ROOT}/bin)
endif()

# Create build directory.
if(NOT EXISTS build)
  file(MAKE_DIRECTORY build)
endif()

# Download make.
if(NOT EXISTS bin/make.exe)
  if(NOT EXISTS build/make/tools/install/bin/make.exe)
    if(NOT EXISTS build/make.nupkg)
      message(STATUS "Downloading build/make.nupkg ...")
      execute_process(COMMAND "${CURL_EXECUTABLE}" -L "${MAKE_URL}"
        -o build/make.nupkg COMMAND_ERROR_IS_FATAL ANY)
    endif()

    message(STATUS "Extracting build/make.nupkg ...")
    file(MAKE_DIRECTORY build/make)
    execute_process(COMMAND "${P7Z_EXECUTABLE}" x ../make.nupkg
      WORKING_DIRECTORY build/make COMMAND_ERROR_IS_FATAL ANY)
  endif()
  message(STATUS "Installing bin/make.exe ...")
  file(COPY build/make/tools/install/bin/make.exe DESTINATION bin)
endif()

# Download ninja.
if(NOT EXISTS bin/ninja.exe)
  if(NOT EXISTS build/ninja.zip)
    message(STATUS "Downloading build/ninja.zip ...")
    execute_process(COMMAND "${CURL_EXECUTABLE}" -L "${NINJA_URL}"
      -o build/ninja.zip COMMAND_ERROR_IS_FATAL ANY)
  endif()
  message(STATUS "Installing bin/ninja.exe ...")
  execute_process(COMMAND "${P7Z_EXECUTABLE}" x ../build/ninja.zip
    WORKING_DIRECTORY bin COMMAND_ERROR_IS_FATAL ANY)
endif()

# Download dependencies.
if(NOT EXISTS build/usr/lib/libxml2.lib)
  if(NOT EXISTS build/usr/lib/zlib.lib)
    message(STATUS "Downloading dependencies ...")
    foreach(lib "zlib/[x]" "libxml2/[x]" "xz_utils/[x]" "swig/[x]")
      execute_process(COMMAND conan install
        -if build/usr/src
        -s compiler.runtime=MT
        -s compiler.version=16
        -g deploy
        "${lib}@"
        COMMAND_ERROR_IS_FATAL ANY)
    endforeach()
    message(STATUS "Installing dependencies ...")
    file(GLOB CONAN_DIRECTORIES build/usr/src/*)
    foreach(dir ${CONAN_DIRECTORIES})
      if(NOT IS_DIRECTORY ${dir})
        continue()
      endif()
      if(IS_DIRECTORY ${dir}/bin)
        file(COPY ${dir}/bin DESTINATION build/usr)
      endif()
      if(IS_DIRECTORY ${dir}/include)
        file(COPY ${dir}/include DESTINATION build/usr)
      endif()
      if(IS_DIRECTORY ${dir}/lib)
        file(COPY ${dir}/lib DESTINATION build/usr)
      endif()
    endforeach()
  endif()
  message(STATUS "Merging iconv.lib into libxml2.lib ...")
  execute_process(COMMAND "${LIB_EXECUTABLE}" /nologo
    /OUT:build/usr/lib/libxml2.lib
         build/usr/lib/libxml2_a.lib
         build/usr/lib/iconv.lib
    COMMAND_ERROR_IS_FATAL ANY)
  file(REMOVE build/usr/lib/libxml2_a.lib)
endif()

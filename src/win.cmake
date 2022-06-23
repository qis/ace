set(MAKE_URL "https://community.chocolatey.org/api/v2/package/make/4.3")

find_program(P7Z_EXECUTABLE 7z.exe REQUIRED)
find_program(CURL_EXECUTABLE curl.exe REQUIRED)
find_program(LIB_EXECUTABLE lib.exe REQUIRED)

# Copy VS 2022 MSVC CRT files.
if(NOT EXISTS win/crt/lib/libcpmt.lib)
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

  message(STATUS "Copying VS 2022 MSVC CRT include files ...")
  file(COPY ${CRT_ROOT}/include DESTINATION win/crt)

  message(STATUS "Copying VS 2022 MSVC CRT lib files ...")
  file(COPY ${CRT_INSTALL_FILES} DESTINATION win/crt/lib)

  message(STATUS "Writing win/crt/version.txt ...")
  file(WRITE win/crt/version.txt "${CRT_VERSION}\n")
endif()

# Copy Windows 10 SDK files.
if(NOT EXISTS win/sdk/lib/um/kernel32.Lib)
  # Find Windows 10 SDK directory.
  set(PROGRAM_FILES_X86 "ProgramFiles(x86)")
  set(SDK_ROOT "$ENV{${PROGRAM_FILES_X86}}/Windows Kits/10")
  if(NOT IS_DIRECTORY ${SDK_ROOT})
    message(FATAL_ERROR "Could not find Windows 10 SDK installation in ${SDK_ROOT}")
  endif()

  file(GLOB SDK_DIRECTORIES ${SDK_ROOT}/Include/* ${SDK_ROOT}/Lib/*)
  if(NOT SDK_DIRECTORIES)
    message(FATAL_ERROR "Could not find Windows 10 SDK version in ${SDK_ROOT}")
  endif()

  # Find Windows 10 SDK version.
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
    message(FATAL_ERROR "Could not find Windows 10 SDK version with ucrt in ${SDK_ROOT}")
  endif()

  message(STATUS "Copying Windows 10 SDK bin files ...")
  file(COPY ${SDK_ROOT}/bin/${SDK_VERSION}/x64 DESTINATION win/sdk)
  file(RENAME win/sdk/x64 win/sdk/bin)

  message(STATUS "Copying Windows 10 SDK include files ...")
  file(COPY ${SDK_ROOT}/Include/${SDK_VERSION}/shared DESTINATION win/sdk/include)
  file(COPY ${SDK_ROOT}/Include/${SDK_VERSION}/ucrt DESTINATION win/sdk/include)
  file(COPY ${SDK_ROOT}/Include/${SDK_VERSION}/um DESTINATION win/sdk/include)

  message(STATUS "Copying Windows 10 SDK lib files ...")
  file(COPY ${SDK_ROOT}/Lib/${SDK_VERSION}/ucrt/x64 DESTINATION win/sdk/lib)
  file(RENAME win/sdk/lib/x64 win/sdk/lib/ucrt)

  file(COPY ${SDK_ROOT}/Lib/${SDK_VERSION}/um/x64 DESTINATION win/sdk/lib)
  file(RENAME win/sdk/lib/x64 win/sdk/lib/um)

  message(STATUS "Writing win/sdk/version.txt ...")
  file(APPEND win/sdk/version.txt "${SDK_VERSION}\n")
endif()

# Download make.
if(NOT EXISTS bin/make.exe)
  if(NOT EXISTS build/make/tools/install/bin/make.exe)
    if(NOT EXISTS src/make.nupkg)
      message(STATUS "Downloading src/make.nupkg ...")
      execute_process(COMMAND "${CURL_EXECUTABLE}" -L "${MAKE_URL}" -o src/make.nupkg COMMAND_ERROR_IS_FATAL ANY)
    endif()

    message(STATUS "Extracting src/make.nupkg ...")
    file(MAKE_DIRECTORY build/make)
    execute_process(COMMAND "${P7Z_EXECUTABLE}" x ${CMAKE_CURRENT_LIST_DIR}/make.nupkg
      WORKING_DIRECTORY build/make COMMAND_ERROR_IS_FATAL ANY)
  endif()
  message(STATUS "Installing bin/make.exe ...")
  file(COPY build/make/tools/install/bin/make.exe DESTINATION bin)
endif()

# Download ninja.
set(NINJA_URL "https://github.com/ninja-build/ninja/releases/download/v1.11.0/ninja-win.zip")
if(NOT EXISTS bin/ninja.exe)
  if(NOT EXISTS src/ninja.zip)
    message(STATUS "Downloading src/ninja.zip ...")
    execute_process(COMMAND "${CURL_EXECUTABLE}" -L "${NINJA_URL}" -o src/ninja.zip COMMAND_ERROR_IS_FATAL ANY)
  endif()
  message(STATUS "Installing bin/ninja.exe ...")
  execute_process(COMMAND "${P7Z_EXECUTABLE}" x ${CMAKE_CURRENT_LIST_DIR}/ninja.zip
    WORKING_DIRECTORY bin COMMAND_ERROR_IS_FATAL ANY)
endif()

# Download dependencies.
if(NOT EXISTS win/usr)
  if(NOT EXISTS build/usr)
    message(STATUS "Downloading dependencies ...")
    foreach(lib "zlib/[x]" "libxml2/[x]" "xz_utils/[x]")
      execute_process(COMMAND conan install
        -if build/usr
        -s compiler.runtime=MT
        -s compiler.version=16
        -g deploy
        "${lib}@"
        COMMAND_ERROR_IS_FATAL ANY)
    endforeach()
  endif()
  message(STATUS "Installing dependencies ...")
  file(GLOB CONAN_DIRECTORIES build/usr/*)
  foreach(dir ${CONAN_DIRECTORIES})
    if(NOT IS_DIRECTORY ${dir})
      continue()
    endif()
    if(IS_DIRECTORY ${dir}/bin)
      file(COPY ${dir}/bin DESTINATION win/usr)
    endif()
    if(IS_DIRECTORY ${dir}/include)
      file(COPY ${dir}/include DESTINATION win/usr)
    endif()
    if(IS_DIRECTORY ${dir}/lib)
      file(COPY ${dir}/lib DESTINATION win/usr)
    endif()
  endforeach()
  message(STATUS "Merging iconv.lib into libxml2.lib ...")
  execute_process(COMMAND ${LIB_EXECUTABLE} /OUT:win/usr/lib/libxml2.lib
    win/usr/lib/libxml2_a.lib
    win/usr/lib/iconv.lib
    COMMAND_ERROR_IS_FATAL ANY)
  file(REMOVE win/usr/lib/libxml2_a.lib)
endif()

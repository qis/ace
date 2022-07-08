# Creates license files in OUTPUT directory using RTF and TXT config files
# as inputs and inserts formatted license text for all PORTS.
#
# ace_create_license(<OUTPUT>
#   [RTF file]
#   [TXT file]
#   [PORTS port1 [port2 ...])
#
# Requirements
#
# * The RTF and TXT files must have the string "${THIRD_PARTY_LICENSES}"
#   present.
#
# * The TXT file should be 76 characters wide.
#
# * The RTF file must start with the exact text from the following file:
#   - ${CMAKE_MODULE_PATH}/Ace/license.rtf
#
# * A conforming port share directory must contain the following files:
#   - license.rtf
#   - license.txt
#

function(ace_check_license_head LICENSE_FILE LICENSE_HEAD_EXPECTED)
  string(LENGTH "${LICENSE_HEAD_EXPECTED}" LICENSE_HEAD_LENGTH)
  file(READ ${LICENSE_FILE} LICENSE_HEAD LIMIT ${LICENSE_HEAD_LENGTH})

  if(NOT "${LICENSE_HEAD}" STREQUAL "${LICENSE_HEAD_EXPECTED}")
    message(VERBOSE "Expected license head:\n\n${LICENSE_HEAD_EXPECTED}")
    message(VERBOSE "Observed license head:\n\n${LICENSE_HEAD}")
    message(FATAL_ERROR "Invalid license head: ${LICENSE_FILE}")
  endif()
endfunction()

function(ace_append_license OUTPUT LICENSE_FILE LICENSE_HEAD_EXPECTED)
  ace_check_license_head(${LICENSE_FILE} "${LICENSE_HEAD_EXPECTED}")
  string(LENGTH "${LICENSE_HEAD_EXPECTED}" LICENSE_HEAD_LENGTH)

  file(READ ${LICENSE_FILE} LICENSE_TEXT OFFSET ${LICENSE_HEAD_LENGTH})
  string(FIND "${LICENSE_TEXT}" "}" LICENSE_END REVERSE)

  if(NOT LICENSE_END GREATER 0)
    message(VERBOSE "License text:\n${LICENSE_TEXT}")
    message(FATAL_ERROR "License file missing closing brace '}': ${LICENSE_FILE}")
  endif()

  string(SUBSTRING "${LICENSE_TEXT}" 0 ${LICENSE_END} LICENSE_TEXT)
  string(STRIP "${LICENSE_TEXT}" LICENSE_TEXT)
  string(APPEND ${OUTPUT} "${LICENSE_TEXT}")
  set(${OUTPUT} "${${OUTPUT}}" PARENT_SCOPE)
endfunction()

function(ace_create_license OUTPUT)
  cmake_parse_arguments(PARSE_ARGV 1 LICENSE "" "RTF;TXT" "PORTS")


  list(REMOVE_DUPLICATES LICENSE_PORTS)

  if(LICENSE_RTF)
    find_file(LICENSE_HEAD_FILE Ace/license.rtf PATHS ${CMAKE_MODULE_PATH} REQUIRED)
    file(READ ${LICENSE_HEAD_FILE} LICENSE_HEAD_EXPECTED)
    ace_check_license_head(${LICENSE_RTF} "${LICENSE_HEAD_EXPECTED}")
  endif()

  set(THIRD_PARTY_LICENSES_RTF "")
  set(THIRD_PARTY_LICENSES_TXT "")

  set(FIRST_PORT ON)
  foreach(PORT ${LICENSE_PORTS})
    find_file(PORT_RTF_LICENSE NAMES "license.rtf" PATHS
      ${ACE_TARGET_ROOT}/share/${PORT} NO_DEFAULT_PATH NO_CACHE)
    find_file(PORT_TXT_LICENSE NAMES "license.txt" PATHS
      ${ACE_TARGET_ROOT}/share/${PORT} NO_DEFAULT_PATH NO_CACHE)

    if(LICENSE_RTF)
      if(PORT_RTF_LICENSE)
        if(NOT FIRST_PORT)
          string(APPEND THIRD_PARTY_LICENSES_RTF "\n\n")
        endif()
        ace_append_license(THIRD_PARTY_LICENSES_RTF
          ${PORT_RTF_LICENSE} "${LICENSE_HEAD_EXPECTED}")
      else()
        message(WARNING "Missing license file: ${ACE_TARGET_ROOT}/share/${PORT}/license.rtf")
      endif()
    endif()

    if(LICENSE_TXT)
      if(PORT_TXT_LICENSE)
        if(NOT FIRST_PORT)
          string(APPEND THIRD_PARTY_LICENSES_TXT "\n\n")
        endif()
        file(READ ${PORT_TXT_LICENSE} LICENSE_TEXT)
        string(STRIP "${LICENSE_TEXT}" LICENSE_TEXT)
        string(APPEND THIRD_PARTY_LICENSES_TXT "${LICENSE_TEXT}")
      else()
        message(WARNING "Missing license file: ${ACE_TARGET_ROOT}/share/${PORT}/license.txt")
      endif()
    endif()

    unset(PORT_RTF_LICENSE)
    unset(PORT_TXT_LICENSE)

    set(FIRST_PORT OFF)
  endforeach()

  get_filename_component(NAME ${LICENSE_RTF} NAME_WE)

  if(LICENSE_RTF)
    message(VERBOSE "Writing license: ${OUTPUT}/${NAME}.rtf")
    set(THIRD_PARTY_LICENSES "${THIRD_PARTY_LICENSES_RTF}")
    configure_file(${LICENSE_RTF} ${OUTPUT}/${NAME}.rtf LF)
  endif()

  if(LICENSE_TXT)
    message(VERBOSE "Writing license: ${OUTPUT}/${NAME}.txt")
    set(THIRD_PARTY_LICENSES "${THIRD_PARTY_LICENSES_TXT}")
    configure_file(${LICENSE_TXT} ${OUTPUT}/${NAME}.txt LF)
  endif()
endfunction()

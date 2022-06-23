set(CMAKE_EXECUTABLE_SUFFIX ".wasm")

find_program(WASM2JS_EXECUTABLE wasm2js)

foreach(lang C CXX)
  set(CMAKE_${lang}_IMPORT_FILE_PREFIX "")
  set(CMAKE_${lang}_IMPORT_FILE_SUFFIX ".js")
  set(CMAKE_${lang}_LINK_EXECUTABLE
    "<CMAKE_${lang}_COMPILER> <FLAGS> <OBJECTS> -o <TARGET> <CMAKE_${lang}_LINK_FLAGS> <LINK_FLAGS> <LINK_LIBRARIES>")
  if(WASM2JS_EXECUTABLE)
    list(APPEND CMAKE_${lang}_LINK_EXECUTABLE "${WASM2JS_EXECUTABLE} -Oz <TARGET> -o <TARGET>.js")
  endif()
endforeach()

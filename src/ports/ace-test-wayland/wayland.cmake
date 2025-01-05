add_library(wayland STATIC)
target_include_directories(wayland PUBLIC
  ${CMAKE_CURRENT_BINARY_DIR}/include/wayland)

find_path(WAYLAND_INCLUDE_DIR "wayland-client.h" REQUIRED)
target_include_directories(wayland PUBLIC
  ${WAYLAND_INCLUDE_DIR})

find_library(WAYLAND_CLIENT wayland-client REQUIRED)
find_library(WAYLAND_CURSOR wayland-client REQUIRED)
target_link_libraries(wayland PRIVATE
  ${WAYLAND_CLIENT}
  ${WAYLAND_CURSOR})

find_package(unofficial-libffi CONFIG REQUIRED)
target_link_libraries(wayland PRIVATE unofficial::libffi::libffi)

set(WAYLAND_PROTOCOLS
  stable/xdg-shell/xdg-shell.xml
  stable/presentation-time/presentation-time.xml
  staging/xdg-activation/xdg-activation-v1.xml
  staging/content-type/content-type-v1.xml
  staging/fractional-scale/fractional-scale-v1.xml
  staging/tearing-control/tearing-control-v1.xml
  unstable/xdg-decoration/xdg-decoration-unstable-v1.xml
  unstable/xdg-output/xdg-output-unstable-v1.xml
  unstable/fullscreen-shell/fullscreen-shell-unstable-v1.xml
  unstable/input-timestamps/input-timestamps-unstable-v1.xml
  unstable/keyboard-shortcuts-inhibit/keyboard-shortcuts-inhibit-unstable-v1.xml
  unstable/pointer-constraints/pointer-constraints-unstable-v1.xml
  unstable/relative-pointer/relative-pointer-unstable-v1.xml)

find_program(WAYLAND_SCANNER wayland-scanner REQUIRED)

make_directory(${CMAKE_CURRENT_BINARY_DIR}/src/wayland)
make_directory(${CMAKE_CURRENT_BINARY_DIR}/include/wayland)

foreach(WAYLAND_PROTOCOL ${WAYLAND_PROTOCOLS})
  get_filename_component(WAYLAND_PROTOCOL_NAME ${WAYLAND_PROTOCOL} DIRECTORY)
  get_filename_component(WAYLAND_PROTOCOL_NAME ${WAYLAND_PROTOCOL_NAME} NAME)

  find_file(WAYLAND_PROTOCOL_FILE "share/wayland-protocols/${WAYLAND_PROTOCOL}" NO_CACHE REQUIRED)

  set(WAYLAND_PROTOCOL_SOURCE ${CMAKE_CURRENT_BINARY_DIR}/src/wayland/${WAYLAND_PROTOCOL_NAME}.c)
  set(WAYLAND_PROTOCOL_HEADER ${CMAKE_CURRENT_BINARY_DIR}/include/wayland/${WAYLAND_PROTOCOL_NAME}.h)

  add_custom_command(OUTPUT ${WAYLAND_PROTOCOL_SOURCE}
    COMMAND ${WAYLAND_SCANNER} private-code ${WAYLAND_PROTOCOL_FILE} ${WAYLAND_PROTOCOL_SOURCE}
    COMMENT "Generating source: ${WAYLAND_PROTOCOL_NAME}.c")

  add_custom_command(OUTPUT ${WAYLAND_PROTOCOL_HEADER}
    COMMAND ${WAYLAND_SCANNER} client-header ${WAYLAND_PROTOCOL_FILE} ${WAYLAND_PROTOCOL_HEADER}
    COMMENT "Generating header: ${WAYLAND_PROTOCOL_NAME}.h")

  target_sources(wayland
    PRIVATE ${WAYLAND_PROTOCOL_SOURCE}
    PUBLIC  ${WAYLAND_PROTOCOL_HEADER})

  unset(WAYLAND_PROTOCOL_HEADER)
  unset(WAYLAND_PROTOCOL_SOURCE)
  unset(WAYLAND_PROTOCOL_FILE)
  unset(WAYLAND_PROTOCOL_NAME)
endforeach()

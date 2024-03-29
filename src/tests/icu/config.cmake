find_package(ICU REQUIRED COMPONENTS data uc i18n)
target_link_libraries(main PRIVATE ICU::data ICU::uc ICU::i18n)

add_custom_command(OUTPUT icudtl.dat
  COMMAND ${CMAKE_COMMAND} -E copy_if_different ${ICU_DATA} icudtl.dat
  MAIN_DEPENDENCY ${ICU_DATA} USES_TERMINAL)

target_sources(main PRIVATE icudtl.dat)

find_program(ICUPKG_EXECUTABLE icupkg REQUIRED)
message(STATUS "Found icupkg: ${ICUPKG_EXECUTABLE}")

find_program(PKGDATA_EXECUTABLE pkgdata REQUIRED)
message(STATUS "Found pkgdata: ${PKGDATA_EXECUTABLE}")

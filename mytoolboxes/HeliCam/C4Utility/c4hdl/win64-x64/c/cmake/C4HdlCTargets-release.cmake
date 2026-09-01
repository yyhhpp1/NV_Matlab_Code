#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "C4Hdl::C4HdlC" for configuration "Release"
set_property(TARGET C4Hdl::C4HdlC APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(C4Hdl::C4HdlC PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/c/lib/C4HdlC.lib"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/c/bin/C4HdlC.dll"
  )

list(APPEND _cmake_import_check_targets C4Hdl::C4HdlC )
list(APPEND _cmake_import_check_files_for_C4Hdl::C4HdlC "${_IMPORT_PREFIX}/c/lib/C4HdlC.lib" "${_IMPORT_PREFIX}/c/bin/C4HdlC.dll" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)


include(TargetArch)

# Helper function to create a target architecture specific installation directory
function(target_architecture_directory output_var)
  target_architecture(CMAKE_TARGET_ARCHITECTURES)
  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    if(CMAKE_TARGET_ARCHITECTURES STREQUAL "i386")
      set(ARCHITECTURE_DIRECTORY "win32-i86")
    else()
      set(ARCHITECTURE_DIRECTORY "win64-x64")
    endif()
  else() #Linux
    if(CMAKE_TARGET_ARCHITECTURES STREQUAL "i386")
      set(ARCHITECTURE_DIRECTORY "linux32-i86")
    elseif(CMAKE_TARGET_ARCHITECTURES STREQUAL "armv7")
      set(ARCHITECTURE_DIRECTORY "linux32-ARMv7")
    else()
      set(ARCHITECTURE_DIRECTORY "linux64-x64")
    endif()
  endif()

  set(${output_var} "${ARCHITECTURE_DIRECTORY}" PARENT_SCOPE)
endfunction()

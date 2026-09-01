cmake_minimum_required (VERSION 3.10)

############################ Project ############################
# define the project and the core version of the C4hdl library  #
#################################################################
project(h8SurfSimple
    VERSION 1.0.0 
    DESCRIPTION "simple c example using C4HdlC library"
)

################### Variables ####################
# Change if you want modify path or other values #
##################################################
set(C_EXAMPLE_NAME ${PROJECT_NAME}_simple)

# get architecture dependent path
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(TargetArchDirectory)
target_architecture_directory(TARGET_ARCH_DIRECTORY)

list(APPEND CMAKE_PREFIX_PATH "$ENV{C4UTILITY_ROOT}/c4hdl/${TARGET_ARCH_DIRECTORY}/c/cmake")  
find_package(C4HdlC REQUIRED)

################# Files #################
#   Define files and paths to project.  #
#########################################
file(GLOB C_EXAMPLE_SOURCE_FILE
  "src/*.c"
)

####################### Target #######################
#   Define target library and configure properties   #
######################################################    
add_executable(${C_EXAMPLE_NAME}
  ${C_EXAMPLE_SOURCE_FILE}
)
  
set_target_properties(${C_EXAMPLE_NAME} PROPERTIES 
  VERSION ${PROJECT_VERSION}
  CXX_VISIBILITY_PRESET hidden
)

target_link_libraries(${C_EXAMPLE_NAME} PUBLIC C4Hdl::C4HdlC)

############# Pre/Post Build #############
#  Pre- and/or Post-Build commands       #
##########################################
# copy all library dependencies
add_custom_command(TARGET ${C_EXAMPLE_NAME}
  POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:C4Hdl::C4HdlC> $<TARGET_FILE_DIR:${C_EXAMPLE_NAME}>
)

#################### Installation ####################
#  Define installation directories for each target   #
######################################################


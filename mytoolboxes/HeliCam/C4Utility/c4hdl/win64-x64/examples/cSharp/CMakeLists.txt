cmake_minimum_required (VERSION 3.10)

############################ Project ############################
# define the project and the core version of the C4hdl library  #
#################################################################
project(h8SurfSimple
    VERSION 1.0.0 
    DESCRIPTION "simple cSharp example using C4HdlCLR library"
    LANGUAGES CSharp
)

################### Variables ####################
# Change if you want modify path or other values #
##################################################
set(CS_EXAMPLE_NAME ${PROJECT_NAME})
  

################# Files #################
#   Define files and paths to project.  #
#########################################
file(GLOB CS_EXAMPLE_SOURCE_FILE
  "src/*.cs"
)

set(C4HDLCLR_BINARY_PATH
  $ENV{C4UTILITY_ROOT}/c4hdl/win64-x64/clr/bin
)

file(GLOB C4HDLCLR_BINARY_FILES 
  $ENV{C4UTILITY_ROOT}/c4hdl/win64-x64/clr/bin/*.dll
)
  
####################### Target #######################
#   Define target library and configure properties   #
######################################################    
add_executable(${CS_EXAMPLE_NAME}
  ${CS_EXAMPLE_SOURCE_FILE}
)
  
set_target_properties(${CS_EXAMPLE_NAME} PROPERTIES 
  VERSION ${PROJECT_VERSION}
  VS_DOTNET_TARGET_FRAMEWORK_VERSION "v4.6.2"
  WIN32_EXECUTABLE FALSE
)

set_property(TARGET ${CS_EXAMPLE_NAME} PROPERTY VS_DOTNET_REFERENCES
  "Microsoft.CSharp"
  "System"
  "System.Core"
  "System.Data"
  "System.Data.DataSetExtensions"
  "System.Net.Http"
  "System.Xml"
  "System.Xml.Linq"
  ${C4HDLCLR_BINARY_PATH}/C4HdlCLR.dll
)
  
############# Pre/Post Build #############
#  Pre- and/or Post-Build commands       #
##########################################
# copy all library dependencies
add_custom_command(TARGET ${CS_EXAMPLE_NAME}
  POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy ${C4HDLCLR_BINARY_FILES} $<TARGET_FILE_DIR:${CS_EXAMPLE_NAME}>
)

#################### Installation ####################
#  Define installation directories for each target   #
######################################################



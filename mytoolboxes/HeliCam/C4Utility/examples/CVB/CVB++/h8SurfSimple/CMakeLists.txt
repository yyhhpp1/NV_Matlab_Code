cmake_minimum_required(VERSION 3.5)

project(h8SurfSimple)

set (CMAKE_CXX_STANDARD 14)

#find CVB
file(TO_CMAKE_PATH "$ENV{CVB}/cmake" CVB_MODULE_PATH)
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${CVB_MODULE_PATH}")
find_package(CVB REQUIRED)

set(SOURCES
  main.cpp
)

add_executable(${PROJECT_NAME} 
  ${SOURCES}
)

target_link_libraries(${PROJECT_NAME}
  CVB::CVCDriver
  CVB::CVCUtilities
)

if(UNIX)
  target_link_libraries(${PROJECT_NAME} pthread)
endif()

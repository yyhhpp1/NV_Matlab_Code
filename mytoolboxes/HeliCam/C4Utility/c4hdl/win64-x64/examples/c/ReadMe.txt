# C example using the C4Hdl library

**Content**
* Into
* Requirements
* Setup Example Project
* Build Example


## Intro
The C example project use the C4HdlC library. 
This is a wrapped version of the C4Hdl library which exports a C based interface.

## Requirements
* C4HdlC library
* Visual Studio 
* cMake (3.12 or higher)
* C4Utility

Keep the folder structure like the *C4Utility* placed the files:
```
.
├── c
|   ├── bin
|   |   ├─ C4HdlC.dll/so
|   |   └─ *.dll  # On Windows: additional libraries, e.g. VCRuntime
|   ├── cmake
|   |   └─ *.cmake # cmake files used in cMake project setup when calling `find_package(C4HdlC REQUIRED)`
|   ├── include
|   |   └─ C4HdlC.h
|   └── lib
|       └─ C4HdlC.lib # Windows only
|
├── documentation
|   └── html # C4Hdl documentation (index.html)
|
├── examples
|   ├── c
|   |   ├── src
|   |   |   └─ h8SurfSimple.c
|   |   ├─ CMakeLists.txt
|   |   └─ ReadMe.txt
|   ├── cSharp
|   |   └─ #cSharp example
|   ├── Python
|   |   └─ #Python example
|
└── genicam
    └─ #GenICam reference implementation
```

## Setup Example Project
The example project is based on cMake. To setup the example project run the followin commands:
```
cd ./example/c
mkdir build
cd build
cMake ../
```

## Build Example
The create project could be built in the IDE or with the command:
cMake ../
```
cmake --build . --config Release
```

Additionally to the dependencies in the output directory, the C4Hdl library require an installed C4Utility which includes the GenTL consumer diaphus.cti
 

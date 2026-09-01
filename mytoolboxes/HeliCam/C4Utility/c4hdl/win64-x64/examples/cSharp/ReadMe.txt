# CSharp example using the C4Hdl library

**Content**
* Into
* Requirements
* Setup Example Project
* Build Example


## Intro
The C# example project use the C4HdlCLR library. 
This is a wrapped version of the C4Hdl library which export a *common language runtime* based interface.
Thanks to the CLR, the library is directly usable in a C# or Visual C++ application.

By the way: You may would read this document in a markdown viewer.

## Requirements
* C4HdlCLR library
* Visual Studio
* cMake (3.12 or higher)
* C4Utility

Keep the folder structure like the *C4Utility* placed the files:
```
.
├── clr
|   ├── bin
|   |   ├─ C4HdlCLR.dll
|   |   └─ *.dll  #many more dll's
|   ├── include
|   |   ├─ C4BufferCLR.hpp
|   |   ├─ C4DeviceCLR.hpp
|   |   ├─ C4FeatureInfoCLR.hpp
|   |   ├─ C4HandlerCLR.hpp
|   |   └─ C4InterfaceCLR.hpp
|   └── lib
|
├── examples
|   ├── cpp
|   |   └─ #cpp example
|   ├── cSharp
|   |   ├── src
|   |   |   └─ Program.cs
|   |   ├─ CMakeLists.txt
|   |   ├─ ReadMe.txt
|   |   └─ windowsSetup.bat
|
└── licenses
    └─ #all licenses of third party libraries
```

## Setup Example Project
The example project is based on cMake. When executing the *windowsSetup.sh* script, a build folder containing a Visual Studio Solution would be created.
It is also possible to call cMake direct on your console.

## Build Example
The Visual Studio builds the C# example and copies all required dependencies to the output directory.
Additionally to the dependencies in the output directory, the C4Hdl library require an installed C4Utility which install the GenTL consumer diaphus.cti
 

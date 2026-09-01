@echo off
setlocal enableextensions
md build\x64
endlocal
cd build\x64 && cmake -G "Visual Studio 15 Win64" ../../ 
    
cd ..\..

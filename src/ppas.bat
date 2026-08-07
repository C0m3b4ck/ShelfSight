@echo off
SET THEFILE=BookwormPascal.exe
echo Linking %THEFILE%
9xld.exe -b pei-i386 -m i386pe  --gc-sections   --subsystem windows --entry=_WinMainCRTStartup    -o BookwormPascal.exe link.res
if errorlevel 1 goto linkend
9xpostw32.exe --subsystem gui --input BookwormPascal.exe --stack 16777216
if errorlevel 1 goto linkend
goto end
:asmend
echo An error occured while assembling %THEFILE%
goto end
:linkend
echo An error occured while linking %THEFILE%
:end

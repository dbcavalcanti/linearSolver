@echo off

rem ============================================================
rem Build the complete project.
rem
rem Run this file from the main project folder:
rem   build.bat
rem ============================================================

rem Work from the folder containing this script.
pushd "%~dp0"

rem Build the external libraries first.
echo Checking external libraries...
call ext\build_ext.bat
if errorlevel 1 goto :error

rem Use the project Makefile to compile and link the Fortran program.
echo Compiling the Fortran program...
nmake /nologo
if errorlevel 1 goto :error

popd
echo.
echo Project built successfully.
echo Run the program with: build\bin\lis_test.exe
exit /b 0

:error
popd
echo.
echo ERROR: The project could not be built.
exit /b 1

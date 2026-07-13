@echo off

rem ============================================================
rem Build the external libraries used by this project.
rem
rem Add one CALL command here for each external library.
rem ============================================================

rem Load the Intel Fortran and Visual Studio build tools.
call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat" intel64
if errorlevel 1 exit /b 1

rem Build LIS.
call "%~dp0lis\build_lis.bat"
if errorlevel 1 exit /b 1

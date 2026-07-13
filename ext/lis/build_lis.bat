@echo off

rem ============================================================
rem Build LIS with its Fortran interface enabled.
rem
rem This script is called by ext\build_ext.bat.
rem ============================================================

rem Do not rebuild LIS when the library already exists.
rem Delete win\lis.lib if you want to force a new build.
if exist "%~dp0win\lis.lib" goto :already_built

rem LIS needs this old Microsoft SDK file when reading its Makefile.
set "INCLUDE=%INCLUDE%;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Include"

rem Work in the directory containing the LIS Windows build files.
pushd "%~dp0win"

rem Remove files from an earlier build, if there are any.
if exist Makefile nmake distclean

rem Create a new Makefile and enable the LIS Fortran interface.
call configure.bat --enable-fortran --disable-test
if errorlevel 1 goto :error

rem Compile the C library and use Intel ifx for its Fortran code.
nmake FC=ifx
if errorlevel 1 goto :error

popd
echo LIS was built successfully.
exit /b 0

:already_built
echo LIS is already built. Nothing to do.
exit /b 0

:error
popd
echo ERROR: LIS could not be built.
exit /b 1

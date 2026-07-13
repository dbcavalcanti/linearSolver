# Simple LIS Fortran test

This project builds LIS and uses it from a small Fortran program.

## Files

```text
linearSolver
|-- build.bat             Builds the complete project
|-- Makefile              Compiles and links the Fortran program
|-- ext
|   |-- build_ext.bat     Builds all external libraries
|   `-- lis
|       |-- build_lis.bat Builds LIS
|       `-- ...           LIS source code
|-- src\main.F90          Fortran test program
`-- build                 Generated when the project is built
    |-- obj               Intermediate compiler files
    `-- bin               Executable
```

## Build

Open **Command Prompt** in the main project folder and run:

```bat
build.bat
```

The main build script:

1. Builds the external libraries.
2. Calls `nmake` using the root `Makefile`.
3. The Makefile compiles `src\main.F90` and links it with LIS.

If `ext\lis\win\lis.lib` already exists, LIS is not rebuilt. Delete that file
before running `build.bat` if you want to force a new LIS build.

## Run

After building, run:

```bat
build\bin\lis_test.exe
```

The last line should be:

```text
LIS smoke test passed.
```

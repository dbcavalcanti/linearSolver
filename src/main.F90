program lis_test
  ! Require every variable to be declared explicitly
  implicit none

  ! Import the Fortran definitions for LIS objects, constants, and routines
#include "lisf.h"

  ! LIS objects used to define and solve the linear system
  LIS_MATRIX :: matrix
  LIS_VECTOR :: rhs, solution
  LIS_SOLVER :: solver

  ! Status, loop counter, and solver result variables
  LIS_INTEGER :: ierr, i, iterations
  LIS_REAL :: residual, value

  ! Exact solution used to verify the computed result
  LIS_REAL, parameter :: expected(3) = [1.0d0, 2.0d0, 3.0d0]

  ! Initialize the LIS execution environment
  ! ierr: receives the return status from LIS routines
  call lis_initialize(ierr)

  ! Subroutine to check the status
  call check_lis(ierr, 'lis_initialize')

  ! Create a matrix
  ! matrix: the matrix to be created
  ! ierr: receives the return status from LIS routines
  ! LIS_COMM_WORLD: communicator for parallel execution (default is the world communicator)
  call lis_matrix_create(LIS_COMM_WORLD, matrix, ierr)
  call check_lis(ierr, 'lis_matrix_create')

  ! Set the size of the matrix to 3x3
  ! lis_matrix_set_size(matrix, local_n, global_n, ierr)
  ! matrix: the matrix whose size is being set
  ! local_n: For the serial case, local n is set as 0. For parallel execution, local n is the number of rows in the local submatrix.
  ! global_n: total number of rows in the complete matrix
  ! ierr: receives the return status from LIS routines
  call lis_matrix_set_size(matrix, 0, 3, ierr)
  call check_lis(ierr, 'lis_matrix_set_size')

  ! Symmetric positive-definite tridiagonal matrix:
  ! [ 2 -1  0 ] [1]   [0]
  ! [-1  2 -1 ] [2] = [0]
  ! [ 0 -1  2 ] [3]   [4]
  !  lis_matrix_set_value(LIS_INTEGER flag, LIS_INTEGER i, LIS_INTEGER j, LIS_SCALAR value, LIS_MATRIX A, LIS_INTEGER ierr)
  ! flag: LIS_INS_VALUE to insert a value, LIS_ADD_VALUE to add a value
  ! i: row index (1-based)
  ! j: column index (1-based)
  ! value: the value to be inserted or added
  ! A: the matrix to which the value is being added
  ! ierr: receives the return status from LIS routines
  ! If LIS_INS_VALUE is used, the value at position (i,j) is replaced with the new value.
  ! If LIS_ADD_VALUE is used, the new value is added to the existing value at position (i,j).
  call lis_matrix_set_value(LIS_INS_VALUE, 1, 1,  2.0d0, matrix, ierr)
  call check_lis(ierr, 'lis_matrix_set_value')
  call lis_matrix_set_value(LIS_INS_VALUE, 1, 2, -1.0d0, matrix, ierr)
  call check_lis(ierr, 'lis_matrix_set_value')
  call lis_matrix_set_value(LIS_INS_VALUE, 2, 1, -1.0d0, matrix, ierr)
  call check_lis(ierr, 'lis_matrix_set_value')
  call lis_matrix_set_value(LIS_INS_VALUE, 2, 2,  2.0d0, matrix, ierr)
  call check_lis(ierr, 'lis_matrix_set_value')
  call lis_matrix_set_value(LIS_INS_VALUE, 2, 3, -1.0d0, matrix, ierr)
  call check_lis(ierr, 'lis_matrix_set_value')
  call lis_matrix_set_value(LIS_INS_VALUE, 3, 2, -1.0d0, matrix, ierr)
  call check_lis(ierr, 'lis_matrix_set_value')
  call lis_matrix_set_value(LIS_INS_VALUE, 3, 3,  2.0d0, matrix, ierr)
  call check_lis(ierr, 'lis_matrix_set_value')

  ! Once the values have been set, the matrix is assembled by the following routine.
  ! The assemblage is done using the matrix format specified by the user.
  ! The storage format can be assigned using lis_matrix_set_type(LIS_MATRIX A, LIS_INTEGER matrix_type, LIS_INTEGER ierr)
  call lis_matrix_assemble(matrix, ierr)
  call check_lis(ierr, 'lis_matrix_assemble')

  ! Create vectors with the same size and distribution as the matrix
  call lis_vector_duplicate(matrix, rhs, ierr)
  call check_lis(ierr, 'lis_vector_duplicate(rhs)')
  call lis_vector_duplicate(matrix, solution, ierr)
  call check_lis(ierr, 'lis_vector_duplicate(solution)')

  ! Set the right-hand side to [0, 0, 4]
  call lis_vector_set_value(LIS_INS_VALUE, 1, 0.0d0, rhs, ierr)
  call lis_vector_set_value(LIS_INS_VALUE, 2, 0.0d0, rhs, ierr)
  call lis_vector_set_value(LIS_INS_VALUE, 3, 4.0d0, rhs, ierr)

  ! Create the solver object
  call lis_solver_create(solver, ierr)
  call check_lis(ierr, 'lis_solver_create')

  ! Configure the solver
  ! lis_solver_set_option(character text, LIS_SOLVER solver, LIS_INTEGER ierr)
  ! Text options:
  ! -i <solver> : specify the solver type (e.g., cg, bicg, gmres)
  ! -p <preconditioner> : specify the preconditioner type (e.g., jacobi, ilu)
  ! -tol <tolerance> : specify the convergence tolerance
  call lis_solver_set_option('-i cg -p jacobi -tol 1.0e-12 -print none', solver, ierr)
  call check_lis(ierr, 'lis_solver_set_option')

  ! Solve the linear system A x = b
  !  lis_solve(LIS_MATRIX A, LIS_VECTOR b, LIS_VECTOR x, LIS_SOLVER solver, LIS_INTEGER ierr)
  call lis_solve(matrix, rhs, solution, solver, ierr)
  call check_lis(ierr, 'lis_solve')

  ! Get and print the number of iterations from the solver
  call lis_solver_get_iter(solver, iterations, ierr)
  print '(a,i0)', 'Iterations: ', iterations

  ! Get and print the relative residual norm from the solver
  call lis_solver_get_residualnorm(solver, residual, ierr)
  print '(a,es12.4)', 'Relative residual: ', residual

  ! Print each computed value and compare it with the exact solution
  do i = 1, 3
    call lis_vector_get_value(solution, i, value, ierr)
    call check_lis(ierr, 'lis_vector_get_value')
    print '(a,i0,a,f12.8)', 'x(', i, ') = ', value
    if (abs(value - expected(i)) > 1.0d-9) error stop 'incorrect solution'
  end do

  ! Release all LIS objects and shut down the LIS environment
  call lis_solver_destroy(solver, ierr)
  call lis_vector_destroy(solution, ierr)
  call lis_vector_destroy(rhs, ierr)
  call lis_matrix_destroy(matrix, ierr)
  call lis_finalize(ierr)
  print '(a)', 'LIS test passed.'

contains

  ! Stop the program and report which LIS operation failed
  subroutine check_lis(status, operation)
    LIS_INTEGER, intent(in) :: status
    character(len=*), intent(in) :: operation

    if (status /= 0) then
      print '(a,a,a,i0)', 'LIS error in ', operation, ': ', status
      error stop
    end if
  end subroutine check_lis

end program lis_test

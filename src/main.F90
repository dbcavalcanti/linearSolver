program lis_smoke_test
  implicit none

#include "lisf.h"

  LIS_MATRIX :: matrix
  LIS_VECTOR :: rhs, solution
  LIS_SOLVER :: solver
  LIS_INTEGER :: ierr, i, iterations
  LIS_REAL :: residual, value
  LIS_REAL, parameter :: expected(3) = [1.0d0, 2.0d0, 3.0d0]

  call lis_initialize(ierr)
  call check_lis(ierr, 'lis_initialize')

  call lis_matrix_create(LIS_COMM_WORLD, matrix, ierr)
  call check_lis(ierr, 'lis_matrix_create')
  call lis_matrix_set_size(matrix, 0, 3, ierr)
  call check_lis(ierr, 'lis_matrix_set_size')

  ! Symmetric positive-definite tridiagonal matrix:
  ! [ 2 -1  0 ] [1]   [0]
  ! [-1  2 -1 ] [2] = [0]
  ! [ 0 -1  2 ] [3]   [4]
  call set_entry(1, 1,  2.0d0)
  call set_entry(1, 2, -1.0d0)
  call set_entry(2, 1, -1.0d0)
  call set_entry(2, 2,  2.0d0)
  call set_entry(2, 3, -1.0d0)
  call set_entry(3, 2, -1.0d0)
  call set_entry(3, 3,  2.0d0)
  call lis_matrix_assemble(matrix, ierr)
  call check_lis(ierr, 'lis_matrix_assemble')

  call lis_vector_duplicate(matrix, rhs, ierr)
  call check_lis(ierr, 'lis_vector_duplicate(rhs)')
  call lis_vector_duplicate(matrix, solution, ierr)
  call check_lis(ierr, 'lis_vector_duplicate(solution)')
  call lis_vector_set_value(LIS_INS_VALUE, 1, 0.0d0, rhs, ierr)
  call lis_vector_set_value(LIS_INS_VALUE, 2, 0.0d0, rhs, ierr)
  call lis_vector_set_value(LIS_INS_VALUE, 3, 4.0d0, rhs, ierr)

  call lis_solver_create(solver, ierr)
  call check_lis(ierr, 'lis_solver_create')
  call lis_solver_set_option('-i cg -p jacobi -tol 1.0e-12 -print none', solver, ierr)
  call check_lis(ierr, 'lis_solver_set_option')
  call lis_solve(matrix, rhs, solution, solver, ierr)
  call check_lis(ierr, 'lis_solve')

  call lis_solver_get_iter(solver, iterations, ierr)
  call lis_solver_get_residualnorm(solver, residual, ierr)
  print '(a,i0)', 'Iterations: ', iterations
  print '(a,es12.4)', 'Relative residual: ', residual

  do i = 1, 3
    call lis_vector_get_value(solution, i, value, ierr)
    call check_lis(ierr, 'lis_vector_get_value')
    print '(a,i0,a,f12.8)', 'x(', i, ') = ', value
    if (abs(value - expected(i)) > 1.0d-9) error stop 'incorrect solution'
  end do

  call lis_solver_destroy(solver, ierr)
  call lis_vector_destroy(solution, ierr)
  call lis_vector_destroy(rhs, ierr)
  call lis_matrix_destroy(matrix, ierr)
  call lis_finalize(ierr)
  print '(a)', 'LIS smoke test passed.'

contains

  subroutine set_entry(row, column, coefficient)
    LIS_INTEGER, intent(in) :: row, column
    LIS_SCALAR, intent(in) :: coefficient

    call lis_matrix_set_value(LIS_INS_VALUE, row, column, coefficient, matrix, ierr)
    call check_lis(ierr, 'lis_matrix_set_value')
  end subroutine set_entry

  subroutine check_lis(status, operation)
    LIS_INTEGER, intent(in) :: status
    character(len=*), intent(in) :: operation

    if (status /= 0) then
      print '(a,a,a,i0)', 'LIS error in ', operation, ': ', status
      error stop
    end if
  end subroutine check_lis

end program lis_smoke_test

program MakeGridLog
implicit none

real, allocatable, dimension(:) :: x, y
integer :: i, j, in, jn, status
real :: x0, y0, xn, yn, dx, dy, dyb, dyt, a, b, h
character*8 :: gridName
character*50 :: inputs_dir

! Obtendo variaveis de ambiente
call get_environment_variable("GRID_NAME", gridName, status=status)
if (status /= 0) stop "ERROR: GRID_NAME not defined"

call get_environment_variable("INPUTS_DIR", inputs_dir, status=status)
if (status /= 0) stop "ERROR: INPUTS_DIR not defined"


open(unit=7,  file = trim(inputs_dir)//trim(gridName)//".grd", status="unknown")


! Delimitacao do dominio e do espacamento de grade
x0 = 0.0                !m
xn = 10.0               !m      
y0 = 0.0                !m   
yn = 1.0                !m   
dx = 0.1                !m   
dyb = 0.00025           !m 
dyt = 0.1               !m

!Calcula in e jn, onde i=1,...,in e j=1,...,jn
 in = int((xn-x0)/dx)
 jn = int((yn-y0)/dyb)

allocate(x(1:in), y(1:jn))

! Cria a grade
do i = 1,in
   x(i) = (i-1)*dx + x0
enddo

h = yn-y0
y(1) = y0
dy = dyb
do j = 2,int((yn-y0)/dyb)
   y(j) = y(j-1) + dy

   b = (dyb - dyt)/log(dyb/h)
   a = dyb-b*log(dyb)
   dy = a+b*log(y(j))
   
   if (y(j)>=yn) exit
enddo
jn = j

! Escreve arquivo de grade
write(7,*) in, jn
!
do i = 1,in
  write(7,*) x(i)
enddo
!
do j = 1,jn
  write(7,*) y(j)
enddo

close(7)
end program MakeGridLog
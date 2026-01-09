program MakeGridLinear

implicit none
real, allocatable, dimension(:) :: x, y
integer :: i, j, in, jn, status
real :: x0, y0, xn, yn, dx, dy, dx0, dy0, dyn, a, b
character*8 :: gridName
character*50 :: inputs_dir

! Obtendo variaveis de ambiente
call get_environment_variable("GRID_NAME", gridName, status=status)
if (status /= 0) stop "ERROR: GRID_NAME not defined"

call get_environment_variable("INPUTS_DIR", inputs_dir, status=status)
if (status /= 0) stop "ERROR: INPUTS_DIR not defined"

open(unit=7,  file = trim(inputs_dir)//trim(gridName)//".grd", status="unknown")

! Delimitacao do dominio e do espacamento de grade
x0 = 0.0                 !m
xn = 1000.0              !m      
y0 = 0.0                 !m   
yn = 500.0               !m   
dx0 = 10.0               !m   
dy0 = 0.01               !m
dyn = 10.0               !m

!Calcula in e jn, onde i=1,...,in e j=1,...,jn
 in = int((xn-x0)/dx0)
 jn = int((yn-y0)/dy0)

allocate(x(1:in), y(1:jn))

! Cria a grade
dx = dx0
do i = 1,in
   x(i) = (i-1)*dx + x0
enddo

dy = dy0
y(1) = y0
a = (dyn-dy0)/(yn-y0)
b = dy0 - a*y0
do j = 2,jn
   y(j) = y(j-1)+ dy
   dy = a*y(j) + b

   if (y(j)>=yn) exit
enddo
jn = j

! Escreve arquivo de grade
write(7,*) in, jn

do i = 1,in
  write(7,*) x(i)
enddo

do j = 1,jn
  write(7,*) y(j)
enddo


close(7)
end program MakeGridLinear

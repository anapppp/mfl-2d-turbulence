module MakeGridMista
   implicit none
   contains

subroutine makeGridMista()

real, allocatable, dimension(:) :: x, y
integer :: i, j, in, jn, jin, status
real :: x0, y0, xn, yn, ynlog, ynlin1, dx, dy, dyb, dytlog, dytlin1, dytlin2, a, b, h
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
xn = 10.0                !m      
y0 = 0.0                 !m   
ynlog = 0.06             !m
ynlin1 = 0.1             !m  
yn = 0.5                 !m 
dx = 0.2                 !m   
dyb = 0.0003             !m
dytlog = 0.0008          !m
dytlin1 = 0.001          !m
dytlin2 = 0.2            !m


!Calcula in e jn, onde i=1,...,in e j=1...,jn
 in = int((xn-x0)/dx)+2
 jn = int((yn-y0)/dyb)

allocate(x(1:in), y(1:jn))

! Cria a grade x
do i = 1,in
   x(i) = (i-1)*dx + x0
enddo

! Cria a grade y log
h = ynlog-y0
y(1) = y0
dy = dyb
do j = 2,int((yn-y0)/dyb)
   y(j) = y(j-1) + dy

   b = (dyb - dytlog)/log(dyb/h)
   a = dyb-b*log(dyb)
   dy = a+b*log(y(j))
   
   if (y(j)>=ynlog) exit
enddo
jin = j+1

! Cria a grade y linear1
b = (dytlog - dytlin1)/(ynlog - ynlin1)
a = dytlog-b*ynlog

dy = dytlog
do j = jin,int((yn-y0)/dyb)
   y(j) = y(j-1) + dy

   dy = a+b*y(j)
   
   if (y(j)>=ynlin1) exit
enddo
jin = j+1

!Cria a grade y linear2
b = (dytlin1 - dytlin2)/(ynlin1 - yn)
a = dytlin1-b*ynlin1

dy = dytlin1
do j = jin,int((yn-y0)/dyb)
   y(j) = y(j-1) + dy
   
   dy = a+b*y(j)
   
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
end subroutine makeGridMista

end module MakeGridMista

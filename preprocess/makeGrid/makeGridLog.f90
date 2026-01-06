program MakeGridLog
implicit none
!-------------------------------------------------------------------------!
! Ana Paula Kelm Soares
! 26/abr/2012
! LEMMA/UFPR
! PPGMNE
!-------------------------------------------------------------------------!
!
!  Programa para criar o arquivo de grade com formato padrao. 
!  O dominio deve ser necessariamente retangular e 2D.
!  O espaçamento de grade pode ser variável. 
!  O nome do arquivo de grade deve seguir o seguinte padrao:
!   - nomegrad.grd
! sendo que o nome dado a grade, ou "nomegrad", deve ter 8 caracteres. 
! 
!  O formato do arquivo de grade segue o seguinte padrao:
!  - 1ª linha: 
!              deve conter os valores in e jn, que são os indices dos 
!              ultimos pontos de grade, respectivamente nas direcoes 
!              x e y. O primeiro ponto de grade é convencionado como 
!              tendo indice 0.
!  - Linhas seguintes: 
!              devem conter o valor em metros do ponto x, e,  
!              subsequentemente, dos pontos y, tambem em metros. 
! 
!
!  EXEMPLO:
! 
! in  jn 
! x(1)
! x(2)
! .
! .
! .
! x(in-1)
! x(in)
! y(1)
! y(2)
! .
! .
! .
! y(jn-1)
! y(jn)
!
!-------------------------------------------------------------------------!
!  MakeGrid_v2.1: grade log em y e uniforme em x
!-------------------------------------------------------------------------!
!

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
xn = 20.0               !m      
y0 = 0.0                !m   
yn = 1.0                !m   
dx = 0.5                !m   
dyb = 0.001             !m
dyt = 0.1               !m
!
!
!Calcula in e jn, onde i=1,...,in e j=1,...,jn
! i ==> coordenada x
! j ==> coordenada y
!
 in = int((xn-x0)/dx)
 jn = int((yn-y0)/dyb)
!
! Aloca arrays
allocate(x(1:in), y(1:jn))
!
!
! Cria a grade
do i = 1,in
   x(i) = (i-1)*dx + x0
enddo
!

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
!
!
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

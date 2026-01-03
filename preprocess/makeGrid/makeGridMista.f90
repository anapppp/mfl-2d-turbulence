program MakeGridMista
!-------------------------------------------------------------------------!
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
!  MakeGrid_v3.1: grade uniforme em x, log entre y0 e ynlog, linear1 entre 
!                 ynlog e ynlin1, e linear2 entre ynlin1 e yn.
!-------------------------------------------------------------------------!
!
implicit none
real, allocatable, dimension(:) :: x, y
integer :: i, j, in, jn, jin
real :: x0, y0, xn, yn, ynlog, ynlin1, dx, dy, dyb, dytlog, dytlin1, dytlin2, a, b, h
character*8 :: nomegrad
!
!
!-------------------------------------------------------------------------!
! Descricao das variaveis
!
! x, y     : array com as coordenadas x e y dos pontos de grade
! in, jn   : indice do ultimo ponto de grade, respectivamente em x e y 
! x0, y0   : coordenada do ponto inicial do dominio (m)
! xn, yn   : coordenada do ponto final do dominio (m)
! dx, dy   : espacamento de grade em x e y
! nomegrad : nome da grade
!-------------------------------------------------------------------------!
!
!
! Nome da Grade
nomegrad = "grdPlaca"
!
!
open(unit=7, file="./"//nomegrad//".grd", status="unknown")
!
!
! Delimitacao do dominio e do espacamento de grade
x0 = 0.0                 !m
xn = 7.0                 !m      
y0 = 0.0                 !m   
ynlog = 0.06             !m
ynlin1 = 0.1             !m  
yn = 0.5                 !m 
dx = 0.1                 !m   
dyb = 0.00025            !m
dytlog = 0.0008          !m
dytlin1 = 0.001          !m
dytlin2 = 0.2            !m
!
!
!Calcula in e jn, onde i=1,...,in e j=1,...,jn
! i ==> coordenada x
! j ==> coordenada y
!
 in = int((xn-x0)/dx)+2
 jn = int((yn-y0)/dyb)
!
! Aloca arrays
allocate(x(1:in), y(1:jn))
!
!
! Cria a grade x
do i = 1,in
   x(i) = (i-1)*dx + x0
enddo
!
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
!
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
!
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
end program MakeGridMista

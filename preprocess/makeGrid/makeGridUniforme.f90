program MakeGridUniforme
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
!  MakeGrid_v0.1: Cria uma grade uniforme
!-------------------------------------------------------------------------!
!
implicit none
real, allocatable, dimension(:) :: x, y
integer :: i, j, in, jn
real :: x0, y0, xn, yn, dx, dy
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
nomegrad = "grade001"
!
!
open(unit=7, file="./"//nomegrad//".grd", status="unknown")
!
!
! Delimitacao do dominio e do espacamento de grade
x0 = 0.0                 !m
xn = 5.0                 !m      
y0 = 0.0                 !m   
yn = 0.16*1.3            !m   
dx = 0.2                 !m   
dy = 0.002               !m
!
!
!Calcula in e jn, onde i=1,...,in e j=1,...,jn
! i ==> coordenada x
! j ==> coordenada y
!
 in = int((xn-x0)/dx)+2
 jn = int((yn-y0)/dy)+2
!
! Aloca arrays
allocate(x(1:in), y(1:jn))
!
!
! Cria uma grade uniforme
do i = 1,in
   x(i) = (i-1)*dx+x0
enddo
!
do j = 1,jn
   y(j) = (j-1)*dy+y0
enddo
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
end program MakeGridUniforme

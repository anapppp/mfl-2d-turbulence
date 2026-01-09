module Interpolacao
implicit none 
 contains

 real function intCubicLagr1D(f0,f1,f2,f3,x0,deltax1,deltax2,deltax3,ptox)
! Retorna o valor interpolado um polinomio de Lagrange ordem 3
! f0,f1,f2,f3: valores prescritos da funcao
! x0: f(x0) = f0
! deltax1: intervalo em x entre f1 e f0
! deltax2: intervalo em x entre f2 e f1
! deltax3: intervalo em x entre f3 e f2
! ptox: ponto x para o qual o valor da funcao interpolada é retornado

real :: f0,f1,f2,f3,x0,deltax1,deltax2,deltax3,ptox
real :: l0,l1,l2,l3

l0 = ( (x0+deltax1-ptox)/deltax1 ) * &
     ( (x0+deltax1+deltax2-ptox)/(deltax1+deltax2) ) * &
     ( (x0+deltax1+deltax2+deltax3-ptox)/(deltax1+deltax2+deltax3) )

l1 = ( (ptox-x0)/(deltax1) ) * &
     ( (x0+deltax1+deltax2-ptox)/(deltax2) ) * &
     ( (x0+deltax1+deltax2+deltax3-ptox)/(deltax2+deltax3) ) 

l2 = ( (ptox-x0)/(deltax1+deltax2) ) * &
     ( (ptox-x0-deltax1)/(deltax2) ) * &
     ( (x0+deltax1+deltax2+deltax3-ptox)/(deltax3) )

l3 = ( (ptox-x0)/(deltax1+deltax2+deltax3) ) * &
     ( (ptox-x0-deltax1)/(deltax2+deltax3) ) * &
     ( (ptox-x0-deltax1-deltax2)/(deltax3) )

intCubicLagr1D = f0*l0 + f1*l1 + f2*l2 + f3*l3

end function intCubicLagr1D


real function intCubicLagr2D(f,vetx,vety,vdx,vdy, idx_x, idx_y, ptox, ptoy)
! Retorna o valor interpolado no ponto (ptox,ptoy)
! São utilizados 16 pontos de grade. O ponto de grade adotado como referencia
! é o com indices idx_x e idx_y, ilustrado com * : 
!
!      ° ° ° °
!      ° ° * °
!      ° ° ° °
!      ° ° ° °

real :: f(:,:), vetx(:), vety(:), vdx(:), vdy(:)
integer :: idx_x, idx_y
real :: fintx1, fintx2, fintx3, fintx4, ptox, ptoy
                                         
fintx1 =  intCubicLagr1D(f(idx_x-2,idx_y-2),f(idx_x-1,idx_y-2),f(idx_x,idx_y-2),f(idx_x+1,idx_y-2),& 
                                          vetx(idx_x-2),vdx(idx_x-2),vdx(idx_x-1),vdx(idx_x),ptox)
fintx2 =  intCubicLagr1D(f(idx_x-2,idx_y-1),f(idx_x-1,idx_y-1),f(idx_x,idx_y-1),f(idx_x+1,idx_y-1),&
                                          vetx(idx_x-2),vdx(idx_x-2),vdx(idx_x-1),vdx(idx_x),ptox)
fintx3 =  intCubicLagr1D(f(idx_x-2,idx_y  ),f(idx_x-1,idx_y  ),f(idx_x,idx_y  ),f(idx_x+1,idx_y  ),&
                                          vetx(idx_x-2),vdx(idx_x-2),vdx(idx_x-1),vdx(idx_x),ptox)
fintx4 =  intCubicLagr1D(f(idx_x-2,idx_y+1),f(idx_x-1,idx_y+1),f(idx_x,idx_y+1),f(idx_x+1,idx_y+1),&
                                          vetx(idx_x-2),vdx(idx_x-2),vdx(idx_x-1),vdx(idx_x),ptox)

intCubicLagr2D = intCubicLagr1D(fintx1,fintx2,fintx3,fintx4,vety(idx_y-2),vdy(idx_y-2),vdy(idx_y-1),vdy(idx_y),ptoy)
 
end function intCubicLagr2D


function PontoDeReferencia1D(vetx, vdx, ptox)
! Função que retorna o ponto de grade de referencia para interpolação 1D.

real :: vetx(:), vdx(:), ptox
integer :: i, PontoDeReferencia1D
!real :: soma_distancias

 do i = 1,size(vetx)-1

   if (abs(ptox-vetx(i)) <= vdx(i)) then
     PontoDeReferencia1D = i+1
     exit
   endif

   if (ptox < vetx(i)) write(*,*) 'Ponto de Referencia: nao encontrado', ptox
     
 enddo 

call CheckIdxPontoReferencia(PontoDeReferencia1D,size(vetx))

return

end function PontoDeReferencia1D


subroutine CheckIdxPontoReferencia(idx_ptoref,ilim)
! Esta subrotina verifica se os 4 pontos de grade necessários 
! para a interpolação cubica estão dentro do dominio. Se não
! estiverem, o valor de p é ajustado para que sejam utilizados 
! os pontos de dentro do dominio.
! O ponto de índice idx_ptoref deve estar dentro do dominino.
integer :: idx_ptoref, ilim

if ((idx_ptoref) == 1)     idx_ptoref = idx_ptoref+2
if ((idx_ptoref) == 2)     idx_ptoref = idx_ptoref+1
if ((idx_ptoref) == ilim)  idx_ptoref = idx_ptoref-1

return 
end subroutine  CheckIdxPontoReferencia



! -----------------------------------    SPLINE -----------------------------------------


real function intCubicSpline2D(f,vetx,vety,vdx,vdy, idx_x, idx_y, ptox, ptoy)
! Retorna o valor interpolado no ponto (ptox,ptoy) usando spline cúbica
! Utiliza 16 pontos de grade com o ponto de referência em idx_x, idx_y
!
!      ° ° ° °
!      ° ° * °
!      ° ° ° °
!      ° ° ° °

implicit none
real :: f(:,:), vetx(:), vety(:), vdx(:), vdy(:)
integer :: idx_x, idx_y
real :: ptox, ptoy
real :: fintx(4), x_pts(4), y_pts(4)
real :: ax(4), bx(4), cx(4), dx(4)
real :: by(4), cy(4), dy(4)
integer :: i, j

! Pontos de grade nas direções x e y
do i = 1, 4
    x_pts(i) = vetx(idx_x-3+i)
    y_pts(i) = vety(idx_y-3+i)
enddo

! Interpolar em x para cada linha y
do j = 1, 4
    ! Valores da função nos 4 pontos em x para esta linha y
    do i = 1, 4
        ax(i) = f(idx_x-3+i, idx_y-3+j)
    enddo
    
    ! Calcular coeficientes do spline cúbico para esta linha
    call calcSplineCoeffs1D(x_pts, ax, bx, cx, dx)
    
    ! Avaliar spline em ptox para esta linha
    fintx(j) = evalSpline1D(x_pts, ax, bx, cx, dx, ptox)
enddo

! Interpolar em y usando os valores interpolados em x
call calcSplineCoeffs1D(y_pts, fintx, by, cy, dy)
intCubicSpline2D = evalSpline1D(y_pts, fintx, by, cy, dy, ptoy)

end function intCubicSpline2D


subroutine calcSplineCoeffs1D(x, f, b, c, d)
! Calcula coeficientes do spline cúbico natural para 4 pontos
! f: valores da função
! b, c, d: coeficientes (a = f)
! Spline: S(x) = a + b*(x-xi) + c*(x-xi)^2 + d*(x-xi)^3

implicit none
real, intent(in) :: x(4), f(4)
real, intent(out) :: b(4), c(4), d(4)
real :: h(3), alpha(3), l(4), mu(4), z(4)
integer :: i

! Intervalos
do i = 1, 3
    h(i) = x(i+1) - x(i)
enddo

! Coeficientes alpha
do i = 2, 3
    alpha(i) = (3.0/h(i))*(f(i+1)-f(i)) - (3.0/h(i-1))*(f(i)-f(i-1))
enddo

! Sistema tridiagonal - algoritmo de Thomas modificado
l(1) = 1.0
mu(1) = 0.0
z(1) = 0.0

do i = 2, 3
    l(i) = 2.0*(x(i+1)-x(i-1)) - h(i-1)*mu(i-1)
    mu(i) = h(i)/l(i)
    z(i) = (alpha(i) - h(i-1)*z(i-1))/l(i)
enddo

l(4) = 1.0
z(4) = 0.0
c(4) = 0.0

! Substituição reversa
do i = 3, 1, -1
    c(i) = z(i) - mu(i)*c(i+1)
    b(i) = (f(i+1)-f(i))/h(i) - h(i)*(c(i+1)+2.0*c(i))/3.0
    d(i) = (c(i+1)-c(i))/(3.0*h(i))
enddo

b(4) = b(3)
d(4) = d(3)

end subroutine calcSplineCoeffs1D


real function evalSpline1D(x, a, b, c, d, pt)
! Avalia o spline cúbico no ponto pt
! S(x) = a(i) + b(i)*(x-xi) + c(i)*(x-xi)^2 + d(i)*(x-xi)^3

implicit none
real, intent(in) :: x(4), a(4), b(4), c(4), d(4), pt
real :: dx
integer :: i

! Encontrar intervalo correto
i = 1
do while (i < 4)
    if (pt <= x(i+1)) exit
    i = i + 1
enddo

if (i == 4) i = 3

! Avaliar polinômio
dx = pt - x(i)
evalSpline1D = a(i) + b(i)*dx + c(i)*dx**2 + d(i)*dx**3

end function evalSpline1D




real function intCubicSpline1D(f0,f1,f2,f3,x0,deltax1,deltax2,deltax3,ptox)
! Retorna o valor interpolado usando spline cúbico natural
! f0,f1,f2,f3: valores prescritos da funcao
! x0: f(x0) = f0
! deltax1: intervalo em x entre f1 e f0
! deltax2: intervalo em x entre f2 e f1
! deltax3: intervalo em x entre f3 e f2
! ptox: ponto x para o qual o valor da funcao interpolada é retornado

implicit none
real :: f0,f1,f2,f3,x0,deltax1,deltax2,deltax3,ptox
real :: x(4), f(4), h(3)
real :: alpha(3), l(4), mu(4), z(4)
real :: c(4), b(4), d(4)
real :: dx
integer :: i, idx

! Montar vetor de posições
x(1) = x0
x(2) = x0 + deltax1
x(3) = x0 + deltax1 + deltax2
x(4) = x0 + deltax1 + deltax2 + deltax3

! Montar vetor de valores
f(1) = f0
f(2) = f1
f(3) = f2
f(4) = f3

! Calcular intervalos
h(1) = deltax1
h(2) = deltax2
h(3) = deltax3

! Calcular coeficientes alpha
do i = 2, 3
    alpha(i) = (3.0/h(i))*(f(i+1)-f(i)) - (3.0/h(i-1))*(f(i)-f(i-1))
enddo

! Sistema tridiagonal - algoritmo de Thomas
! Condições de contorno: spline natural (segunda derivada zero nas extremidades)
l(1) = 1.0
mu(1) = 0.0
z(1) = 0.0

do i = 2, 3
    l(i) = 2.0*(x(i+1)-x(i-1)) - h(i-1)*mu(i-1)
    mu(i) = h(i)/l(i)
    z(i) = (alpha(i) - h(i-1)*z(i-1))/l(i)
enddo

l(4) = 1.0
z(4) = 0.0
c(4) = 0.0

! Substituição reversa
do i = 3, 1, -1
    c(i) = z(i) - mu(i)*c(i+1)
    b(i) = (f(i+1)-f(i))/h(i) - h(i)*(c(i+1)+2.0*c(i))/3.0
    d(i) = (c(i+1)-c(i))/(3.0*h(i))
enddo

! Encontrar intervalo correto para avaliação
idx = 1
do i = 1, 3
    if (ptox >= x(i) .and. ptox <= x(i+1)) then
        idx = i
        exit
    endif
enddo

! Se o ponto está fora do intervalo, usar o segmento mais próximo
if (ptox < x(1)) then
    idx = 1
else if (ptox > x(4)) then
    idx = 3
endif

! Avaliar o polinômio spline no intervalo correto
dx = ptox - x(idx)
intCubicSpline1D = f(idx) + b(idx)*dx + c(idx)*dx**2 + d(idx)*dx**3

end function intCubicSpline1D

end module Interpolacao
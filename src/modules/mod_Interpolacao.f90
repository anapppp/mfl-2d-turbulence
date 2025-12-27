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

!   soma_distancias = abs(ptox - vetx(i))  +  abs(ptox - vetx(i+1))
    
!   if (soma_distancias <= vdx(i)) then
!     PontoDeReferencia1D = i+1
!     exit
!   endif

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


end module Interpolacao
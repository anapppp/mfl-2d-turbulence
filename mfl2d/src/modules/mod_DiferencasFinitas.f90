module DiferencasFinitas
implicit none 
 contains

subroutine EDP2GaussSeidelGradeUniforme(f, g, dx, dy, in, jn)
implicit none
! Resolve a EDP de segunda ordem nao-homogenea 
! bidimensional por diferencas finitas 
! lap(f) = g => resolvo f
! usando Gauss-Seidel. PARA GRADE UNIFORME.

real, allocatable, dimension(:,:) :: fold
real :: B, erro, dx, dy, errolim, g(:,:), f(:,:)
integer :: i, j, in, jn


 errolim = 1.0E-3
 B = dx/dy

    
allocate(fold(in,jn))

! Condicao de Contorno de Dirichlet
fold = f

do
 
  erro = 0.0
  do i=2,in-1
    do j=2,jn-1 
    
      f(i,j) = fold(i+1,j) + f(i-1,j) + (B**2)*(fold(i,j+1) + f(i,j-1)) - g(i,j)
      f(i,j) = f(i,j)/(2.0*(1.0+B**2))
    
      if (erro < abs(f(i,j) - fold(i,j)) ) erro = abs(f(i,j) - fold(i,j))

    enddo !j
  enddo !i


  fold = f 
  
  erro = erro/maxval(maxval(abs(f),2)) 

  if (erro < errolim) exit  
  
enddo

return
end subroutine EDP2GaussSeidelGradeUniforme


subroutine EDP2GaussSeidel(f, g, dx, dy, in, jn)
implicit none
! Resolve a EDP de segunda ordem nao-homogenea 
! bidimensional por diferencas finitas 
! lap(f) = g => resolvo f
! usando Gauss-Seidel e SOR. 
! Condição de Contorno: Dirichlet no topo e nas laterais
!                       df/dy = 0.0  (imposicao da pressao) (se j=2,jn)
!                       lap_f = 0.0 em i=in (se i=2,in)


real :: Ax, Ay, B, omega, erromax, errolim, erro, ptoFantasmaX, ptoFantasmaY, Ly
real :: dx(:), dy(:), g(:,:), f(:,:), fold(in,jn)
integer :: i, j, in, jn, cont, ierrmax, jerrmax

 errolim = 1.0E-4
 omega = 1.8

  
 fold  =  f
 cont = 0


do
  cont = cont+1
  erromax = 0.0 

  do i=2,in-1
    do j=2,jn-1     

      if (j==1 .or. j==jn) then
        if (i==in) then
          Ax= 2.0/dx(i-1)/dx(i-1)/(dx(i-1)+dx(i-1))
          Ay = 2.0/dy(j)/dy(j)/(dy(j)+dy(j))
          B = 2.0 * ( 1.0/dx(i-1)/dx(i-1) + 1.0/dy(j)/dy(j) )
          ptoFantasmaY = dy(j)*fold(i,j+1)
          Ly = 0.0 !Ay * (ptoFantasmaY - fold(i,j)*(dy(j)+dy(j)) + fold(i,j+1)*dy(j))
          ptoFantasmaX = -Ly/Ax - f(i-1,j)*dx(i-1) + fold(i,j)*(dx(i-1)+dx(i-1))
          f(i,j) = Ax/B * ( dx(i)*f(i-1,j) + ptoFantasmaX ) + &
                   Ay/B * ( ptoFantasmaY + dy(j)*fold(i,j+1) ) - &
                   g(i,j)/B
        else !i!=in
          Ax = 2.0/dx(i)/dx(i-1)/(dx(i)+dx(i-1))
          Ay = 2.0/dy(j)/dy(j)/(dy(j)+dy(j))
          B = 2.0 * ( 1.0/dx(i)/dx(i-1) + 1.0/dy(j)/dy(j) )
          if (j==1) then
            Ax = 2.0/(dx(i)*dx(i-1)*(dx(i)+dx(i-1)))
            Ay = 2.0/(dy(j)*dy(j)*(dy(j)+dy(j)))
            B = 2.0 * ( 1.0/(dx(i)*dx(i-1)) + 1.0/dy(j)**2 )
            ptoFantasmaY = dy(j)*fold(i,j+1)
            f(i,j) = Ax/B * ( dx(i)*f(i-1,j) + dx(i-1)*fold(i+1,j) ) + &
                     Ay/B * ( ptoFantasmaY + dy(j)*fold(i,j+1) ) - &
                     g(i,j)/B
          else  !j=jn
            Ax = 2.0/dx(i)/dx(i-1)/(dx(i)+dx(i-1))
            Ay = 2.0/dy(j-1)/dy(j-1)/(dy(j-1)+dy(j-1))
            B = 2.0 * ( 1.0/dx(i)/dx(i-1) + 1.0/dy(j-1)/dy(j-1) )
            ptoFantasmaY = dy(j-1)*fold(i,j-1)
            f(i,j) = Ax/B * ( dx(i)*f(i-1,j) + dx(i-1)*fold(i+1,j) ) + &
                     Ay/B * ( dy(j-1)*f(i,j-1) + ptoFantasmaY      ) - &
                     g(i,j)/B
          endif
        endif
        
      else
        Ay = 2.0/(dy(j)*dy(j-1)*(dy(j)+dy(j-1)))
        if (i==in) then
          Ax= 2.0/dx(i-1)/dx(i-1)/(dx(i-1)+dx(i-1))
          B = 2.0 * ( 1.0/dx(i-1)/dx(i-1) + 1.0/dy(j)/dy(j-1) )
          Ly = 0.0! Ay * (f(i,j-1)*dy(j) - fold(i,j)*(dy(j)+dy(j-1)) + fold(i,j+1)*dy(j-1))
          ptoFantasmaX = -Ly/Ax - f(i-1,j)*dx(i-1) + fold(i,j)*(dx(i-1)+dx(i-1))
          f(i,j) = Ax/B * ( dx(i-1)*f(i-1,j) + ptoFantasmaX      ) + &
                   Ay/B * ( dy(j)*f(i,j-1) + dy(j-1)*fold(i,j+1) ) - &
                   g(i,j)/B
        else
          Ax = 2.0/(dx(i)*dx(i-1)*(dx(i)+dx(i-1)))
          B = 2.0 * ( 1.0/(dx(i)*dx(i-1)) + 1.0/(dy(j)*dy(j-1)) )
          f(i,j) = Ax/B * ( dx(i)*f(i-1,j) + dx(i-1)*fold(i+1,j) ) + &
                   Ay/B * ( dy(j)*f(i,j-1) + dy(j-1)*fold(i,j+1) ) - &
                   g(i,j)/B
        endif
        
      endif
      
      f(i,j) = omega*f(i,j) + (1-omega)*fold(i,j)
         
      erro = abs(f(i,j)-fold(i,j))
      if (erromax < erro) then
        erromax = erro
        ierrmax = i
        jerrmax = j
      endif
    
    enddo !j
  enddo !i

  erromax = erromax/maxval(maxval(abs(f),2))

  if (erromax <= errolim) exit  
  
  if (cont >= 50000) then
    write(*,*)  'Gauss Seidel: Criterio de convergencia nao atingido', erromax, ierrmax, jerrmax
    exit
  endif

  fold = f   
  
enddo 

return
end subroutine EDP2GaussSeidel


subroutine EDP2GaussSeidel_Xadrez(f, g, dx, dy, in, jn)
implicit none
! Resolve a EDP de segunda ordem nao-homogenea 
! bidimensional por diferencas finitas 
! lap(f) = g => resolvo f
! usando Gauss-Seidel e SOR. 
! Condição de Contorno: DIRICHLET no topo e nas laterais

real :: Ax, Ay, B, omega, erromax, errolim, erro, ptoFantasmaX, ptoFantasmaY, Ly
real :: dx(:), dy(:), g(:,:), f(:,:), fold(in,jn)
integer :: i, j, in, jn, cont, ierrmax, jerrmax

 errolim = 1.0E-6
 omega = 1.8

  
 fold  =  f
 cont = 0

do
  cont = cont+1
  erromax = 0.0 

  do i=2,in-1,2
    do j=2,jn-1,2     
            
      Ay = 2.0/(dy(j)*dy(j-1)*(dy(j)+dy(j-1)))
      Ax = 2.0/(dx(i)*dx(i-1)*(dx(i)+dx(i-1)))
      B = 2.0 * ( 1.0/(dx(i)*dx(i-1)) + 1.0/(dy(j)*dy(j-1)) )
      f(i,j) = Ax/B * ( dx(i)*f(i-1,j) + dx(i-1)*fold(i+1,j) ) + &
               Ay/B * ( dy(j)*f(i,j-1) + dy(j-1)*fold(i,j+1) ) - &
               g(i,j)/B

      !SOR       
      f(i,j) = omega*f(i,j) + (1-omega)*fold(i,j)
         
      erro = abs(f(i,j)-fold(i,j))
      if (erromax < erro) then
        erromax = erro
        ierrmax = i
        jerrmax = j
      endif
    
    enddo !j
  enddo !i
  fold = f 

  do i=3,in-1,2
    do j=2,jn-1,2     
      
      Ay = 2.0/(dy(j)*dy(j-1)*(dy(j)+dy(j-1)))
      Ax = 2.0/(dx(i)*dx(i-1)*(dx(i)+dx(i-1)))
      B = 2.0 * ( 1.0/(dx(i)*dx(i-1)) + 1.0/(dy(j)*dy(j-1)) )
      f(i,j) = Ax/B * ( dx(i)*f(i-1,j) + dx(i-1)*fold(i+1,j) ) + &
               Ay/B * ( dy(j)*f(i,j-1) + dy(j-1)*fold(i,j+1) ) - &
               g(i,j)/B

      !SOR       
      f(i,j) = omega*f(i,j) + (1-omega)*fold(i,j)
         
      erro = abs(f(i,j)-fold(i,j))
      if (erromax < erro) then
        erromax = erro
        ierrmax = i
        jerrmax = j
      endif
    
    enddo !j
  enddo !i
  fold = f 

  do i=2,in-1,2
    do j=3,jn-1,2  
     
      Ay = 2.0/(dy(j)*dy(j-1)*(dy(j)+dy(j-1)))
      Ax = 2.0/(dx(i)*dx(i-1)*(dx(i)+dx(i-1)))
      B = 2.0 * ( 1.0/(dx(i)*dx(i-1)) + 1.0/(dy(j)*dy(j-1)) )
      f(i,j) = Ax/B * ( dx(i)*f(i-1,j) + dx(i-1)*fold(i+1,j) ) + &
               Ay/B * ( dy(j)*f(i,j-1) + dy(j-1)*fold(i,j+1) ) - &
               g(i,j)/B

      !SOR       
      f(i,j) = omega*f(i,j) + (1-omega)*fold(i,j)
         
      erro = abs(f(i,j)-fold(i,j))
      if (erromax < erro) then
        erromax = erro
        ierrmax = i
        jerrmax = j
      endif
    
    enddo !j
  enddo !i
  fold = f 

!4
 
  do i=3,in-1,2
    do j=3,jn-1,2     
      
      Ay = 2.0/(dy(j)*dy(j-1)*(dy(j)+dy(j-1)))
      Ax = 2.0/(dx(i)*dx(i-1)*(dx(i)+dx(i-1)))
      B = 2.0 * ( 1.0/(dx(i)*dx(i-1)) + 1.0/(dy(j)*dy(j-1)) )
      f(i,j) = Ax/B * ( dx(i)*f(i-1,j) + dx(i-1)*fold(i+1,j) ) + &
               Ay/B * ( dy(j)*f(i,j-1) + dy(j-1)*fold(i,j+1) ) - &
               g(i,j)/B

      !SOR       
      f(i,j) = omega*f(i,j) + (1-omega)*fold(i,j)
         
      erro = abs(f(i,j)-fold(i,j))
      if (erromax < erro) then
        erromax = erro
        ierrmax = i
        jerrmax = j
      endif
    
    enddo !j
  enddo !i
  fold = f 


  erromax = erromax/maxval(maxval(abs(f),2))

  if (erromax <= errolim) exit  
  
  if (cont >= 70000) then
    write(*,*)  'Gauss Seidel: Criterio de convergencia nao atingido', erromax, ierrmax, jerrmax
    exit
  endif

enddo !iteracoes

 return
end subroutine EDP2GaussSeidel_Xadrez


subroutine EDP2GaussSeidel_xUnif_CondContCiclica(f, g, dx, vdy, in, jn)
implicit none

! Resolve a EDP de segunda ordem nao-homogenea 
! bidimensional por diferencas finitas 
! lap(f) = g => resolvo f
! usando Gauss-Seidel e SOR. 
! Condição de Contorno: Dirichlet no topo 
!                       dp1/dz = 0.0  (imposicao da pressao)
!                       ciclica nas laterais

real :: A, B, R, p1, p2, p3, omega, erromax, errolim, erro, dx
real :: vdy(:), g(:,:), f(:,:), fold(in,jn)
integer :: i, j, in, jn, cont, ierrmax, jerrmax
  
errolim = 1.0E-4
omega = 1.0
fold  =  f
cont = 0

do  
  cont = cont+1
  erromax = 0.0 
   
  do i=2,in-1
    do j=2,jn-1 

      A = 2.0/(vdy(j)*vdy(j-1))/(vdy(j)+vdy(j-1)) 
      B = 2.0/dx/dx + A*(vdy(j)+vdy(j-1))
      p1 = -B*fold(i,j)
      p2 = (fold(i+1,j)+fold(i-1,j))/dx/dx

      if(j==2) then
        p3 = A*(vdy(j-1)*fold(i,j+1) + vdy(j)*fold(i,j))
      else
        p3 = A*(vdy(j-1)*fold(i,j+1) + vdy(j)*fold(i,j-1))
      endif

      R = p1 + p2 + p3 - g(i,j)

      f(i,j) = fold(i,j) + R/B*omega

      erro = abs(f(i,j)-fold(i,j))
      
      if (erromax < erro) then
        erromax = erro
        ierrmax = i
        jerrmax = j
      endif

    enddo !j
  enddo !i

  
! CC CICLICA 
  do j=2,jn-1 
      
    A = 2.0/(vdy(j)*vdy(j-1))/(vdy(j)+vdy(j-1)) 
    B = 2/dx/dx + A*(vdy(j)+vdy(j-1))
    p1 = -B*fold(in,j)
    p2 = (fold(2,j)+fold(in-1,j))/dx/dx

    if(j==2) then
      p3 = A*(vdy(j-1)*fold(in,j+1) + vdy(j)*fold(in,j))
    else
      p3 = A*(vdy(j-1)*fold(in,j+1) + vdy(j)*fold(in,j-1))
    endif

    R = p1 + p2 + p3 - g(in,j)

    f(in,j) = fold(in,j) + R/B*omega

    erro = abs(f(in,j)-fold(in,j))
     
    if (erromax < erro) then
      erromax = erro
      ierrmax = in
      jerrmax = j
    endif

  enddo !j

  erromax = erromax/maxval(abs(fold))

  if (erromax <= errolim) exit  

  fold = f
  f(1,:) = f(in,:) 

  if (cont >=1E+06) then
    write(*,*)  'Gauss Seidel: Criterio de convergencia nao atingido', erromax, ierrmax, jerrmax
    exit
  endif

enddo

f(:,1) = f(:,2)

return
end subroutine EDP2GaussSeidel_xUnif_CondContCiclica

  

function Lap2D(f, vdx, vdy, in, jn)
! Calcula o laplaciano de f em um campo 2D
! para grade nao uniforme
! Contorno: lap(f)=0 nas bordas


real :: f(:,:), vdx(:), vdy(:), Lap2D(in,jn) 
real :: ax, ay
integer :: i, j, in, jn


Lap2D = 0.0

!$omp parallel do private(ax, ay)
do i = 2, in-1
  ax = 2.0/(vdx(i)*vdx(i-1)*(vdx(i)+vdx(i-1)))
  do j = 2, jn-1
    ay = 2.0/(vdy(j)*vdy(j-1)*(vdy(j)+vdy(j-1)))

    Lap2D(i,j) = ax * (f(i-1,j)*vdx(i) - f(i,j)*(vdx(i)+vdx(i-1)) + f(i+1,j)*vdx(i-1)) + &
                 ay * (f(i,j-1)*vdy(j) - f(i,j)*(vdy(j)+vdy(j-1)) + f(i,j+1)*vdy(j-1))

  enddo
enddo
!$omp end parallel do


return
end function Lap2D


function Grad1D(g, vdelta, dimFlag, in, jn)
! Calcula o gradiente de f(x,y) em relacao a x ou y em 1D
! para grade não-uniforme
! dimFlag = 1   => derivada em relacao a x (vdelta contem os valores de delta x)
! dimFlag = 2   => derivada em relacao a y (vdelta contem os valores de delta y)
! Contorno: Grad1D = 0 nas bordas


real :: g(:,:), vdelta(:), Grad1D(in,jn)
real, allocatable :: f(:)
integer :: i, j, in, jn, dimFlag

Grad1D = 0.0

if (dimFlag==1) then  !deriva em relacao a x
allocate(f(in))  
  !$omp parallel do private(f)
  do j = 1, jn
    f = g(:,j)
    
    do i = 2, in-1      
      Grad1D(i,j) = ( vdelta(i-1)*vdelta(i-1)*f(i+1) + &
                    (vdelta(i)*vdelta(i)-vdelta(i-1)*vdelta(i-1))*f(i) - vdelta(i)*vdelta(i)*f(i-1) )/&
                    ( vdelta(i)*vdelta(i-1)*(vdelta(i)+vdelta(i-1)) )
    enddo
  enddo
  !$omp end parallel do

endif

if (dimFlag==2) then  !deriva em relacao a y
allocate(f(jn))  
  !$omp parallel do private(f)
  do i = 1, in
    f = g(i,:)
    
    do j = 2, jn-1      
      Grad1D(i,j) = ( vdelta(j-1)*vdelta(j-1)*f(j+1) + &
                    (vdelta(j)*vdelta(j)-vdelta(j-1)*vdelta(j-1))*f(j) - vdelta(j)*vdelta(j)*f(j-1) )/&
                    ( vdelta(j)*vdelta(j-1)*(vdelta(j)+vdelta(j-1)) )
    enddo
  enddo
  !$omp end parallel do

endif

return
end function Grad1D

end module DiferencasFinitas
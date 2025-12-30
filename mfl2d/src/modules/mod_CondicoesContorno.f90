! =========================================================================
! MÓDULO PARA CONDIÇÕES DE CONTORNO MELHORADAS
! Substituir as condições de contorno problemáticas no código original
! =========================================================================

module CondicoesContorno
implicit none
contains

!-------------------------------------------------------------------------
! VELOCIDADE VERTICAL NO TOPO - Várias opções
!-------------------------------------------------------------------------

subroutine VelocidadeVerticalTopo(w2, w1, w0, u2, u1, dx, dz, dt,in, kn)
implicit none
real, intent(inout) :: w2(:,:)
real, intent(in) :: w1(:,:), w0(:,:), u2(:,:), u1(:,:)
real, intent(in) :: dx(:), dz(:), dt
integer, intent(in) :: in, kn
integer :: i, k
real :: dudx, dwdz_int, c_phase

! Da equação da continuidade (RECOMENDADO PARA TURBULÊNCIA)
! Integra du/dx de baixo para cima
   do i = 2, in-1
      dwdz_int = 0.0
      
      ! Calcula integral de -du/dx ao longo da vertical
      ! usando regra do trapézio
      dwdz_int = -0.5 * (u2(i+1,1) - u2(i-1,1)) / &
                        (0.5*(dx(i) + dx(i-1)))
      
      w2(i,kn) = w2(i,1)  ! Partindo da superfície
      
      ! Integra ao longo de z
      do k = 2, kn-1
         dudx = (u2(i+1,k) - u2(i-1,k)) / (0.5*(dx(i) + dx(i-1)))
         w2(i,kn) = w2(i,kn) - dudx * dz(k-1)
      enddo
   enddo 

! Condição de contorno lateral (extrapolação)
w2(1,kn) = w2(2,kn)
w2(in,kn) = w2(in-1,kn)

return
end subroutine VelocidadeVerticalTopo


!-------------------------------------------------------------------------
! VELOCIDADE VERTICAL NA SUPERFÍCIE 
!-------------------------------------------------------------------------

subroutine VelocidadeVerticalSuperficie(w2, w1, u2, u1, dx, dz, in, kn)
implicit none
real, intent(inout) :: w2(:,:)
real, intent(in) :: w1(:,:), u2(:,:), u1(:,:)
real, intent(in) :: dx(:), dz(:)
integer, intent(in) :: in, kn
integer :: i, k
real :: dudx, z0

   ! dw/dz = -du/dx na superfície - continuidade
   do i = 2, in-1
      dudx = (u2(i+1,1) - u2(i-1,1)) / (0.5*(dx(i) + dx(i-1)))
      
      ! Aproximação de dw/dz por diferenças progressivas
      ! w(z=0) é prescrito (geralmente 0)
      ! w(z=dz) = w(z=0) - dudx * dz
      w2(i,1) = 0.0  ! Mantém w=0 na superfície
      w2(i,2) = w2(i,1) - dudx * dz(1)
   enddo

! Condição lateral
w2(1,1) = w2(2,1)
w2(in,1) = w2(in-1,1)

return
end subroutine VelocidadeVerticalSuperficie


!-------------------------------------------------------------------------
! CONDIÇÃO DE CONTORNO DE SAÍDA (OUTLET) - Não-reflexiva
!-------------------------------------------------------------------------

subroutine CondicaoSaida(u2, u1, u0, w2, w1, w0, p2, p1, theta2, theta1, &
                        dx, dz, dt, in, kn)
implicit none
real, intent(inout) :: u2(:,:), w2(:,:), p2(:,:), theta2(:,:)
real, intent(in) :: u1(:,:), u0(:,:), w1(:,:), w0(:,:), p1(:,:), theta1(:,:)
real, intent(in) :: dx(:), dz(:), dt
integer, intent(in) :: in, kn
integer :: i, k
real :: c_conv, alpha_sponge

! Condição convectiva (RECOMENDADO PARA TURBULÊNCIA)
   ! dφ/dt + c*dφ/dx = 0
   ! Permite estruturas turbulentas saírem sem reflexão
   
   do k = 1, kn
      ! Velocidade de convecção (média local)
      c_conv = max(0.5*(u1(in,k) + u1(in-1,k)), 0.1)
      
      ! Atualização com esquema upwind
      u2(in,k) = u1(in,k) - c_conv * dt/dx(in-1) * (u1(in,k) - u1(in-1,k))
      w2(in,k) = w1(in,k) - c_conv * dt/dx(in-1) * (w1(in,k) - w1(in-1,k))
      p2(in,k) = p1(in,k) - c_conv * dt/dx(in-1) * (p1(in,k) - p1(in-1,k))
      theta2(in,k) = theta1(in,k) - c_conv * dt/dx(in-1) * &
                     (theta1(in,k) - theta1(in-1,k))
   enddo

return
end subroutine CondicaoSaida


!-------------------------------------------------------------------------
! VERIFICAÇÃO DE DIVERGÊNCIA
!-------------------------------------------------------------------------

subroutine VerificaDivergencia(u2, w2, dx, dz, in, kn, passo_tempo, limiar)
! Verifica a divergência do campo de velocidade
! Útil para diagnóstico

implicit none
real, intent(in) :: u2(:,:), w2(:,:), dx(:), dz(:)
integer, intent(in) :: in, kn, passo_tempo
real, intent(in) :: limiar
real :: div, div_max, div_media
integer :: i, k, i_max, k_max

div_max = 0.0
div_media = 0.0

do i = 2, in-1
   do k = 2, kn-1
      ! Calcula divergência: du/dx + dw/dz
      div = (u2(i+1,k) - u2(i-1,k)) / (0.5*(dx(i) + dx(i-1))) + &
            (w2(i,k+1) - w2(i,k-1)) / (0.5*(dz(k) + dz(k-1)))
      
      div_media = div_media + abs(div)
      
      if (abs(div) > div_max) then
         div_max = abs(div)
         i_max = i
         k_max = k
      endif
   enddo
enddo

div_media = div_media / ((in-2)*(kn-2))

if (div_max > limiar) then
   write(*,'(A,I6,A,E12.4,A,I4,A,I4)') &
      'AVISO passo ', passo_tempo, ': Divergência máxima = ', div_max, &
      ' em i=', i_max, ', k=', k_max
endif

return
end subroutine VerificaDivergencia


!-------------------------------------------------------------------------
! CORREÇÃO DE VELOCIDADE PARA INCOMPRESSIBILIDADE
!-------------------------------------------------------------------------

subroutine CorrecaoIncompressibilidade(u2, w2, dx, dz, in, kn, dt, beta)
! Aplica correção para reduzir divergência
! beta: fator de relaxação (tipicamente 0.5 a 1.0)

implicit none
real, intent(inout) :: u2(:,:), w2(:,:)
real, intent(in) :: dx(:), dz(:), dt, beta
integer, intent(in) :: in, kn
real :: div, phi(in,kn)
integer :: i, k

! Calcula potencial de correção φ tal que ∇²φ = ∇·v
phi = 0.0

do i = 2, in-1
   do k = 2, kn-1
      div = (u2(i+1,k) - u2(i-1,k)) / (0.5*(dx(i) + dx(i-1))) + &
            (w2(i,k+1) - w2(i,k-1)) / (0.5*(dz(k) + dz(k-1)))
      
      ! Aproximação simples: φ ≈ -div * dx * dz / 4
      phi(i,k) = -beta * div * dx(i) * dz(k) / 4.0
   enddo
enddo

! Corrige velocidades: v_novo = v_velho - ∇φ
do i = 2, in-1
   do k = 2, kn-1
      u2(i,k) = u2(i,k) - (phi(i+1,k) - phi(i-1,k)) / (0.5*(dx(i) + dx(i-1)))
      w2(i,k) = w2(i,k) - (phi(i,k+1) - phi(i,k-1)) / (0.5*(dz(k) + dz(k-1)))
   enddo
enddo

return
end subroutine CorrecaoIncompressibilidade


end module CondicoesContorno
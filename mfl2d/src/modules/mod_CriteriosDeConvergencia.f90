module criteriosdeconvergencia
   implicit none
   contains

   subroutine checkcriteriosdeconvergencia(mi, dt, dz, kn)
      implicit none


      real :: c, mi, dt
      real :: dz(:)
      integer :: k, kn

         do k = 1, kn - 1

            c = mi * dt / (dz(k)*dz(k))
            if (c > 1.0/4.0) then
               write(*, *) "Critério de Estabilidade da parte difusiva extrapolado"
               write(*, *) "  k: ", k
               write(*, *) "  dz: ", dz(k)
               write(*, *) "  c: ", c
            endif

         enddo 


      return

   end subroutine checkcriteriosdeconvergencia

end module criteriosdeconvergencia
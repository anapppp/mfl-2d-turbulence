module RotinasInOut
!-------------------------
!Modulo com subrotina de entrada e saida (leitura e impressao de arquivos)
!-------------------------
implicit none 
 contains

!-------------------------


subroutine printResultCampo2D(var, vetx, vetz, nomeSimulacao, nomeVariavel, passoTempo)
! Imprime os resultados em formato padrao. 
! #1 linha: vetor x
! #2 linha: vetor z
! próximas linhas: valor das variaveis dispostas no plano x-z
!
!
! Exemplo:
! 
! x(1),x(2), ... x(size(x))
! z(1),z(2), ... z(size(z))
! var(1,1), var(2,1) ... var(size(x),1)
! var(1,2), var(2,2) ... var(size(x),2)
! .
! .
! .
! var(1,size(z)), var(2,size(z)) ... var(size(x),size(z))
!
!
! A variavel nomeCampo identifica a variavel. O nome do arquivo de saida tem o seguinte padrao:
! nomeSimulacao.nomeVariavel.passoTempo
! onde "nomeVariavel" pode ter apenas 1 caractere e "passoTempo" deve ter 8 caracteres
! Exemplo: simteste.T.50
!
! O diretorio padrao para impressao dos resultados é ./Resultados



real :: var(:,:), vetx(:), vetz(:)
character*8 :: nomeSimulacao, passoTempo
character :: nomeVariavel
integer :: i, k

passoTempo = adjustl(passoTempo)

open(unit=18, file = "./Resultados/"//nomeSimulacao//"."//nomeVariavel//"."//passoTempo, status="unknown") 

write(18,*) vetx
write(18,*) vetz

do k=1,size(vetz)
  write(18,*) (var(i,k), i=1,size(vetx))
enddo

close(18)
end subroutine printResultCampo2D


!-------------------------


subroutine ReadGrade(nomegrade, in, kn, x, z, dx, dz)
! Le o arquivo de grade e retorna vetores x, z, dx, e dz

real, dimension(:) :: x, z, dx, dz
integer :: i, k, in, kn
character*8  :: nomegrade
character*14 :: arquivoGrade

arquivoGrade = "./"//nomegrade//".grd"
open(unit=18,  file = arquivoGrade)

read(18,*)

do i=1,in
 read(18,*) x(i)
enddo

do k=1,kn
 read(18,*) z(k)
enddo

close(18)

! Calcula espaçamento de grade

do i=1,in-1
  dx(i) = x(i+1)-x(i)
enddo

do k=1,kn-1
  dz(k) = z(k+1)-z(k)
enddo

return

end subroutine ReadGrade



subroutine ReadCampo2D(nomearquivo, var, in, kn)
! Le o arquivo em formato padrao, idem ao dado pela 
! funcao "printResultCampo2D"
!
! O nome do arquivo deve ter 8 caracteres e deve 
! estar no diretorio principal

real :: var(:,:)
integer :: i, k, in, kn, error
character*8  :: nomearquivo

open(unit=18,  file = nomearquivo)


read(18,*)
read(18,*)

do k=1,kn
  read(18,*) (var(i,k), i=1,in)
enddo

close(18)

return

end subroutine ReadCampo2D



!-------------------------
end module RotinasInOut

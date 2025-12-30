include '../CodigoFonte/mod_RotinasInOut.f90'
program makeci_pressao_referencia
!-------------------------------------------------------------------------!
!-------------------------------------------------------------------------!
! Ana Paula Kelm Soares
! 16/jun/2012
! LEMMA/UFPR
! PPGMNE
!-------------------------------------------------------------------------!
! Gera o arquivo de condição inicial de pressao no estado basico de referencia
! 
! A grade e o nome do arquivo com condicao inicial de pressão "pCiFile"
! devem estar no arquivo .cfg 
!
! NA LINHA DE COMANDO: 
! Va para o diretorio principal e digite:
! >> gfortran MakeCondicaoInicial/MakeCI_pressao_referencia_v0.1.f90 -o ./MakeCI_pressao_referencia_v0.1
! >> ./MakeCI_pressao_referencia_v0.1
!
!-------------------------------------------------------------------------!

use RotinasInOut
implicit none
 
real, allocatable, dimension(:,:) :: p0
real, allocatable, dimension(:) :: x, z, dx, dz
real :: dt, rho_ref, theta_ref, mi, alphah, R, cp, g, uCiUnif, wCiUnif, pCiUnif, thetaCiUnif
integer :: i, k, in, kn, npt, nptprint, uCiFlag, wCiFlag, pCiFlag, thetaCiFlag
character*14 :: arquivoConfig, arquivoGrade
character*8  :: nomecaso, nomegrade, uCiFile, wCiFile, pCiFile, thetaCiFile


namelist / dominio / nomegrade
namelist / runconfig / dt, npt, nptprint
namelist / paramfisicos / mi, alphah, R, cp, g
namelist / estbasreferencia / rho_ref
namelist / condicaoinicial / uCiFlag, uCiUnif, uCiFile, wCiFlag, wCiUnif, wCiFile, &
                             pCiFlag, pCiUnif, pCiFile, thetaCiFlag, thetaCiUnif, thetaCiFile


write(*,*) "Escreva o nome da simulacao"
read(*,*) nomecaso

arquivoConfig = "./"//nomecaso//".cfg"	

open(unit=8,  file =  arquivoConfig, delim="apostrophe")


! Lendo dados do arquivo nomecaso.cfg
read(8, NML = dominio)
read(8, NML = runconfig)
read(8, NML = paramfisicos)
read(8, NML = estbasreferencia)
read(8, NML = condicaoinicial)
close(8)


! Lendo o arquivo de grade
 call ReadGrade(nomegrade, in, kn, x, z, dx, dz)
  
 allocate(p0(in,kn))

write(*,*) 'Simulacao: ', nomecaso
write(*,*) 'Grade: ', nomegrade
write(*,*) 'Arq. Cond. Inicial de pressao: ', pCiFile

! Define Condicao Inicial
do k=1,kn
  p0(:,k) = 1000.00 + rho_ref*g*z(k)
enddo


! Imprime os resultados 
open(unit=11, file =  pCiFile, status="unknown")

write(11,*) x
write(11,*) z

do k=1,kn
  write(11,*) (p0(i,k), i=1,in)
enddo

close(11)
end program makeci_pressao_referencia

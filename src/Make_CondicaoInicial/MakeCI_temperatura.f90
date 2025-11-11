include 'mod_RotinasInOut.f90'
program makeci_pressao_referencia
!-------------------------------------------------------------------------!
!-------------------------------------------------------------------------!
! Ana Paula Kelm Soares
! 16/jun/2012
! LEMMA/UFPR
! PPGMNE
!-------------------------------------------------------------------------!
! Gera o arquivo de condição inicial de temperatura levemente instavel
! 
! A grade e o nome do arquivo com condicao inicial de pressão "thetaCiFile"
! devem estar no arquivo .cfg 
!
!-------------------------------------------------------------------------!

use RotinasInOut
implicit none  
 
real, allocatable, dimension(:,:) :: theta0
real, allocatable, dimension(:) :: x, z, dx, dz
real :: dt, rho_ref, temp_ref, mi, alphah, R, cp, g, uCiUnif, wCiUnif, pCiUnif, thetaCiUnif, a, b
integer :: i, k, in, kn, npt, nptprint, uCiFlag, wCiFlag, pCiFlag, thetaCiFlag
character*14 :: arquivoConfig, arquivoGrade
character*8  :: nomecaso, nomegrade, uCiFile, wCiFile, pCiFile, thetaCiFile


namelist / dominio / nomegrade
namelist / runconfig / dt, npt, nptprint
namelist / paramfisicos / mi, alphah, R, cp, g
namelist / estbasreferencia / rho_ref, temp_ref
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

! Lendo o tamanho dos arrays
open(unit=10,  file =  "./"//nomegrade//".grd")
read(10,*) in, kn 
close(10)

 allocate(theta0(in,kn))
 allocate( x(in), z(kn), dx(in-1), dz(kn-1) )

! Lendo o arquivo de grade
 call ReadGrade(nomegrade, in, kn, x, z, dx, dz)
  


write(*,*) 'Simulacao: ', nomecaso
write(*,*) 'Grade: ', nomegrade
write(*,*) 'Arq. Cond. Inicial: ', thetaCiFile

! Define Condicao Inicial

a = 1.0/(z(1)-z(kn))
b = 20.0    - a*z(1)
do k=1,kn
  theta0(:,k) = a*z(k) + b
enddo


! Imprime os resultados 
open(unit=11, file =  thetaCiFile, status="unknown")

write(11,*) x
write(11,*) z

do k=1,kn
  write(11,*) (theta0(i,k), i=1,in)
enddo

close(11)
end program makeci_pressao_referencia

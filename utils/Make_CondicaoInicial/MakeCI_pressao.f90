include 'mod_RotinasInOut.f90'
program makeci_p
!-------------------------------------------------------------------------!
!-------------------------------------------------------------------------!
! Ana Paula Kelm Soares
! 14/out/2012
! LEMMA/UFPR
! PPGMNE
!-------------------------------------------------------------------------!
! Gera o arquivo de condição inicial de velocidade do jato
! 
! A grade e o nome do arquivo com condicao inicial 
! devem estar no arquivo .cfg 
!
!-------------------------------------------------------------------------!

use RotinasInOut
implicit none  
 
real, allocatable, dimension(:,:) :: p0
real, allocatable, dimension(:) :: x, z, dx, dz
real :: dt, rho_ref, temp_ref, press_ref_sup, mi, alphah, R, cp, g, uCiUnif, wCiUnif, pCiUnif, TCiUnif, a, b
real :: uCcTop, uCcSup, wCcTop, wCcSup, TCcTop, TCcSup
integer :: i, k, in, kn, npt, nptprint, nptMediaFlut, MediaFlutFlag, uCiFlag, wCiFlag, pCiFlag, TCiFlag
character*14 :: arquivoConfig, arquivoGrade
character*8  :: nomecaso, nomegrade, uCiFile, wCiFile, pCiFile, TCiFile


namelist / dominio / nomegrade
namelist / runconfig / dt, npt, nptprint, nptMediaFlut, MediaFlutFlag
namelist / paramfisicos / mi, alphah, R, cp, g
namelist / estbasreferencia / rho_ref, temp_ref, press_ref_sup
namelist / condicaoinicial / uCiFlag, uCiUnif, uCiFile, wCiFlag, wCiUnif, wCiFile, &
                             pCiFlag, pCiUnif, pCiFile, TCiFlag, TCiUnif, TCiFile
namelist / condicaocontorno / uCcTop, uCcSup, wCcTop, wCcSup, TCcTop, TCcSup


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
read(8, NML = condicaocontorno)
close(8)

! Lendo o tamanho dos arrays
open(unit=10,  file =  "./"//nomegrade//".grd")
read(10,*) in, kn 
close(10)

 allocate(p0(in,kn))
 allocate( x(in), z(kn), dx(in-1), dz(kn-1) )

! Lendo o arquivo de grade
 call ReadGrade(nomegrade, in, kn, x, z, dx, dz)
  

write(*,*) 'Simulacao: ', nomecaso
write(*,*) 'Grade: ', nomegrade
write(*,*) 'Arq. Cond. Inicial: ', pCiFile

! Define Condicao Inicial
do i=1,in
  p0(i,:) = 10 - 1.2*x(i)
enddo


! Imprime os resultados 
open(unit=11, file =  pCiFile, status="unknown")

write(11,*) x
write(11,*) z

do k=1,kn
  write(11,*) (p0(i,k), i=1,in)
enddo

close(11)
end program makeci_p

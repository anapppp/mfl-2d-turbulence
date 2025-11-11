include 'mod_RotinasInOut.f90'
program makeci_u
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
 
real, allocatable, dimension(:,:) :: u0
real, allocatable, dimension(:) :: x, z, dx, dz
real :: dt, rho_ref, temp_ref, press_ref_sup, mi, alphah, R, cp, g, uCiUnif, wCiUnif, pCiUnif, TCiUnif, a, b,d,umedjato,zcorr,uparab
real :: uCcTop, uCcSup, wCcTop, wCcSup, TCcTop, TCcSup
integer :: i, k, in, kn, npt, nptprint, nptmediaflut, MediaFlutFlag, uCiFlag, wCiFlag, pCiFlag, TCiFlag
character*14 :: arquivoConfig, arquivoGrade
character*8  :: nomecaso, nomegrade, uCiFile, wCiFile, pCiFile, TCiFile


namelist / dominio / nomegrade
namelist / runconfig / dt, npt, nptprint, nptmediaflut, MediaFlutFlag
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

 allocate(u0(in,kn))
 allocate( x(in), z(kn), dx(in-1), dz(kn-1) )

! Lendo o arquivo de grade
 call ReadGrade(nomegrade, in, kn, x, z, dx, dz)
  

write(*,*) 'Simulacao: ', nomecaso
write(*,*) 'Grade: ', nomegrade
write(*,*) 'Arq. Cond. Inicial: ', uCiFile

! Define Condicao Inicial

write(*,*) uCcTop

!-----------------------------------!
!              Jato
!-----------------------------------!

u0 =  uCcTop

!Jato com perfil uniforme
u0(:,52:54) = 10.


! Jato com perfil parabólico
!d = 0.011          !espessura do jato na entrada
!umedjato = 10.0    !velocidade media do jato
!do k=1,kn
! zcorr = z(k) - (z(kn)-z(1))/2.0   !coordenada z corrigida, com zcorr=0 no centro do dominio. O jato esta no centro do dominio
! uparab = (-6.0*umedjato/d**2)*zcorr**2 + 3.0/2.0*umedjato
! if(uparab>=0)  u0(1,k) = uparab 
!enddo



!Canal
!do k=1,kn
!  u0(:,k) = -z(k)/mi*(-1.2)*(0.025/2.0-z(k)/2.0)
!enddo


! Imprime os resultados 
open(unit=11, file =  uCiFile, status="unknown")

write(11,*) x
write(11,*) z

do k=1,kn
  write(11,*) (u0(i,k), i=1,in)
enddo

close(11)
end program makeci_u

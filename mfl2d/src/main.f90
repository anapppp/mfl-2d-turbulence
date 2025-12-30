program mfl2dTurbulence


use PontoDePartida
use DiferencasFinitas
use RotinasInOut
implicit none
 
 real, allocatable, dimension(:,:) :: u0, u1, u2, w0, w1, w2, p0, p1, p2, theta0, theta1, theta2, T2
 real, allocatable, dimension(:,:) :: A0, A1, A2, B1, B2, C0, C1, C2, D0, D1, D2, E1, E2, F0, F1, F2, pressao
 real, allocatable, dimension(:,:) :: lap_p0, lap_p1, lap_p2, lap_u0, lap_u1, lap_u2, lap_w0, lap_w1, lap_w2
 real, allocatable, dimension(:,:) :: grad_p0_x, grad_p1_x, grad_p2_x, grad_p0_z, grad_p1_z, grad_p2_z
 real, allocatable, dimension(:,:) :: umed, wmed, pmed, Tmed, thetamed
 real, allocatable, dimension(:) :: x, z, dx, dz
 real :: dt, ptoPartida0(2), ptoPartida1(2), gamma, a, b, Ax, EnCineticaMedia, Vorticidade, dwdx, dudz
 real :: rho_ref, temp_ref, press_ref_sup, mi, alphah, R, cp, g 
 real :: uCiUnif, wCiUnif, pCiUnif, TCiUnif, uCcTop, uCcSup, wCcTop, wCcSup, TCcTop, TCcSup
 integer :: i, k, n, in, kn, npt, nptprint, nptMediaFlut, MediaFlutFlag, contpt
 integer :: uCiFlag, wCiFlag, pCiFlag, TCiFlag, PontosCalcFlutX(3), PontosCalcFlutZ(3), ii, jj
 character*8  :: nomecaso, nomegrade, passotempo, uCiFile, wCiFile, pCiFile, TCiFile
 character*21 :: url

 
 namelist / dominio / nomegrade
 namelist / runconfig / dt, npt, nptprint, nptMediaFlut, MediaFlutFlag
 namelist / paramfisicos / mi, alphah, R, cp, g
 namelist / estbasreferencia / rho_ref, temp_ref, press_ref_sup
 namelist / condicaoinicial / uCiFlag, uCiUnif, uCiFile, wCiFlag, wCiUnif, wCiFile, &
 pCiFlag, pCiUnif, pCiFile, TCiFlag, TCiUnif, TCiFile
 namelist / condicaocontorno / uCcTop, uCcSup, wCcTop, wCcSup, TCcTop, TCcSup
 

 call get_environment_variable("CASE", nomecaso)
nomecaso = trim(nomecaso)
url = "/data/cases/"//nomecaso//"/"

 ! Lendo dados do arquivo nomecaso.cfg
 open(unit=8,  file = url//"input/"//nomecaso//".cfg", status="old", delim="apostrophe")
 read(8, NML = dominio)
 read(8, NML = runconfig)
 read(8, NML = paramfisicos)
 read(8, NML = estbasreferencia)
 read(8, NML = condicaoinicial)
 read(8, NML = condicaocontorno)
 close(8)

! Lendo o tamanho dos arrays
 open(unit=10,  file =  url//"input/"//nomegrade//".grd", status="old")
 read(10,*) in, kn 
 close(10)
 allocate( x(in), z(kn), dx(in-1), dz(kn-1) )
 allocate( umed(in,kn), wmed(in,kn), pmed(in,kn), Tmed(in,kn), thetamed(in,kn) )
 allocate( p0(in,kn), p1(in,kn), p2(in,kn), theta0(in,kn), theta1(in,kn), theta2(in,kn) )
 allocate( u0(in,kn), w0(in,kn), u1(in,kn), w1(in,kn), u2(in,kn), w2(in,kn), T2(in,kn) )
 allocate( A0(in,kn), A1(in,kn), A2(in,kn), B1(in,kn), B2(in,kn), C0(in,kn), C1(in,kn), C2(in,kn) )
 allocate( D0(in,kn), D1(in,kn), D2(in,kn), E1(in,kn), E2(in,kn), F0(in,kn), F1(in,kn), F2(in,kn) )
 allocate( lap_p0(in,kn), lap_p1(in,kn), lap_p2(in,kn), pressao(in,kn) )
 allocate( lap_u0(in,kn), lap_u1(in,kn), lap_u2(in,kn), lap_w0(in,kn), lap_w1(in,kn), lap_w2(in,kn) )
 allocate( grad_p0_x(in,kn), grad_p1_x(in,kn), grad_p2_x(in,kn), grad_p0_z(in,kn), grad_p1_z(in,kn), grad_p2_z(in,kn) )

 ! Lendo o arquivo de grade
 call ReadGrade(url//"input/"//nomegrade//".grd", in, kn, x, z, dx, dz)

 open(unit=9,  file = url//"log/"//nomecaso//".inf", status="unknown")
 open(unit=11, file = url//"log/"//nomecaso//".log", status="unknown")
 open(unit=13, file = url//"results/"//nomecaso//".ecin", status="unknown")
 open(unit=25, file = url//"results/"//nomecaso//".vort", status="unknown")
 open(unit=27, file = url//"results/"//nomecaso//".u.full", status="unknown")
 open(unit=29, file = url//"results/"//nomecaso//".w.full", status="unknown")
 open(unit=31, file = url//"results/"//nomecaso//".p.full", status="unknown")
 open(unit=33, file = url//"results/"//nomecaso//".t.full", status="unknown")
 open(unit=35, file = url//"results/"//nomecaso//".q.full", status="unknown")  


 
 
! Define Condicao Inicial
 if (uCiFlag == 0) then 
   if (uCiUnif <= -9999.9) then !Escoamento de Couette
     b = (uCcTop-uCcSup)/(z(kn)-z(1))
     a = uCcSup - b*z(1)
       do k=1,kn
         u0(:,k) = a + b*z(k)
       enddo
   else
     u0 = uCiUnif
   endif
 endif  
 if (uCiFlag == 1) call ReadCampo2D(uCiFile, u0, in, kn)
 if (wCiFlag == 0) w0 = wCiUnif
 if (wCiFlag == 1) call ReadCampo2D(wCiFile, w0, in, kn)
 if (pCiFlag == 0) p0 = pCiUnif
 if (pCiFlag == 1) call ReadCampo2D(pCiFile, p0, in, kn)
 if (TCiFlag == 0) T2 = TCiUnif
 if (TCiFlag == 1) call ReadCampo2D(TCiFile, T2, in, kn)
 

! Arquivo nomecaso.inf
 write(9,*) 'Simulacao: ', nomecaso
 write(9,*) 'Grade: ', nomegrade
 write(9,*) 'Periodo de simulacao (s):', npt*dt
 write(9,*) 'Intervalo de tempo:   dt =', dt
 write(9,*)
 write(9,*) 'Delimitacao do dominio (m):'
 write(9,*) 'x inicial:', x(1), '  x final:', x(in)
 write(9,*) 'z inicial:', z(1), '  z final:', z(kn)
 write(9,*) 

! Define Condicao de Contorno
 u0(:,1) = uCcSup
 u0(:,kn) = uCcTop

 if (wCcSup <= -9999.9) then
   w0(:,1) = 0.0
   write(9,*) 'Velocidade vertical na superficie: calculada'
 else
   w0(:,1) = wCcSup
   write(9,*) 'Velocidade vertical na superficie: prescrita'
 endif

 if (wCcTop <= -9999.9) then
   w0(:,kn) = 0.0
   write(9,*) 'Velocidade vertical no topo: calculada'
 else 
   w0(:,kn) = wCcTop
   write(9,*) 'Velocidade vertical no topo: prescrita'
 endif

 close(9)

 
 T2(:,1) = TCcSup
 T2(:,kn) = TCcTop

! Inicializa variáveis
 gamma = g/cp  !lapse rate

 do i=1,in
  do k=1,kn
   theta0(i,k) = T2(i,k) + temp_ref + gamma*z(k)
  enddo  
 enddo

 grad_p0_x = Grad1D(p0,dx,1, in, kn)
 grad_p0_z = Grad1D(p0,dz,2, in, kn)
 lap_u0 = Lap2D(u0, dx, dz, in, kn)
 lap_w0 = Lap2D(w0, dx, dz, in, kn)
 lap_p0 = Lap2D(p0, dx, dz, in, kn) 

 A0 = 2.0*dt*alphah*Lap2D(theta0, dx, dz, in, kn)+ theta0
 B1 = 2.0*rho_ref*g/temp_ref*Grad1D(T2,dz,2, in, kn)
 C0 = 2.0*mi*( Grad1D(lap_u0,dx,1, in, kn) + Grad1D(lap_w0,dz,2, in, kn) ) - lap_p0
 D0 = dt/rho_ref*(-grad_p0_x + 2.0*mi*lap_u0) + u0 
 E1 = 2.0*dt*g*T2/temp_ref
 F0 = dt/rho_ref*(-grad_p0_z + 2.0*mi*lap_w0) + w0

 u1  = u0
 u2  = u1
 w1 = w0
 w2  = w1
 p1 = p0
 p2 = p1
 theta1 = theta0
 theta2 = theta1

 A1 = A0
 C1 = C0
 D1 = D0
 F1 = F0

 lap_p1 = lap_p0
 lap_p2 = lap_p1
 lap_u1 = lap_u0
 lap_w1 = lap_w0
 grad_p1_x = grad_p0_x
 grad_p1_z = grad_p0_z

! Ponto para o calculo das flutuacoes
 PontosCalcFlutX(1) = int(1.0/4.0*real(in))
 PontosCalcFlutX(2) = int(1.0/2.0*real(in))
 PontosCalcFlutX(3) = int(3.0/4.0*real(in))
 PontosCalcFlutZ(1) = int((kn+1)/2)-10
 PontosCalcFlutZ(2) = int((kn+1)/2)
 PontosCalcFlutZ(3) = int((kn+1)/2)+5

 write(9,*) 'Pontos para calculo das flutuacoes e da serie full'
 write(9,'(f10.6,f10.6)') ((x(PontosCalcFlutX(ii)), z(PontosCalcFlutZ(jj)), ii=1,3), jj=1,3)


 if (MediaFlutFlag == 0) then
   umed = 0.0
   wmed = 0.0
   pmed = 0.0 
   Tmed = 0.0 
   thetamed = 0.0 
 endif

 if (MediaFlutFlag == 1) then
   call system("cp "//url//"results/"//nomecaso//".u.med ./mediaarq") 
   call ReadCampo2D('mediaarq', umed, in, kn)
   call system("cp "//url//"results/"//nomecaso//".w.med ./mediaarq")
   call ReadCampo2D('mediaarq', wmed, in, kn)
   call system("cp "//url//"results/"//nomecaso//".p.med ./mediaarq")
   call ReadCampo2D('mediaarq', pmed, in, kn)
   call system("cp "//url//"results/"//nomecaso//".t.med ./mediaarq")
   call ReadCampo2D('mediaarq', Tmed, in, kn)
   call system("cp "//url//"results/"//nomecaso//".q.med ./mediaarq")
   call ReadCampo2D('mediaarq', thetamed, in, kn)
   call system("rm mediaarq")

   open(unit=15, file = url//"results/"//nomecaso//".u.flu", status="unknown")
   open(unit=17, file = url//"results/"//nomecaso//".w.flu", status="unknown")
   open(unit=19, file = url//"results/"//nomecaso//".p.flu", status="unknown")
   open(unit=21, file = url//"results/"//nomecaso//".t.flu", status="unknown")
   open(unit=23, file = url//"results/"//nomecaso//".q.flu", status="unknown")  
 endif


write(passotempo,*) '0'

call printResultCampo2D(u0, x, z, url//"results/"//nomecaso//'.u.'//passotempo)
call printResultCampo2D(w0, x, z, url//"results/"//nomecaso//'.w.'//passotempo)
call printResultCampo2D(p0, x, z, url//"results/"//nomecaso//'.p.'//passotempo)
call printResultCampo2D(theta0, x, z, url//"results/"//nomecaso//'.q.'//passotempo)
call printResultCampo2D(T2, x, z, url//"results/"//nomecaso//'.t.'//passotempo)

!-------------------------------------------------------------------------!
! Inicio da previsao
!-------------------------------------------------------------------------!



write(*,*) 'Simulacao: ', nomecaso
write(*,*) 'Grade: ', nomegrade
write(*,*) 'INICIO DA PREVISAO'

 contpt = 0
 
do n = 1, npt

 contpt = contpt + 1

  do i = 2, in
   do k = 2, kn-1

!     Calculando o Ponto de Partida 
      ptoPartida0 = CalculaPontoDePartida2P3NT(i, k, x, z, dx, dz, u1, w1, dt, 0)
      ptoPartida1 = CalculaPontoDePartida2P3NT(i, k, x, z, dx, dz, u1, w1, dt, 1)
!      ptoPartida0 = CalculaPontoDePartida3NTRobert(i, k, x, z, dx, dz, u1, w1, dt, 0)
!      ptoPartida1 = CalculaPontoDePartida3NTRobert(i, k, x, z, dx, dz, u1, w1, dt, 1)

!     Calculando a Temperatura Potencial
      theta2(i,k) = ValorNoPontoDePartida(A0, x, z, dx, dz, ptoPartida0, i, k)
   
!     Calculando o Laplaciano da Pressao
      lap_p2(i,k) = ValorNoPontoDePartida(B1, x, z, dx, dz, ptoPartida1, i, k) + &
                    ValorNoPontoDePartida(C0, x, z, dx, dz, ptoPartida0, i, k)   

   enddo !k
  enddo !i
   
! Calculando o campo de Pressão 
!  call EDP2GaussSeidel(p2, lap_p2, dx, dz, in, kn)
!  call EDP2GaussSeidelGradeUniforme(p2,lap_p2, dx(1), dz(1), in, kn)
  call EDP2GaussSeidel_Xadrez(p2, lap_p2, dx, dz, in, kn)


! Calculando os gradientes de Pressão 
  grad_p2_x = Grad1D(p2,dx,1, in, kn)
  grad_p2_z = Grad1D(p2,dz,2, in, kn)

  do i = 2, in-1
   do k = 2, kn-1 
  !     Calculando o Ponto de Partida 
      ptoPartida0 = CalculaPontoDePartida2P3NT(i, k, x, z, dx, dz, u1, w1, dt, 0)  
      ptoPartida1 = CalculaPontoDePartida2P3NT(i, k, x, z, dx, dz, u1, w1, dt, 1)
!      ptoPartida0 = CalculaPontoDePartida3NTRobert(i, k, x, z, dx, dz, u1, w1, dt, 0)
!      ptoPartida1 = CalculaPontoDePartida3NTRobert(i, k, x, z, dx, dz, u1, w1, dt, 1)
      
!     Calculando as componentes u e w da velocidade
      u2(i,k) = -dt/rho_ref*grad_p2_x(i,k) + ValorNoPontoDePartida(D0, x, z, dx, dz, ptoPartida0, i, k)
      w2(i,k) = -dt/rho_ref*grad_p2_z(i,k) + ValorNoPontoDePartida(E1, x, z, dx, dz, ptoPartida1, i, k) + &
                ValorNoPontoDePartida(F0, x, z, dx, dz, ptoPartida0, i, k)   
                
     enddo !k
  enddo !i


! Calculando a velocidade vertical no topo
 if (wCcTop <= -9999.9) w2(:,kn) = 1.5*w1(:,kn-1) - 0.5*w1(:,kn-3)
 if (wCcSup <= -9999.9) w2(:,1)  = 1.5*w1(:,2)    - 0.5*w1(:,4)

 u2(in,:) = 1.5*u1(in-1,:) - 0.5*u1(in-3,:)
  
! Calculando o Laplaciano da velocidade
  lap_u2 = Lap2D(u2, dx, dz, in, kn)
  lap_u2(:,1) = grad_p2_x(:,1)/mi
  lap_w2 = Lap2D(w2, dx, dz, in, kn)
  lap_w2(:,1) = 0.0   

! Calculando o desvio do estado de referencia da temperatura, a pressao total, a energia cinetica e a vorticidade medias
  EnCineticaMedia = 0.0
  Vorticidade = 0.0
  do i = 2, in-1
    do k = 2, kn-1   
      T2(i,k) = theta2(i,k) - temp_ref - gamma*z(k)
      EnCineticaMedia = EnCineticaMedia + (u2(i,k)**2 + w2(i,k)**2)/2.0 
      dwdx = (w2(i+1,k)*dx(i-1)**2 + w2(i,k)*(dx(i)**2-dx(i-1)**2) - w2(i-1,k)*dx(i)**2)/(dx(i)*dx(i-1)*(dx(i)+dx(i-1)))
      dudz = (u2(i,k+1)*dz(k-1)**2 + u2(i,k)*(dz(k)**2-dz(k-1)**2) - u2(i,k-1)*dz(k)**2)/(dz(k)*dz(k-1)*(dz(k)+dz(k-1)))
      Vorticidade = Vorticidade + (dwdx - dudz)
    enddo !k
  enddo !i
  EnCineticaMedia = EnCineticaMedia/((in-2)*(kn-2))
  Vorticidade = Vorticidade/((in-2)*(kn-2))
  
! Calculando A2, B2, C2, D2, E2, e F2 
  A2 = 2.0*dt*alphah*Lap2D(theta2, dx, dz, in, kn)+ theta2
  B2 = 2.0*rho_ref*g/temp_ref*Grad1D(T2,dz,2, in, kn)
  C2 = 2.0*mi*( Grad1D(lap_u2,dx,1, in, kn) + Grad1D(lap_w2,dz,2, in, kn) ) - lap_p2
  D2 = dt/rho_ref*(-grad_p2_x + 2.0*mi*lap_u2) + u2 
  E2 = 2.0*dt*g*T2/temp_ref
  F2 = dt/rho_ref*(-grad_p2_z + 2.0*mi*lap_w2) + w2
    
  if (n>(npt-nptMediaFlut) ) then

!   Calculando as Medias 
    if (MediaFlutFlag == 0) then !calcula media
      umed = umed + u2
      wmed = wmed + w2
      pmed = pmed + p2
      Tmed = Tmed + T2
      thetamed = thetamed + theta2
    endif                     

!   Calculando as Flutuacoes
    if (MediaFlutFlag == 1) then  !calcula flutuacoes
      write(15,*) n*dt, ((u2(PontosCalcFlutX(ii),PontosCalcFlutZ(jj))-umed(PontosCalcFlutX(ii),PontosCalcFlutZ(jj)),ii=1,3), jj=1,3)
      write(17,*) n*dt, ((w2(PontosCalcFlutX(ii),PontosCalcFlutZ(jj))-wmed(PontosCalcFlutX(ii),PontosCalcFlutZ(jj)),ii=1,3), jj=1,3)
      write(19,*) n*dt, ((p2(PontosCalcFlutX(ii),PontosCalcFlutZ(jj))-pmed(PontosCalcFlutX(ii),PontosCalcFlutZ(jj)),ii=1,3), jj=1,3)
      write(21,*) n*dt, ((T2(PontosCalcFlutX(ii),PontosCalcFlutZ(jj))-Tmed(PontosCalcFlutX(ii),PontosCalcFlutZ(jj)),ii=1,3), jj=1,3)
      write(23,*) n*dt, ((theta2(PontosCalcFlutX(ii),PontosCalcFlutZ(jj))-thetamed(PontosCalcFlutX(ii),PontosCalcFlutZ(jj)), &
                                                                                                                    ii=1,3), jj=1,3)
    endif

!   Registranto a serie temporal full
    write(27,*) n*dt, ((u2(PontosCalcFlutX(ii),PontosCalcFlutZ(jj)),ii=1,3), jj=1,3)
    write(29,*) n*dt, ((w2(PontosCalcFlutX(ii),PontosCalcFlutZ(jj)),ii=1,3), jj=1,3)
    write(31,*) n*dt, ((p2(PontosCalcFlutX(ii),PontosCalcFlutZ(jj)),ii=1,3), jj=1,3)
    write(33,*) n*dt, ((T2(PontosCalcFlutX(ii),PontosCalcFlutZ(jj)),ii=1,3), jj=1,3)
    write(35,*) n*dt, ((theta2(PontosCalcFlutX(ii),PontosCalcFlutZ(jj)),ii=1,3), jj=1,3)
  endif


! Escrevendo arquivo de saida 
  
  write(13,*)n*dt, EnCineticaMedia
  write(25,*)n*dt, Vorticidade

  if (contpt == nptprint) then
  
    write(*,*)  'n=',n,'Tempo(s) = ',n*dt 
    write(passotempo,'(i8)') n
    write(11,*) 'n=',n,'Tempo(s) = ',n*dt
   
    call printResultCampo2D(u2, x, z, url//"results/"//nomecaso//'.u.'//passotempo)
    call printResultCampo2D(w2, x, z, url//"results/"//nomecaso//'.w.'//passotempo)
    call printResultCampo2D(p2, x, z, url//"results/"//nomecaso//'.p.'//passotempo)
    call printResultCampo2D(theta2, x, z, url//"results/"//nomecaso//'.q.'//passotempo)
    call printResultCampo2D(T2, x, z, url//"results/"//nomecaso//'.t.'//passotempo)
    contpt = 0
    
  endif
   
  u0 = u1
  u1 = u2
  w0 = w1
  w1 = w2
  p0 = p1
  p1 = p2
  theta0 = theta1
  theta1 = theta2
  
  A0 = A1
  A1 = A2    
  B1 = B2  
  C0 = C1
  C1 = C2
  D0 = D1
  D1 = D2
  E1 = E2
  F0 = F1
  F1 = F2
  
  lap_p0 = lap_p1
  lap_p1 = lap_p2
  lap_u0 = lap_u1
  lap_u1 = lap_u2
  lap_w0 = lap_w1
  lap_w1 = lap_w2
  
  grad_p0_x = grad_p1_x
  grad_p1_x = grad_p2_x
  grad_p0_z = grad_p1_z
  grad_p1_z = grad_p2_z

enddo !n

! Escrevendo as medias no arquivo de saida
if (MediaFlutFlag == 0) then
  umed = umed/nptMediaFlut
  wmed = wmed/nptMediaFlut
  pmed = pmed/nptMediaFlut
  Tmed = Tmed/nptMediaFlut
  thetamed = thetamed/nptMediaFlut

  write(passotempo,'(a)') 'med'
  call printResultCampo2D(umed, x, z, url//"results/"//nomecaso//'.u.'//passotempo)
  call printResultCampo2D(wmed, x, z, url//"results/"//nomecaso//'.w.'//passotempo)
  call printResultCampo2D(pmed, x, z, url//"results/"//nomecaso//'.p.'//passotempo)
  call printResultCampo2D(Tmed, x, z, url//"results/"//nomecaso//'.t.'//passotempo)
  call printResultCampo2D(thetamed, x, z, url//"results/"//nomecaso//'.q.'//passotempo)
endif


if (MediaFlutFlag == 1) then
  close(15)
  close(17)
  close(19)
  close(21)
  close(23)
endif


write(*,*) 'FIM DA PREVISAO'
write(*,*) 'Simulacao: ', nomecaso



!-------------------------------------------------------------------------!
! Fim da previsao
!-------------------------------------------------------------------------!


close(11)
close(13)
close(25)
close(27)
close(29)
close(31)
close(33)
close(35)

end program mfl2dTurbulence

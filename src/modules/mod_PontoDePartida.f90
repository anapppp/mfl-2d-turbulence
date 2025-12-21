include 'mod_Interpolacao.f90'
module PontoDePartida
!-------------------------
!Modulo com funcoes necessárias para calcular o valor da funcao no ponto de partida
!-------------------------
use Interpolacao
implicit none 
 contains

 function CalculaPontoDePartida3NTRobert(ii, jj, vetx, vety, vdx, vdy, velu, velv, dt, xnFlag)
!  Calcula o ponto de partida pelo método de 3 niveis de tempo de Robert (1 passso). Fonte: 
!     Robert, A. A stable numerical integration scheme for the primitive meteorological 
!     equations Atmosphere-Ocean, Taylor & Francis, 1981, 19, 35-46

real :: a, b, xn, yn, CalculaPontoDePartida3NTRobert(2), dt, n
real :: vetx(:), vety(:), vdx(:), vdy(:), velu(:,:), velv(:,:)
integer :: ii, jj, iteracao, xnflag

      if (xnFlag == 0)  n = 2.0      
      if (xnFlag == 1)  n = 1.0

      a = 0.0
      b = 0.0
      do iteracao = 1,4   !estas sao as iteracoes para encontrar a e b

        a = dt * ValorNoPontoDePartida(velu, vetx, vety, vdx, vdy, (/vetx(ii)-a, vety(jj)-b/), ii, jj)
        b = dt * ValorNoPontoDePartida(velv, vetx, vety, vdx, vdy, (/vetx(ii)-a, vety(jj)-b/), ii, jj)

      enddo
      xn = vetx(ii) - n*a
      yn = vety(jj) - n*b

      CalculaPontoDePartida3NTRobert = (/xn, yn/)      
      
return

end function CalculaPontoDePartida3NTRobert


!-------------------------


function CalculaPontoDePartida2P3NT(ii, jj, vetx, vety, vdx, vdy, velu, velv, dt, xnFlag)
! Calcula o ponto de partida utilizando o método de 2 passos e 3 niveis de tempo. 
!
! Fonte: Almeida, R. C.; Costa, G. A. S.; Fonseca, L. C. M. & Alves, J. L. D. 
!        Particle trajectory calculations with a two-step three-time level 
!        semi-Lagrangian scheme well suited for curved flows International 
!        Journal for Numerical Methods in Fluids, 2009, 61, 995-1028
!
! xnFlag = 1 => retorna a posição da particula no passo de tempo anterior (t)
! xnFlag = 0 => retorna a posicao da particula a dois passos de tempo atrás (t-dt)

real :: a, b, xn, yn, CalculaPontoDePartida2P3NT(2), dt, n, aold, bold
real :: vetx(:), vety(:), vdx(:), vdy(:), velu(:,:), velv(:,:)
integer :: ii, jj, iteracao, step, xnFlag

      xn = vetx(ii)
      yn = vety(jj)
      
      !if (xnFlag == 0)  n = 2.0      
      !if (xnFlag == 1)  n = 1.0


      do step = 1,2  !estes são os dois passos
        a = 0.0
        b = 0.0
        do iteracao = 1,4   !estas sao as iteracoes para encontrar a e b
        
          aold = a
          bold = b
          a = dt/2.0 * ValorNoPontoDePartida(velu, vetx, vety, vdx, vdy, (/xn-aold, yn-bold/), ii, jj)
          b = dt/2.0 * ValorNoPontoDePartida(velv, vetx, vety, vdx, vdy, (/xn-aold, yn-bold/), ii, jj)

          enddo
        xn = xn - 2.0*a
        yn = yn - 2.0*b

      enddo
     
      if (max(abs(a-aold),abs(b-bold)) >=1.0E-02) write(*,*) 'Ponto de Partida: Calculo nao convergiu',&
                                                             ii, jj, max(abs(a-aold),abs(b-bold))
            
!      CalculaPontoDePartida2P3NT = (/ xn , yn /)
      
      
 if (xnFlag == 0)  CalculaPontoDePartida2P3NT = (/ xn , yn /)      
 if (xnFlag == 1)  CalculaPontoDePartida2P3NT = (/ xn+(vetx(ii)-xn)/2.0 , yn+(vety(jj)-yn)/2.0 /)
      
return

end function CalculaPontoDePartida2P3NT


!-------------------------


real function  ValorNoPontoDePartida(f, vetx, vety, vdx, vdy, vetPtoPartida, ii, jj)
! Esta funcao calcula o valor da funcao f interpolado no ponto (ptox,ptoy)
! Se o ponto esta fora do dominio, a o valor é substituido pelo valor 
! no ponto do contorno que cruza a trajetoria da particula
!
! Esta funcao difere da ValorNoPontoDePartidaGradeUniforme pois utiliza 
! a função PontoDeReferencia1D para calcular iref ee jref. Tb considera dx 
! e dy variavel no dominio.

integer :: iref, jref, sizex, sizey, ii, jj
real :: f(:,:), vetx(:), vety(:), vdx(:), vdy(:), vetPtoPartida(2)  
real :: xn, yn, xnc, ync, vpp
sizex = size(vetx)
sizey = size(vety)
xn = vetPtoPartida(1)
yn = vetPtoPartida(2)
        
    if (xn<vetx(1) .or. xn>vetx(sizex) .or. yn<vety(1) .or. yn>vety(sizey)) then  !ponto de partida está em algum lugar fora do dominio 

      if (xn<vetx(1)) then       !regiao A
        xnc = vetx(1)
        ync = (vety(jj)-yn)/(vetx(ii)-xn)*(xnc-xn)+yn
        if (ync<vety(1))then 
          ync = vety(1)
          xnc = (ync-yn)/(vety(jj)-yn)*(vetx(ii)-xn) + xn
          iref = PontoDeReferencia1D(vetx, vdx, xnc)
          vpp = intCubicLagr1D(f(iref-2,1),f(iref-1,1),&
                       f(iref,1),f(iref+1,1),vetx(iref-2),vdx(iref-2),vdx(iref-1),vdx(iref),xnc)
        else 
          if (ync>vety(sizey)) then 
            ync = vety(sizey)
            xnc = (ync-yn)/(vety(jj)-yn)*(vetx(ii)-xn) + xn
            iref = PontoDeReferencia1D(vetx, vdx, xnc)
            vpp = intCubicLagr1D(f(iref-2,sizey),f(iref-1,sizey),&
                       f(iref,sizey),f(iref+1,sizey),vetx(iref-2),vdx(iref-2),vdx(iref-1),vdx(iref),xnc)
          else 
            jref = PontoDeReferencia1D(vety, vdy, ync)
            vpp = intCubicLagr1D(f(1,jref-2),f(1,jref-1),f(1,jref),&
                       f(1,jref+1),vety(jref-2),vdy(jref-2),vdy(jref-1),vdy(jref),ync)
          endif
        endif 

      else 
        if (xn>vetx(sizex)) then   !regiao B
          xnc = vetx(sizex)
          ync = (vety(jj)-yn)/(vetx(ii)-xn)*(xnc-xn)+yn
          if (ync<vety(1))then 
            ync = vety(1)
            xnc = (ync-yn)/(vety(jj)-yn)*(vetx(ii)-xn) + xn
            iref = PontoDeReferencia1D(vetx, vdx, xnc)
            vpp = intCubicLagr1D(f(iref-2,1),f(iref-1,1),&
                      f(iref,1),f(iref+1,1),vetx(iref-2),vdx(iref-2),vdx(iref-1),vdx(iref),xnc)
          else 
            if (ync>vety(sizey)) then 
              ync = vety(sizey)
              xnc = (ync-yn)/(vety(jj)-yn)*(vetx(ii)-xn) + xn
              vpp = intCubicLagr1D(f(iref-2,sizey),f(iref-1,sizey),&
                            f(iref,sizey),f(iref+1,sizey),vetx(iref-2),vdx(iref-2),vdx(iref-1),vdx(iref),xnc)
            else 
              jref = PontoDeReferencia1D(vety, vdy, ync)
              vpp = intCubicLagr1D(f(sizex,jref-2),f(sizex,jref-1),&
                            f(sizex,jref),f(sizex,jref+1),vety(jref-2),vdy(jref-2),vdy(jref-1),vdy(jref),ync)
            endif
         endif 

        else 
          if (yn<vety(1)) then  !regiao C
            ync = vety(1)
            xnc = (ync-yn)/(vety(jj)-yn)*(vetx(ii)-xn) + xn
            iref = PontoDeReferencia1D(vetx, vdx, xnc)
            vpp = intCubicLagr1D(f(iref-2,1),f(iref-1,1),&
                       f(iref,1),f(iref+1,1),vetx(iref-2),vdx(iref-2),vdx(iref-1),vdx(iref),xnc)

          else !regiao D
            ync = vety(sizey)
            xnc = (ync-yn)/(vety(jj)-yn)*(vetx(ii)-xn) + xn
            iref = PontoDeReferencia1D(vetx, vdx, xnc)
            vpp = intCubicLagr1D(f(iref-2,sizey),f(iref-1,sizey),& 
                       f(iref,sizey),f(iref+1,sizey),vetx(iref-2),vdx(iref-2),vdx(iref-1),vdx(iref),xnc)
            
          endif
        endif
      endif    
    
    else  !o ponto de partida esta dentro do dominio

    iref = PontoDeReferencia1D(vetx, vdx, xn)
    jref = PontoDeReferencia1D(vety, vdy, yn)

    vpp = intCubicLagr2D(f, vetx, vety, vdx, vdy, iref, jref, xn, yn)
    
    endif

    ValorNoPontoDePartida = vpp

end function  ValorNoPontoDePartida


!-------------------------


real function  ValorNoPontoDePartida_CondContCiclica(f, vetx, vety, vdx, vdy, vetPtoPartida, ii, jj)
! Esta funcao calcula o valor da funcao f interpolado no ponto (ptox,ptoy)
! Considera condicao de contorno ciclica em x.

integer :: iref, jref, sizex, sizey, ii, jj, i, j
real :: f(:,:), vetx(:), vety(:), vdx(:), vdy(:), vetPtoPartida(2)  
real :: xn, yn, xnc, ync, vpp

sizex = size(vetx)
sizey = size(vety)

xn = vetPtoPartida(1)
yn = vetPtoPartida(2)
      
    if (xn<vetx(1) .or. xn>vetx(sizex) .or. yn<vety(1) .or. yn>vety(sizey)) then  !ponto de partida está em algum lugar fora do dominio 

      if (xn<vetx(1)) then       !regiao A
        xnc = vetx(1)
        ync = (vety(jj)-yn)/(vetx(ii)-xn)*(xnc-xn)+yn
        if (ync<vety(1))then 
          ync = vety(1)
          xnc = (ync-yn)/(vety(jj)-yn)*(vetx(ii)-xn) + xn
          iref = PontoDeReferencia1D(vetx, vdx, xnc)
          vpp = intCubicLagr1D(f(iref-2,1),f(iref-1,1),&
                       f(iref,1),f(iref+1,1),vetx(iref-2),vdx(iref-2),vdx(iref-1),vdx(iref),xnc)
        else 
          if (ync>vety(sizey)) then
            ync = vety(sizey)
            xnc = (ync-yn)/(vety(jj)-yn)*(vetx(ii)-xn) + xn
            iref = PontoDeReferencia1D(vetx, vdx, xnc)
            vpp = intCubicLagr1D(f(iref-2,sizey),f(iref-1,sizey),&
                       f(iref,sizey),f(iref+1,sizey),vetx(iref-2),vdx(iref-2),vdx(iref-1),vdx(iref),xnc)
           else
             
              if(yn<=vety(1) .or. yn>=vety(sizey)) then
                jref = PontoDeReferencia1D(vety, vdy, ync)   
                vpp = intCubicLagr1D(f(1,jref-2),f(1,jref-1),f(1,jref),&
                      f(1,jref+1),vety(jref-2),vdy(jref-2),vdy(jref-1),vdy(jref),ync)
              else
                !*** CC CICLICA! iref vai para o fim do dominio ***! 
                do while (xn<vetx(1))
                  xn = vetx(sizex)-vetx(1)+ xn
                enddo
                iref = PontoDeReferencia1D(vetx, vdx, xn)
                jref = PontoDeReferencia1D(vety, vdy, yn)
                vpp = intCubicLagr2D(f, vetx, vety, vdx, vdy, iref, jref, xn, yn)
              endif
           
           endif
        endif 

      else 
        if (xn>vetx(sizex)) then   !regiao B
          xnc = vetx(sizex)
          ync = (vety(jj)-yn)/(vetx(ii)-xn)*(xnc-xn)+yn
          if (ync<vety(1))then 
            ync = vety(1)
            xnc = (ync-yn)/(vety(jj)-yn)*(vetx(ii)-xn) + xn
            iref = PontoDeReferencia1D(vetx, vdx, xnc)
            vpp = intCubicLagr1D(f(iref-2,1),f(iref-1,1),&
                      f(iref,1),f(iref+1,1),vetx(iref-2),vdx(iref-2),vdx(iref-1),vdx(iref),xnc)
          else 
            if (ync>vety(sizey)) then 
              ync = vety(sizey)
              xnc = (ync-yn)/(vety(jj)-yn)*(vetx(ii)-xn) + xn
              iref = PontoDeReferencia1D(vetx, vdx, xnc)
              vpp = intCubicLagr1D(f(iref-2,sizey),f(iref-1,sizey),&
                            f(iref,sizey),f(iref+1,sizey),vetx(iref-2),vdx(iref-2),vdx(iref-1),vdx(iref),xnc)
            else 

              if(yn<=vety(1) .or. yn>=vety(sizey)) then
                jref = PontoDeReferencia1D(vety, vdy, ync)
                vpp = intCubicLagr1D(f(sizex,jref-2),f(sizex,jref-1),&
                         f(sizex,jref),f(sizex,jref+1),vety(jref-2),vdy(jref-2),vdy(jref-1),vdy(jref),ync)
              else
                !*** CC CICLICA! iref vai para o inicio do dominio ***! 
                do while(xn>vetx(sizex))
                  xn = vetx(1) + xn - vetx(sizex)
                enddo
                iref = PontoDeReferencia1D(vetx, vdx, xn)
                jref = PontoDeReferencia1D(vety, vdy, yn)
                vpp = intCubicLagr2D(f, vetx, vety, vdx, vdy, iref, jref, xn, yn)
              endif

            endif
         endif 

        else 
          if (yn<vety(1)) then  !regiao C
            ync = vety(1)
            xnc = (ync-yn)/(vety(jj)-yn)*(vetx(ii)-xn) + xn
            iref = PontoDeReferencia1D(vetx, vdx, xnc)
            vpp = intCubicLagr1D(f(iref-2,1),f(iref-1,1),&
                       f(iref,1),f(iref+1,1),vetx(iref-2),vdx(iref-2),vdx(iref-1),vdx(iref),xnc)

          else !regiao D
            ync = vety(sizey)
            xnc = (ync-yn)/(vety(jj)-yn)*(vetx(ii)-xn) + xn
            iref = PontoDeReferencia1D(vetx, vdx, xnc)
            vpp = intCubicLagr1D(f(iref-2,sizey),f(iref-1,sizey),& 
                       f(iref,sizey),f(iref+1,sizey),vetx(iref-2),vdx(iref-2),vdx(iref-1),vdx(iref),xnc)
            
          endif
        endif
      endif    
    
    else  !o ponto de partida esta dentro do dominio

    iref = PontoDeReferencia1D(vetx, vdx, xn)
    jref = PontoDeReferencia1D(vety, vdy, yn)

    vpp = intCubicLagr2D(f, vetx, vety, vdx, vdy, iref, jref, xn, yn)
    
    endif

     ValorNoPontoDePartida_CondContCiclica = vpp

end function  ValorNoPontoDePartida_CondContCiclica


!-------------------------


real function  ValorNoPontoDePartidaGradeUniforme(f, vetx, vety, vdx, vdy, xn, yn, ii, jj)
! Esta funcao calcula o valor da funcao f interpolado no ponto (ptox,ptoy)
! Se o ponto esta fora do dominio, a o valor é substituido pelo valor 
! no ponto do contorno que cruza a trajetoria da particula

integer :: p, q, iref, jref, sizex, sizey, ii, jj
real :: f(:,:), vetx(:), vety(:), vdx(:), vdy(:)
real :: xn, yn, xnc, ync, dx, dy

sizex = size(vetx)
sizey = size(vety)
dx = vdx(1)
dy = vdy(1)

        
    if (xn<vetx(1) .or. xn>vetx(sizex) .or. yn<vety(1) .or. yn>vety(sizey)) then  !ponto de partida está em algum lugar fora do dominio 

      if (xn<vetx(1)) then       !regiao A
        xnc = vetx(1)
        ync = (vety(jj)-yn)/(vetx(ii)-xn)*(xnc-xn)+yn
        if (ync<vety(1))then 
          ync = vety(1)
          xnc = (ync-yn)/(vety(jj)-yn)*(vetx(ii)-xn) + xn
          p = int((vetx(ii)-xnc)/dx)
          iref = ii-p
          ValorNoPontoDePartidaGradeUniforme = intCubicLagr1D(f(iref-2,1),f(iref-1,1),&
                                    f(iref,1),f(iref+1,1),vetx(iref-2),dx,dx,dx,xnc)
        else 
          if (ync>vety(sizey)) then 
            ync = vety(sizey)
            xnc = (ync-yn)/(vety(jj)-yn)*(vetx(ii)-xn) + xn
            p = int((vetx(ii)-xnc)/dx)
            iref = ii-p
            ValorNoPontoDePartidaGradeUniforme = intCubicLagr1D(f(iref-2,sizey),f(iref-1,sizey),&
                           f(iref,sizey),f(iref+1,sizey),vetx(iref-2),dx,dx,dx,xnc)
          else 
            q = int((vety(jj)-ync)/dy)
            jref = jj-q
            ValorNoPontoDePartidaGradeUniforme = intCubicLagr1D(f(1,jref-2),f(1,jref-1),&
                                        f(1,jref),f(1,jref+1),vety(jref-2),dy,dy,dy,ync)
          endif
        endif 

      else 
        if (xn>vetx(sizex)) then   !regiao B
          xnc = vetx(1)
          ync = (vety(jj)-yn)/(vetx(ii)-xn)*(xnc-xn)+yn
          if (ync<vety(1))then 
            ync = vety(1)
            xnc = (ync-yn)/(vety(jj)-yn)*(vetx(ii)-xn) + xn
            p = int((vetx(ii)-xnc)/dx)
            iref = ii-p
            ValorNoPontoDePartidaGradeUniforme = intCubicLagr1D(f(iref-2,1),f(iref-1,1),&
                                         f(iref,1),f(iref+1,1),vetx(iref-2),dx,dx,dx,xnc)
          else 
            if (ync>vety(sizey)) then 
              ync = vety(sizey)
              xnc = (ync-yn)/(vety(jj)-yn)*(vetx(ii)-xn) + xn
              p = int((vetx(ii)-xnc)/dx)
              iref = ii-p
              ValorNoPontoDePartidaGradeUniforme = intCubicLagr1D(f(iref-2,sizey),f(iref-1,sizey),&
                             f(iref,sizey),f(iref+1,sizey),vetx(iref-2),dx,dx,dx,xnc)
            else 
              q = int((vety(jj)-ync)/dy)
              jref = jj-q
              ValorNoPontoDePartidaGradeUniforme = intCubicLagr1D(f(sizex,jref-2),f(sizex,jref-1),&
                             f(sizex,jref),f(sizex,jref+1),vety(jref-2),dy,dy,dy,ync)
            endif
         endif 

        else 
          if (yn<vety(1)) then  !regiao C
            ync = vety(1)
            xnc = (ync-yn)/(vety(jj)-yn)*(vetx(ii)-xn) + xn
            p = int((vetx(ii)-xnc)/dx)
            iref = ii-p
            ValorNoPontoDePartidaGradeUniforme = intCubicLagr1D(f(iref-2,1),&
                                f(iref-1,1),f(iref,1),f(iref+1,1),vetx(iref-2),dx,dx,dx,xnc)

          else !regiao D
            ync = vety(sizey)
            xnc = (ync-yn)/(vety(jj)-yn)*(vetx(ii)-xn) + xn
            p = int((vetx(ii)-xnc)/dx)
            iref = ii-p
            ValorNoPontoDePartidaGradeUniforme = intCubicLagr1D(f(iref-2,sizey),f(iref-1,sizey),& 
                           f(iref,sizey),f(iref+1,sizey),vetx(iref-2),dx,dx,dx,xnc)
            
          endif
        endif
      endif    
    
    else  !o ponto de partida esta dentro do dominio
      
    p = int((vetx(ii)-xn)/dx)
    q = int((vety(jj)-yn)/dy)
    iref = ii-p
    jref = jj-q

    ValorNoPontoDePartidaGradeUniforme = intCubicLagr2D(f, vetx, vety, vdx, vdy, iref, jref, xn, yn)
    
    endif


end function  ValorNoPontoDePartidaGradeUniforme


!-------------------------



end module PontoDePartida

#!/usr/bin/env python
import matplotlib
import matplotlib.pyplot as plt
import sys
import numpy
import asciitable
from class_LerArquivos import *
from class_Label import *
from math import pi
import cmath 

"""
-------------------------------------------------------------------------
 Ana Paula Kelm Soares
 25/Outubro/2012
 LEMMA/UFPR
 PPGMNE
-------------------------------------------------------------------------
 Script para calcular e plotar o espectro. 
 Para rodar o script na linha de comando, mude para o diretorio 
 principal e digite:

 python ./PosProcessamento/CalculaEspectro.py nomedoarquivo 

 O arquivo "nomedoarquivo" deve estar na pasta ./Resultados

!-------------------------------------------------------
! programa para calculo de transformadas de Fourier discretas
!
! autor: Ricardo C. de Almeida
! data: 14/04/2011
!
!
! constantes:
! reais:
! pi : pi
!
! variaveis
!
! inteiras:
! n: indice de frequencias
! k: indice de dados medidos
! ndata: numero de dados de entrada
! nmax: indice da frequencia maxima
! ios: verificacao de IOSTAT
!
! reais:
! a: array de dados de entrada
! freq: array das frequencias (ciclos/tempo)
! omega: array das frequencias angulares (rad/tempo)
! periodo: array dos periodos (tempo/ciclo)
! modamp: array dos modulos d as amplitudes dos coeficientes
! espectro: array ds energias do espectro
! pd: periodo da serie de dados
! dt: intervalo de tempo entre os dados!
! dummy1: variavel auxiliar para leitura dos dados
! rndatac: resto da divisao do numero de dadso por 2 (verificacao de paridade)
! hfndata: metado do numero de dados de entrada
! partimag: expoente da parte imaginaria em forma real
! 
! complexas
! fa: array dos coeficientes de Fourier
! sumampk: somador de amplitudes dos coef. de Fourier no loop de k
! termexp: exponencial da serie de fourier
! 
!-------------------------------------------------------


-------------------------------------------------------------------------
"""

filename = sys.argv[1]
nomesim, nomelabel, nomevar, passotempo = Labels('./Resultados/' + filename)

# Lendo arquivo
tempo, dados = LerFlutuacoes('./Resultados/' + filename)

dt = tempo[1] - tempo[0]  # intervalo de tempo
print 'dt: ', dt

nlist = []
#omegalist = []
freqlist = []
#periodolist = []
espectrolist = []

# Numero de pontos
npontos = len(dados)   
# Numero de divisoes da serie
ndivserie = 20

ndataserie = len(tempo)
nptotrexo = int(ndataserie/ndivserie)
idxdivserielist = range(0,ndataserie,nptotrexo)
del idxdivserielist[-1]

print 'npontos:', npontos
print 'ndivserie: ', ndivserie
print 'ndataserie:', ndataserie
print 'nptotrexo', nptotrexo


# Verifica paridade de ndata
ndata = nptotrexo
    
hfndata=float(ndata)/2.0
rndatac=hfndata-float(int(hfndata))

if rndatac<0.2:  # ndata eh par
  nmax=ndata/2
else:            # ndata eh impar
  ndata=ndata-1
  nmax=(ndata)/2



#--------------------------------------------------------#
# Loop em cada ponto: a = flutuacao em cada ponto
#--------------------------------------------------------#

for dadopto in dados:
  espectromedia = numpy.zeros(nmax+1)
  print 'calculando ponto ...'
  
#--------------------------------------------------------  
# Inicia loop do trexo da serie
  for idxdivserie in idxdivserielist:   

    a = dadopto[idxdivserie:idxdivserie+nptotrexo]

#   cria listas e incializa arrays
    freq = numpy.zeros(nmax+1)#ndata)
#    omega = numpy.zeros(nmax+1)
#    periodo = numpy.zeros(nmax+1)
    modamp = numpy.zeros(nmax+1)
    espectro = numpy.zeros(nmax+1)
    fa = numpy.ones(nmax+1)*complex(0,0) # variavel complexa

#--------------------------------------------------------
#   inicia loop das frequencias (n)
    for n in range(nmax+1):
      sumampk = complex(0,0) # zera somador das amplitudes do loop em k

#     loop dos dados (k)
      for k in range(ndata):
        partimag = -2.0*pi*float(n)*float(k)/float(ndata)
        termexp = complex(0,partimag) # variavel complexa
        sumampk = sumampk+a[k]*cmath.exp(termexp)    # variavel complexa
 

#     atribui valor a coeficiente complexo
      fa[n] = sumampk/ndata  # variavel complexa


#   fim do loop das frequencias (n)
#--------------------------------------------------------

#   calcula periodo dos dados
    pd = float(ndata)*dt

#   calcula frequencias e periodos
    for n in range(1,nmax+1):
      freq[n] = float(n)/pd
#      omega[n] = 2.0*pi*freq[n]
#      periodo[n] = pd/float(n)

#   calcula modulos das amplitudes e espectro
    modamp = abs(fa)  # modulo de fa
    espectro = [2.0*i**2  for i in modamp]

#   calcula a media do espectro (espectromedia)
    for n in range(nmax+1):
      espectromedia[n] = espectromedia[n] + espectro[n] 


#   Fim loop do trexo da serie
#--------------------------------------------------------#
 
  espectromedia = [i/float(ndivserie)  for i in espectromedia ]
  
# armazena resultados
#  nlist.append(n)
#  omegalist.append(omega)
  freqlist.append(freq)
#  periodolist.append(periodo)
  espectrolist.append(espectromedia)

# Apagando variaveis da memoria
  del n, freq, espectromedia #, omega, periodo


#--------------------------------------------------------#
# Fim do loop nos pontos (dadopto) 
#--------------------------------------------------------#





# Escrevendo arquivo de saida
dadoswrite = espectrolist
dadoswrite.insert(0,freqlist[0])
dadoswrite = zip(*dadoswrite)
namecol = ['frequencia', 'pto1', 'pto2', 'pto3', 'pto4', 'pto5', 'pto6', 'pto7', 'pto8', 'pto9']
asciitable.write(dadoswrite, './SaidasPosProcessamento/'+filename[:-3]+'esp', names=namecol, delimiter=';')


# Plotando 

# Curva com inclunacao -3
xx = [1.0E+01,1.0E+03]
yy = [1.0E-12,1.0E-18]

# fig1

plt.figure(1)
plt.xscale('log')
plt.yscale('log')
plt.ylabel('Energia')
plt.xlabel('Frequencia')
plt.plot(xx, yy,'--', color='k')

plt.plot(freqlist[0], espectrolist[0], label = '1')
plt.plot(freqlist[1], espectrolist[1], label = '2')
plt.plot(freqlist[2], espectrolist[2], label = '3')

plt.legend()


# fig2

plt.figure(2)
plt.xscale('log')
plt.yscale('log')
plt.ylabel('Energia')
plt.xlabel('Frequencia')
plt.plot(xx, yy,'--', color='k')

plt.plot(freqlist[3], espectrolist[3], label = '4')
plt.plot(freqlist[4], espectrolist[4], label = '5')
plt.plot(freqlist[5], espectrolist[5], label = '6')

plt.legend()

# fig3

plt.figure(3)

plt.xscale('log')
plt.yscale('log')
plt.ylabel('Energia')
plt.xlabel('Frequencia')
plt.plot(xx, yy,'--', color='k')

plt.plot(freqlist[6], espectrolist[6], label = '7')
plt.plot(freqlist[7], espectrolist[7], label = '8')
plt.plot(freqlist[8], espectrolist[8], label = '9')

plt.legend()

plt.show()


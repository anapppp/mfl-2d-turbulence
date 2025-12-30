#!/usr/bin/env python
import matplotlib
import matplotlib.pyplot as plt
from numpy import *
import sys
from class_LerArquivos import *
from class_Label import *
"""
-------------------------------------------------------------------------
 Ana Paula Kelm Soares
 19/Outubro/2012
 LEMMA/UFPR
 PPGMNE
-------------------------------------------------------------------------
 Script para plotar o perfil Normalizado de um jato. 
 Para rodar o script na linha de comando, mude para o diretorio 
 principal e digite:

 python ./PosProcessamento/PloPerfilNormalizado.py nomedoarquivo mi rho

 O arquivo "nomedoarquivo" deve estar na pasta ./Resultados
-------------------------------------------------------------------------
"""

plt.figure(figsize=(10,8.5))
pylab.xlim([-2,2])
pylab.ylim([0,1])

etateorico = [ i/100.0  for i in range(-200,201)]
fBradbury = [ exp(-0.6749*i*i*(1+0.0269*i*i*i*i))  for i in etateorico]
fTownsend = [ exp(-0.6619*i*i*(1+0.0565*i*i*i*i))  for i in etateorico]

paramlist = sys.argv
filename = paramlist[1]
xplotrlist = [float(i) for i in paramlist[2:]]

# Lendo arquivo
nomesim, nomelabel, nomevar, passotempo = Labels('./Resultados/' + filename)
X,Y,Z = LerArquivoPadrao('./Resultados/' + filename)

for xplotr in xplotrlist: 

# Encontrando ponto x mais proximo de xplotr
  listdelta = []
  listdelta = abs(X[0,:]-xplotr)
  deltax = X[0,1] - X[0,0]
  for i in range(len(listdelta)):
    if listdelta[i] <= deltax:
       ixplot = i
       xplot = xplot = "%.1f" %X[0,ixplot] #str(X[0,ixplot]) 

  y = Y[:,ixplot]
  y = y - (max(y)-min(y))/2.0
  u = Z[:,ixplot]


# Calculando paramentros
  U1 = u[0]        #velocidade do escoamento livre
  U0 = max(u)-U1   #diferenca da velocidade no centro do jato e o escoamento livre


  for i in range(len(y)): 
    if((u[i]-U1) <= U0/2.0 <= (u[i+1]-U1)):
       print i, y[i], (u[i]-U1)/2
       a = (y[i+1]-y[i])/(u[i+1]-u[i]) 
       b = y[i] - a*(u[i]-U1)
       delta = abs(a*U0/2.0 + b)
       break

    
# Calculando variaveis adimensionais
  f = [ (i-U1)/U0  for i in u]
  eta = [ i/delta  for i in y]

  print '-----'
  print filename
  print 'xplot: ', xplot
  print 'U1: ', U1
  print 'U0: ', U0
  print 'delta: ', delta
  print '-----'


# Plotando 
#  fig = plt.figure()
  plt.plot(eta, f, '-o', label=xplot+'m')

#matplotlib.rcParams.update({'font.size': 13})
plt.plot(etateorico,fBradbury,'-', color='k', label='Bradbury (1965)')
#plt.plot(etateorico,fTownsend,'--', color='k', label='Townsend (1956)')
#plt.plot(medicoes[0], medicoes[1], label='Medido')

#plt.title(nomesim)
plt.ylabel('f($\eta$)', size='20')
plt.xlabel('$\eta$', size='20')
plt.legend()

plt.show()

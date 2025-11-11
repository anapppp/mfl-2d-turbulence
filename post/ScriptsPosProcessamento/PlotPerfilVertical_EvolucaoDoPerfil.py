#!/usr/bin/env python
import matplotlib
import matplotlib.pyplot as plt
import sys
from class_LerArquivos import *
from class_Label import *
"""
-------------------------------------------------------------------------
 Ana Paula Kelm Soares
 12/Julho/2012
 LEMMA/UFPR
 PPGMNE
-------------------------------------------------------------------------
 Script para plotar o perfil vertical. 
 Para rodar o script na linha de comando, mude para o diretorio 
 principal e digite:

 python ./PosProcessamento/PloPerfilVertical.py nomedoarquivo xplot

 O arquivo "nomedoarquivo" deve estar na pasta ./Resultados
 A variavel xplot e a coordenada x para o qual o perfil sera plotado.
-------------------------------------------------------------------------
"""


paramlist = sys.argv
filename = paramlist[1]
xplotrlist = [float(i) for i in paramlist[2:]]

fig = plt.figure(figsize=(6.5,5.5))
fig.gca().ticklabel_format(style='sci', scilimits=(0,0), axis='x')

# Lendo arquivo
X,Y,Z = LerArquivoPadrao('./Resultados/' + filename)
nomesim, nomelabel, nomevar, passotempo = Labels('./Resultados/' + filename)

for xplotr in xplotrlist: 

# Encontrando ponto x mais proximo de xplotr
  listdelta = []
  listdelta = abs(X[0,:]-xplotr)
  deltax = X[0,1] - X[0,0]
  for i in range(len(listdelta)):
    if listdelta[i] <= deltax:
       ixplot = i
       xplot = "%.1f" %X[0,ixplot] #str(X[0,ixplot]) 

    
# Plotando 
  plt.plot(Y[:,ixplot],Z[:,ixplot], label=xplot + 'm')

#plt.title(nomesim+ '\n' +nomevar+ '\n' +'n='+passotempo+'   x='+xplot)
plt.title(nomesim)
plt.ylabel(nomelabel)
plt.xlabel('z(m)')
plt.legend()
plt.show()

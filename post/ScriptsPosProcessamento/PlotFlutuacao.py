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
 Script para plotar as flutuacoes. 
 Para rodar o script na linha de comando, mude para o diretorio 
 principal e digite:

 python ./PosProcessamento/CalculaEspectro.py nomedoarquivo 

 O arquivo "nomedoarquivo" deve estar na pasta ./Resultados

-------------------------------------------------------------------------
"""

filename = sys.argv[1]
nomesim, nomelabel, nomevar, passotempo = Labels('./Resultados/' + filename)

# Lendo arquivo
tempo, dados = LerFlutuacoes('./Resultados/' + filename)

# Diferenca relativa maxima
pointlist = [3,4,5,7]  # lista com os indices dos pontos A, B, C e D

print 'Simulacao: ', nomesim
print 'Variavel: ', nomevar
print 'Maxima diferenca relativa (%):'
for i in pointlist:
  vmax = max(dados[i][:])
  vmin = min(dados[i][:])
  maxdifrel = abs(vmax-vmin)/min([abs(vmax),abs(vmin)])
  maxdifrel = maxdifrel*100
  print 'ponto',i+1, ':', maxdifrel
 

# Plotando 

# fig1

pylab.xlim([12,15])

fig = plt.figure(1)
plt.ylabel(nomelabel)
plt.xlabel('tempo(s)')
fig.gca().ticklabel_format(style='sci', scilimits=(0,0), axis='y')

plt.plot(tempo[:], dados[4][:], color='k')

plt.show()


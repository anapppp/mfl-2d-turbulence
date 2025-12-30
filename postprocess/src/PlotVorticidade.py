#!/usr/bin/env python
import matplotlib
import matplotlib.pyplot as plt
import sys
from class_LerArquivos import *
from class_Label import *
"""
-------------------------------------------------------------------------
 Ana Paula Kelm Soares
 14/Dezembro/2012
 LEMMA/UFPR
 PPGMNE
-------------------------------------------------------------------------
 Script para plotar a vorticidade em funcao do tempo. 
 Para rodar o script na linha de comando, mude para o diretorio 
 principal e digite:

 python ./PosProcessamento/PlotVorticidade.py nomedasimulacao

 O arquivo "nomedoarquivo" deve estar na pasta ./Resultados
-------------------------------------------------------------------------
"""

# Lendo arquivo

nomesim = sys.argv[1]
filename = './Resultados/' + nomesim + '.vort'

filedata = open(filename, 'r')
dadosarq = filedata.readlines()

tempo = []
vorticidade = []
for line in dadosarq:
  a = map(float, line.split())
  tempo.append(a[0])
  vorticidade.append(a[1])

# Plotando 

fig = plt.figure()
#plt.title(nomesim+ '\n' + 'Vorticidade')
plt.xlabel('t(s)')
plt.ylabel('Vorticidade ($s^{-1}$)')

plt.plot(tempo, vorticidade, color='k')

plt.show()

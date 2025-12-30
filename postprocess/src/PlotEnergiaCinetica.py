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
 Script para plotar a energia cinetica em funcao do tempo. 
 Para rodar o script na linha de comando, mude para o diretorio 
 principal e digite:

 python ./PosProcessamento/PloEnergiaCinetica.py nomedasimulacao

 O arquivo "nomedoarquivo" deve estar na pasta ./Resultados
 A variavel xplot e a coordenada x para o qual o perfil sera plotado.
-------------------------------------------------------------------------
"""

# Lendo arquivo

nomesim = sys.argv[1]
filename = './cases/' + nomesim + '/results/' + nomesim + '.ecin'

filedata = open(filename, 'r')
dadosarq = filedata.readlines()

tempo = []
encinetica = []
for line in dadosarq:
    t, ec = map(float, line.split())
    tempo.append(t)
    encinetica.append(ec)

# Plotando

fig = plt.figure()
# plt.title(nomesim+ '\n' + 'Energia Cinetica')
plt.xlabel('t(s)')
plt.ylabel('Energia Cinetica ($m^{2}/s^{2}$)')

plt.plot(tempo, encinetica, color='k')

plt.show()

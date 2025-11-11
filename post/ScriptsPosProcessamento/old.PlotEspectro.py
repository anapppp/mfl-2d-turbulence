#!/usr/bin/env python
import matplotlib
import matplotlib.pyplot as plt
import sys
from class_LerArquivos import *
from class_Label import *
"""
-------------------------------------------------------------------------
 Ana Paula Kelm Soares
 11/Outubro/2012
 LEMMA/UFPR
 PPGMNE
-------------------------------------------------------------------------
 Script para plotar o perfil medio. 
 Para rodar o script na linha de comando, mude para o diretorio 
 principal e digite:

 python ./PosProcessamento/PloPerfilMeio.py nomedoarquivo 

 O arquivo "nomedoarquivo" deve estar na pasta ./Resultados
-------------------------------------------------------------------------
"""

# Lendo arquivo
filename = 'espectro.pto5.txt'

n, omega, frequencia, periodo, espectro = LerEspectro(filename)

# Plotando 

fig = plt.figure()

plt.xscale('log')
plt.yscale('log')
plt.ylabel('Energia')
plt.xlabel('Frequencia')

plt.plot(frequencia, espectro, color='k')

plt.show()

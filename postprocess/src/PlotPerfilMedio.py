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
filename = sys.argv[1]
filename = './Resultados/' + filename

y, var = LerPerfilMedio(filename)

nomesim, nomelabel, nomevar, passotempo = Labels(filename)


# Plotando 

fig = plt.figure()
plt.title(nomesim+ '\n' +nomevar)
# plt.title(nomevar+ '\n' + ' x='+xplot + 'm')

plt.ylabel('z(m)')
plt.xlabel(nomelabel)

plt.plot(var, y, color='k')

plt.show()

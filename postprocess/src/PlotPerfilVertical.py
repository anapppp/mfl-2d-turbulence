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

# Lendo arquivo

nomesim = sys.argv[1]
filename = './cases/' + nomesim + '/results/' + nomesim + '.u.40000'

X, Y, Z = LerArquivoPadrao(filename)
nomesim, nomelabel, nomevar, passotempo = Labels(filename)

xplot = float(sys.argv[2])


# Encontrando ponto x mais proximo de xplot

listdelta = []
listdelta = abs(X[0, :]-xplot)
deltax = X[0, 1] - X[0, 0]
for i in range(len(listdelta)):
    if listdelta[i] <= deltax:
        ixplot = i
        xplot = "%.1f" % X[0, ixplot]  # str(X[0,ixplot])


# Plotando

fig = plt.figure()
# plt.title(nomesim+ '\n' +nomevar+ '\n' +'n='+passotempo+'   x='+xplot)
plt.title('x='+xplot + 'm')

plt.ylabel('z(m)')
plt.xlabel(nomelabel)

plt.plot(Z[:, ixplot], Y[:, ixplot], color='k')

plt.show()

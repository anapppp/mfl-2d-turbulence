#!/usr/bin/env python
import matplotlib.pyplot as plt
import sys
from class_LerArquivos import *
"""
-------------------------------------------------------------------------
 Ana Paula Kelm Soares
 28/Maio/2012
 LEMMA/UFPR
 PPGMNE
-------------------------------------------------------------------------
Script para plotar os vetores do campo de velocidade. Utiliza o formato 
padrao da saida do modelo.
Para rodar o script na linha de comando, mude para o diretorio 
principal e digite:

python ./PosProcessamento/PloVetor.py nomedocaso passodetempo

Os arquivos com os valores das velocidades devem estar na pasta ./Resultados	
-------------------------------------------------------------------------
"""

# Lendo arquivo

nomedocaso = sys.argv[1]
passodetempo = sys.argv[2]
filenameU = './Resultados/' + nomedocaso + '.u.' + passodetempo
filenameV = './Resultados/' + nomedocaso + '.w.' + passodetempo

X,Y,U = LerArquivoPadrao(filenameU)
X,Y,V = LerArquivoPadrao(filenameV)

# Numero de linhas e colunas para pular
nlcpx = 1
nlcpy = 1

# Plotando

plt.figure()

plt.title(nomedocaso + '\n' +' n='+ passodetempo)
plt.ylabel('z(m)')
plt.xlabel('x(m)')

Q = plt.quiver( X[::nlcpy,::nlcpx], Y[::nlcpy,::nlcpx], U[::nlcpy,::nlcpx], V[::nlcpy,::nlcpx], units='width' )


plt.show()



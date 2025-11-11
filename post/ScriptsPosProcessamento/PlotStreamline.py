#!/usr/bin/env python
import matplotlib.pyplot as plt
import numpy as np
import sys
from class_LerArquivos import *
from class_Streamplot import streamplot

"""
-------------------------------------------------------------------------
 Ana Paula Kelm Soares
 28/Maio/2012
 LEMMA/UFPR
 PPGMNE
-------------------------------------------------------------------------
Script para plotar as linhas de corrente. Utiliza o formato 
padrao da saida do modelo.
Para rodar o script na linha de comando, mude para o diretorio 
principal e digite:

python ./PosProcessamento/PlotStreamline.py nomedocaso passodetempo

!!! APENAS PARA GRADE UNIFORME !!!!

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


# Plotando

plt.figure()

plt.title(nomedocaso + '\n' +' n='+ passodetempo)
plt.ylabel('z(m)')
plt.xlabel('x(m)')

streamplot(X[0], Y[:,0], U, V, density=3, INTEGRATOR='RK4', color=U)

plt.show()



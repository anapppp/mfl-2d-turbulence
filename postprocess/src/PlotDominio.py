#!/usr/bin/env python
import matplotlib
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
Script para plotar a grade. Utiliza o formato 
padrao do arquivo .grd.
Para rodar o script na linha de comando, mude para o diretorio 
principal e digite:

python ./ScriptsPosProcessamento/PloContorno.py nomedagrade

O arquivo "nomedagrade" e o nome do arquivo .grd, que 
deve estar no diretorio principal.
-------------------------------------------------------------------------
"""

# Lendo arquivo

filename = sys.argv[1]
filename = filename + '.grd'
X,Y = LerArquivoGrade(filename)


# Plotando 

minx = min(X[0])
maxx = max(X[0])	
miny = min(Y[:,0])
maxy = max(Y[:,0])

# Numero de linhas e colunas para pular
nlcpx = 1
nlcpy = 1

fig = plt.figure()
fig.gca().set_aspect('equal')
plt.axis([minx, maxx, miny, maxy])
plt.title(filename)

plt.plot(X[::nlcpy,::nlcpx],Y[::nlcpy,::nlcpx],'ro', color='k',  markersize=1 )

plt.show()

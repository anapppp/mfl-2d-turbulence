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

# Pontos espectro
MatrizPontos = [[1.100000,  0.063000, '1'],
                [2.400000,  0.063000, '2'],
                [3.600000,  0.063000, '3'],
                [1.100000,  0.079000, '4'],
                [2.400000,  0.079000, '5'],
                [3.600000,  0.079000, '6'],
                [1.100000,  0.095000, '7'],
                [2.400000,  0.095000, '8'],
                [3.600000,  0.095000, '9']]



# Plotando 

minx = 0.0
maxx = 5.0	
miny = 0
maxy = 0.16





fig, ax = plt.subplots()

#fig.gca().set_aspect('equal')
plt.axis([minx-1, maxx+1, miny-0.05, maxy+0.05])

# Plotando as bordas
plt.plot([minx, maxx],[miny, miny], color='k')
plt.plot([maxx, maxx],[miny, maxy], color='k')
plt.plot([minx, maxx],[maxy, maxy], color='k')
plt.plot([minx, minx],[miny, maxy], color='k')
plt.plot([minx, maxx],[(maxy+miny)/2, (maxy+miny)/2], '--', color='k')


for pto in MatrizPontos:
  plt.plot(pto[0],pto[1],'ro', color='k',  markersize=7)


for pto in MatrizPontos:
  ax.annotate(pto[2], xy=(pto[0], pto[1]), xytext=(-20,20), 
            textcoords='offset points', ha='center', va='bottom',
            bbox=dict(boxstyle='round,pad=0.5', fc='w', alpha=1.0),
            arrowprops=dict(arrowstyle='->', connectionstyle='arc3,rad=0.5', 
                            color='k'))


plt.grid(True)
plt.show()

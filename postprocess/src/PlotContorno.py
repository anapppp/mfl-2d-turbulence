#!/usr/bin/env python
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.pylab
import sys
from class_LerArquivos import *
from class_Label import *

"""
-------------------------------------------------------------------------
 Ana Paula Kelm Soares
 28/Maio/2012
 LEMMA/UFPR
 PPGMNE
-------------------------------------------------------------------------
Script para plotar um grafico de contorno. Utiliza o formato 
padrao da saida do modelo.
Para rodar o script na linha de comando, mude para o diretorio 
principal e digite:

python ./PosProcessamento/PlotContorno.py nomedoarquivo

O arquivo "nomedoarquivo" deve estar na pasta ./Resultados	
-------------------------------------------------------------------------
"""

# Lendo arquivo

filename = sys.argv[1]
filename = './Resultados/' + filename

X,Y,Z = LerArquivoPadrao(filename)

nomesim, nomelabel, nomevar, passotempo = Labels(filename)

zmax = int(Z[0,0])
zmin = int(Z[0,0])

for line in Z:
  if (max(line)>zmax): 
    zmax = int(max(line))
  if (min(line)<zmin):
    zmin = int(min(line))

plotlevels = range(zmin+2,zmax,((zmax-zmin)/10))

# Plotando 

fig, ax = plt.subplots()

plt.ylabel('z(m)')
plt.xlabel('x(m)')
#plt.title(nomesim+ '\n' +nomevar+ '\n' +'n='+passotempo)

plt.contour(X,Y,Z,plotlevels)
plt.colorbar().set_label(nomelabel)
plt.grid(True)
#plt.gray()


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


for pto in MatrizPontos:
  ax.annotate(pto[2], xy=(pto[0], pto[1]), xytext=(-20,20), 
            textcoords='offset points', ha='center', va='bottom',
            bbox=dict(boxstyle='round,pad=0.5', fc='w', alpha=1.0),
            arrowprops=dict(arrowstyle='->', connectionstyle='arc3,rad=0.5', 
                            color='k'))

plt.show()

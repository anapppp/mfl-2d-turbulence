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
 Script para plotar o espectro .esp. 
 Para rodar o script na linha de comando, mude para o diretorio 
 principal e digite:

 python ./PosProcessamento/PloPerfilMeio.py nomedoarquivo 

 O arquivo "nomedoarquivo" deve estar na pasta ./Resultados
-------------------------------------------------------------------------
"""

# Lendo arquivo
filename = sys.argv[1]

frequencia, espectro = LerEspectro('./SaidasPosProcessamento/'+filename)


# Plotando 

# Curva com inclunacao -3
xx = [1.0E+01,1.0E+02]
yy = [1.0E-17,1.0E-20]

# fig1

plt.figure(1)
plt.xscale('log')
plt.yscale('log')
plt.ylabel('Energia')
plt.xlabel('Frequencia')
plt.title(filename[:9])
plt.plot(xx, yy,':', color='k', linewidth=2)

plt.plot(frequencia, espectro[0], label = '1', color = 'gray')
plt.plot(frequencia, espectro[1], label = '2', color = 'k')
plt.plot(frequencia, espectro[2], label = '3', color = 'k', linewidth=2 )


plt.legend()


# fig2

plt.figure(2)
plt.xscale('log')
plt.yscale('log')
plt.ylabel('Energia')
plt.xlabel('Frequencia')
plt.title(filename[:9])
plt.plot(xx, yy,':', color='k', linewidth=2)

plt.plot(frequencia, espectro[3], label = '4', color = 'gray')
plt.plot(frequencia, espectro[4], label = '5', color = 'k')
plt.plot(frequencia, espectro[5], label = '6', color = 'k', linewidth=2)

plt.legend()

# fig3

plt.figure(3)

plt.xscale('log')
plt.yscale('log')
plt.ylabel('Energia')
plt.xlabel('Frequencia')
plt.title(filename[:10])
plt.plot(xx, yy,':', color='k', linewidth=2)

plt.plot(frequencia, espectro[6], label = '7', color = 'gray')
plt.plot(frequencia, espectro[7], label = '8',color = 'k')
plt.plot(frequencia, espectro[8], label = '9',color = 'k', linewidth=2)

plt.legend()

plt.show()

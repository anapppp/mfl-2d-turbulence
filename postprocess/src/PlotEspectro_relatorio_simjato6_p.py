#!/usr/bin/env python
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
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

fig, ax = plt.subplots(figsize=(6.5,5.5))

pylab.xlim([4.0,1000])
pylab.ylim([1.0E-22,1.0E-15])


plt.xscale('log')
plt.yscale('log')
plt.ylabel('Energia')
plt.xlabel('Frequencia($s^{-1}$)')
#plt.title(filename[:8])

plt.plot(frequencia, espectro[3], label = 'A', color = 'gray')
plt.plot(frequencia, espectro[4], label = 'B', color = 'k')
plt.plot(frequencia, espectro[5], label = 'C', color = 'k', linewidth=2 )
plt.legend()


# Curva com inclinacao -3
#xx = [1.0E+01,1.0E+02]
#yy = [1.0E-19,1.0E-22]
xx = [1.0E+01,30.006]
yy = [1.0E-19,3.6942E-21]


plt.plot(xx, yy,':', color='k', linewidth=2)

marc = [xx[0]+10,yy[0]-8.04E-20,'-3']

#plt.plot(marc[0],marc[1],'ro', color='k',  markersize=7)

ax.annotate(marc[2], xy=(marc[0], marc[1]), xytext=(-15,-15),
            textcoords='offset points', ha='center', va='bottom',
            #bbox=dict(boxstyle='round,pad=0.5', fc='w', alpha=1.0),
            #arrowprops=dict(arrowstyle='->', connectionstyle='arc3,rad=0.5', color='k')
            )


plt.show()

slope,intercept=np.polyfit(np.log(xx),np.log(yy),1)
print(slope)
print(marc)






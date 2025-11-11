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
filename = './SaidasPosProcessamento/' + filename

x, z, ufina, ugrossa, err_GCI, err_rel = LerErro(filename)

err_GCI_rel = [err_GCI[i]/ufina[i]*100  for i in range(len(ufina))]

#-----------------------------
# Grafico de contorno
#-----------------------------

# Retira os valores repetidos
xx = list(set(x))
zz = list(set(z))

# Ordena os valores
xx.sort()
zz.sort()

# Fazendo meshgrid
X,Z = pylab.meshgrid(xx, zz)

# Definindo array com os valores do erro
ERR_GCI = scipy.zeros((len(xx),len(zz)))
ERR_REL = scipy.zeros((len(xx),len(zz)))

for n in range(len(err_GCI)):
  for k in range(len(zz)):
    for i in range(len(xx)):
      if(x[n]==X[k,i] and z[n]==Z[k,i]): 
        ERR_GCI[i,k] = err_GCI[n]
        ERR_REL[i,k] = err_rel[n]
  


ERR_GCI = zip(*ERR_GCI)
ERR_REL = zip(*ERR_REL)
#-----------------------------



# Plotando 

#fig1 = plt.figure()
#plt.title(filename)
#plt.ylabel('$\epsilon_{GCI}$')
#plt.xlabel('x')
#plt.plot(x, err_rel, 'o', color='k')

#fig2 = plt.figure()
#plt.title(filename)
#plt.ylabel('$\epsilon_{GCI}$')
#plt.xlabel('z')
#plt.plot(z, err_GCI, 'o', color='k')


#fig3 = plt.figure()
#plt.title(filename)
#plt.ylabel('z')
#plt.xlabel('x')
#plt.contour(X,Z,ERR_GCI,20)
#plt.colorbar().set_label('m/s')
#plt.grid(True)


#coordenada normalizada, delta calculado para simjato2
y = Z[:,-7]
y = y - (max(y)-min(y))/2.0
eta = [i/0.0110614949059 for i in y]


fig4 = plt.figure()
#plt.title('x=4,1m')
plt.xlabel('$E_{GCI}(m/s)$')
plt.ylabel('$\eta$')
#plt.plot(zip(*list(ERR_GCI))[-3], Z[:,-3], 'o-', color='k')
plt.plot(zip(*list(ERR_GCI))[-7], eta, 'o-', color='k')


fig5 = plt.figure()
#plt.title('centro do jato')
plt.xlabel('x')
plt.ylabel('$E_{GCI}(m/s)$')
plt.plot(X[0],list(ERR_GCI)[40], 'o-', color='k')




plt.show()

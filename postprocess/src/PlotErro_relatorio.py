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

 python ./PosProcessamento/PloPerfilMeio.py nomedoarquivoerro nomedoarquivovelocidade 

 O arquivo "nomedoarquivo" deve estar na pasta ./Resultados
-------------------------------------------------------------------------
"""

#-----------------------------
# Lendo arquivo .err
#-----------------------------
filename = sys.argv[1]
filename = './SaidasPosProcessamento/' + filename
x, z, ufina, ugrossa, err_GCI, err_rel = LerErro(filename)


#-----------------------------
# Fazendo meshgrid da grade
#-----------------------------
# Retira os valores repetidos
xx = list(set(x))  
zz = list(set(z))

# Ordena os valores
xx.sort() 
zz.sort()

X,Z = pylab.meshgrid(xx, zz)

#-----------------------------
# Fazendo meshgrid da Velocidade e dos Erros
#-----------------------------

# Definindo array com os valores do erro
ERR_GCI = scipy.zeros((len(xx),len(zz)))
ERR_REL = scipy.zeros((len(xx),len(zz)))
U = scipy.zeros((len(xx),len(zz)))

for n in range(len(err_GCI)):
  for k in range(len(zz)):
    for i in range(len(xx)):
      if(x[n]==X[k,i] and z[n]==Z[k,i]): 
        ERR_GCI[i,k] = err_GCI[n]
        ERR_REL[i,k] = err_rel[n]
        U[i,k] = ufina[n]
  
ERR_GCI = zip(*ERR_GCI)
ERR_REL = zip(*ERR_REL)
U = zip(*U)


#-----------------------------
# Encontrando ponto x mais proximo de xplot
#-----------------------------
xplot = float(sys.argv[2])
listdelta = []
listdelta = abs(X[0,:]-xplot)
deltax = X[0,1] - X[0,0]
for i in range(len(listdelta)):
  if listdelta[i] <= deltax:
     ixplot = i
     xplot = str(X[0,ixplot])


#-----------------------------
# Obtendo o perfil normalizado
#-----------------------------

# Calculando U0 e U1
u = zip(*list(U))[ixplot] 
U1 = u[0]        #velocidade do escoamento livre
U0 = max(u)-U1   #diferenca da velocidade no centro do jato e o escoamento livre


# Calculando delta
y = Z[:,ixplot] 
y = y - (max(y)-min(y))/2.0

for i in range(len(y)): 
  if((u[i]-U1) <= U0/2.0 <= (u[i+1]-U1)):
     print i, y[i], (u[i]-U1)/2
     a = (y[i+1]-y[i])/(u[i+1]-u[i]) 
     b = y[i] - a*(u[i]-U1)
     delta = abs(a*U0/2.0 + b)
     break

#Calculando variaveis adimensionais
f = [ (i-U1)/U0  for i in u]
eta = [ i/delta  for i in y]

print 'xplot: ', xplot
print 'U1: ', U1
print 'U0: ', U0
print 'delta: ', delta

#err_GCI_rel = [err_GCI[i]/ufina[i]*100  for i in range(len(ufina))]

#-----------------------------
# Plotando
#-----------------------------

fig = plt.figure(figsize=(6.5,5.5))


ax1 = fig.add_subplot(111)
ax1.set_xlabel('$\eta$')
ax1.set_ylabel('$E_{GCI}(m/s)$')
ax1.plot(eta, zip(*list(ERR_GCI))[ixplot],'o-', color='k', label='$E_{GCI}$')
ax1.set_ylim([0,1.2])


ax2 = ax1.twinx()
ax2.set_ylabel('f($\eta$)')
ax2.plot(eta,f, color='gray', linewidth=2, label='f($\eta$) - simjato4')
ax2.set_ylim([0,1])

ax1.set_xlim([-2.2,2.2])

ax1.legend(loc=2)
ax2.legend(loc=1)


fig2 = plt.figure()
#plt.title('centro do jato')
plt.xlabel('x(m)')
plt.ylabel('$E_{GCI}(m/s)$')
plt.plot(X[0],list(ERR_GCI)[40], 'o-', color='k')



plt.show()

#!/usr/bin/env python
import matplotlib
import matplotlib.pyplot as plt
from numpy import *
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
 Script para plotar o perfil Normalizado pela Lei da parede. 
 Para rodar o script na linha de comando, mude para o diretorio 
 principal e digite:

 python ./PosProcessamento/PloPerfilNormalizado.py nomedoarquivo mi rho

 O arquivo "nomedoarquivo" deve estar na pasta ./Resultados
-------------------------------------------------------------------------
"""


# Lendo arquivo
nomesim = sys.argv[1]
xplot = float(sys.argv[2])
passotempo = sys.argv[3]

filename = './cases/' + nomesim + '/results/' + nomesim + '.u.' + passotempo
nomesim, nomelabel, nomevar, passotempo = Labels(filename)

X, Y, Z = LerArquivoPadrao(filename)

mi = 1.817E-05
rho = 1.188

y = Y[:, -2]
u = Z[:, 25]


# Calculando tensao na superficie - tauzero = du/dy em y=0
dyu = y[2]-y[1]
dyd = y[1]-y[0]
tauzero = dyd*dyd*u[2] + (dyu*dyu-dyd*dyd)*u[1] - dyu*dyu*u[0]
tauzero = tauzero/dyu/dyd/(dyu+dyd)
tauzero = mi*abs(tauzero)

# Calculando variaveis adimensionais
nu = mi/rho
uestrela = sqrt(tauzero/rho)
unorm = [i/uestrela for i in u]
ymais = [i*uestrela/nu for i in y]

print('tau_0: ', tauzero)
print('u*: ', uestrela)
print('escala viscosa (nu/u*):', nu/uestrela)

# Plotando
fig = plt.figure()

plt.xscale('log')

plt.plot(ymais, unorm, label='Simulado')
ymaisteorico = range(0, 15)
plt.plot(ymaisteorico, ymaisteorico, color='k', label='U/u*=y+')
ymaisteorico = range(7, 10000)
plt.plot(ymaisteorico, [2.5*log(i)+5 for i in ymaisteorico],
         color='k', label='U/u*=2,5ln(y+)+5')

plt.title(nomesim)
plt.ylabel('U/u*')
plt.xlabel('y+')
plt.legend()

plt.show()

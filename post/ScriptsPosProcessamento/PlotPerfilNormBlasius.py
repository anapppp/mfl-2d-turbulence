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

 python ./PosProcessamento/PloPerfilNormalizado.py nomedoarquivo mi rho L

 O arquivo "nomedoarquivo" deve estar na pasta ./Resultados
-------------------------------------------------------------------------
"""

filename = sys.argv[1]
mi = float(sys.argv[2])
rho = float(sys.argv[3])
L = float(sys.argv[4])

#-------Velocidade Vertical----------

# Lendo arquivo
filename = './Resultados/' + filename

nomesim, nomelabel, nomevar, passotempo = Labels(filename)

X,Y,Z = LerArquivoPadrao(filename)
y = Y[:,-2]
u = Z[:,-2]

U = u[-1]


# Calculando variaveis adimensionais
delta = sqrt(mi*L/rho/U)
eta = [i/delta for i in y]
unorm = [i/U for i in u]

print 'delta_99:', 4.9*delta


# Valores Teoricos

blasius = [[0.0,
0.03508771929824561,
0.21052631578947364,
0.56140350877193,
0.7894736842105265,
1.0526315789473681,
1.350877192982455,
1.6491228070175437,
2.0350877192982475,
2.5087719298245617,
2.929824561403509,
3.2631578947368407,
3.7368421052631584,
4.105263157894736,
4.596491228070176,
5.298245614035086,
5.8771929824561395,
6.491228070175439,
7.017543859649126,
7.473684210526317,
7.982456140350877,
9.0,
40.0,
],[0.0,
0.0028650763599646577,
0.06338508140855739,
0.18437460557869498,
0.2621544869367665,
0.3428246876183265,
0.4378959989902816,
0.5300896125205101,
0.63382557112205,
0.7577369683200811,
0.83846396566957,
0.8903824308973877,
0.9394736842105267,
0.9655054903445669,
0.9887037738230473,
0.9975892969834667,
1.00,
1.00,
1.00,
1.00,
1.00,
1.00,
1.00,
]]



# Plotando 
fig1 = plt.figure()
plt.title(nomesim)
plt.ylabel('u/U')
plt.xlabel('$\eta$')

plt.plot(eta,unorm, color='k', label='Simulado')
plt.plot(blasius[0], blasius[1],  label='Solucao de Blasius')

plt.legend()


#-------Velocidade Horizontal----------

# Lendo arquivo
filename = './Resultados/' + filename

nomesim, nomelabel, nomevar, passotempo = Labels(filename)

filename = './Resultados/' + nomesim + '.w.' + passotempo

X,Y,Z = LerArquivoPadrao(filename)
y = Y[:,-2]
w = Z[:,-2]


# Calculando variaveis adimensionais
wnorm = [i*sqrt(L*rho/mi/U) for i in w]

# Valores Teoricos
blasius = [[0.0, 0.37025533758015616, 0.7583853621948256, 1.1646013585607284, 1.447427080362142, 1.6772625952101756, 1.9778784901594144, 2.207925289724168,
2.3494015360398905, 2.508625698560095, 2.7208823249770226, 2.897812146758365, 3.2337971032865336, 3.4989171658268097, 3.834521809864884, 4.187578571504031, 
4.487560612303109, 4.752173591523257,  5.087186638354514, 5.545505445863575, 5.950834046419251, 6.268056920102685, 6.708627811407262, 7.043387316578456, 
7.27250446338964, 7.589685080129728, 8.030213714490962, 9.0, 40.0, ],
[0.0, 0.0172661870503597, 0.04892086330935251, 0.1122302158273381, 0.17266187050359713, 0.22446043165467622, 0.29640287769784174, 0.36258992805755397,
0.3971223021582734, 0.44028776978417267, 0.49496402877697837, 0.5438848920863308, 0.6244604316546762, 0.6791366906474819, 0.7338129496402876, 
0.776978417266187, 0.8057553956834532, 0.8258992805755395, 0.8402877697841725, 0.8517985611510792, 0.8546762589928056, 0.8575539568345323,
0.860, 0.860, 0.860, 0.860, 0.860, 0.86, 0.86, ]]

# Plotando 
fig2 = plt.figure()
plt.title(nomesim)
plt.ylabel('w \sqrt{\frac{L}{$\nu$ U}}')
plt.xlabel('$\eta$')


plt.plot(eta,wnorm, color='k',label='Simulado')
plt.plot(blasius[0], blasius[1],  label='Solucao de Blasius')

plt.legend()
plt.show()


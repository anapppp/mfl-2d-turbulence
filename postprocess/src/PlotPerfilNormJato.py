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
 19/Outubro/2012
 LEMMA/UFPR
 PPGMNE
-------------------------------------------------------------------------
 Script para plotar o perfil Normalizado de um jato. 
 Para rodar o script na linha de comando, mude para o diretorio 
 principal e digite:

 python ./PosProcessamento/PloPerfilNormalizado.py nomedoarquivo mi rho

 O arquivo "nomedoarquivo" deve estar na pasta ./Resultados
-------------------------------------------------------------------------
"""

nomesim = sys.argv[1]
xplot = float(sys.argv[2])
passotempo = sys.argv[3]

filename = './cases/' + nomesim + '/results/' + nomesim + '.u.' + passotempo

nomesim, nomelabel, nomevar, passotempo = Labels(filename)

X,Y,Z = LerArquivoPadrao(filename)


# Encontrando ponto x mais proximo de xplot
listdelta = []
listdelta = abs(X[0,:]-xplot)
deltax = X[0,1] - X[0,0]
for i in range(len(listdelta)):
  if listdelta[i] <= deltax:
     ixplot = i
     xplot = str(X[0,ixplot])


y = Y[:,ixplot]
y = y - (max(y)-min(y))/2.0
u = Z[:,ixplot]


# Calculando paramentros
U1 = u[0]        #velocidade do escoamento livre
U0 = max(u)-U1   #diferenca da velocidade no centro do jato e o escoamento livre


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


print ('xplot: ', xplot)
print ('U1: ', U1)
print ('U0: ', U0)
print ('delta: ', delta)

# Valores medidos Gordeyev S. V., Thomas F. O. Coherent structure in the turbulent planar jet. Journal of Fluid Mechanics, 2002.
medicoes = [[-1.8743009689, -1.8322969645, -1.7798172738, -1.7273375831,  -1.6696108439, -1.6329091202, -1.5699445378, -1.5174832578, -1.4545647021, 
-1.4073504706, -1.3549352174, -1.3129864451, -1.2658182404, -1.2239154949, -1.1819943387, -1.134826134, -1.1086645341, -1.0667525833, -1.0143465353,
-0.9567302603, -0.9095804663, -0.8676869261, -0.8310588452, -0.7943479161, -0.7472165328, -0.6738222908, -0.6267461395, -0.5691022484, -0.5219340437,
-0.4799852714, -0.4066186454, -0.3279589441, -0.2860561987, -0.2230916162, -0.1496053207, -0.0866131222, -0.0130715946, 0.1025567855, 0.1919499229,
0.2393574667, 0.2920212644, 0.3394288081, 0.4026327296, 0.4500678894, 0.4922283847, 0.5396635445, 0.5608082296, 0.6082249787, 0.6346167123, 0.655752192,
0.6874370009, 0.7348629554, 0.7612362783, 0.7929210872, 0.8298345339, 0.861500932, 0.8984051734, 0.9458771546, 0.9880560606, 1.0355096311, 1.0724598992, 
1.1041723241, 1.1569005592, 1.2096564104, 1.2728879479, 1.2993165029, 1.3467240467, 1.3731065749, 1.4152762755, 1.4679584839, 1.5101097738, 1.5575173176,
1.6259774929, 1.6839159552, 1.7681172761, 1.8575840563, 1.9312360481, 2.0101811152, ],
[0.0857593262, 0.094497503, 0.1102363473, 0.1259751916, 0.143463052, 0.1609601178, 0.181948312, 0.2011897913, 0.230934573, 0.2484270361, 0.276425103, 
0.295671185,  0.3219202357, 0.3499229052, 0.3744229397, 0.4006719904, 0.4234276114, 0.4496789635, 0.4794283479, 0.5179320185, 0.5476837042, 0.5774376913,
0.6089452972, 0.6246910455, 0.6579453663, 0.6946908154, 0.7384530412, 0.7717027593, 0.79795181, 0.817197892, 0.8591972936, 0.8941891239, 0.9221917934, 
0.9431799876, 0.9624122615, 0.9781465031, 0.986870872, 0.9885715601, 0.9815271673, 0.9622419626, 0.9429544565, 0.9236692518, 0.8991231906, 0.8745840333, 
0.8535498124, 0.8290106552, 0.8062343221, 0.7851977999, 0.7641704831, 0.7431454675, 0.7151105792, 0.6923227395, 0.6747980577, 0.6467631694, 0.6239799323,
0.5994476791, 0.5784157596, 0.5468713322, 0.5223344763, 0.494292684, 0.4645041769, 0.4312153361, 0.3996686075, 0.3628679263, 0.3330679125, 0.3050353255,
0.2857501208, 0.2664741215, 0.2436885831, 0.220898442, 0.2016155386, 0.1823303339, 0.1577819713, 0.1349895289, 0.1156882149, 0.0946332819, 0.0823418406,
0.0630428279, ]]


# Plotando 
fig = plt.figure()

plt.plot(eta, f, label='Simulado')

etateorico = [ i/100.0  for i in range(-200,201)]
fBradbury = [ exp(-0.6749*i*i*(1+0.0269*i*i*i*i))  for i in etateorico]
fTownsend = [ exp(-0.6619*i*i*(1+0.0565*i*i*i*i))  for i in etateorico]

plt.plot(etateorico,fBradbury,'--', color='k', label='Brasbury (1965)')
plt.plot(etateorico,fTownsend,'-', color='k', label='Townsend (1956)')

plt.plot(medicoes[0], medicoes[1], label='Medido')

#plt.title(nomesim)
plt.ylabel('f($\eta$)')
plt.xlabel('$\eta$')
plt.legend()

plt.show()

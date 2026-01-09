#!/usr/bin/env python
import sys
import numpy as np
import matplotlib.pyplot as plt

from class_LerArquivos import *
from class_Label import *

"""
-------------------------------------------------------------------------
 Ana Paula Kelm Soares
 11/Outubro/2012
 LEMMA/UFPR
 PPGMNE
-------------------------------------------------------------------------
 Script para plotar o perfil normalizado pela Lei da Parede
 Uso:

 python ./PosProcessamento/PloPerfilNormalizado.py nomesim mi rho passotempo
-------------------------------------------------------------------------
"""

# -----------------------------
# Leitura dos argumentos
# -----------------------------
nomesim = sys.argv[1]
passotempo = sys.argv[2]
mi = 1.817E-05 
rho = 1.188

# -----------------------------
# Leitura do arquivo
# -----------------------------
filename = f'./cases/{nomesim}/results/{nomesim}.u.{passotempo}'

nomesim, nomelabel, nomevar, passotempo = Labels(filename)
X, Y, Z = LerArquivoPadrao(filename)

# -----------------------------
# Extração do perfil
# -----------------------------
y = Y[:, -2]        # direção normal à parede
u = Z[:, 25]        # perfil em x fixo

# -----------------------------
# Tensão de cisalhamento na parede
# du/dy em y = 0 (malha não uniforme)
# -----------------------------
dyu = y[2] - y[1]
dyd = y[1] - y[0]

tauzero = (
    dyd*dyd*u[2]
    + (dyu*dyu - dyd*dyd)*u[1]
    - dyu*dyu*u[0]
) / (dyu * dyd * (dyu + dyd))

tauzero = mi * abs(tauzero)

# -----------------------------
# Variáveis adimensionais
# -----------------------------

nu = mi / rho
uestrela = np.sqrt(tauzero / rho)

unorm = u / uestrela
ymais = y * uestrela / nu

# -----------------------------
# Saída numérica
# -----------------------------
print('tau_0:', tauzero)
print('u*:', uestrela)
print('escala viscosa (nu/u*):', nu / uestrela)

# -----------------------------
# Plot
# -----------------------------
plt.figure()
plt.xscale('log')

plt.plot(ymais, unorm, label='Simulado')

y_teor = np.linspace(1, 15, 200)
plt.plot(y_teor, y_teor, 'k', label='U/u* = y+')

y_teor = np.linspace(7, 1e4, 500)
plt.plot(y_teor, 2.5*np.log(y_teor) + 5, 'k--',
         label='U/u* = 2.5 ln(y+) + 5')

plt.title(nomesim)
plt.xlabel('y+')
plt.ylabel('U/u*')
plt.legend()
plt.grid(True, which='both', linestyle='--', alpha=0.5)

plt.show()

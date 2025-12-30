#!/usr/bin/env python
import scipy
import pylab

"""
-------------------------------------------------------------------------
 Ana Paula Kelm Soares
 28/Maio/2012
 LEMMA/UFPR
 PPGMNE
-------------------------------------------------------------------------
"""


def Labels(filename):
    filename = (filename.split('/'))[-1]
    filename = filename.split('.')
    nomeSimulacao = filename[0]
    parametro = filename[1]
    passoTempo = filename[2]

    if parametro == 'q':
        nomeLabel = '$\Theta$(K)'
        nomeVariavel = 'Temperatura Potencial (K)'
    elif parametro == 't':
        nomeLabel = 'T2(K)'
        nomeVariavel = 'Temperatura - desvio do estado basico (K)'
    elif parametro == 'p':
        nomeLabel = 'p(Pa)'
        nomeVariavel = 'Pressao - desvio do estado basico (Pa)'
    elif parametro == 'u':
        nomeLabel = 'u(m/s)'
        nomeVariavel = 'Velocidade Horizontal (m/s)'
    elif parametro == 'w':
        nomeLabel = 'w(m/s)'
        nomeVariavel = 'Velocidade Vertical (m/s)'
    else:
        nomeLabel = ''
        nomeVariavel = ''

    return nomeSimulacao, nomeLabel, nomeVariavel, passoTempo

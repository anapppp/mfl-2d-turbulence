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


def LerArquivoPadrao(filename):
	# Retorna X, Y, e Z em formato meshgrid

	filedata = open(filename, 'r')

	x = []
	y = []
	z = []
	Z = []

	x = filedata.readline()
	y = filedata.readline()
	z = filedata.readlines()

	x = map(float, x.split())
	y = map(float, y.split())
	X,Y = pylab.meshgrid(x, y)

	for line in z:
		Z.append(map(float,line.split()))
        Z = scipy.array(Z)

	filedata.close()

	return X, Y, Z



def LerArquivoGrade(filename):
	# Retorna X, Y em formato meshgrid

	filedata = open(filename, 'r')

	x = []
	y = []

        [tamx, tamy] = map(int,(filedata.readline()).split())
     
        vetor = map(float,filedata.readlines())

	x = vetor[:tamx]
	y = vetor[tamx:]

	X,Y = pylab.meshgrid(x, y)
  
	filedata.close()
  
	return X, Y


def oldLerEspectro(filename):
	# Le saida do espectro

	filedata = open(filename)

        m = []
        m2 = []

        n = []  
        omega = []         
        frequencia = []
        periodo = []
        espectro = []
 
	m = filedata.readlines()
       
        for i in m:
          m2.append(map(float,i.split()))

        m2 = zip(*m2)

        n = list(m2[0])
        omega = list(m2[1])
        frequencia = list(m2[2])
        periodo = list(m2[3])
        espectro = list(m2[4])

	filedata.close()

	return n, omega, frequencia, periodo, espectro

def LerFlutuacoes(filename):
	# Le arquivos de flutuacao

	filedata = open(filename)

        m = []
        matriz = []

	m = filedata.readlines()
       
        for i in m:
          matriz.append(map(float,i.split()))

        matriz = zip(*matriz)

	filedata.close()

	return matriz[0], matriz[1:]

def LerEspectro(filename):
	# Le arquivo .esp

	filedata = open(filename)

        m = []
        m2 = []

        frequencia = []
        espectro = []
        filedata.readline()
	m = filedata.readlines()
       
        for i in m:
          m2.append(map(float,i.split(';')))

        m2 = zip(*m2)

        frequencia = list(m2[0])
        espectro = list(m2[1:])

	filedata.close()

	return frequencia, espectro

def LerErro(filename):
	# Le arquivos de flutuacao

	filedata = open(filename)

        m = []
        matriz = []
        filedata.readline()
	m = filedata.readlines()
       
        for i in m:
          matriz.append(map(float,i.split(';')))

        matriz = zip(*matriz)

	filedata.close()

	return matriz[0], matriz[1], matriz[2], matriz[3], matriz[4], matriz[5]


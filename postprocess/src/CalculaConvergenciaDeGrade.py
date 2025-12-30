#!/usr/bin/env python
from class_LerArquivos import *
from class_Label import *
import asciitable
import sys
"""
-------------------------------------------------------------------------
 Ana Paula Kelm Soares
 22/Outubro/2012
 LEMMA/UFPR
 PPGMNE
-------------------------------------------------------------------------
Script para calcular erro de discretizacao. Utiliza o formato 
padrao da saida do modelo.


python ./PosProcessamento/PlotContorno.py arquivo_gradefina arquivo_gradegrossa


PARA GRADE UNIFORME
-----------------------------------------------------------------------
"""

# Lendo arquivo

#filename1 = 'simjato1.u.med'    #grade fina
#filename2 = 'simjato5.u.med'    #grade grossa

filename1 = sys.argv[1]    #grade fina
filename2 = sys.argv[2]    #grade grossa

X1,Y1,Z1 = LerArquivoPadrao('./Resultados/'+filename1)
X2,Y2,Z2 = LerArquivoPadrao('./Resultados/'+filename2)


h1 = Y1[1,0] - Y1[0,0]   # espacamento da grade fina
h2 = Y2[1,0] - Y2[0,0]   # espacamento da grade grossa
Fs = 3.0  #fator de seguranca
m =  2.0  # ordem assintotica do erro de discretizacao
r = h2/h1


# Procurando pontos x iguais nas duas grades
idx_x1=[]
idx_x2=[]
for x2 in X2[0]:
  try:
    idx_x1.append(list(X1[0]).index(x2))
    idx_x2.append(list(X2[0]).index(x2))
  except:
    pass 


# Procurando pontos y iguais nas duas grades
idx_y1=[]
idx_y2=[]
for y2 in Y2[:,0]:
  try:
    idx_y1.append(list(Y1[:,0]).index(y2))
    idx_y2.append(list(Y2[:,0]).index(y2))
  except:
    pass


# Calculando o erro GCI
errolist = []
for i in range(len(idx_x1)):
  for j in range(len(idx_y1)):
    erro_GCI = Fs*abs(Z1[idx_y1[j]][idx_x1[i]] - Z2[idx_y2[j]][idx_x2[i]]) / ( r**m-1)
    erro_relativo = abs(Z1[idx_y1[j]][idx_x1[i]] - Z2[idx_y2[j]][idx_x2[i]])
    erro_relativo = erro_relativo/abs(Z1[idx_y1[j]][idx_x1[i]])*100.0
    errolist.append([X1[0][idx_x1[i]],Y1[:,0][idx_y1[j]],Z1[idx_y1[j]][idx_x1[i]], Z2[idx_y2[j]][idx_x2[i]], erro_GCI, erro_relativo])


# Escrevendo arquivo de saida
asciitable.write(errolist, './SaidasPosProcessamento/'+filename1[0:11]+filename2[0:11]+'err', names=['x','y',filename1[9]+'1',filename2[9]+'2','erro_GCI','erro_relativo'], delimiter=';')



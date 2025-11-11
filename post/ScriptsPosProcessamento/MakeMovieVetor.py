#!/usr/bin/python
"""
-------------------------------------------------------------------------
 Ana Paula Kelm Soares
 26/Setembro/2012
 LEMMA/UFPR
 PPGMNE
-------------------------------------------------------------------------
Script para criar um filme com os graficos de vetor velocidade. Utiliza o formato 
padrao da saida do modelo.
Para rodar o script na linha de comando, mude para o diretorio 
principal e digite:

python ./PosProcessamento/MakeMovieVetor nomesim parametro

Os arquivos devem estar na pasta ./Resultados
As figuras e o filme sao gravados no diretorio ./Graficos
-------------------------------------------------------------------------
"""

import os                         
from numpy import *
import matplotlib.pyplot as plt
import sys
from class_LerArquivos import *
from class_Label import *

# Numero de linhas e colunas para pular
nlcpx = 1
nlcpy = 1


# Cria lista com nome dos arquivos
nomesim = sys.argv[1]
    
filenamelistU = []   
filenamelistV = []   
for file in os.listdir('./Resultados'):
  if file.startswith(nomesim + '.u'):
    filenamelistU.append(file)
  if file.startswith(nomesim + '.w'):
    filenamelistV.append(file) 

filenamelistU.sort
filenamelistV.sort

filenamelist = filenamelistU + filenamelistV
filenamelist.numpy.matrix.transpose()


passotempolist = []   
# Fazendo as figuras
for filename in filenamelistu:
    
    print filename

    # Lendo arquivo
    try: 
      X,Y,U = LerArquivoPadrao('./Resultados/' + filename[0])
      X,Y,V = LerArquivoPadrao('./Resultados/' + filename[1])

      nomesim, nomelabel, nomevar, passotempo = Labels('./Resultados/' +filename[0])

      # Plotando 
      plt.title(nomedocaso + '\n' +' n='+ passodetempo)
      plt.ylabel('z(m)')
      plt.xlabel('x(m)')

      Q = plt.quiver( X[::nlcpy,::nlcpx], Y[::nlcpy,::nlcpx], U[::nlcpy,::nlcpx], V[::nlcpy,::nlcpx], units='width' )

      # Salvando figura em formato .png
      filenamegraph = './Graficos/' + nomesim + '.' + passotempo + '.velocidade.png'
      plt.savefig(filenamegraph, dpi=100)
      plt.clf()

      passotempolist.append(int(passotempo))

    except:
      print 'Arquivo nao plotado'


# Criando arquivo com a ordem das figuras      
passotempolist.sort()

fileordemarquivos = open('ord_list.txt','w')

for passotempo in passotempolist:
  fileordemarquivos.write('./Graficos/' + nomesim + '.' + str(passotempo) + '.velocidade.png\n')

fileordemarquivos.close()

# Fazendo o filme
command = ('mencoder',
           'mf://@'+fileordemarquivos.name,
           '-mf',
           'type=png:w=800:h=600:fps=3',
           '-ovc',
           'lavc',
           '-lavcopts',
           'vcodec=mpeg4',
           '-oac',
           'copy',
           '-o',
           './Graficos/' + nomesim + '.velocidade.avi')

          
os.spawnvp(os.P_WAIT, 'mencoder', command)
os.system('rm '+ fileordemarquivos.name)

#!/usr/bin/python
"""
-------------------------------------------------------------------------
 Ana Paula Kelm Soares
 24/Setembro/2012
 LEMMA/UFPR
 PPGMNE
-------------------------------------------------------------------------
Script para criar um filme com os graficos de contorno. Utiliza o formato 
padrao da saida do modelo.
Para rodar o script na linha de comando, mude para o diretorio 
principal e digite:

python ./PosProcessamento/MakeMovieContorno nomesim parametro

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



# Cria lista com nome dos arquivos
nomesim = sys.argv[1]
parametro = sys.argv[2]
    
filenamelist = []   
for file in os.listdir('./Resultados'):
  if file.startswith(nomesim + '.' + parametro):
    filenamelist.append(file)
    
passotempolist = []   
# Fazendo as figuras
for filename in filenamelist:

    filenamegraph = './Graficos/' + filename + '.contorno.png'
    print filenamegraph

    # Lendo arquivo
    try: 
      X,Y,Z = LerArquivoPadrao('./Resultados/' + filename)

      nomesim, nomelabel, nomevar, passotempo = Labels('./Resultados/' +filename)

      # Plotando 
      plt.figure()
      plt.ylabel('z(m)')
      plt.xlabel('x(m)')
#      plt.title(nomesim+ '\n' +nomevar+ '\n' +'n='+passotempo) 
      tempo = str(float(passotempo)*1.44E-01)
      plt.title('t='+tempo+'s')
      #plotlevels = range(-20,+50)
      #plotlevels = [i/50.0*0.0025 for i in plotlevels]
      plt.contour(X,Y,Z,100)#,plotlevels)
      plt.colorbar().set_label(nomelabel)
      plt.grid(True)

      # Salvando figura em formato .png
      plt.savefig(filenamegraph, dpi=100)
      plt.clf()

      passotempolist.append(int(passotempo))

    except:
      print 'Arquivo nao plotado'


# Criando arquivo com a ordem das figuras      
passotempolist.sort()

fileordemarquivos = open('ord_list.txt','w')

for passotempo in passotempolist:
  fileordemarquivos.write('./Graficos/' + nomesim + '.' + parametro + '.'  + str(passotempo) + '.contorno.png\n')

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
           './Graficos/' + nomesim + '.' + parametro + '.contorno.avi')

          
os.spawnvp(os.P_WAIT, 'mencoder', command)
os.system('rm '+ fileordemarquivos.name)

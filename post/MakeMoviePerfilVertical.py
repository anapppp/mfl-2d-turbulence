#!/usr/bin/python
"""
-------------------------------------------------------------------------
 Ana Paula Kelm Soares
 24/Setembro/2012
 LEMMA/UFPR
 PPGMNE
-------------------------------------------------------------------------
Script para criar um filme com os graficos de perfil vertical. Utiliza o formato 
padrao da saida do modelo.
Para rodar o script na linha de comando, mude para o diretorio 
principal e digite:

python ./PosProcessamento/MakeMoviePerfilVertical nomesim parametro xplot

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
xplot = float(sys.argv[3])
    
filenamelist = []   
for file in os.listdir('./Resultados'):
  if file.startswith(nomesim + '.' + parametro):
    filenamelist.append(file)
    
passotempolist = []   
# Fazendo as figuras
for filename in filenamelist:

    filenamegraph = './Graficos/' + filename + '.perfil.png'
    print filenamegraph

    # Lendo arquivo
    try:
      X,Y,Z = LerArquivoPadrao('./Resultados/' + filename)

      nomesim, nomelabel, nomevar, passotempo = Labels('./Resultados/' +filename)
 
      passotempolist.append(int(passotempo))

      # Encontrando ponto x mais proximo de xplot
      listdelta = []
      listdelta = abs(X[0,:]-xplot)
      deltax = X[0,1] - X[0,0]
      for i in range(len(listdelta)):
        if listdelta[i] <= deltax:
          ixplot = i
          xplotc = "%.1f" %X[0,ixplot]  #str(X[0,ixplot]) 
    
      # Plotando
      fig = plt.figure()
      pylab.xlim([0.0,10])
      pylab.ylim([0.0,0.16])
      #plt.title(nomesim+ '\n' +nomevar+ '\n' +'n='+passotempo+'   x='+xplotc)
      tempo = "%.1f" %(float(passotempo)*0.0001)
      plt.title('t='+tempo+'s    '+'x='+xplotc+'m')
      #plt.title(nomevar+ '\n' + ' x='+xplotc + 'm')
      plt.ylabel('z(m)')
      plt.xlabel(nomelabel)
      #fig.gca().ticklabel_format(style='sci', scilimits=(0,0), axis='x')
      plt.plot(Z[:,ixplot], Y[:,ixplot], color='k')

     
      # Salvando figura em formato .png
      plt.savefig(filenamegraph, dpi=100)
      plt.clf()

    except:
      print 'Arquivo nao plotado'  

      
# Criando arquivo com a ordem das figuras      
passotempolist.sort()

fileordemarquivos = open('ord_list.txt','w')

for passotempo in passotempolist:
  fileordemarquivos.write('./Graficos/' + nomesim + '.' + parametro + '.'  + str(passotempo) + '.perfil.png\n')
 
fileordemarquivos.close()

# Fazendo o filme
command = ('mencoder',
           'mf://@'+fileordemarquivos.name,
           '-mf',
           'type=png:w=800:h=600:fps=10',
           '-ovc',
           'lavc',
           '-lavcopts',
           'vcodec=mpeg4',
           '-oac',
           'copy',
           '-o',
           './Graficos/' + nomesim + '.' + parametro + '.perfil.avi')
           


os.spawnvp(os.P_WAIT, 'mencoder', command)
os.system('rm '+ fileordemarquivos.name)

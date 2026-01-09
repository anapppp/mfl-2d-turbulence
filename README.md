# Método de Filtragem Lagrangeana

O Método de Filtragem Lagrangeana (MFL) é um método destinado à simulação numérica de escoamentos turbulentos, baseado na filtragem espacial das equações de Navier–Stokes escritas no referencial Lagrangeano. A filtragem se dá implicitamente através da discretização das equações em diferenças finitas. A grande vantagem da utilização do referencial Lagrangeano é que, neste referencial, as não linearidades das equações não são explicitadas. Com isso, é possível filtrar as equações sem que haja necessidade de se utilizarem parametrizações de processos subgrade.

No presente trabalho, o MFL foi utilizado na simulação do jato plano turbulento, com o objetivo de mostrar a capacidade deste método em simular este tipo de escoamento turbulento. Foram realizadas simulações com número de Reynolds entre 2.970 e 10.000. Os resultados se mostraram, de forma geral, satisfatórios quando comparados com resultados teóricos e experimentais. Além disso, o modelo foi capaz de simular adequadamente o espectro de energia. O MFL também se mostrou computacionalmente eficiente e competitivo em relação a outros métodos de simulação de escoamentos turbulentos usualmente utilizados.

- Autora: Ana Paula Kelm Soares
- LEMMA/UFPR
- PPGMNE - Programa de Pós-Graduação em Metodos Numericos em Engenharia - UFPR

## Descricao das variaveis


```
! Os indices 0, 1 e 2 das seguintes variáveis referem-se aos instantes 
! t-dt , t e t+dt, respectivamente
!      u: componente x da velocidade
!      w: componente z da velocidade
!      p: pressao - desvio do estado basico 
!      theta : temperatura potencial 
!      T: temperatura - desvio do estado basico
!      lap_p: laplaciano de p
!      lap_u: laplaciano de u
!      lap_w: laplaciano de w
!      grad_p0_x: gradiente de p0 em relação a x (idem para instantes 1 e 2)
!      grad_p0_z: gradiente de p0 em relacao a z (idem para instantes 1 e 2)
! x, z: coordenada espacial
! dx, dz: espacamento de grade
! umed, wmed, pmed, Tmed, thetamed: perfil vertical medio de cada variavel, nos 
!                                   ultimos "nptMediaFlut" passos de tempo
! dt: passo de tempo
! ptoPartida0: = (xn, zn), posicao de partida da particula, no instante t-dt
! ptoPartida1: = (xn, zn), posicao de partida da particula, no instante t
! gamma: lapse rate 
! EnCineticaMedia: energia cinética media no instante t+dt
! rho_ref: densidade no estado basico de referencia (Kg/m3)
! temp_ref: temperatura no estado básico de referência (K)
! press_ref_sup: pressao no estado basico de referencia na superficie (Pa)
! mi: Viscosidade dinâmica (Pa.s)
! alphah: condutividade térmica (W/m.K)
! R: constante do gas ideal (J/kg K) 
! cp: capacidade de calor específico a pressão constante (J/kg°C)
! g: aceleração da gravidade (m/s2) 
! uCiUnif, wCiUnif, pCiUnif, TCiUnif: condicao inicial uniforme
! uCiFlag, wCiFlag, pCiFlag, TCiFlag: uCiFlag = 0, condição inicial uniforme;
!                                         uCiFlag = 1, ler condicao inicial no arquivo
! uCiFile, wCiFile, pCiFile, TCiFile: nome do arquivo para condicao inicial
! uCcTop, wCcTop, TCcTop: condicao de contorno de u, w, e T no topo
! uCcSup, wCcSup, TCcSup: condicao de contorno de u, w e T na superficie
! i: indice dos pontos de grade em x
! k: indice dos pontos de grade em z
! n: indice do tempo
! in: 1 <= i <= in
! kn: 1 <= k <= kn
! npt: 1 <= n <= npt
! nptprint: a cada "nptprint" passos de tempo os resultados sao impressos
! nptMediaFlut: Nos ultimos "nptMediaFlut" passos de tempo as medias ou flutuacoes sao calculadas
! MediaFlutFlag: MediaFlutFlag=0 => calcula a media; MediaFlutFlag=1 => calcula flutuacoes (o arquivo nomecaso.med deve estar na pasta Resultados)
! PontosCalcFlutX, PontosCalcFlutZ: coordenadas dos pontos para o calculo das flutuacoes
! nomecaso: nome da simulacao
! nomegrade: nome do arquivo de grade
```

## Compilação e execução: 
No diretorio principal digite:

```prompt
gfortran main.f90 -o ./mfl2dTurbulence
./mfl2dTurbulence
```

## Docker

### Build o container
```prompt
docker build -t mfl-simulation .
```


### Rodar o Fortran
```prompt
docker run --rm mfl-simulation
``` 


### Rodar o Python
```prompt
docker run --rm mfl-simulation python3 seu_script.py
```                         

```
docker compose up --build
```

### Limpa e cria o container

``` 
docker compose down -v
docker compose build --no-cache preprocess
docker compose up preprocess
```

```
docker compose build --no-cache mfl2d
docker compose up mfl2d
```

```
docker compose build --no-cache postprocess
docker compose up postprocess
```

### Limpa o cache do build

```
docker builder prune
```

### Remover Containers parados

```
docker container prune
```
Idem imagens e volumes

### Entrar dentro o container

```
docker exec -it postprocess /bin/bash
```

### Inicia novo container e volume sem sobreescrever antigos
```
docker compose -p simPlaca up -d nomedoservice --build
```
o `build` refaz a imagem. Sem ele, o container é feito usando a imagem antiga.

## Pós-processamento


### Copia o resultados do volume do container para o local

```
docker cp nome-do-container:/data/cases .
```

Certifique-se de que o python está instalado. Em seguida, mude para o diretório src crie um ambiente virtual:

```
python -m venv .venv
``` 

Para instalar todos as bibliotecas necessárias, use o arquivo requirements.txt. Entre no seu ambiente virtual, e depois:
```
.\.venv\Scripts\Activate.ps1
```

```
pip install -r requirements.txt
```

Para atualizar os requirement, entrar no ambiente virtual, e depois

```
pip freeze > requirements.txt
```
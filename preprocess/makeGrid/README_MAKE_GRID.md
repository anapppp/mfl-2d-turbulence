# MakeGrid2D

Programa para criar o arquivo de grade com formato padrao.
O dominio deve ser necessariamente retangular e 2D.
O espaçamento de grade pode ser variável.

## Como usar

Inserir as informações no arquivo das variáveis de ambiente `.env` na raiz do projeto. Escolha a opção `MAKE_GRID = true` para que o programa crie o arquivo de grade. Escolha o nome da grade em `GRID_NAME` e  tipo de grade em `GRID_TYPE`.
O nome dado a grade, ou "nomegrad", deve ter 8 caracteres. Os tipos de grade podem ser os seguintes:

- Uniforme: `GRID_TYPE = uniform`
- Linear: `GRID_TYPE = linear`
- Logarítmica: `GRID_TYPE = log`
- Mista (log+linear+linear): `GRID_TYPE = mixed`

Em seguida, adicione as dimensões do domínio e o espaçamento de grade.

> - As variações das grades acontecem apenas no eixo *vertical*. A grade será sempre uniforme na direção horizontal.
> - Grade mista: uniforme em x, logarítma entre `Y0` e `Y_LOG_END`, linear entre `Y_LOG_END` e `Y_LIN1_END`e linear com outro espaçamento de grade entre `Y_LIN1_END` e `YN`. Esse tipo de grade geralmente fornece os melhores resultados. Se o desejo for de que alguma região tenha espaçamento uniforme, pode-se definir os espaçamentos inicial e final da região como sendo iguais.
> - O final do trecho linear2 da grade mista é definio na variável `YN`

Exemplo:

```prompt
# Configuração da grade
MAKE_GRID=true
GRID_NAME=xxxxxxxx        # nome da grade (8 caracteres)
GRID_TYPE=uniform         # opções: uniform | linear | log | mixed

# Dominío em X
X0=0.0               # coordenada inicial em x (m)
XN=10.0              # coordenada final em x (m)
DX=0.2                    # espaçamento em x (m)

# Dominío em Y - varia conforme o tipo de grade escolhido
Y0=0.0               # coordenada inicial em y (m)
YN=0.5               # coordenada final em y (m)


# ============ GRADE: UNIFORM ==========
# GRID_TYPE=uniform
# Apenas um espaçamento:

DY=0.001                # espaçamento constante em y (m)

# ============ GRADE: LINEAR ou LOG ===========
# GRID_TYPE=linear ou log
# Espaçamentos inicial e final

DY0=0.0003              # espaçamento no início
DYN=0.0020              # espaçamento no fim

# ============= GRADE: MIXED ===========
# GRID_TYPE=mixed
# Trechos: log -> linear1 -> linear2

Y_LOG_END= 0.06         # final do trecho log (m)
Y_LIN1_END=0.10         # final do trecho linear1 (m)

DY0=0.0003              # espaçamento inicial (log)
DY_LOG_END=0.0008       # espaçamento no fim do trecho log
DY_LIN1_END=0.0010      # espaçamento no fim do trecho linear1
DYN=0.2                 # espaçamento final (linear2)
```

Depois de preenchido o .env, o programa será executado conforme a configuração do projeto (via Docker, Makefile ou script customizado), lerá as variáveis automaticamente e criará o arquivo `.grd` no diretório `/cases/<casename>/inputs/`.

## Formato de saída Padrão

O formato do arquivo de grade segue o seguinte padrao:

- 1ª linha: deve conter os valores in e jn, que são os indices dos últimos pontos de grade, respectivamente nas direcoes x e y. O primeiro ponto de grade é convencionado como tendo indice 0.
- Linhas seguintes: devem conter o valor em metros do ponto x, e, subsequentemente, dos pontos y, tambem em metros.

Exemplo:

```prompt
 in  jn 
 x(1)
 x(2)
 .
 .
 .
 x(in-1)
 x(in)
 y(1)
 y(2)
 .
 .
 .
 y(jn-1)
 y(jn)

 ```
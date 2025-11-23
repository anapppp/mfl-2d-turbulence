# Imagem base com Python
FROM python:3.10-slim

# Instala o compilador gfortran
RUN apt-get update && apt-get install -y --no-install-recommends \
    gfortran && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Cria diretório de trabalho
WORKDIR /mfl_simulation

# Copia todos os arquivos .f90 e .py
COPY *.f90 ./
COPY *.py ./
COPY src/ ./src/

# Compila o(s) arquivo(s) Fortran
# ajuste o nome conforme o seu programa
RUN gfortran ./src/Make_Grid/MakeGrid_uniforme.f90 -o MakeGrid_uniforme
RUN gfortran ./src/Make_CondicoesIniciail/*.f90 -o MakeCondicoesIniciais
RUN gfortran ./src/CamadaLimite2D.ContornoDirich/CodigoFonte/CamadaLimite2D_v2.0.f90 -o CamadaLimite2D


# Comando padrão: abre o bash
CMD ["/bin/bash"]

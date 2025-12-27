FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    gfortran \
    libnetcdf-dev \
    libnetcdff-dev \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*  

WORKDIR /mfl_simulation

COPY . .
RUN mkdir -p log results

# Compile o código Fortran
RUN gfortran -O3 -march=native -funroll-loops -fopenmp \
    -I/usr/include \
    modules/mod_CondicoesContorno.f90 \
    modules/mod_PontoDePartida.f90 \
    modules/mod_RotinasInOut.f90 \
    modules/mod_DiferencasFinitas.f90 \
    modules/mod_NetCDFOutput.f90 \
    main.f90 \
    -lnetcdff -lnetcdf \
    -o mfl2dTurbulence

ENV OMP_NUM_THREADS=4
ENV GFORTRAN_UNBUFFERED_ALL=y

# Exemplo: Instale dependências Python se necessário
# RUN pip3 install -r requirements.txt

# Altere o comando conforme o que deseja rodar por padrão
CMD ["./mfl2dTurbulence", "simPlaca"]


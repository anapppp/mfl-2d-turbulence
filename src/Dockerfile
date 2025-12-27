FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    gfortran \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /mfl_simulation

COPY . .

# Compile o código Fortran
RUN gfortran modules/mod_PontoDePartida.f90 \
    modules/mod_RotinasInOut.f90 \
    modules/mod_DiferencasFinitas.f90 \
    main.f90 -o mfl2dTurbulence

# Exemplo: Instale dependências Python se necessário
# RUN pip3 install -r requirements.txt

# Altere o comando conforme o que deseja rodar por padrão
CMD ["./mfl2dTurbulence", "simPlaca"]
RUN mkdir -p log results


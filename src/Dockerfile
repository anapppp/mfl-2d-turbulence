FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    gfortran \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /mfl_simulation

COPY . .

RUN gfortran main.f90 -o ./mfl2dTurbulence

CMD ["./mfl2dTurbulence simPlaca"]


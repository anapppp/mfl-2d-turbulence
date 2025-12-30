module NetCDFOutput
  !---------------------------------------------------------------------------
  ! Módulo para salvar resultados em NetCDF4 com convenções CF
  ! Adaptado para o modelo de Camada Limite Atmosférica 2D
  !---------------------------------------------------------------------------
  use netcdf
  implicit none
  
  ! IDs do arquivo NetCDF (persistentes durante a simulação)
  integer, save :: ncid_main = -1
  integer, save :: time_dimid, x_dimid, z_dimid
  integer, save :: time_varid, x_varid, z_varid
  integer, save :: u_varid, w_varid, p_varid, theta_varid, t_varid
  integer, save :: ecin_varid, vort_varid
  integer, save :: current_time_index = 0
  
  ! IDs para arquivos de séries temporais (full)
  integer, save :: ncid_full = -1
  integer, save :: time_full_dimid, point_dimid
  integer, save :: time_full_varid, x_point_varid, z_point_varid
  integer, save :: u_full_varid, w_full_varid, p_full_varid
  integer, save :: theta_full_varid, t_full_varid
  integer, save :: current_full_index = 0
  
contains

  !---------------------------------------------------------------------------
  ! CRIAR ARQUIVO PRINCIPAL (campos 2D ao longo do tempo)
  !---------------------------------------------------------------------------
  subroutine create_main_netcdf(filename, nomecaso, nomegrade, in, kn, &
                                 x, z, dt, npt, compression_level)
    character(len=*), intent(in) :: filename, nomecaso, nomegrade
    integer, intent(in) :: in, kn, npt
    real, intent(in) :: x(in), z(kn), dt
    integer, intent(in), optional :: compression_level
    
    integer :: comp_level, dimids(3)
    character(len=19) :: timestamp
    
    comp_level = 6
    if (present(compression_level)) comp_level = compression_level
    
    print *, "Criando arquivo NetCDF principal: ", trim(filename)
    
    ! Criar arquivo NetCDF4
    call check(nf90_create(trim(filename), &
              ior(NF90_NETCDF4, NF90_CLOBBER), ncid_main))
    
    ! Definir dimensões
    call check(nf90_def_dim(ncid_main, "time", NF90_UNLIMITED, time_dimid))
    call check(nf90_def_dim(ncid_main, "x", in, x_dimid))
    call check(nf90_def_dim(ncid_main, "z", kn, z_dimid))
    
    ! Definir coordenada tempo
    call check(nf90_def_var(ncid_main, "time", NF90_DOUBLE, time_dimid, time_varid))
    call check(nf90_put_att(ncid_main, time_varid, "standard_name", "time"))
    call check(nf90_put_att(ncid_main, time_varid, "long_name", "time"))
    call check(nf90_put_att(ncid_main, time_varid, "units", "seconds since simulation start"))
    call check(nf90_put_att(ncid_main, time_varid, "axis", "T"))
    
    ! Definir coordenada x
    call check(nf90_def_var(ncid_main, "x", NF90_DOUBLE, x_dimid, x_varid))
    call check(nf90_put_att(ncid_main, x_varid, "standard_name", "projection_x_coordinate"))
    call check(nf90_put_att(ncid_main, x_varid, "long_name", "x coordinate"))
    call check(nf90_put_att(ncid_main, x_varid, "units", "m"))
    call check(nf90_put_att(ncid_main, x_varid, "axis", "X"))
    
    ! Definir coordenada z
    call check(nf90_def_var(ncid_main, "z", NF90_DOUBLE, z_dimid, z_varid))
    call check(nf90_put_att(ncid_main, z_varid, "standard_name", "height"))
    call check(nf90_put_att(ncid_main, z_varid, "long_name", "height above ground"))
    call check(nf90_put_att(ncid_main, z_varid, "units", "m"))
    call check(nf90_put_att(ncid_main, z_varid, "positive", "up"))
    call check(nf90_put_att(ncid_main, z_varid, "axis", "Z"))
    
    ! Ordem: (x, z, time)
    dimids = [x_dimid, z_dimid, time_dimid]
    
    ! Definir variáveis 3D (x, z, time)
    call define_3d_variable(ncid_main, "u", dimids, u_varid, &
         "eastward_wind", "x-component of velocity", "m s-1", comp_level)
    
    call define_3d_variable(ncid_main, "w", dimids, w_varid, &
         "upward_air_velocity", "z-component of velocity", "m s-1", comp_level)
    
    call define_3d_variable(ncid_main, "p", dimids, p_varid, &
         "air_pressure_deviation", "pressure deviation from base state", "Pa", comp_level)
    
    call define_3d_variable(ncid_main, "theta", dimids, theta_varid, &
         "air_potential_temperature", "potential temperature", "K", comp_level)
    
    call define_3d_variable(ncid_main, "t", dimids, t_varid, &
         "air_temperature_deviation", "temperature deviation from base state", "K", comp_level)
    
    ! Variáveis escalares (time)
    call check(nf90_def_var(ncid_main, "kinetic_energy", NF90_DOUBLE, &
               time_dimid, ecin_varid))
    call check(nf90_put_att(ncid_main, ecin_varid, "long_name", &
               "mean kinetic energy"))
    call check(nf90_put_att(ncid_main, ecin_varid, "units", "m2 s-2"))
    
    call check(nf90_def_var(ncid_main, "vorticity", NF90_DOUBLE, &
               time_dimid, vort_varid))
    call check(nf90_put_att(ncid_main, vort_varid, "long_name", &
               "mean vorticity"))
    call check(nf90_put_att(ncid_main, vort_varid, "units", "s-1"))
    
    ! Atributos globais
    call check(nf90_put_att(ncid_main, NF90_GLOBAL, "title", &
               "2D Atmospheric Boundary Layer Model"))
    call check(nf90_put_att(ncid_main, NF90_GLOBAL, "simulation_name", trim(nomecaso)))
    call check(nf90_put_att(ncid_main, NF90_GLOBAL, "grid_name", trim(nomegrade)))
    call check(nf90_put_att(ncid_main, NF90_GLOBAL, "institution", "LEMMA/UFPR"))
    call check(nf90_put_att(ncid_main, NF90_GLOBAL, "source", &
               "Lagrangian Filtering Method - 2D Turbulence"))
    call check(nf90_put_att(ncid_main, NF90_GLOBAL, "Conventions", "CF-1.8"))
    call check(nf90_put_att(ncid_main, NF90_GLOBAL, "author", &
               "Ana Paula Kelm Soares - PPGMNE"))
    call check(nf90_put_att(ncid_main, NF90_GLOBAL, "timestep", dt))
    call check(nf90_put_att(ncid_main, NF90_GLOBAL, "total_timesteps", npt))
    
    call get_timestamp(timestamp)
    call check(nf90_put_att(ncid_main, NF90_GLOBAL, "creation_date", timestamp))
    
    ! Sair do modo definição e escrever coordenadas
    call check(nf90_enddef(ncid_main))
    
    call check(nf90_put_var(ncid_main, x_varid, dble(x)))
    call check(nf90_put_var(ncid_main, z_varid, dble(z)))
    
    current_time_index = 0
    
    print *, "  ✓ Arquivo NetCDF criado com sucesso"
    
  end subroutine create_main_netcdf

  !---------------------------------------------------------------------------
  ! ESCREVER TIMESTEP NO ARQUIVO PRINCIPAL
  !---------------------------------------------------------------------------
  subroutine write_timestep_netcdf(time, u, w, p, theta, t, &
                                   ecin, vort, in, kn)
    real, intent(in) :: time, ecin, vort
    integer, intent(in) :: in, kn
    real, intent(in) :: u(in,kn), w(in,kn), p(in,kn), theta(in,kn), t(in,kn)
    
    integer :: start(3), count(3)
    
    if (ncid_main < 0) then
      print *, "ERRO: Arquivo NetCDF principal não foi criado!"
      return
    endif
    
    current_time_index = current_time_index + 1
    
    ! Escrever tempo
    call check(nf90_put_var(ncid_main, time_varid, dble(time), &
                           start=[current_time_index]))
    
    ! Escrever escalares
    call check(nf90_put_var(ncid_main, ecin_varid, dble(ecin), &
                           start=[current_time_index]))
    call check(nf90_put_var(ncid_main, vort_varid, dble(vort), &
                           start=[current_time_index]))
    
    ! Configurar hiperslab para campos 2D
    start = [1, 1, current_time_index]
    count = [in, kn, 1]
    
    ! Escrever campos 2D
    call check(nf90_put_var(ncid_main, u_varid, dble(u), start=start, count=count))
    call check(nf90_put_var(ncid_main, w_varid, dble(w), start=start, count=count))
    call check(nf90_put_var(ncid_main, p_varid, dble(p), start=start, count=count))
    call check(nf90_put_var(ncid_main, theta_varid, dble(theta), start=start, count=count))
    call check(nf90_put_var(ncid_main, t_varid, dble(t), start=start, count=count))
    
    ! Sync para garantir escrita
    call check(nf90_sync(ncid_main))
    
  end subroutine write_timestep_netcdf

  !---------------------------------------------------------------------------
  ! CRIAR ARQUIVO DE SÉRIES TEMPORAIS (substituir .full)
  !---------------------------------------------------------------------------
  subroutine create_full_netcdf(filename, nomecaso, npt_full, &
                                x_points, z_points, npoints)
    character(len=*), intent(in) :: filename, nomecaso
    integer, intent(in) :: npt_full, npoints
    real, intent(in) :: x_points(npoints), z_points(npoints)
    
    integer :: dimids(2)
    
    print *, "Criando arquivo de séries temporais: ", trim(filename)
    
    call check(nf90_create(trim(filename), &
              ior(NF90_NETCDF4, NF90_CLOBBER), ncid_full))
    
    ! Dimensões
    call check(nf90_def_dim(ncid_full, "time", NF90_UNLIMITED, time_full_dimid))
    call check(nf90_def_dim(ncid_full, "point", npoints, point_dimid))
    
    ! Coordenada tempo
    call check(nf90_def_var(ncid_full, "time", NF90_DOUBLE, &
               time_full_dimid, time_full_varid))
    call check(nf90_put_att(ncid_full, time_full_varid, "units", &
               "seconds since simulation start"))
    
    ! Coordenadas dos pontos
    call check(nf90_def_var(ncid_full, "x_point", NF90_DOUBLE, &
               point_dimid, x_point_varid))
    call check(nf90_put_att(ncid_full, x_point_varid, "long_name", &
               "x coordinate of measurement point"))
    call check(nf90_put_att(ncid_full, x_point_varid, "units", "m"))
    
    call check(nf90_def_var(ncid_full, "z_point", NF90_DOUBLE, &
               point_dimid, z_point_varid))
    call check(nf90_put_att(ncid_full, z_point_varid, "long_name", &
               "z coordinate of measurement point"))
    call check(nf90_put_att(ncid_full, z_point_varid, "units", "m"))
    
    ! Variáveis de série temporal (time, point)
    dimids = [point_dimid, time_full_dimid]
    
    call check(nf90_def_var(ncid_full, "u", NF90_FLOAT, dimids, u_full_varid))
    call check(nf90_def_var_deflate(ncid_full, u_full_varid, 1, 1, 6))
    call check(nf90_put_att(ncid_full, u_full_varid, "long_name", "x-velocity"))
    call check(nf90_put_att(ncid_full, u_full_varid, "units", "m s-1"))
    
    call check(nf90_def_var(ncid_full, "w", NF90_FLOAT, dimids, w_full_varid))
    call check(nf90_def_var_deflate(ncid_full, w_full_varid, 1, 1, 6))
    call check(nf90_put_att(ncid_full, w_full_varid, "long_name", "z-velocity"))
    call check(nf90_put_att(ncid_full, w_full_varid, "units", "m s-1"))
    
    call check(nf90_def_var(ncid_full, "p", NF90_FLOAT, dimids, p_full_varid))
    call check(nf90_def_var_deflate(ncid_full, p_full_varid, 1, 1, 6))
    call check(nf90_put_att(ncid_full, p_full_varid, "long_name", "pressure"))
    call check(nf90_put_att(ncid_full, p_full_varid, "units", "Pa"))
    
    call check(nf90_def_var(ncid_full, "theta", NF90_FLOAT, dimids, theta_full_varid))
    call check(nf90_def_var_deflate(ncid_full, theta_full_varid, 1, 1, 6))
    call check(nf90_put_att(ncid_full, theta_full_varid, "long_name", &
               "potential temperature"))
    call check(nf90_put_att(ncid_full, theta_full_varid, "units", "K"))
    
    call check(nf90_def_var(ncid_full, "t", NF90_FLOAT, dimids, t_full_varid))
    call check(nf90_def_var_deflate(ncid_full, t_full_varid, 1, 1, 6))
    call check(nf90_put_att(ncid_full, t_full_varid, "long_name", "temperature"))
    call check(nf90_put_att(ncid_full, t_full_varid, "units", "K"))
    
    ! Atributos globais
    call check(nf90_put_att(ncid_full, NF90_GLOBAL, "title", &
               "Time series at specific points"))
    call check(nf90_put_att(ncid_full, NF90_GLOBAL, "simulation_name", &
               trim(nomecaso)))
    
    ! Sair do modo definição e escrever coordenadas
    call check(nf90_enddef(ncid_full))
    
    call check(nf90_put_var(ncid_full, x_point_varid, dble(x_points)))
    call check(nf90_put_var(ncid_full, z_point_varid, dble(z_points)))
    
    current_full_index = 0
    
    print *, "  ✓ Arquivo de séries temporais criado"
    
  end subroutine create_full_netcdf

  !---------------------------------------------------------------------------
  ! ESCREVER SÉRIE TEMPORAL
  !---------------------------------------------------------------------------
  subroutine write_full_netcdf(time, u_points, w_points, p_points, &
                               theta_points, t_points, npoints)
    real, intent(in) :: time
    integer, intent(in) :: npoints
    real, intent(in) :: u_points(npoints), w_points(npoints)
    real, intent(in) :: p_points(npoints), theta_points(npoints), t_points(npoints)
    
    integer :: start(2), count(2)
    
    if (ncid_full < 0) return
    
    current_full_index = current_full_index + 1
    
    call check(nf90_put_var(ncid_full, time_full_varid, dble(time), &
                           start=[current_full_index]))
    
    start = [1, current_full_index]
    count = [npoints, 1]
    
    call check(nf90_put_var(ncid_full, u_full_varid, u_points, &
                           start=start, count=count))
    call check(nf90_put_var(ncid_full, w_full_varid, w_points, &
                           start=start, count=count))
    call check(nf90_put_var(ncid_full, p_full_varid, p_points, &
                           start=start, count=count))
    call check(nf90_put_var(ncid_full, theta_full_varid, theta_points, &
                           start=start, count=count))
    call check(nf90_put_var(ncid_full, t_full_varid, t_points, &
                           start=start, count=count))
    
  end subroutine write_full_netcdf

  !---------------------------------------------------------------------------
  ! FECHAR ARQUIVOS
  !---------------------------------------------------------------------------
  subroutine close_all_netcdf()
    if (ncid_main >= 0) then
      call check(nf90_close(ncid_main))
      ncid_main = -1
      print *, "  ✓ Arquivo principal fechado"
    endif
    
    if (ncid_full >= 0) then
      call check(nf90_close(ncid_full))
      ncid_full = -1
      print *, "  ✓ Arquivo de séries temporais fechado"
    endif
  end subroutine close_all_netcdf

  !---------------------------------------------------------------------------
  ! FUNÇÕES AUXILIARES
  !---------------------------------------------------------------------------
  
  subroutine define_3d_variable(ncid, name, dimids, varid, &
                                standard_name, long_name, units, comp_level)
    integer, intent(in) :: ncid, dimids(3), comp_level
    character(len=*), intent(in) :: name, standard_name, long_name, units
    integer, intent(out) :: varid
    
    call check(nf90_def_var(ncid, trim(name), NF90_FLOAT, dimids, varid))
    call check(nf90_def_var_deflate(ncid, varid, 1, 1, comp_level))
    
    ! Chunking otimizado [x_chunk, z_chunk, time_chunk]
    call check(nf90_def_var_chunking(ncid, varid, NF90_CHUNKED, [64, 32, 1]))
    
    call check(nf90_put_att(ncid, varid, "standard_name", trim(standard_name)))
    call check(nf90_put_att(ncid, varid, "long_name", trim(long_name)))
    call check(nf90_put_att(ncid, varid, "units", trim(units)))
    call check(nf90_put_att(ncid, varid, "_FillValue", -9999.0))
    
  end subroutine define_3d_variable

  subroutine check(status)
    integer, intent(in) :: status
    
    if (status /= nf90_noerr) then
      print *, "NetCDF Error: ", trim(nf90_strerror(status))
      stop "NetCDF operation failed"
    endif
  end subroutine check

  subroutine get_timestamp(timestamp)
    character(len=19), intent(out) :: timestamp
    integer :: values(8)
    
    call date_and_time(values=values)
    write(timestamp, '(I4.4,A,I2.2,A,I2.2,A,I2.2,A,I2.2,A,I2.2)') &
          values(1), '-', values(2), '-', values(3), ' ', &
          values(5), ':', values(6), ':', values(7)
  end subroutine get_timestamp

end module NetCDFOutput

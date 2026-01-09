program MakeGrid

use MakeGridLinear;
use MakeGridUniforme;
use MakeGridLog;
use MakeGridMista;

implicit none
 
  integer :: status
  logical :: makegrid
  character(len=50) :: gridType, tmp

  call get_environment_variable("MAKE_GRID", tmp, status=status)
  if (status /= 0) tmp = "false"
  makegrid = (trim(adjustl(tmp)) == "true" .or. trim(adjustl(tmp)) == "TRUE" .or. trim(adjustl(tmp)) == "1")
  
  if (.not. makegrid) then
    print *, "MAKE_GRID is false. Exiting..."
    stop
  end if
  
  call get_environment_variable("GRID_TYPE", gridType, status=status)
  if (status /= 0) stop "ERROR: GRID_TYPE not defined"
  
    select case (trim(gridType))
      case ("uniform")
        call makeGridUniforme()
      case ("linear")
        call makeGridLinear()
      case ("log")
        call makeGridLog()
      case ("mixed")
        call makeGridMista()
      case default
        stop "ERROR: GRID_TYPE option not recognized. Use: uniform | linear | log | mixed"
    end select

end program MakeGrid
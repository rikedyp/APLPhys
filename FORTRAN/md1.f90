! MD1: a simple, minimal molecular dynamics program in Fortran 90
!
! Lennard-Jones potential, 'velocity' Verlet time integration algorithm.
! Computes kinetic and potential energy, density, pressure.
!
! Furio Ercolessi, SISSA, Trieste, May 1995, revised May 1997
!
! Files used by this program:
!
! Unit  I/O  Meaning
! ----  ---  ----------------------------------------------------------------
!   1    I   Input sample (coordinates, and perhaps also velocities and
!            accelerations) read at the beginning of the run
!   2    O   Output sample (coordinates, velocities, accelerations) written
!            at the end of the run
!   *    I   Standard input for the simulation control
!   *    O   Standard output containing various informations on the run
!
! Output suitable to be directly fed to 'gnuplot' to produce plots as a
! function of time.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  MODULES CONTAINING
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!    DATA STRUCTURES

module Particles
!
!  Contains all the data structures containing informations
!  about atom properties
!
   integer, parameter :: DIM=3     ! change DIM to switch between 2D and 3D !
   logical :: VelAcc = .FALSE.     ! velocities and accelerations in file?
   integer :: N=0
   double precision, dimension(DIM) :: BoxSize
!     the following arrays are allocated at run time, 
!     when the number of atoms N is known.
   double precision, dimension(:,:), allocatable :: pos     ! positions
   double precision, dimension(:,:), allocatable :: vel     ! velocities
   double precision, dimension(:,:), allocatable :: acc     ! accelerations
   double precision, dimension(:), allocatable :: ene_pot   ! potential energies
   double precision, dimension(:), allocatable :: ene_kin   ! kinetic energies
!     scalars derived from the above quantities
   double precision :: volume, density                   ! these are constants 
   double precision :: virial      ! virial term, used to compute the pressure
end module Particles

module Simulation_Control
!
!  Contains the parameters controlling the simulation, which will be 
!  supplied as input by the user.
!
   character*80     :: title         !  Arbitrary 'title' string
   character*80     :: SampIn        !  Name of file containing input sample
   character*80     :: SampOut       !  Name of file to contain output sample
   integer          :: Nsteps        !  Number of time steps to do
   double precision :: deltat        !  Time steps (redueced units)
   double precision :: RhoRequested  !  Desired density.  0 leaves it unchanged.
   double precision :: TRequested    !  Desired temperature, or <0 if constant E
   logical          :: ChangeRho     !  .TRUE. when user is changing the density
   logical          :: ConstantT     !  made .TRUE. when (TRequested >= 0)
end module Simulation_Control

module Potential
!     
!     Contains parameters of the Lennard-Jones potential
!
   double precision, parameter :: Rcutoff = 2.5d0   ! cutoff distance
   double precision, parameter :: phicutoff = &     ! potential at cutoff
                                4.d0/(Rcutoff**12) - 4.d0/(Rcutoff**6)
end module Potential

module Statistics
!
!  Contains statistical quantities accumulated during the run.
!  All quantities are resetted to zero.
!
   double precision :: temperature_sum = 0.d0
   double precision :: ene_kin_sum     = 0.d0
   double precision :: ene_pot_sum     = 0.d0
   double precision :: pressure_sum    = 0.d0
end module Statistics

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  CODE STARTS
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!     HERE

program MD1
!
!  This is the main driver for the molecular dynamics program.
!
implicit none
call Initialize
call Evolve_Sample
call Terminate
end program MD1

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  INITIALIZATION
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!     ROUTINES

subroutine Initialize
!
!  Initialization procedure (called once at the beginning, before the
!  time evolution starts)
!
use Particles
implicit none
!
!  Read the user directives controlling the simulation
!
call Read_Input
!
!  Read the input sample containing the initial particle coordinates
!  (and perhaps also velocities and accelerations)
!
call Read_Sample
!
!  Print informations on the run on the standard output file
!
call Initial_Printout
end subroutine Initialize


subroutine Read_Sample
!
!  Reads the initial sample from file unit 1
!
use Particles
use Simulation_Control
implicit none
double precision, dimension(DIM) :: PosAtomReal,VelAtomReal,AccAtomReal
double precision, dimension(DIM) :: Mass_center
double precision :: scale
integer :: i,k,lis

lis = len_trim(SampIn)
open(unit=1,file=SampIn(1:lis),status='old', &
     action='read',err=700)   
read(1,'(1X,L2,I7,3E23.15)',end=600,err=900) VelAcc,N,BoxSize
if ( N <= 0 ) then
   print*,'Read_Sample: FATAL: N is',N
   stop
endif
!
!  compute volume and density once for all (they do not change in the run)
!
volume  = product(BoxSize)
density = N / volume
!
!   ... unless the user wants to change the density, in this case we do
!   it here:
!
if (ChangeRho) then
   scale = ( density / RhoRequested ) ** ( 1.d0 / DIM )
   BoxSize = scale*BoxSize
   volume  = product(BoxSize)
   density = N / volume
endif
!
!  now that we know the system size, we can dynamically allocate the
!  arrays containing atomic informations
!
allocate( pos(DIM,N) )
allocate( vel(DIM,N) )
allocate( acc(DIM,N) )
allocate( ene_pot(N) )
allocate( ene_kin(N) )
!
!  read the coordinates from the file (one line per atom), normalize
!  them to the box size along each direction and store them.
!  Energies are set initially to zero.
!
do i=1,N
   read(1,*,end=800,err=900) PosAtomReal
   pos(:,i) = PosAtomReal/BoxSize
   ene_pot(i) = 0.d0
   ene_kin(i) = 0.d0
enddo
!
!  For "new" samples (that is, samples just created by defining the atomic
!  coordinates and not the result of previous simulations), we have now
!  read everything, and velocities and accelerations are set to zero.
!  For sample which have been produced by previous simulations, we also
!  have to read velocities and accelerations.
!  The logical variable 'VelAcc' distinguishes between these two cases.
!
if (VelAcc) then     ! also read velocities and accelerations
   do i=1,N
      read(1,'(1X,3E23.15)',end=800,err=900) VelAtomReal
      vel(:,i) = VelAtomReal/BoxSize
   enddo
   do i=1,N
      read(1,'(1X,3E23.15)',end=800,err=900) AccAtomReal
      acc(:,i) = AccAtomReal/BoxSize
   enddo
else                 ! set velocities and accelerations to zero
   vel = 0.d0
   acc = 0.d0
endif
!
!  compute center of mass coordinates
!
Mass_Center = sum( pos , dim=2 ) / N
!
!  translate atoms so that center of mass is at the origin
!
do k=1,DIM
   pos(k,:) = pos(k,:) - Mass_Center(k)
enddo
!
!  all coordinates read successfully if we get to this point
!
close(unit=1)
return
!
!  handling of various kinds of errors
!
600 continue
   print*,'Read_Sample: FATAL: ',SampIn(1:lis),' is empty?'
   stop
700 continue
   print*,'Read_Sample: FATAL: ',SampIn(1:lis),' not found.'
   stop
800 continue
   print*,'Read_Sample: FATAL: premature end-of-file at atom ',i
   close(unit=1)
   stop   
900 continue
   print*,'Read_Sample: FATAL: read error in ',SampIn(1:lis)
   close(unit=1)
   stop
end subroutine Read_Sample


subroutine Read_Input
!
!  Read the parameters controlling the simulation from the standard input.
!
use Simulation_Control
implicit none
!
!  Read the input parameters controlling the simulation from the standard
!  input.
!
read(*,'(a)',end=200,err=800) title
read(*,'(a)',end=200,err=800) SampIn
read(*,'(a)',end=200,err=800) SampOut
read(*,  *  ,end=200,err=800) Nsteps
read(*,  *  ,end=200,err=800) deltat
read(*,  *  ,end=200,err=800) RhoRequested
read(*,  *  ,end=200,err=800) TRequested
ChangeRho = ( RhoRequested > 0 )
ConstantT = ( TRequested >= 0 )
return   !  successful exit
200 continue
   print*,'Read_Input: FATAL: premature end-of-file in standard input'
   stop
800 continue
   print*,'Read_Input: FATAL: read error in standard input'
   stop
end subroutine Read_Input


subroutine Initial_Printout
!
!  Prints informations on the run parameters on the standard output
!  Leading # are to directly use the output as a gnuplot input.
!
use Particles
use Simulation_Control
implicit none
print '(a,/,a,/,a)','#','# MD1: a minimal molecular dynamics program','#'
print '(2a)','# ',title(1:len_trim(title))
print '(2a)','#  Input sample: ',SampIn(1:len_trim(SampIn))
if (VelAcc) then
   print '(a)','#          (positions, velocities, accelerations read from file)'
else
   print '(a)','#                                (only positions read from file)'
endif
print '(2a)','# Output sample: ',SampOut(1:len_trim(SampOut))
print '(a,i8,a,f7.4,a,f12.4)', &
   '# Number of steps:',Nsteps,', time step:',deltat, &
   ', total time:',Nsteps*deltat
print '(a,i6)','# Number of atoms:',N
print '(a,3f12.6,a,f15.3)', &
   '# Box size:',BoxSize,', Volume:',volume
if (ChangeRho) then
   print '(a,f12.6,a)','# Density:',density,' (changed)'
else
   print '(a,f12.6,a)','# Density:',density,' (unchanged)'
endif
if (ConstantT) then
   print '(a,f12.6)','# Constant T run with T =',TRequested
else
   print '(a)','# Free evolution run.'
endif

!
!  Now print headers of columns
!
print '(a,/,a,/,a)', '#', &
'#  Step   Temperature     Kinetic      Potential   Total Energy    Pressure',&
'# -----  ------------  ------------  ------------  ------------  ------------'
end subroutine Initial_Printout

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  TIME EVOLUTION
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!     ROUTINES

subroutine Evolve_Sample
!
!  This is the main subroutine, controlling the time evolution of the system.
!
use Particles
use Simulation_Control
use Statistics
implicit none
integer step
double precision :: ene_kin_aver,ene_pot_aver,ene_tot_aver,temperature,pressure
double precision :: chi
!
!  We need to have the initial temperature ready in case we are going
!  at constant T:
!
call Compute_Temperature(ene_kin_aver,temperature) 
!
!  "Velocity Verlet" integrator (see e.g. Allen and Tildesley book, p. 81).
!  Simple velocity scaling (done on velocities at the previous step)
!  applied when ConstantT is enabled.
!
time: do step=1,Nsteps
   call Refold_Positions
   pos = pos + deltat*vel + 0.5d0*(deltat**2)*acc      ! r(t+dt)
   if (ConstantT .and. (temperature > 0) ) then	  !  veloc rescale for const T
      call Compute_Temperature(ene_kin_aver,temperature) ! T(t)
      chi = sqrt( Trequested / temperature )
      vel = chi*vel + 0.5d0*deltat*acc                 ! v(t+dt/2)
   else                          !  regular constant E dynamics
      vel = vel + 0.5d0*deltat*acc                     ! v(t+dt/2)
   endif   
   call Compute_Forces                                 ! a(t+dt),ene_pot,virial
   vel = vel + 0.5d0*deltat*acc                        ! v(t+dt)
   call Compute_Temperature(ene_kin_aver,temperature)  ! at t+dt, also ene_kin
   ene_pot_aver = sum( ene_pot ) / N
   ene_tot_aver = ene_kin_aver + ene_pot_aver
!
!  For the pressure calculation, see the Allen and Tildesley book, section 2.4
!
   pressure = density*temperature + virial/volume
   print '(1x,i6,5f14.6)',step,temperature, &
                          ene_kin_aver,ene_pot_aver,ene_tot_aver,pressure
!     accumulate statistics:
   temperature_sum = temperature_sum + temperature
   ene_kin_sum     = ene_kin_sum     + ene_kin_aver
   ene_pot_sum     = ene_pot_sum     + ene_pot_aver
   pressure_sum    = pressure_sum    + pressure
enddo time
end subroutine Evolve_Sample


subroutine Refold_Positions
!
!  Particles that left the box are refolded back into the box by
!  periodic boundary conditions 
!
use Particles
implicit none
where ( pos >  0.5d0 ) pos = pos - 1.d0
where ( pos < -0.5d0 ) pos = pos + 1.d0
end subroutine Refold_Positions


subroutine Compute_Forces
!
!  Compute forces on atoms from the positions, using the Lennard-Jones 
!  potential.
!  Note double nested loop, giving O(N^2) time: this is a SLOW ROUTINE,
!  unsuitable for large systems.
!
use Particles
use Potential
implicit none
double precision, dimension(DIM) :: Sij,Rij
double precision :: Rsqij,phi,dphi
double precision :: rm2,rm6,rm12
integer :: i,j
!
!  Reset to zero potential energies, forces, virial term
!
ene_pot = 0.d0
acc = 0.d0
virial = 0.d0
!
!  Loop over all pairs of particles
!
do i = 1,N-1                                      ! looping an all pairs
   do j = i+1,N
      Sij = pos(:,i) - pos(:,j)                   ! distance vector between i j
      where ( abs(Sij) > 0.5d0 )                  ! (in box scaled units)
         Sij = Sij - sign(1.d0,Sij)               ! periodic boundary conditions
      end where                                   ! applied where needed.
      Rij = BoxSize*Sij                           ! go to real space units
      Rsqij = dot_product(Rij,Rij)                ! compute square distance
      if ( Rsqij < Rcutoff**2 ) then              ! particles are interacting?
                                                  ! compute Lennard-Jones potntl
         rm2 = 1.d0/Rsqij                         !  1/r^2
         rm6 = rm2**3                             !  1/r^6
         rm12 = rm6**2                            !  1/r^12
         phi  = 4.d0 * ( rm12 - rm6 ) - phicutoff !  4[1/r^12 - 1/r^6] - phi(Rc)
                                      !  The following is dphi = -(1/r)(dV/dr)
         dphi = 24.d0*rm2*( 2.d0*rm12 - rm6 )     !  24[2/r^14 - 1/r^8]
         ene_pot(i) = ene_pot(i) + 0.5d0*phi      ! accumulate energy
         ene_pot(j) = ene_pot(j) + 0.5d0*phi      ! (i and j share it)
         virial = virial - dphi*Rsqij             ! accumul. virial=sum r(dV/dr)
         acc(:,i) = acc(:,i) + dphi*Sij           ! accumulate forces
         acc(:,j) = acc(:,j) - dphi*Sij           !    (Fji = -Fij)
      endif
   enddo
enddo
virial = - virial/DIM                             ! definition of virial term
end subroutine Compute_Forces


subroutine Compute_Temperature(ene_kin_aver,temperature)
!
!  Starting from the velocities currently stored in vel, it updates
!  the kinetic energy array ene_kin, and computes and returns the
!  averaged (on particles) kinetic energy ene_kin_aver and the
!  instantaneous temperature.
!
use Particles
implicit none
double precision :: ene_kin_aver, temperature
double precision, dimension(DIM) :: real_vel
integer :: i
do i=1,N
   real_vel = BoxSize*vel(:,i)                        ! real space velocity of i
   ene_kin(i) = 0.5d0*dot_product(real_vel,real_vel)  ! kin en of each atom 
enddo
ene_kin_aver = sum( ene_kin ) / N
temperature = 2.d0*ene_kin_aver/DIM
end subroutine Compute_Temperature


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  TERMINATION
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!    ROUTINES

subroutine Terminate
!
!  Termination procedure (called once at the end, after time evolution
!  and before program termination)
!
use Particles
implicit none
!
!  Print a line with averages, etc
!
call Print_Statistics
!
!  Write the final sample (positions, velocities, accelerations) on file
!
call Write_Sample
!
!  Deallocate all the dynamical arrays to clean memory ('ecological' practice)
!
deallocate( pos )
deallocate( vel )
deallocate( acc )
deallocate( ene_pot )
deallocate( ene_kin )
end subroutine Terminate


subroutine Print_Statistics
!
!  Print the mean value, averaged during the run, of the statistical 
!  quantities which have been accumulated
!  
use Simulation_Control
use Statistics
implicit none
if ( Nsteps <= 0 ) return               ! protection against '0 steps run'
print '(a,/,a,5f14.6)','#','# Means', &
                     temperature_sum / Nsteps , &
                     ene_kin_sum / Nsteps , &
                     ene_pot_sum / Nsteps , &
                     ( ene_kin_sum + ene_pot_sum ) / Nsteps , &
                     pressure_sum / Nsteps         
end subroutine Print_Statistics


subroutine Write_Sample
!
!  Writes the final sample to file unit 2
!
use Particles
use Simulation_Control
implicit none
double precision, dimension(DIM) :: PosAtomReal,VelAtomReal,AccAtomReal
integer :: i,lis

lis = len_trim(SampOut)
open(unit=2,file=SampOut(1:lis),status='unknown', &
     action='write',err=700)
VelAcc = .TRUE.  ! we are going to write velocities and accelerations in SampOut
!
!  The '%' signals to ignore this line to the BallRoom program producing
!  an image from the simulation
!
write(2,'(A1,L2,I7,3E23.15)',err=900) '%',VelAcc,N,BoxSize
!
!  Multiply coordinates (which are scaled by the box size) by BoxSize in
!  order to have them in real, unscaled units, then write them in the
!  file (one line per atom).
!
do i=1,N
   PosAtomReal = pos(:,i)*BoxSize
   write(2,'(1X,3E23.15)',err=900) PosAtomReal
enddo
!
!  Do the same for velocities and accelerations.
!
do i=1,N
   VelAtomReal = vel(:,i)*BoxSize
   write(2,'(A1,3E23.15)',err=900) '%',VelAtomReal
enddo
do i=1,N
   AccAtomReal = acc(:,i)*BoxSize
   write(2,'(A1,3E23.15)',err=900) '%',AccAtomReal
enddo
!
!  file written successfully if we get to this point
!
close(unit=2)
return
!
!  handling of various kinds of errors
!
700 continue
   print*,'Write_Sample: WARNING: cannot open ',SampOut(1:lis),' for write'
   return
900 continue
   print*,'Write_Sample: WARNING: error when writing ',SampOut(1:lis)
   close(unit=2)
   return
end subroutine Write_Sample

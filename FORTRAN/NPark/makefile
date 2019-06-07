OBJ	=	kind_mod.o 	\
		params.o        \
		input.o 	\
		box.o  		\
		snap_ensight.o 	\
		setup.o 	\
		EAM.o		\
		MEAM.o		\
		LJ.o 		\
		powerlaw.o 	\
		softsphere.o 	\
		calc.o 		\
		restart.o 		\
		integrate.o 	\
		nmdc.o 

FC = pgf90
FCFLAGS	=

LINK = $(FC)
LINKFLAGS =

EXE = nmdc


##########
# Target #
##########
nmdc : $(OBJ)
	$(FC) $(FCFLAGS) $(OBJ) -o $(EXE)
	rm *.o *.mod

clean:
	rm *.o *.mod nmdc


######################
# Individual objects #
######################
kind_mod.o: kind_mod.f90
	$(FC) $(FCFLAGS) -c kind_mod.f90

params.o: params.f90
	$(FC) $(FCFLAGS) -c params.f90

input.o: input.f90
	$(FC) $(FCFLAGS) -c input.f90

box.o: box.f90
	$(FC) $(FCFLAGS) -c box.f90

snap_ensight.o: snap_ensight.f90
	$(FC) $(FCFLAGS) -c snap_ensight.f90

setup.o: setup.f90
	$(FC) $(FCFLAGS) -c setup.f90

EAM.o: EAM.f90
	$(FC) $(FCFLAGS) -c EAM.f90

MEAM.o: MEAM.f90
	$(FC) $(FCFLAGS) -c MEAM.f90

LJ.o: LJ.f90
	$(FC) $(FCFLAGS) -c LJ.f90

powerlaw.o: powerlaw.f90
	$(FC) $(FCFLAGS) -c powerlaw.f90

softsphere.o: softsphere.f90
	$(FC) $(FCFLAGS) -c softsphere.f90

calc.o: calc.f90 
	$(FC) $(FCFLAGS) -c calc.f90

restart.o: restart.f90 
	$(FC) $(FCFLAGS) -c restart.f90

integrate.o: integrate.f90
	$(FC) $(FCFLAGS) -c integrate.f90

nmdc.o: nmdc.f90
	$(FC) $(FCFLAGS) -c nmdc.f90


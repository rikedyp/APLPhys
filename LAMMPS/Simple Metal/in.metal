units metal
lattice fcc 3.632
region box block -5 5 -5 5 -5 5
create_box 1 box
create_atoms 1 box
pair_style lj/cut 6.0
pair_coeff * * 2.0 1.0
mass 1 63.546
velocity all create 600 32075
fix 1 all nve
thermo 100
dump    1 all atom 250 dump.metal
dump    3 all movie 100 movie.mpg type type &
    zoom 1.6 adiam 1.5
dump_modify 3 pad 5
run 10000
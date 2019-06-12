# APLParticleSim
Simplistic simulations in APL

## Overview
This project is a preliminary investigation into physics simulations in APL. It is intended to demonstrate APL as a tool for translating mathematical formulae into executable code.

The code is available as Dyalog scripted namespaces and python, FORTRAN and LAMMPS examples for comparison.

The project is explained in a series of Jupyter notebooks which can be read here on GitHub, using [nbviewer](https://nbviewer.jupyter.org/) or with a Jupyter installation with the [Dyalog Jupyter kernel](https://github.com/Dyalog/dyalog-jupyter-kernel).
### Audience
We hope that this project will appeal to physical science, computing and mathematics students and teachers; researchers in physics / materials science and those using molecular dynamics in particular; and of course the APL and array programming communities.
### Scope
As it stands, this project is a proof-of-concept for a simple Lennard-Jones melt velocity Verlet simulation. We hope the accompanying code explanations and comparative speed tests will show that APL is suitable as a rapid-development tool with the added benefit of tolerable computation speed.
### Future
We hope to expand this project to include other computational simulation models, initially inspired by the LAMMPS gamut. There is also the potential to use Dyalog APL for data processing of experimental data, perhaps in combination with Microsoft Office Excel (maybe libre office?).
## APLPhys simulation engine
### Masses on springs
A bit of a toy for showing off the stencil ⌺ primitive.  
Masses are arranged in a 2D grid. Adjacent masses are connected by simple Hooke springs with no resistance. The mass-spring grid floats in a vacuum.  
### Lennard-Jones melt
For speed testing against python, FORTRAN and LAMMPS.  
A block of hexagonally packed particles interact via pair-wise LJ potential. The integrator is the velocity Verlet algorithm. 
## Web-based front end
This MiServer-based UI demonstrates the simulations in an interactive browser-based environment.
### Menu
### CSS balls

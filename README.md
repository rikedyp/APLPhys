# APLPhys
Computational physics in APL

## Overview
This project is a preliminary investigation into physics simulations in APL. It is intended to demonstrate APL as a tool for translating algorithms and mathematical formulae into executable code. 

The code is available as Dyalog [\]Link](https://github.com/dyalog/link)-able .apl* files.

### Documentation
The code will be explained in a series of Jupyter notebooks which can be read here on GitHub, using [nbviewer](https://nbviewer.jupyter.org/) or with a Jupyter installation with the [Dyalog Jupyter kernel](https://github.com/Dyalog/dyalog-jupyter-kernel). These will reside in the [Jupyter] folder.

### Audience
We hope that this project will appeal to physical science, computing and mathematics students and teachers; researchers in physics and materials science, and those using molecular dynamics in particular; and of course the APL and array programming communities.

### Scope
As it stands, this project only contains a proof-of-concept for a simple Lennard-Jones melt velocity Verlet simulation. We hope the accompanying code explanations and comparative speed tests will show that APL is suitable as a rapid-development tool with the added benefit of tolerable computation speed.

### Repository branches
The [master](https://github.com/rikedyp/APLPhys/tree/master) branch will contain code which aims to be semantically clear with regards to the procedure of the simulations.  
The [faster](https://github.com/rikedyp/APLPhys/tree/faster) branch will contain code which is rewritten to be more computationally efficient.

### Future
We hope to expand this project to include other computational simulation models, initially inspired by the LAMMPS gamut. There is also the potential to use APL for processing experimental data, perhaps in combination with Microsoft Office Excel (and perhaps libre office?).

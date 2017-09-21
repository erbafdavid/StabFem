# StabFem

## General description of the project

StabFem is a set of programs to perform Global Stability calculations in Fluid Mechanics, which is developed 
for both research and education purposes.

The project is based on two softwares :

- The finite-element software FreeFem++ is used to generate the meshes, construct the operators
and solve the various linear problems involved in the computation.

- Matlab is used as a driver to monitor the computations in terminal or script mode and as a graphical interface to plot the results.


The kind of computation currently implemented comprises :
- Computation of a base flow (steady solution of Navier-Stokes equations) in a given geometry.
- Simple computation of eigenvalue/eigenmodes
- Interactive exploration of the spectrum
- Adjoint eigenmodes and structural sensitivity
- Computation of amplitude equations through weakly nonlinear development 
- (...)

The kind of geometry handled comprises :
- axisymmetric geometry (bluff body, jet through a hole, etc..)
- 2D geometry (flow around a cylinder, etc...)


## Example

Here is an example of the sequence of commands you should type in a Matlab terminal (or in a Matlab script)
to compute the leading eigenmode for Re=100.

```
bf = FreeFem_Init('Mesh.edp'); % initialize a mesh/baseflow
Re = 100;
bf = FreeFem_BaseFlow(bf,Re) % compute baseflow with Newton iteration
bf = FreeFem_Adapt(bf);      % adapts the mesh
m=1;shift=-0.1549 + 5.343i;
[ev,em] = FreeFem_Stability(bf,'m',m,'shift',shift,'nev',1) % computes one eigenmode
plotFF(em,’ux1.re’) % plots the real part of the axial velocity component of the eigenmode
```

## How to install and use this software ?

- If you just want to install the current stable version, simply type the following command in terminal 
(after making sure the git command is available on your system)

```
git clone https://github.com/erbafdavid/StabFem
```


- If you want to participare to the project you should create a git account (...)


## Motivation

As a growing number of teams in different countries, I’ve been using FreeFem++ for several years
to perform global stability calculations in fluid mechanics. This means in a first step computing a 
« base flow » by solving the Steady Navier-Stokes equations (by Netwon iteration) in a given geometry, 
and in a second step looking for eigenvalues/eigenmodes by solving the linearised unsteady NS equations. 
After these two main steps may come a number of variants (adjoint, structural sensititity, weakly nonlinear developments…)

After experimenting several ways to monitor the calculations and post-process the results 
(all in a single FreeFem script, modular programs, bash scripts, etc…)  I ended up designing a matlab interface 
to do all from a script or from a console in interactive mode. 


## Stable version (branch master)

At the moment, the demonstrator works for the wake of axisymetrical bluff bodies (disks, spheres,…) 
but it will be easy to adapt it to 2D objects (cylinders, etc..).
check out the two scripts in the directory  EXAMPLES :
- SCRIPT_Lshape.edp -> demonstation of the data exchange format and plotting.  
- SCRIPT_DiskIntube.edp -> stability (and much more !) for a simple test-case
of a disk in a pipe)

Note that the plotting part of the interface is based on a previous package FreeFem2Matlab
written by Julien Dambrine and deposited on mathworks. This latter uses the pdeplot 
command from pdetools library, and I don’t know an alternative with octave/scilab.



## History :
Developped by D. Fabre in june 2017, incorporating a number of FreeFem sources from 
J. Tchoufag, P. Bonnefis, J. Mougel, V. Citro and many other students and collegues.

Initially uploaded on GitHub with help of Alexei Stukov on july 7, 2017. 



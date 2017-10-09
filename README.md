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
bf = SF_Init('Mesh.edp'); % initialize a mesh/baseflow
Re = 100;
bf = SF_BaseFlow(bf,'Re',Re) % compute baseflow with Newton iteration
bf = Sf_Adapt(bf);      % adapts the mesh
m=1;shift=-0.1549 + 5.343i;
[ev,em] = SF_Stability(bf,'m',m,'shift',shift,'nev',1) % computes one eigenmode
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




## Current Status 

The software is still under development. At the moment, the included cases are the following :

# CYLINDER : 

Study of the Bénard-Von Karman instability for Re>47 in the wake of a cylinder. This directory contains scripts performing the base flow computation, linear stability analysis, adjoint and sensitivity analysis, as well as a nonlinear determination of the limit cycle using "harmonic balance" method.

# Example_DISK_IN_PIPE

An example in axisymmetric coordinates : flow around a disk within a pipe. This directory contains a demonstrator of the software which performs the stability analysis, displays the spectrum, allows to click on eigenvalues to plot the corresponding eigenmodes, computes instability branches (eigenvalue as function of Re), and performs the weakly nonlinear analysis of the leading instability (steady, non-axisymmetric).


# Example_Lshape

A simple example to demonstrate the matlab/FreeFem exchange data format for a simple problem

# SPHERE_WORK

(under development ; may not work)

# BIRDCALL

(under work ; may not work due to recent changes in the nomenclature. If interested, get branch "Version2.0" instead of branch "Master").
 


## Planned developments.


In near future we plan to incorporate the following cases :

# CYLINDER_VIV
Study of the vortex-induced vibrations around a spring-mounted cylinder.

#  STRAINED_BUBBLE
equilibrium shape and oscillation modes of a bubble within a uniaxial straining flow.


At longer term, a translation of the Software in python is under reflection.



## Authors :

The Matlab part of the software is by D. Fabre (2017).

The FreeFem part incorporates a number of sources from J. Tchoufag, P. Bonnefis, J. Mougel, V. Citro 
and many other students and collegues.

Note that the plotting part of the interface is based on a previous package FreeFem2Matlab
written by Julien Dambrine and deposited on mathworks. This latter uses the pdeplot 
command from pdetools library, and I don’t know an alternative with octave/scilab.

Initially uploaded on GitHub with help of Alexei Stukov on july 7, 2017. 





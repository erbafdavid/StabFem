# StabFem

## *Latest news (20/06/2018)*

*The project is currently in rapid progress. Here are the latest novelties:*

- A research paper advertising the software was just submitted to Rev. Appl. Mech. [See here:](https://github.com/erbafdavid/StabFem/blob/master/ARTICLE_STABFEM/ARTICLE_ASME_Submitted.pdf)
- Writing a documentation is in progress. [See here:](https://github.com/erbafdavid/StabFem/blob/master/99_Documentation/main.pdf)
- The graphical interface has been modified to replace pdetools/pdeplots by the alternative (and freeware) pdeplot2dff, 
- Compatibility with Octave is now supported ! Test-cases "EXAMPLE_Lshape", "CYLINDER" and "ROTATING_POLYGONS" are successful. (a few points still may have to be fixed in other cases) 
- Compatibility with windows 10 is now (check test-cases "EXAMPPLES_Lshape", "CYLINDER" and "POROUSDISK")
- DNS will soon be possible with StabFem :)

## General description of the project

StabFem is a set of programs to perform Global Stability calculations in Fluid Mechanics, which is developed 
for both research and education purposes.

The project is multi-system (linux, macOS, Windows), and based on two softwares :

- The finite-element software FreeFem++ is used to generate the meshes, construct the operators
and solve the various linear problems involved in the computation.

- Matlab/Octave is used as a driver to monitor the computations in terminal or script mode and as a graphical interface to plot the results.

The classes of problems currently integrated are as follows:
- Incompressible flows around fixed objets and/or through conduits,
- Incompressible flows around bodies in solid-body motion (spring-mounted of in free motion),
- Linear acoustics,
- Compressible flows around fixed bodies
- Free surface problems (oscillation of bubbles and liquid bridges, bathtub vortices, etc..)

The kind of computations currently implemented comprises :
- Computation of a base flow (steady solution of Navier-Stokes equations) in a given geometry.
- Simple computation of eigenvalue/eigenmodes
- Interactive exploration of the spectrum
- Adjoint eigenmodes and structural sensitivity
- Harmonic balance approach to describe oscillation cycles in the nonlinear regime. 
- Direct numerical simulation (to be integrated soon...)

The geometries have to be 2D or axisymmetric.


## Example

Here is an example of the sequence of commands you should type in a Matlab terminal (or in a Matlab script)
to compute the leading eigenmode for Re=100.

```
run('../SOURCES_MATLAB/SF_Start.edp'); % set the global variables (path names, etc...) for stabfem
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

- If you want to participare to the project the recommended procedure will be as follows :
1/ Create a github account (e.g. github/tartempion)
2/ Do a "fork" of the project on the github. This will create a copy of the full repository on the github site, (e.g. http://github.com/tartempion/StabFem)
3/ in a terminal type "git clone http://github.com/tartempion/StabFem" .
This will import the whole project on your computer in a directory synchronized with the github site.
You will then be able to manage your own version of the project using git commands such as "git commit", "git push", etc...
4/ when suitable you can merge your fork of the project with the main one using "pull request".



### Instalation remarks :

To run properly the software you should previously install matlab (or Octave) and FreeFem++ on you system.
Then, the only system-dependent adaptation should be the definition of the variable ff in the file SOURCES_MATLAB/SF_Start.m.

With most linux and mac systems this should be :

```
ff = '/usr/local/bin/FreeFem++ -v 0';
```

With Windows 10 systems this should be :
```
ff = 'FreeFem++';
```


Note that with Ubuntu 18 there is a little issue with the library libstdc++.so.6 which is not where Matlab looks for it
(see Instalationnotes.md for a simple solution to this problem) 



## Test-cases currently implemented :

The software is still under development. At the moment, the included cases are the following :

- CYLINDER : 

Study of the Bénard-Von Karman instability for Re>47 in the wake of a cylinder. This directory contains scripts performing the base flow computation, linear stability analysis, adjoint and sensitivity analysis, as well as a nonlinear determination of the limit cycle using "harmonic balance" method.

- DISK_IN_PIPE :

An example in axisymmetric coordinates : flow around a disk within a pipe. This directory contains a demonstrator of the software which performs the stability analysis, displays the spectrum, allows to click on eigenvalues to plot the corresponding eigenmodes, computes instability branches (eigenvalue as function of Re), and performs the weakly nonlinear analysis of the leading instability (steady, non-axisymmetric).

- LiquidBridge :

An example with a free surface : computation of the equilibrium shape of a liquid bridge and of the oscillation modes of this bridge (in the inviscid, potential case).

(see Chireux et al., Phys. Fluids 2015 for details on this case)  

(NB This case is operational but the way the curvature is computed is not optimal and should be improved...)

- POROUS_ROTATING_DISK

Flow over/across a porous disk. Work in progress.

- SQUARE_CONFINED

flow in a pipe with a square object. Work in progress.

- Example_Lshape :

A simple example to demonstrate the matlab/FreeFem exchange data format for a simple problem

### Test-cases currently not operational :

The next cases may not be operational with the present version and need to be updated to run with the latest version of StabFem.

- SPHERE_WORK :

(under development ; may not work)

- BIRDCALL :

(under work ; may not work due to recent changes in the nomenclature. If interested, get branch "Version2.0" instead of branch "Master").
 
- CYLINDER_VIV :
Study of the vortex-induced vibrations around a spring-mounted cylinder.

- STRAINED_BUBBLE :

Equilibrium shape and oscillation modes of a bubble within a uniaxial straining flow.





## Authors :

The Matlab part of the software is by D. Fabre (2017).

The FreeFem part incorporates a number of sources from J. Tchoufag, P. Bonnefis, J. Mougel, V. Citro, F. Giannetti, O. Marquet, and many other students and collegues.

The plotting part of the interface uses the function pdeplot2dff (alternative to pdeplot and fully compatible with Octave) developped by [Chloros](https://github.com/samplemaker/freefem_matlab_octave_plot). 

At longer term, a translation of the Software in python is under reflection.

Initially uploaded on GitHub with help of Alexei Stukov on july 7, 2017. 







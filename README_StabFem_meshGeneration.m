#############

Rules for mesh construction to use GlobalMesh

the interface requires two files :

mesh.msh 
	-> mesh description in FreeFem format

mesh.mshinfo
	-> auxiliary file providing description of the case
	example 
	
---	
Mesh for a sphere
PROBLEM TYPE :
AxiXR
PARAMETERS : 
R  	Xmin 	Xmax 	Rmax
0.5 -20		60		20
---

on line 3 the keyword will allow to select the newton/stability solvers according to the case considered
cases already implemented :

AxiXR -> axisymmetric base flow in (X-R) coordinates (sphere, disk, whistle)


Cases expected in next versions :

AxiXRComplex -> axi. base flow with complex coordinate mapping (Raffaele ?)


AxiBUBBLE -> axisymmetric , with deformable surface (Paul ?)

2D	-> 2D case (Cylinder, etc...)

AxiXR_Mobile -> free bodies (Joël)

(....)


##########

Rules for numbering of boundaries 


1 -> Inlet ; dirichlet condition for Ux
		variants : 	11 dirichlet for base flow ; Neumann for stability (whistle)	
					12 impedance (?)
					
2-> WALL
		variants : 21,22,23 if several walls needs to be distinguished
		
3-> OUTLET

4 ?

5 -> symmetry plane ?

6 -> symmetry axis in X/R setting

7 -> stress-free ?

8 -> deformable free surface ? (paul ?)
			

StabFem

Collection of matlab drivers for global stability programs written in FreeFem++.

Version 2.2,  D. Fabre, june 2017, 

Incorporating Freefem++ sources from J. Tchoufag, J. Mougel, R. Longobardi, etc..

Based on FreeFem2Matlab for echanging files.


main functions : 

baseflow = FreeFem_Init('mesh.edp') 
	-> to create a mesh and base-flow guess 
	
baseflow = FreeFem_BaseFlow(baseflow,Re) 
	-> to compute the base flow with Newton iteration

baseflow = FreeFem_Adapt(baseflow) 
	-> to adapt the mesh 
		(variant : [baseflow,eigenmode] = FreeFem_Adapt(baseflow,eigenmode) 

[ev,eigenmode] = FreeFem_Stability(baseflow,Re,m,shift,nev)
	-> to compute nev eigenvalue/eigenvectors using arpack or shift-invert
		(variant :[ev,eigenmode] = FreeFem_Stability(baseflow,Re,m,shift,nev,'A') for adjoint
	
In version 2.0 the programs work only for axisymmetric base flows (sphere, whistling jets, etc...)
	it is planned to include 2D cases , etc.. in future versions.


this directory contains two self-contained examples :

    SCRIPT_DiskInTube.m
   	Test case of a thick disk in a tube
    Choice '1' will allow to select the modes you want to plot by just clicking !
    
    SCRIPT_Sphere.m
    -> Test case of a sphere
	(see Meliga et al.; Tchoufag et al.; Citro et al.; etc...)     

	To adapt for other cases, please check 'README_meshGeneration.m' for explanations
	about the way to generate the mesh, label numbering, etc..

    Enjoy !
    
   
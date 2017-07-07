
FreeFem to matlab 
collection of functions to plot Freefem results through matlab (requires the toolbox pdetools)


Adapted from a version by J. Dambrime (2010) from mathworks
improved using structure syntax.
D. Fabre, may 2017

main functions : 
importFFmesh
-> creates a structure containing the mesh geometry and characteristics

importFFdata
-> imports data generated from Freefem.
Allows to import several quantities (as specificed in header) which may comprise :
   - real scalars (ex. Reynolds number)
   - complex scalars (ex. eigenvalue)
   - real-valued P1 fields (ex. base flow)
   - complex-valued P1 fields (ex. eigenmode components)
   - (to be implemented : 1D fields defined on a boundary)


plotFF
-> tool to plot fields (based on pdeplot)


this directory contains a self-contained example :
    SCRIPT_Lshaped.m
    -> basic example for the heat equation on a L-shaped domain
        
    
    Enjoy !
% File to print VTK 

path = '/home/jsagg/Sources/StabFem/CompressibleCylinder/WORK/'; % path of the VTK folder
file = 'SCMode_1_1.vtk'; % name of the VTK file
field = 'p'; % The field to be plotted u,p,T,rho
typeField = 'S'; % Scalar (S), or vector (X), (Y) or (Z) component

system(['python EigenModePlot.py ',path,' ',file,' --opt_field ',field, ...
    ' --opt_typeField ', typeField]);


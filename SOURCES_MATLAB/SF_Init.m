function baseflow = SF_MeshInit(meshfile,problemtype)
% Matlab/FreeFem driver for generating initial mesh and base flow
%
% usage : [baseflow,eigenmode] = SF_Init('Mesh.edp')
% 
% 'Mesh.edp' must be a FreeFem script which generates a file "mesh.msh" and
% initial base flow "BaseFlow_Guess.txt".
%
% Version 2.0 by D. Fabre ,  june 2017

global ff ffdir ffdatadir sfdir verbosity

[status,result]=system(['mkdir ' ffdatadir ]); 
system(['rm ' ffdatadir '*.txt ' ffdatadir '*.ff2m ' ffdatadir '*.msh ']);
[status,result]=system(['mkdir ' ffdatadir '/BASEFLOWS']); 
[status,result]=system(['rm ' ffdatadir '/BASEFLOWS/*']); 


%[status,result]= system([ff,' ',ffdir,meshfile]);
command = [ff,' ',meshfile];
error = 'ERROR : Freefem not working (path may be wrong, change variable ff in script)';
mysystem(command,error);

   
if(nargout==1)
mesh = importFFmesh('mesh.msh');
[status,result]=system(['cp mesh.msh ' ffdatadir '/mesh_init.msh']); 
[status,result]=system(['cp BaseFlow_guess.txt ' ffdatadir 'BASEFLOWS/BaseFlow_init.txt']); 
mesh.namefile=[ ffdatadir 'BASEFLOWS/mesh_init.msh'];
baseflow=importFFdata(mesh,'BaseFlow.ff2m');
baseflow.namefile = [ ffdatadir 'BASEFLOWS/BaseFlow_init.txt'];
disp(['      ### INITIAL MESH CREATED WITH np = ',num2str(mesh.np),' points']);

system(['rm ' ffdatadir 'Eigenmode_guess.txt']);

end
    
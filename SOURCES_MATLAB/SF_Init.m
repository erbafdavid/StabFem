function baseflow = SF_Init(meshfile,parameters)
% Matlab/FreeFem driver for generating initial mesh and base flow
%
% usage in one-input mode : baseflow = SF_Init('Mesh.edp')
%
% usage in two-input mode : baseflow = SF_Init('Mesh.edp',params)
%   in this case params is an array containing the parameters needed by the
%   freefem script ;  for instance the dimensions of the mesh  
%
% 'Mesh.edp' must be a FreeFem script which generates a file "mesh.msh",
% a description file "mesh.ff2m", a parameter file "SF_Init.ff2m", and an initial base flow "BaseFlow_init.txt" / "BaseFlow_init.ff2m" 
%
% Version 2.0 by D. Fabre ,  june 2017

global ff ffdir ffdatadir sfdir verbosity

if(exist(ffdatadir)~=7&&exist(ffdatadir)~=5)
    mymake(ffdatadir);
else
	myrm([ffdatadir '*.txt ' ffdatadir '*.ff2m ' ffdatadir '*.msh ']);
end

if(exist([ffdatadir 'BASEFLOWS'])~=7)
    mymake([ffdatadir 'BASEFLOWS']);
end
myrm([ffdatadir 'BASEFLOWS/*']);

if(nargin==1)
    command = [ff,' ',meshfile];
else
    command = ['echo  ' parameters ' | ',ff,' ',meshfile];
end

error = 'ERROR : SF_Init not working ! \n Possible causes : \n 1/ your "ff" variable is not correctly installed (check SF_Start.m) ; \n 2/ Your Freefem++ script is bugged (try running it outside the Matlab driver) ';
mysystem(command,error);

   
if(nargout==1)
mesh = importFFmesh('mesh.msh');
mycp('mesh.msh',[ffdatadir '/mesh_init.msh']);
mycp('BaseFlow_guess.txt',[ffdatadir 'BASEFLOWS/BaseFlow_init.txt']);
mesh.namefile=[ ffdatadir 'BASEFLOWS/mesh_init.msh'];
baseflow=importFFdata(mesh,'BaseFlow.ff2m');
baseflow.namefile = [ ffdatadir 'BASEFLOWS/BaseFlow_init.txt'];
disp(['      ### INITIAL MESH CREATED WITH np = ',num2str(mesh.np),' points']);

% myrm([ffdatadir 'Eigenmode_guess.txt']);

end
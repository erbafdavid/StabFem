function mesh = SF_Mesh(meshfile,varargin)
% StabFem Driver for generating initial mesh 
% 
% usage in one-input mode : mesh = SF_Mesh('Mesh.edp')
%
% usage in two-input mode : baseflow = SF_Init('Mesh.edp','Params',[Param1 Param2 ...])
%   in this case Params is an array containing the parameters (reals) needed by the
%   freefem script ;  for instance Reynolds number, wavenumber, etc... 
%
% 'Mesh.edp' must be a FreeFem script which generates a file "mesh.msh",
% a description file "mesh.ff2m", a geometrical parameter file "SF_Init.ff2m"
%
% Copyright D. Fabre , latest revision  june 2018
% This function is part of the StabFem project distributed under gnu licence 3. 


 global ff ffdir ffdatadir sfdir verbosity

if(exist(ffdatadir)~=7&&exist(ffdatadir)~=5)
    mymake([ffdatadir]);
else
    myrm([ffdatadir '*.txt ' ffdatadir '*.ff2m ' ffdatadir '*.msh ']);
end

% if(exist([ffdatadir 'BASEFLOWS'])~=7)
%    mysystem(['mkdir ' ffdatadir 'BASEFLOWS']); 

 % Optional parameters
  
 %p = inputParser;
%addParameter(p,'Params',NaN);
%parse(p,varargin{:})
 Params = 'NaN';
 numvarargs = length(varargin);
 if(numvarargs==2&&strcmp(lower(varargin{1}),'params'))
    Params = varargin{2};
 end

myrm([ffdatadir 'BASEFLOWS/*']);

if((Params)==NaN)
    command = [ff,' ',meshfile];
else
    stringparam = []; 
    for pp = Params;
        stringparam = [stringparam, num2str(pp), '  ' ]; 
    end
    command = ['echo ', stringparam, '  | ',ff,' ',meshfile];
end

error = 'ERROR : SF_Mesh not working ! \n Possible causes : \n 1/ your "ff" variable is not correctly installed (check SF_Start.m) ; \n 2/ Your Freefem++ script is bugged (try running it outside the Matlab driver) ';
mysystem(command,error);

% copy the mesh in directory ffdatadir
mesh.filename=[ ffdatadir 'mesh.msh'];
%mycp('mesh.msh', mesh.filename);
%mycp('mesh.ff2m', [ffdatadir 'mesh.ff2m']); 
%mycp('SF_Init.ff2m', [ffdatadir 'SF_Init.ff2m']); 

mesh = importFFmesh('mesh.msh');

mydisp(1,['      ### INITIAL MESH CREATED WITH np = ',num2str(mesh.np),' points']);
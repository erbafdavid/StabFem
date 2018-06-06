function mesh = SF_Mesh(meshfile,varargin)
% Matlab/FreeFem driver for generating initial mesh 
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
% Version 2.0 by D. Fabre ,  june 2017

p = inputParser;
addParameter(p,'Params',NaN);
parse(p,varargin{:})

 global ff ffdir ffdatadir sfdir verbosity
% 
% if(exist(ffdatadir)~=7&&exist(ffdatadir)~=5)
%     mysystem(['mkdir ' ffdatadir ]); 
% else
%     mysystem(['rm ' ffdatadir '*.txt ' ffdatadir '*.ff2m ' ffdatadir '*.msh '],'skip');
% end
% 
% %if(exist([ffdatadir 'BASEFLOWS'])~=7)
% %    mysystem(['mkdir ' ffdatadir 'BASEFLOWS']); 
% %end
% mysystem(['rm ' ffdatadir 'BASEFLOWS/*'],'skip'); 
% 

if((p.Results.Params)==NaN)
    command = [ff,' ',meshfile];
else
    stringparam = []; 
    for pp = p.Results.Params;
        stringparam = [stringparam, num2str(pp), '  ' ]; 
    end
    command = ['echo   ', stringparam, '  | ',ff,' ',meshfile];
end

error = 'ERROR : SF_Mesh not working ! \n Possible causes : \n 1/ your "ff" variable is not correctly installed (check SF_Start.m) ; \n 2/ Your Freefem++ script is bugged (try running it outside the Matlab driver) ';
mysystem(command,error);

   
% copy the mesh in directory ffdatadir
mesh.filename=[ ffdatadir 'mesh.msh'];
mycp('mesh.msh', mesh.filename);
mycp('mesh.ff2m', [ffdatadir 'mesh.ff2m']); 
mycp('SF_Init.ff2m', [ffdatadir 'SF_Init.ff2m']); 


mesh = importFFmesh('mesh.msh');

   


mydisp(1,['      ### INITIAL MESH CREATED WITH np = ',num2str(mesh.np),' points']);
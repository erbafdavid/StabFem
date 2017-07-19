function baseflow = FreeFem_MeshInit(meshfile,problemtype)
% Matlab/FreeFem driver for generating initial mesh and base flow
%
% usage : [baseflow,eigenmode] = FreeFem_Adapt(baseflow,eigenmode)
%
% with only one input argument the adaptation will be done only on base
% flow.
%
% with two input arguments the adaptation will be done on base flow and
% eigenmode structure.
%
%
% Version 2.0 by D. Fabre ,  june 2017

global ff ffdir ffdatadir sfdir verbosity

[status,result]=system(['mkdir ' ffdatadir ]); 
[status,result]=system(['mkdir ' ffdatadir '/CHBASE']); 
[status,result]=system(['rm ' ffdatadir '/CHBASE/*']); 


%[status,result]= system([ff,' ',ffdir,meshfile]);
command = [ff,' ',meshfile];
error = 'ERROR : Freefem not working (path may be wrong, change variable ff in script)';
mysystem(command,error);

%    if(status~=0) 
 %       result
 %       error('ERROR : Freefem not working (path may be wrong, change variable ff in script)');
 %       
 %   else
  %      disp('FreeFem : initial mesh successfully created');
  %  end
   
if(nargout==1)
mesh = importFFmesh('mesh.msh');
[status,result]=system(['cp mesh.msh ' ffdatadir '/CHBASE/mesh_init.msh']); 
[status,result]=system(['cp chbase_guess.txt ' ffdatadir '/CHBASE/chbase_init.txt']); 
mesh.namefile=[ ffdatadir '/CHBASE/mesh_init.msh'];
baseflow=importFFdata(mesh,'chbase.ff2m');
baseflow.namefile = [ ffdatadir '/CHBASE/chbase_init.txt'];
disp(['      ### INITIAL MESH CREATED WITH np = ',num2str(mesh.np),' points']);

end
    
function fffield = SF_MeshStretch(fffield, varargin)
%
% This is part of StabFem Project, D. Fabre, July 2017 -- present
% Matlab driver for StretchMesh
%
% Usage : 1/ (for fress surface problems)
%   ffmesh = SF_MeshStretch(ffmesh,[opt,val])
%         2/ for base-flow associated problems
%   bf = SF_MeshStretch(bf,[opt,val])

%
% The mesh will be stretched in both X(R) and Y(Z) directions. 
% Note that the resulting mesh is not necessarily an equilibrium shape ! use
%

global ff ffdir ffdatadir sfdir verbosity

% Interpreting parameters
p = inputParser;
addParameter(p, 'Xratio', 1);
addParameter(p, 'Yratio', 1);
addParameter(p, 'Xmin', 0);
addParameter(p, 'Ymin', 0);
parse(p, varargin{:});


if(strcmpi(fffield.datatype,'mesh'))
    ffmesh = fffield;
else
    ffmesh = fffield.mesh;
end

% designation of the adapted mesh
if(isfield(ffmesh,'meshgeneration'))
     meshgeneration = ffmesh.meshgeneration+1;
else
    meshgeneration = 1;
    disp('WARNING : no mesh generation in SF_MeshStretch');
end
designation = ['_stretch',num2str(meshgeneration)];
% this desingation will be added to the names of the mesh/BF files

mycp(ffmesh.filename, [ffdatadir, 'mesh_guess.msh']); % position mesh file
command = ['echo ', num2str(p.Results.Xratio), ' ', num2str(p.Results.Yratio), ' ', num2str(p.Results.Xmin), ' ', num2str(p.Results.Ymin),  ' | ', ff, ' ', ffdir, 'MeshStretch.edp'];
errormsg = 'ERROR : FreeFem MeshStretch aborted';
status = mysystem(command, errormsg);
mycp('WORK/mesh_guess.msh',[ffdatadir,'MESHES/mesh',designation,'.msh']);
mycp('WORK/mesh_guess.ff2m',[ffdatadir,'MESHES/mesh',designation,'.ff2m']);
ffmesh = importFFmesh([ffdatadir,'MESHES/mesh',designation,'.msh']);
ffmesh.generation = meshgeneration;


if(strcmpi(fffield.datatype,'mesh'))
    % first argument was a mesh ; then result is also the mesh
    fffield=ffmesh;
    
else
    % first argument was a baseflow ; then baseflow will be recomputed
    fffield.mesh=ffmesh;
     mydisp(2,' SF_Adapt : recomputing base flow');
    baseflowNew  = SF_BaseFlow(fffield, 'type', 'POSTADAPT'); 
     if (baseflowNew.iter > 0)
     fffield = baseflowNew; 
     mycp([ffdatadir, 'BaseFlow.txt'],  [ffdatadir, 'MESHES/BaseFlow', designation, '.txt']);
     mycp([ffdatadir, 'BaseFlow.ff2m'], [ffdatadir, 'MESHES/BaseFlow', designation, '.ff2m']);   
     fffield.filename = [ffdatadir, 'MESHES/BaseFlow', designation, '.txt'];
     myrm([ffdatadir '/BASEFLOWS/*']); % after adapt we clean the "BASEFLOWS" directory as the previous baseflows are no longer compatible
     mycp([ffdatadir, 'BaseFlow.txt'],  [ffdatadir, 'BASEFLOWS/BaseFlow_Re',num2str(fffield.Re),'.txt']);
     mycp([ffdatadir, 'BaseFlow.ff2m'],  [ffdatadir, 'BASEFLOWS/BaseFlow_Re',num2str(fffield.Re),'.ff2m']);
     else
         error('ERROR in SF_Adapt : baseflow recomputation failed');
     end
end


end
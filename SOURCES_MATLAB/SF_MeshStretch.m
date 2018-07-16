function ffmesh = SF_MeshStretch(ffmesh, Xratio, Yratio)
%
% This is part of StabFem Project, D. Fabre, July 2017 -- present
% Matlab driver for SplitMesh
%
% Usage : ffmesh = SF_MeshStretch(ffmesh,Xratio,Yratio)
%
% The mesh will be stretched in both X(R) and Y(Z) directions. Note that
% the resulting mesh is not necessarily an equilibrium shape ! use
%


global ff ffdir ffdatadir sfdir verbosity

mycp(ffmesh.filename, [ffdatadir, 'mesh_guess.msh']); % position mesh file
command = ['echo ', num2str(Xratio), ' ', num2str(Yratio), ' | ', ff, ' ', ffdir, 'MeshStretch.edp'];
error = 'ERROR : FreeFem MeshStretch aborted';
status = mysystem(command, error);
ffmesh = importFFmesh([ffdatadir, 'mesh_guess.msh']);
end
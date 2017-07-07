function [baseflow,eigenmode] = FreeFem_Adapt(baseflow,eigenmode)
% Matlab driver for Adapting Mesh 
%
% usage : [baseflow,eigenmode] = FreeFem_Adapt(baseflow,eigenmode)
%
% with only one input argument the adaptation will be done only on base
% flow.
%
% with two input arguments the adaptation will be done on base flow and
% eigenmode structure.
%
% The base flow (and if specified the eigenmode) will be recomputed on
% adapted mesh
%
% Version 1.2 by D. Fabre , 2 june 2017

global ff ffdir ffdatadir


if(nargin==1&&nargout&&1)
    % adapt to base flow
    [status]=system([ff,' ',ffdir,'Adapt_Axi.edp']);
    disp(['FreeFem :  ADAPT mesh to base flow for Re = ' num2str(baseflow.Re) ])
   
    
elseif(nargin>=2)
    % adapt to both base flow and eigenmode (or forced structure)
    [status]=system([ff,' ',ffdir,'Adapt_UVWP.edp < Eigenmode.txt']);
    disp(['FreeFem : ADAPT mesh to base flow and mode for Re =' num2str(baseflow.Re) ])
    
else
    error('ERROR in FreeFem_Adapt : wrong number or input/outout arguments')
end


    % clean 'CHBASE' directory to avoid mesh/baseflow incompatibilities
    system(['rm ' ffdatadir '/CHBASE/chbase_Re*']);

    % recomputing base flow after adapt
    mesh = importFFmesh('mesh.msh');
    mesh.namefile=[ffdatadir '/CHBASE/mesh_adapt_Re' num2str(baseflow.Re) '.msh'];
    baseflow.mesh=mesh;
    baseflow = FreeFem_BaseFlow(baseflow,baseflow.Re);
    baseflow.namefile = [ ffdatadir '/CHBASE/chbase_Re' num2str(baseflow.Re) '.txt'];
    
    system(['cp mesh.msh ' ffdatadir '/CHBASE/mesh_adapt_Re' num2str(baseflow.Re) '.msh']);
    system(['cp chbase.txt ' ffdatadir '/CHBASE/chbase_adapt_Re' num2str(baseflow.Re) '.txt']);
   
   % system(['cp chbase.txt ' ffdatadir '/CHBASE/chbase_Re' num2str(baseflow.Re) '.txt']);
    
     if(nargout==2&&nargin==2)
        [ev,eigenmode]=FreeFem_Stability(baseflow,baseflow.Re,eigenmode.m,eigenmode.sigma,1);
     end
    
end
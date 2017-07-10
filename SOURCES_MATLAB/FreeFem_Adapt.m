function [baseflow,eigenmode] = FreeFem_Adapt(baseflow,eigenmode)
% 
% This is part of StabFem Project, version 2.1, D. Fabre, July 2017
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
% Version 2.1 by D. Fabre, 2 july 2017

global ff ffdir ffdatadir

system('cp mesh.msh mesh_ans.msh');
system('cp chbase.txt chbase_ans.txt');

if(nargin==1&&nargout&&1)
    % adapt to base flow
    [status]=system([ff,' ',ffdir,'Adapt_Axi.edp']);
    if(status~=0)  
        error('ERROR : FreeFem adaptmesh aborted');
    else
    	disp(['FreeFem :  ADAPT mesh to base flow for Re = ' num2str(baseflow.Re) ])
    end
    
elseif(nargin>=2)
    % adapt to both base flow and eigenmode (or forced structure)
    [status]=system([ff,' ',ffdir,'Adapt_UVWP.edp < Eigenmode.txt']);
     if(status~=0)  
        error('ERROR : FreeFem adaptmesh aborted');
    else
    disp(['FreeFem : ADAPT mesh to base flow and mode for Re =' num2str(baseflow.Re) ])
    end
else
    error('ERROR in FreeFem_Adapt : wrong number or input/outout arguments')
end
   
   
    % recomputing base flow after adapt
    system('cp mesh_adapt.msh mesh.msh'); 
	system('cp chbase_adaptguess.txt chbase_guess.txt');
    baseflowNew = baseflow; % initialise structure
    baseflowNew.mesh=importFFmesh('mesh.msh');
    baseflowNew = FreeFem_BaseFlow(baseflowNew,baseflow.Re,'NEW');
    if(exist('chbase.txt')==2)
		%  Newton successful : store base flow
		baseflow=baseflowNew;
		baseflow.mesh.namefile=[ffdatadir '/CHBASE/mesh_adapt_Re' num2str(baseflow.Re) '.msh'];
    	system(['cp chbase.txt ' ffdatadir '/CHBASE/chbase_adapt_Re' num2str(baseflow.Re) '.txt']);
    	baseflow.namefile = [ ffdatadir '/CHBASE/chbase_Re' num2str(baseflow.Re) '.txt'];
    	system(['cp mesh.msh ' ffdatadir '/CHBASE/mesh_adapt_Re' num2str(baseflow.Re) '.msh']);
    	 % clean 'CHBASE' directory to avoid mesh/baseflow incompatibilities
    	 system(['rm ' ffdatadir '/CHBASE/chbase_Re*']); 
         system(['cp chbase.txt ' ffdatadir '/CHBASE/chbase_Re' num2str(baseflow.Re) '.txt']);%except last one...`
         system(['cp chbase.ff2m ' ffdatadir '/CHBASE/chbase_Re' num2str(baseflow.Re) '.ff2m']);%except last one...
    	 if(nargout==2&&nargin==2)
        	[ev,eigenmode]=FreeFem_Stability(baseflow,baseflow.Re,eigenmode.m,eigenmode.sigma,1);
         end
   	else % Newton has probably diverged : revert to previous mesh/baseflow
 		system('mv mesh_ans.msh mesh.msh');
 		system('mv chbase_ans.txt chbase_guess.txt');
        error(' ERROR in FreeFem_Adapt : recomputing base flow failed, going back to baseflow/mesh') 
    end
        system('rm mesh_ans.msh chbase_ans.txt');
end
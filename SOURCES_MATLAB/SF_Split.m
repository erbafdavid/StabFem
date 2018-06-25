function baseflow = SF_Split(baseflow)
% 
% This is part of StabFem Project, D. Fabre, July 2017 -- present
% Matlab driver for SplitMesh 
%
% Usage : baseflow = SF_Split(baseflow)
%
% The mesh will be refined by splitting each triangles in four triangles.
% The base flow will be recomputed on the adapted mesh
%


global ff ffdir ffdatadir sfdir verbosity


        mycp([ffdatadir 'Eigenmode.txt'],[ffdatadir 'AdaptField.txt']);
        command = [ff,' ',ffdir,'SplitMesh.edp'];
        error = 'ERROR : FreeFem adaptmesh aborted';
        status=mysystem(command,'skip');
    
    
    if(status~=0)
        mymv([ffdatadir 'mesh_ans.msh'],[ffdatadir 'mesh.msh']);
        mymv([ffdatadir 'BaseFlow_ans.txt'],[ffdatadir 'BaseFlow.txt']);
        mymv([ffdatadir 'BaseFlow_ans.txt'],[ffdatadir 'BaseFlow_guess.txt']);
        error(' ERROR in SF_Split : recomputing base flow failed, going back to baseflow/mesh')
    end
%    meshnp = importFFmesh('mesh_adapt.msh','nponly'); // old version to
%    discard this and correct soon
     
 meshinfo = importFFdata(baseflow.mesh,'mesh.ff2m');
     disp(['      ### SPLIT MESH : ']);
  
    disp(['      #   Number of points np = ',num2str(meshinfo.np), ...
        ' ; Ndof = ', num2str(meshinfo.Ndof)]);
    disp(['      #  deltamin, deltamax : ',num2str(meshinfo.deltamin), ' , ',...
        num2str(meshinfo.deltamax)]);    
 
   
   
    % recomputing base flow after adapt
    
    baseflowNew = baseflow; % initialise structure
    baseflowNew.mesh=importFFmesh([ffdatadir 'mesh.msh']);
    
    baseflowNew = SF_BaseFlow(baseflowNew,'Re',baseflow.Re,'type','NEW');
    
     
    
    if(baseflowNew.iter>0)
		%  Newton successful : store base flow
		baseflow=baseflowNew;
		baseflow.mesh.namefile=[ffdatadir '/BASEFLOWS/mesh_adapt_Re' num2str(baseflow.Re) '.msh'];
    	mycp(['BaseFlow.txt'],[ffdatadir '/BASEFLOWS/BaseFlow_adapt_Re' num2str(baseflow.Re) '.txt']);
        baseflow.namefile = [ ffdatadir '/BASEFLOWS/BaseFlow_Re' num2str(baseflow.Re) '.txt'];
    	mycp(['mesh.msh'],[ffdatadir '/BASEFLOWS/mesh_adapt_Re' num2str(baseflow.Re) '.msh']);
        % clean 'BASEFLOWS' directory to avoid mesh/baseflow incompatibilities
         myrm([ffdatadir '/BASEFLOWS/BaseFlow_Re*']);
         mycp(['BaseFlow.txt'],[ffdatadir '/BASEFLOWS/BaseFlow_Re' num2str(baseflow.Re) '.txt']);
    	 mycp(['BaseFlow.ff2m'],[ffdatadir '/BASEFLOWS/BaseFlow_Re' num2str(baseflow.Re) '.ff2m']);
       
   	else % Newton has probably diverged : revert to previous mesh/baseflow
        mymv([ffdatadir 'mesh_ans.msh'],[ffdatadir 'mesh.msh']);
        mymv([ffdatadir 'BaseFlow_ans.txt'],[ffdatadir 'BaseFlow_guess.txt']);
        error(' ERROR in SF_Adapt : recomputing base flow failed, going back to baseflow/mesh') 
    end
        %myrm([ffdatadir 'mesh_ans.msh ',ffdatadir 'BaseFlow_ans.txt']);
end
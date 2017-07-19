function baseflow = FreeFem_BaseFlow(baseflow,Re,opt) 
% Matlab/FreeFem driver for Base flow calculation (Newton iteration)
%
% usage : baseflow = FreeFem_BaseFlow(baseflow1,Re)
%
% this driver will lanch the Freefem "Newton" program of the coresponding
% case. NB if base flow was already created it simply copies it from
% "CHASE" directory.
%
% 		NB if for some reason the mesh/baseflow compatibility was lost, use FreeFem_BaseFlow(baseflow,Re,'PREV') 
%	    to recontstruct the structures and reposition the files correctly.
% 
%       similarly to force recomputation even in the case a file exists (for instance just after adaptmesh) use 
%        FreeFem_BaseFlow(baseflow,Re,'NEW')
%
% Version 2.0 by D. Fabre , june 2017
% 
% In future developements we should put a "parse" parameters selector, for
% instance for the Mach number in compressible cases


global ff ffdir ffdatadir sfdir verbosity


%%% SELECTION OF THE SOLVER TO BE USED DEPENDING ON THE CASE
if(strcmp(baseflow.mesh.problemtype,'AxiXR')==1)
            % Newton calculation for axisymmetric base flow
            solvercommand = ['echo ' num2str(Re) ' | ',ff,' ',ffdir,'Newton_Axi.edp'];  
        elseif(strcmp(baseflow.mesh.problemtype,'2D')==1)
            solvercommand = ['echo ' num2str(Re) ' | ',ff,' ',ffdir,'Newton_2D.edp']; 
        % elseif (other cases...)
        
        end
        error = 'ERROR : FreeFem base flow computation aborted';

        
%%% Selection of what to do according to the parameters
 if ((nargin==3)&&(strcmp(opt,'PREV')==1))
    % recover base flow from previous adapted case 
    disp(['FUNCTION FreeFem_BaseFlow : recovering previous adapted mesh/baseflow for Re = ', num2str(Re)]);
    file = [ ffdatadir '/CHBASE/chbase_adapt_Re' num2str(Re) '.txt' ];
         system(['cp ' file ' chbase_guess.txt']);
    file = [ ffdatadir '/CHBASE/mesh_adapt_Re' num2str(Re) '.msh' ];
         system(['cp ' file ' mesh.msh']);
    mysystem(solvercommand,error); %needed to generate .ff2m file
    mesh = importFFmesh('mesh.msh');
    mesh.namefile=[ffdatadir '/CHBASE/mesh_adapt_Re' num2str(baseflow.Re) '.msh'];
    baseflow.mesh=mesh;
    baseflow.iter=0;
    
 elseif(exist([ ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.txt'])==2&&nargin==2)   
        disp(['FUNCTION FreeFem_BaseFlow : base flow already computed for Re = ', num2str(Re)]);
        system(['cp ' ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.txt  chbase.txt']);
        system(['cp ' ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.txt  chbase_guess.txt']);
        system(['cp ' ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.ff2m chbase.ff2m']);
        baseflow.iter=0;
        
 else
   %      
        if(verbosity>0)disp(['FUNCTION FreeFem_BaseFlow : computing base flow for Re = ', num2str(Re)]);end
%        system(['cp ' baseflow.namefile ' chbase_guess.txt']);
        

        %%%
        mysystem(solvercommand,error);  %%% CALL NEXTON SOLVER
        %%%
        
        if(exist('chbase.txt')==0);
          error('ERROR : FreeFem base flow computation did not converge');
        end
        
        system(['cp chbase.txt ' ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.txt']);
        system(['cp chbase.ff2m ' ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.ff2m']);
%        system(['cp chbase.txt chbase_guess.txt']);    
 end

 if(nargout==1)
               baseflow = importFFdata(baseflow.mesh,['chbase.ff2m']); 
               baseflow.namefile = [ ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.txt'];
        end
 
 
if(baseflow.iter>1)
    message = ['      ### Base flow for Re = ' num2str(Re), ' ; converged in ',num2str(baseflow.iter),' iterations '];
    if(isfield(baseflow,'Drag')==1) %% adding drag information for blunt-body wake
        message = [message , '; Drag = ',num2str(baseflow.Drag)];
    if(isfield(baseflow,'deltaP0')==1) %% adding pressure drop information for jet flow
        message = [message , '; deltaP0 = ',num2str(baseflow.deltaP0)];
    end
 disp(message);
else
 disp(['      ### Base flow recovered from previous computation for Re = ' num2str(Re)]);   
end
%if(nargout==1)
%baseflow = importFFdata(baseflow.mesh,['chbase.ff2m']);
%baseflow.namefile = [ ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.txt'];
%end

end


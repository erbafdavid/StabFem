function baseflow = FreeFem_BaseFlow(baseflow,varargin) 
% Matlab/FreeFem driver for Base flow calculation (Newton iteration)
%
% usage : baseflow = FreeFem_BaseFlow(baseflow1,'Re',Re,[...])
%
% this driver will lanch the Freefem "Newton" program of the coresponding
% case. NB if base flow was already created it simply copies it from
% "CHASE" directory.
%
%  Other syntax : baseflow = FreeFem_BaseFlow(baseflow1,Re) (kept for compatibility but to be abandonned in future versions)  
%
% 		NB if for some reason the mesh/baseflow compatibility was lost, use FreeFem_BaseFlow(baseflow,'Re',Re,'type','PREV') 
%	    to recontstruct the structures and reposition the files correctly.
% 
%       similarly to force recomputation even in the case a file exists (for instance just after adaptmesh) use 
%        FreeFem_BaseFlow(baseflow,'Re',Re,'type','NEW')
%
% Version 2.0 by D. Fabre , september 2017
% 



global ff ffdir ffdatadir sfdir verbosity

%%% management of optionnal parameters
if(nargin~=2) % recommended syntax with parameter selector
    p = inputParser;
   addParameter(p,'Re',baseflow.Re,@isnumeric);
   addParameter(p,'type','Normal',@ischar);
   parse(p,varargin{:});
   Re = p.Results.Re;
else % old syntax with two inputs
   p.Results.Re = varargin{1};
   p.Results.type = 'Normal';
   Re =  varargin{1};
end



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
 if (strcmp(p.Results.type,'PREV')==1)
    % recover base flow from previous adapted case 
    disp(['      ### FUNCTION FreeFem_BaseFlow : recovering previous adapted mesh/baseflow for Re = ', num2str(Re)]);
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
        if(verbosity>0)disp(['      ### FUNCTION FreeFem_BaseFlow : computing base flow for Re = ', num2str(Re)]);end
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
    message = ['      # Base flow converged in ',num2str(baseflow.iter),' iterations '];
    if(isfield(baseflow,'Drag')==1) %% adding drag information for blunt-body wake
        message = [message , '; Drag = ',num2str(baseflow.Drag)];
    end    
    if(isfield(baseflow,'Lx')==1) %% adding drag information for blunt-body wake
        message = [message , '; Lx = ',num2str(baseflow.Lx)];
    end
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


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
%       similarly to force recomputation even in the case a file exists (for instance just after adaptemesh) use 
%        FreeFem_BaseFlow(baseflow,Re,'NEW')
%
% Version 2.0 by D. Fabre , june 2017


global ff ffdir ffdatadir

%[status]= system(['echo ' num2str(Re) ' | ',ff,' ',ffdir,'Newton_Axi.edp']);

 if ((nargin==3)&&(strcmp(opt,'PREV')==1))
    % recover base flow from previous adapted case 
    disp(['FUNCTION FreeFem_BaseFlow : recovering previous adapted mesh/baseflow for Re = ', num2str(Re)]);
    file = [ ffdatadir '/CHBASE/chbase_adapt_Re' num2str(Re) '.txt' ]
         system(['cp ' file ' chbase_guess.txt']);
    file = [ ffdatadir '/CHBASE/mesh_adapt_Re' num2str(Re) '.msh' ]
         system(['cp ' file ' mesh.msh']);
    [status]= system(['echo ' num2str(Re) ' | ',ff,' ',ffdir,'Newton_Axi.edp']); %needed to generate .ff2m file
    mesh = importFFmesh('mesh.msh');
    mesh.namefile=[ffdatadir '/CHBASE/mesh_adapt_Re' num2str(baseflow.Re) '.msh'];
    baseflow.mesh=mesh;
    
 elseif(exist([ ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.txt'])==2&&nargin==2) %&&(strcmp(opt,'NEW')~=1)); %UGLY
    
        disp(['FUNCTION FreeFem_BaseFlow : base flow already computed for Re = ', num2str(Re)]);
        system(['cp ' ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.txt  chbase.txt']);
        system(['cp ' ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.txt  chbase_guess.txt']);
        system(['cp ' ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.ff2m chbase.ff2m']);

        
    else
        disp(['FUNCTION FreeFem_BaseFlow : computing base flow for Re = ', num2str(Re)]);
%        system(['cp ' baseflow.namefile ' chbase_guess.txt']);
        
        if(strcmp(baseflow.mesh.problemtype,'AxiXR')==1)
            % Newton calculation for axisymmetric base flow
            [status]= system(['echo ' num2str(Re) ' | ',ff,' ',ffdir,'Newton_Axi.edp']);    
        elseif(strcmp(baseflow.mesh.problemtype,'2D')==1)
            % Newton calculation for 2D flow ; who wants to implement this ?
        % elseif (other cases...)
        end
        
        if(status~=0)  
            error('ERROR : FreeFem base flow computation aborted');
        elseif(exist('chbase.txt')==0);
            error('ERROR : FreeFem base flow computation did not converge');
        else
            disp(['FreeFem : base flow successfully computed for Re = ' num2str(Re) ])
        end
        
        system(['cp chbase.txt ' ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.txt']);
        system(['cp chbase.ff2m ' ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.ff2m']);
        
         
 end

   
if(nargout==1)
            baseflow = importFFdata(baseflow.mesh,['chbase.ff2m']); 
            baseflow.namefile = [ ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.txt'];
end
            
 
    

%if(nargout==1)
%baseflow = importFFdata(baseflow.mesh,['chbase.ff2m']);
%baseflow.namefile = [ ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.txt'];
%end

end


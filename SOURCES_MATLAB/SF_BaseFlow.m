function baseflow = SF_BaseFlow(baseflow,varargin) 
% Matlab/SF_ driver for Base flow calculation (Newton iteration)
%
% usage : baseflow = SF_BaseFlow(baseflow1,'Re',Re,[...])
%
% this driver will lanch the "Newton" program of the coresponding
% case. NB if base flow was already created it simply copies it from
% "BASEFLOW" directory.
%
%
% 		NB if for some reason the mesh/baseflow compatibility was lost, use SF__BaseFlow(baseflow,'Re',Re,'type','PREV') 
%	    to recontstruct the structures and reposition the files correctly.
% 
%       similarly to force recomputation even in the case a file exists (for instance just after adaptmesh) use 
%        SF__BaseFlow(baseflow,'Re',Re,'type','NEW')
%
% Version 2.0 by D. Fabre , september 2017
% 

global ff ffMPI ffdir ffdatadir sfdir verbosity

%%% MANAGEMENT OF PARAMETERS (Re, Mach, Omegax, Porosity...)
% Explanation
% (Mode 1) if parameters are transmitted to the function we use these ones. 
%      (for instance baseflow = SF_BaseFlow(baseflow1,'Re',10)
% (Mode 2) if no parameters are passed and if the field exists in the previous
% baseflow, we take these
%      (for instance SF_BaseFlow(bf) is equivalent to SF_Baseflow(bf,'Re',bf.Re) )
% (Mode 3) if no previous value we will define default values set in the next lines.
%
% This syntax allows to do baseflow=SF_BaseFlow(baseflow) which is useful
% for instance to recompute the baseflow after mesh adaptation.
%
% Parameters currently handled comprise : Re, Omegax, Porosity. 
% usage of Parameter 'type' is to be rationalized...



% check if fields previously exist (Mode 2) or assign default value (mode 3)
if(isfield(baseflow,'Darcy')) 
    Darcy = baseflow.Darcy; 
else
    Darcy = 0; 
end

if(isfield(baseflow,'Porosity')) 
    Porosity = baseflow.Porosity; 
else
    Porosity = 0; 
end

if(isfield(baseflow,'Omegax')) 
    Omegax = baseflow.Omegax; 
else
    Omegax = 0; 
end

%%% check which parameters are transmitted to varargin (Mode 1) 
   p = inputParser;
   addParameter(p,'Re',baseflow.Re,@isnumeric); % Reynolds

   if(isfield(baseflow,'Ma')) MaDefault = baseflow.Ma ; else MaDefault = 0.01; end;
   addParameter(p,'Mach',MaDefault,@isnumeric); % Reynolds
   
   addParameter(p,'Omegax',Omegax,@isnumeric); % rotation rate (for swirling body)
   addParameter(p,'Darcy',Darcy,@isnumeric); % For porous body
   addParameter(p,'Porosity',Porosity,@isnumeric); % For porous body 2
   addParameter(p,'type','Normal',@ischar); % mode 
   addParameter(p,'ncores',1,@isnumeric); % number of cores to launch the sim
   parse(p,varargin{:});
   
% Now the right parameters are in p.Results   
   Re = p.Results.Re;
   Ma = p.Results.Mach
   Omegax = p.Results.Omegax;
   Darcy = p.Results.Darcy;
   Porosity=p.Results.Porosity;
   ncores = p.Results.ncores % By now only for the 2D compressible


%%% SELECTION OF THE SOLVER TO BE USED DEPENDING ON THE CASE

switch(baseflow.mesh.problemtype)

    case ('AxiXR')
            % Newton calculation for axisymmetric base flow
                if(verbosity>1)  disp('## solving base flow (axisymmetric case)'); end
                    solvercommand = ['echo ' num2str(Re) ' | ',ff,' ',ffdir,'Newton_Axi.edp']; 
 
    case('AxiXRPOROUS') % axisymmetric WITH SWIRL
               if(verbosity>1)  disp('## solving base flow (axisymmetric case WITH SWIRL)'); end
                    solvercommand = ['echo ' num2str(Re) ' ' num2str(p.Results.Omegax) ' ' num2str(p.Results.Darcy) ' ' num2str(p.Results.Porosity) ' | ',ff,' ',ffdir,'Newton_AxiSWIRL.edp']   
          
    case('2D')
            if(verbosity>1)  disp('## solving base flow (2D CASE)'); end
            solvercommand = ['echo ' num2str(Re) ' | ',ff,' ',ffdir,'Newton_2D.edp'];
            
    case('2DComp')
            if(verbosity>1)  disp('## solving base flow (2D CASE COMPRESSIBLE)'); end

            solvercommand = ['echo ' num2str(Re) ' ' num2str(p.Results.Mach) ' | ',ffMPI,' -np ',num2str(ncores),' ','Newton_2D_Comp.edp'];         
              %NB at the moment the script is in the local folder, it is to be joined in ffdir in due time 

              % REMARK : 'Newton_2D_Comp.edp' (mpi parallel version) works best but we have to find how to pass the parameters ! 
              
   % case (other cases...)
        
end %switch

error = 'ERROR : SF_ base flow computation aborted';
        
%%% Selection of what to do according to the parameters
 if (strcmp(p.Results.type,'PREV')==1)
    % recover base flow from previous adapted case 
    disp(['      ### FUNCTION SF_BaseFlow : recovering previous adapted mesh/baseflow for Re = ', num2str(Re)]);
    file = [ ffdatadir '/BASEFLOWS/BaseFlow_adapt_Re' num2str(Re) '.txt' ];
         mycp(file,[ffdatadir 'BaseFlow_guess.txt']);
    file = [ ffdatadir '/BASEFLOWS/mesh_adapt_Re' num2str(Re) '.msh' ];
         mycp(file,[ffdatadir 'mesh.msh']);
    mysystem(solvercommand,error); %needed to generate .ff2m file
    mesh = importFFmesh('mesh.msh');
    mesh.namefile=[ffdatadir '/BASEFLOWS/mesh_adapt_Re' num2str(baseflow.Re) '.msh'];
    baseflow.mesh=mesh;
    baseflow = importFFdata(baseflow.mesh,'BaseFlow.ff2m'); 
    baseflow.namefile = [ ffdatadir 'BASEFLOWS/BaseFlow_Re' num2str(Re) '.txt'];
    baseflow.iter=0;
    
 elseif(exist([ ffdatadir '/BASEFLOWS/BaseFlow_Re' num2str(Re) '.txt'])==2&&strcmp(p.Results.type,'NEW')~=1)   
        disp(['FUNCTION SF_BaseFlow : base flow already computed for Re = ', num2str(Re)]);
        mycp([ffdatadir '/BASEFLOWS/BaseFlow_Re' num2str(Re) '.txt'],[ffdatadir 'BaseFlow.txt']);
        mycp([ffdatadir '/BASEFLOWS/BaseFlow_Re' num2str(Re) '.txt'],[ffdatadir 'BaseFlow_guess.txt']);
        mycp([ffdatadir '/BASEFLOWS/BaseFlow_Re' num2str(Re) '.ff2m'],[ffdatadir 'BaseFlow.ff2m']);
%         mysystem(solvercommand,error) %%%%%%%%%%%%%%%%%%%%%%%%%
        baseflow = importFFdata(baseflow.mesh,[ffdatadir 'BaseFlow.ff2m']); 
        baseflow.namefile = [ ffdatadir 'BASEFLOWS/BaseFlow_Re' num2str(Re) '.txt'];
        baseflow.iter=0;
        
 else
        if(verbosity>0)disp(['      ### FUNCTION SF__BaseFlow : computing base flow for Re = ', num2str(Re)]);end
%         mycp(baseflow.namefile,'BaseFlow_guess.txt');
        

        %%%
        mysystem(solvercommand,error);  %%% CALL NEXTON SOLVER
        %%%
        
        if(exist([ffdatadir,'BaseFlow.txt'])==0);
          error('ERROR : SF_ base flow computation did not converge');
        end
        

if(strcmp(baseflow.mesh.problemtype,'2DComp')
%% to be rationalised
        system(['cp ' ffdatadir 'BaseFlow.txt ' ffdatadir 'BASEFLOWS/BaseFlow_Re' num2str(Re) 'Ma' num2str(Ma) '.txt']);
        system(['cp ' ffdatadir 'BaseFlow.ff2m ' ffdatadir 'BASEFLOWS/BaseFlow_Re' num2str(Re) 'Ma' num2str(Ma) '.ff2m']);
else
        mycp([ffdatadir 'BaseFlow.txt'],[ffdatadir 'BASEFLOWS/BaseFlow_Re' num2str(Re) '.txt']);
        mycp([ffdatadir 'BaseFlow.txt'],[ffdatadir 'BaseFlow_guess.txt']);
        mycp([ffdatadir 'BaseFlow.ff2m'],[ffdatadir 'BASEFLOWS/BaseFlow_Re' num2str(Re) '.ff2m']);
end

         baseflow = importFFdata(baseflow.mesh,'BaseFlow.ff2m'); 
         baseflow.namefile = [ ffdatadir 'BASEFLOWS/BaseFlow_Re' num2str(Re) 'Ma' num2str(Ma) '.txt'];
        
 end

 
              
 
 
if(baseflow.iter>=1)
    message = ['      # Base flow converged in ',num2str(baseflow.iter),' iterations '];
    if(isfield(baseflow,'Fx')==1) %% adding drag information for blunt-body wake
        message = [message , '; Fx = ',num2str(baseflow.Fx)];
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
%baseflow = importFFdata(baseflow.mesh,['BaseFlow.ff2m']);
%baseflow.namefile = [ ffdatadir '/BaseFlow/BaseFlow_Re' num2str(Re) '.txt'];
%end

end


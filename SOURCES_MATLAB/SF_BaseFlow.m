function baseflow = SF_BaseFlow(baseflow,varargin) 
% StabFem wrapper for Base flow calculation (Newton iteration)
%
% usage : baseflow = SF_BaseFlow(baseflow1,['Param1',Value1,...])
%
% this wrapper will lanch the "Newton" FreeFem++ program of the corresponding
% case. NB if base flow was already created it simply copies it from
% "BASEFLOW" directory (unless if specified differently by parameter 'Type').
%
% List of valid parameters :
%   Re          Reynolds number 
%   Ma          Mach number (for compressible cases)
%   Omegax      Rotation rate (for swirling axisymetric or 2D body)
%   Darcy       Darcy number (for cases with porous body)
%   Porosity    Porosity (for cases with porous body)
%   Type        'Normal' (default) ;  'NEW' to force new computation ; 'PREV' if connection was lost (obsolete ?) 
%   ncores      Number of cores (for parallel computations)
%
% SF IMPLEMENTATION : 
% According to parameters, this wrapper will launch one of the following FreeFem++ solvers :
%       'Newton_Axi.edp'
%       'Newton_AxiSWIRL.edp'
%       'Newton_2D.edp'
%       'Newton_2D_Comp.edp'
%
% 		NB if for some reason the mesh/baseflow compatibility was lost, use SF_BaseFlow(baseflow,'Re',Re,'type','PREV') 
%	    to recontstruct the structures and reposition the files correctly.
%       similarly to force recomputation even in the case a file exists (for instance just after adaptmesh) use 
%        SF__BaseFlow(baseflow,'Re',Re,'type','NEW')
% This syntax allows to do baseflow=SF_BaseFlow(baseflow) which is useful
% for instance to recompute the baseflow after mesh adaptation.
%
% This program is part of the StabFem project distributed under gnu licence. 
% Copyright D. Fabre, 2017-2018.
%

global ff ffMPI ffdir ffdatadir sfdir verbosity

% MANAGEMENT OF PARAMETERS (Re, Mach, Omegax, Porosity...)
% Explanation
% (Mode 1) if parameters are transmitted to the function we use these ones. 
%      (for instance baseflow = SF_BaseFlow(baseflow1,'Re',10)
% (Mode 2) if no parameters are passed and if the field exists in the previous
% baseflow, we take these values
%      (for instance SF_BaseFlow(bf) is equivalent to SF_Baseflow(bf,'Re',bf.Re) )
% (Mode 3) if no previous value we will define default values set in the next lines.

   p = inputParser;
   if(isfield(baseflow,'Re')) ReDefault = baseflow.Re ; else ReDefault = 2; end;
   addParameter(p,'Re',ReDefault,@isnumeric); % Reynolds

   if(isfield(baseflow,'Ma')) MaDefault = baseflow.Ma ; else MaDefault = 0.01; end;
   addParameter(p,'Mach',MaDefault,@isnumeric); % Mach
   
   if(isfield(baseflow,'Omegax')) OmegaxDefault = baseflow.Omegax;  else OmegaxDefault = 0; end
   addParameter(p,'Omegax',OmegaxDefault,@isnumeric); % rotation rate (for swirling body)
   
   if(isfield(baseflow,'Darcy')) DarcyDefault = baseflow.Darcy; else DarcyDefault = 0; end
   addParameter(p,'Darcy',DarcyDefault,@isnumeric); % For porous body
   
   if(isfield(baseflow,'Porosity')) PorosityDefault = baseflow.PorosityDefault; else PorosityDefault = 0.95;  end
   addParameter(p,'Porosity',PorosityDefault,@isnumeric); % For porous body too
   
   addParameter(p,'type','Normal',@ischar); % mode type 
   addParameter(p,'ncores',1,@isnumeric); % number of cores to launch in parallel
   
   parse(p,varargin{:});
   
% Now the right parameters are in p.Results   
   Re = p.Results.Re;
   Ma = p.Results.Mach;
   Omegax = p.Results.Omegax;
   Darcy = p.Results.Darcy;
   Porosity = p.Results.Porosity;
   ncores = p.Results.ncores;  % By now only for the 2D compressible



%%% SELECTION OF THE SOLVER TO BE USED DEPENDING ON THE CASE

switch(baseflow.mesh.problemtype)

    case('AxiXR')   % Newton calculation for axisymmetric base flow
        mydisp(1,'## solving base flow (axisymmetric case)'); 
        solvercommand = ['echo ' num2str(Re) ' | ',ff,' ',ffdir,'Newton_Axi.edp'];
        filename = [ffdatadir 'BASEFLOWS/BaseFlow_Re' num2str(Re)];
 
    case('AxiXRPOROUS') % axisymmetric WITH SWIRL
          mydisp(1,'## solving base flow (axisymmetric case WITH SWIRL)'); 
          solvercommand = ['echo ' num2str(Re) ' ' num2str(p.Results.Omegax) ' ' num2str(p.Results.Darcy) ' ' num2str(p.Results.Porosity) ' | ',ff,' ',ffdir,'Newton_AxiSWIRL.edp']   
          filename = [ffdatadir 'BASEFLOWS/BaseFlow_Re' num2str(Re) '_Omega' num2str(p.Results.Omegax) '_Da' num2str(p.Results.Darcy) '_Por' num2str(p.Results.Porosity)  ];

    case('2D')
          mydisp(1,'## solving base flow (2D INCOMPRESSIBLE)'); 
          solvercommand = ['echo ' num2str(Re) ' | ',ff,' ',ffdir,'Newton_2D.edp'];
          filename = [ffdatadir 'BASEFLOWS/BaseFlow_Re' num2str(Re)];
             
    case('2DComp')
         mydisp(1,'## solving base flow (2D COMPRESSIBLE) '); 
         solvercommand = ['echo ' num2str(Re) ' ' num2str(p.Results.Mach) ' | ',ffMPI,' -np ',num2str(ncores),' ',ffdir,'Newton_2D_Comp.edp'];         
         filename = [ffdatadir 'BASEFLOWS/BaseFlow_Re' num2str(Re) 'Ma' num2str(Ma)];
              
   % case (other cases...)
        
end %switch

error = 'ERROR : SF_ base flow computation aborted';
        
% if (strcmp(p.Results.type,'PREV')==1) OBSOLETE
% recover base flow from previous adapted case 
%    disp(['      ### FUNCTION SF_BaseFlow : recovering previous adapted mesh/baseflow for Re = ', num2str(Re)]);
%    file = [ ffdatadir '/BASEFLOWS/BaseFlow_adapt_Re' num2str(Re) '.txt' ];
%         mycp(file,[ffdatadir 'BaseFlow_guess.txt']);
%    file = [ ffdatadir '/BASEFLOWS/mesh_adapt_Re' num2str(Re) '.msh' ];
%         mycp(file,[ffdatadir 'mesh.msh']);
%    mysystem(solvercommand,error); %needed to generate .ff2m file
%    mesh = importFFmesh('mesh.msh');
%    mesh.namefile=[ffdatadir '/BASEFLOWS/mesh_adapt_Re' num2str(baseflow.Re) '.msh'];
%    baseflow.mesh=mesh;
%    baseflow = importFFdata(baseflow.mesh,'BaseFlow.ff2m'); 
%    baseflow.namefile = [ ffdatadir 'BASEFLOWS/BaseFlow_Re' num2str(Re) '.txt'];
%    baseflow.iter=0;
    
 if(exist([ filename '.txt'])==2&&strcmp(p.Results.type,'NEW')~=1)   
        disp(['FUNCTION SF_BaseFlow : base flow already computed for Re = ', num2str(Re)]);
        mycp([filename '.txt'],[ffdatadir 'BaseFlow.txt']);
%        mycp([ffdatadir '/BASEFLOWS/BaseFlow_Re' num2str(Re) '.txt'],[ffdatadir 'BaseFlow_guess.txt']);
        mycp([filename '.ff2m'],[ffdatadir 'BaseFlow.ff2m']);
%         mysystem(solvercommand,error) %%%%%%%%%%%%%%%%%%%%%%%%%
        baseflow = importFFdata(baseflow.mesh,[filename '.ff2m']); 
        baseflow.filename = [ ffdatadir 'BASEFLOWS/BaseFlow_Re' num2str(Re) '.txt'];
        baseflow.iter=0;
        
 else
        mydisp(1,['      ### FUNCTION SF_BaseFlow : computing base flow for Re = ', num2str(Re)]);
        
%  POSITION THE "GUESS" FILE 
    mycp(baseflow.filename,[ffdatadir 'BaseFlow_guess.txt']);
           
% CALL NEWTON SOLVER
     mysystem(solvercommand,error);  
        if(exist([ffdatadir,'BaseFlow.txt'])==0);
          error('ERROR : SF_ base flow computation did not converge');
        end
   

%if(strcmp(baseflow.mesh.problemtype,'2DComp'))
%% to be rationalised
%        system(['cp ' ffdatadir 'BaseFlow.txt ' ffdatadir 'BASEFLOWS/BaseFlow_Re' num2str(Re) 'Ma' num2str(Ma) '.txt']);
%        system(['cp ' ffdatadir 'BaseFlow.ff2m ' ffdatadir 'BASEFLOWS/BaseFlow_Re' num2str(Re) 'Ma' num2str(Ma) '.ff2m']);
%else
%        mycp([ffdatadir 'BaseFlow.txt'],[ffdatadir 'BASEFLOWS/BaseFlow_Re' num2str(Re) '.txt']);
%        mycp([ffdatadir 'BaseFlow.txt'],[ffdatadir 'BaseFlow_guess.txt']);
%        mycp([ffdatadir 'BaseFlow.ff2m'],[ffdatadir 'BASEFLOWS/BaseFlow_Re' num2str(Re) '.ff2m']);
%end
    
    mycp([ffdatadir 'BaseFlow.txt'],[filename '.txt']);
%        mycp([ffdatadir 'BaseFlow.txt'],[ffdatadir 'BaseFlow_guess.txt']);
    mycp([ffdatadir 'BaseFlow.ff2m'],[filename '.ff2m']);

         baseflow = importFFdata(baseflow.mesh,'BaseFlow.ff2m'); 
         baseflow.filename = [filename '.txt'];
        
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
    mydisp(2,message);
else
 disp(['      ### Base flow recovered from previous computation for Re = ' num2str(Re)]);   
end


end


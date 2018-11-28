function varargout = SF_Stability(baseflow,varargin)


%> StabFem wrapper for Eigenvalue calculations
%>
%> usage : 
%> 1/  [eigenvalues,eigenvectors] = SF_Stability(field, [,param1,value1] [,param2,value2] [...])
%> 2/  [eigenvalues,sensitivity,evD,evA,Endo] = SF_Stability(field,'type','S','nev',1, [...])
%> 3/  [eigenvalues,Endogeneity,evD,evA] = SF_Stability(field,'type','E','nev',1, [...])
%>
%> field is either a "baseflow" structure (with "mesh" structure as a subfield) 
%> or directly a "mesh" structure (for instance in problems such as sloshing where baseflow is not relevant).
%>
%> Output :
%> eigenvalues -> array containing the eigenvalues
%> eigenvector -> array of struct objects containing the eigenvectors.
%> [sensitivity,evD,evA,Endo] -> sensitivity, direct and adjoint eigenmodes and endogeneity (with type = 'S' and nev = 1)
%> 
%> List of accepted parameters (in approximate order of usefulness):
%>
%>  1/ geometrical parameters
%>
%>   m :         Azimuthal wavenumer (for axisymmetric problem) (def. 1)
%>   k :         Transverse wavenumber (for 3D stability of 2D flow) (def. 0)
%>   sym :       Symmetry condition for a 2D problem  (def. 'A')
%>               (set to 'S' for symmetric, 'A' for antisymmetric, or 'N' if no symmetry plane is present)
%> 
%>  2/ Numerical parameters of the solver
%>    
%>   shift :     shift for shift-invert algorithm.
%>               value can be either a numerical value (complex), 'prev' to use previously computed eigenvalue, 
%>               or 'cont' to use extrapolated value from two previous computations. 
%>               (obviously 'prev' and 'cont' cannot be used at first call to this function).
%>   nev :       requested number of eigenvalues
%>               (the solver will use Arnoldi method if nev>1 and shift-invert if nev=1)
%>   type :      'D' for direct problem (default) ; 'A' for ajoint problem ; 'DA' for discrete adjoint 
%>   solver :    Alternative solver 
%>               In this case the program will use an alternative ff solver
%>               (e.g. myStab2D.edp instead of Stab2D.edp)
%>               Useful in developpment/debugging mode ; the alternative
%>               solver has to use the same input parameters is the standard.
%>
%>  3/ Physical parameters
%>
%>     Many options here, chose the ones relevant to your case)
%>     NB : in some cases the values will be automatically picked from the
%>     base flow (or mesh) object. But warning this is not done systematically
%>     
%>   Re :        Reynolds number (specify only if it differs from the one of base flow, which is not usual)
%>   STIFFNESS : For spring-mounted object
%>   MASS :      For spring-mounted object
%>   DAMPING :   For spring-mounted object
%>   gamma :     Surface tension (for free-surface problems)
%>   rhog :      gravity parameter (for free-surface problems)
%>   nu :        viscosity (for free-surface problems)
%>   GammaBAR :  circulation (for potential problems)
%>   alphaMILES :parameter modelling contact line dissipation (linear model of Miles & Hocking ) 
%> 
%>  4/ Post-processing options 
%> 
%>   sort :      how to sort the eigenvalues if nev>1. Accepted values :
%>               'LR' (largest real), 'SR' (smallest real), ,'SM' (smallest magnitude), 'SI', 'SIA' (smallest absolute value of imaginary part),
%>               'cont' (sort according to proximity with previous computation; continuation mode) 
%>   PlotSpectrum : set to 'yes' to launch the spectrum explorator.
%>               This option will draw the spectrum in figure 100 and will allow to display the eigenmodes 
%>               by clicking on the corresponding eigenvalue. 
%>  PlotSpectrumField : which field to plot in the spectrum explorator. 
%>
%> STABFEM IMPLEMENTATION :
%> According to parameters, this wrapper will launch one of the following
%> FreeFem++ solvers :
%>      'Stab2D.edp'
%>      'StabAxi.edp'
%>       (list to be completed)
%>
%>
%> This program is part of the StabFem project distributed under gnu licence. 
%> Copyright D. Fabre, 2017-2018.
%>

global ff ffMPI ffdir ffdatadir sfdir verbosity

persistent sigmaPrev sigmaPrevPrev % for continuation on one branch
persistent eigenvaluesPrev % for sort of type 'cont'

myrm([ffdatadir 'Eigenmode_guess.txt']) % TODO : add parameter to put a guess file only when required



   if(strcmpi(baseflow.datatype,'Mesh')==1)
       % first argument is a simple mesh
       ffmesh = baseflow; 
       mycp(ffmesh.filename,[ffdatadir 'mesh.msh']); % this should be done in this way in the future
   else
       % first argument is a base flow
       ffmesh = baseflow.mesh;
       mycp(baseflow.filename,[ffdatadir 'BaseFlow.txt']);
       mycp(baseflow.mesh.filename,[ffdatadir 'mesh.msh']); % this should be done in this way in the future
   end
  
%% Chapter 1 : management of optionnal parameters
    p = inputParser;
  
   % parameter for most cases
    if(isfield(baseflow,'Re')) ReDefault = baseflow.Re ; else ReDefault = 0; end;
    addParameter(p,'Re',ReDefault,@isnumeric); % Reynolds
   
    % parameter for compressible cases   
   if(isfield(baseflow,'Ma')) MaDefault = baseflow.Ma ; else MaDefault = 0.01; end;
   addParameter(p,'Ma',MaDefault,@isnumeric);
   
    % parameter for Rotating Porous Case
   if(isfield(baseflow,'Omegax')) OmegaxDefault = baseflow.Omegax ; else OmegaxDefault = 0.; end;
   addParameter(p,'Omegax',OmegaxDefault,@isnumeric);
   
   if(isfield(baseflow,'Darcy')) DarcyDefault = baseflow.Darcy ; else DarcyDefault = 0.1; end;
   addParameter(p,'Darcy',DarcyDefault,@isnumeric);
   
   if(isfield(baseflow,'Porosity')) PorosityDefault = baseflow.Porosity ; else PorosityDefault = 0.95; end;
   addParameter(p,'Porosity',PorosityDefault,@isnumeric);  
   
   %parameters for spring-mounted object  
   addParameter(p,'STIFFNESS',0);
   addParameter(p,'MASS',0);
   addParameter(p,'DAMPING',0);
   
   % parameters for free-surface problems
    if(isfield(baseflow,'gamma')) gammaDefault = baseflow.gamma ;else gammaDefault = 0; end;
    addParameter(p,'gamma',gammaDefault,@isnumeric);
    if(isfield(baseflow,'rhog')) rhogDefault = baseflow.rhog ;else rhogDefault = 0; end;
    addParameter(p,'rhog',rhogDefault);
    if(isfield(baseflow,'nu')) nuDefault = baseflow.nu ;else nuDefault = 0; end;
    addParameter(p,'nu',nuDefault);
    if(isfield(baseflow,'beta')) alphaDefault = baseflow.alpha ;else alphaDefault = 0; end;
    addParameter(p,'alpha',alphaDefault);
    if(isfield(baseflow,'GammaBAR')) GammaBARDefault = baseflow.GammaBar ;else GammaBARDefault = 0; end;
    addParameter(p,'GammaBAR',GammaBARDefault);
    addParameter(p,'typestart','pined');
    addParameter(p,'typeend','pined');
    
   %symmetry paramaters for axisymmetric case
   addParameter(p,'m',1,@isnumeric);
   %symmetry parameters for 2D case
   addParameter(p,'k',0,@isnumeric);
   addParameter(p,'sym','A',@ischar);   
   
  %parameters for the eigenvalue solver
   addParameter(p,'shift',1+1i);
   addParameter(p,'nev',1,@isnumeric);
   addParameter(p,'type','D',@ischar); 
   addParameter(p,'solver','default',@ischar);
   
   %parameters for mpirun
   addParameter(p,'ncores',1,@isnumeric);
   
   % parameters for the post-processing options
   addParameter(p,'sort','no',@ischar); 
   addParameter(p,'PlotSpectrum','no',@ischar);
   addParameter(p,'PlotSpectrumField','ux1',@ischar); 
   addParameter(p,'plot','no',@ischar);
   
   parse(p,varargin{:});
   
   % parameters for continuation mode
   if(isempty(sigmaPrev))   sigmaPrev = p.Results.shift; sigmaPrevPrev = p.Results.shift; end;
   if(isempty(eigenvaluesPrev)) eigenvaluesPrev = [p.Results.nev:-1:1]; end;
   
   if(strcmp(p.Results.shift,'prev')==1)
       shift = sigmaPrev;       
       mydisp(5,['   # SHIFT from previous computation = ' num2str(shift)]); 
   elseif(strcmp(p.Results.shift,'cont')==1)      
       shift = 2*sigmaPrev-sigmaPrevPrev;      
       mydisp(5,['   # SHIFT extrapolated from two previous computations = ' num2str(shift)]); 
   elseif(isnumeric(p.Results.shift)==1);
       shift = p.Results.shift;
       mydisp(5,['   # SHIFT specified by user = ' num2str(shift)]); 
   else
       error('   # ERROR in SF_Stabilty while specifying the shift')
   end
 
   
%% Chapter 2 : select the relevant freefem script

% explanation : we will launch a command with the form 
%   echo "47 0 0.7 A D 10" | FreeFem++ Stab2D.edp
%  
% this will be slitted in the form :
%   echo "argumentstring" | "fff" "solver"
% so in each case we have to a) construct the argumentstring containing the parameters,
% b) define the fff command (usually FreeFem++ but can be FreeFem+++-mpi in some cases
%  and c) define the default solver (which can be replaced by a custom one)
%



switch ffmesh.problemtype

    case('AxiXR')
     
     mydisp(1,['      ### FUNCTION SF_Stability : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);
     mydisp(1,['      ### USING Axisymmetric Solver']);
     argumentstring = [ num2str(p.Results.Re) ' '  num2str(real(shift)) ' ' num2str(imag(shift)) ...
                          ' ' num2str(p.Results.m) ' ' p.Results.type ' ' num2str(p.Results.nev) ];
     fff = ff;               
     solver = [ffdir 'StabAxi.edp'];
%     solvercommand = ['echo ' argumentstring ' | ' ff ' ' ffdir 'StabAxi.edp'];
%     status = mysystem(solvercommand);

     case ('AxiXRCOMPLEX') 
         
     mydisp(1,['      ### FUNCTION SF_Stability : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);
     mydisp(1,['      ### USING Axisymmetric Solver WITH COMPLEX MAPPING']);
     argumentstring = [' " ' num2str(p.Results.Re) ' '  num2str(real(shift)) ' ' num2str(imag(shift)) ...
                          ' ' num2str(real(p.Results.m)) ' ' p.Results.type ' ' num2str(p.Results.nev) ' " ' ];
%     if(imag(p.Results.m)==0)
        fff = ffMPI;               
        solver = [ffdir 'StabAxi_COMPLEX.edp']; 
%        solvercommand = ['echo ' argumentstring ' | ' ffMPI ' ' ffdir 'StabAxi_COMPLEX.edp'];
%     else
%         mydisp(1,'### TRICK ### m imaginary ; we use the alternative solver for m=0'); 
%         solvercommand = ['echo ' argumentstring ' | ' ffMPI ' ' ffdir 'StabAxi_COMPLEX_m0.edp'];
%     end
     
%     status = mysystem(solvercommand);
        
    case('AxiXRPOROUS')
    
     mydisp(1,['      ### FUNCTION SF_Stability POROUS : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);
     mydisp(1,['      ### USING Axisymmetric Solver WITH POROSITY AND SWIRL']);
     argumentstring = [ num2str(p.Results.Re) ' ' num2str(baseflow.Omegax) ' ' num2str(baseflow.Darcy) ' ' num2str(baseflow.Porosity) ' '  num2str(real(shift)) ' ' num2str(imag(shift))... 
                             ' ' num2str(p.Results.m) ' ' p.Results.type ' ' num2str(p.Results.nev) ];
     fff = ff;               
     solver = [ffdir 'StabAxi_Porous.edp'];
%     solvercommand = ['echo ' argumentstring ' | ' ff ' ' ffdir 'StabAxi_Porous.edp'];
%     status = mysystem(solvercommand);        
    
 
    case('2D')
         % 2D flow (cylinder, etc...)

         if(p.Results.k==0)
            % 2D Baseflow / 2D modes
        mydisp(1,['      ### FUNCTION SF_Stability : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);
        mydisp(1,['      ### USING 2D Solver']);
        argumentstring = [ num2str(p.Results.Re) ' '  num2str(real(shift)) ' ' num2str(imag(shift))... 
                             ' ' p.Results.sym ' ' p.Results.type ' ' num2str(p.Results.nev) ];
        fff = ff;               
        solver = [ffdir 'Stab2D.edp'];
%        solvercommand = ['echo ' argumentstring ' | ' ff ' ' ffdir 'Stab2D.edp'];
%        status = mysystem(solvercommand);
        
         else 
             % 2D BaseFlow / 3D modes
                 mydisp(1,['      ### FUNCTION SF_Stability : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);
        mydisp(1,['      ### 3D Stability of 2D Base-Flow with k = ',num2str(p.Results.k)]);
        argumentstring = [num2str(p.Results.Re) ' ' num2str(p.Results.k) ' '  num2str(real(shift)) ....
            ' ' num2str(imag(shift)) ' ' p.Results.sym ' ' p.Results.type ' ' num2str(p.Results.nev) ];
        fff = ff;               
        solver = [ffdir 'Stab2D_Modes3D.edp'];                 
%        solvercommand = ['echo ' argumentstring ' | ' ff ' ' ffdir 'Stab2D_Modes3D.edp'];
%        status = mysystem(solvercommand);
         end
         
    case('AxiCompCOMPLEX')
         % AxiCompCOMPLEX flow (Whistling jet, etc...)

        % 2D Baseflow / 2D modes
        mydisp(1,['      ### FUNCTION SF_Stability : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);
        mydisp(1,['      ### USING Axi compressible COMPLEX Solver']);
        if(p.Results.sym == 'A')
            symmetry = 0;
        elseif(p.Results.sym == 'S')
            symmetry = 1;
        elseif(p.Results.sym == 'N')
            symmetry = 2;
        end
        
        if(p.Results.type == 'D')
            typeEig = 0;
        elseif(p.Results.type == 'A')
            typeEig = 1;
        elseif(p.Results.type == 'S')
            typeEig = 2;
        else
            typeEig = 0;
        end
        argumentstring = [' " ' num2str(p.Results.Re) ' ' num2str(p.Results.Ma) ' ' num2str(real(shift)) ' ' num2str(imag(shift))... 
                             ' ' num2str(symmetry) ' ' num2str(typeEig) ' ' num2str(p.Results.nev) ' " '];
        fff = [ ffMPI ];               
        solver = [ffdir 'Stab_Axi_Comp_COMPLEX.edp'];
%        solvercommand = ['echo ' argumentstring ' | ',ffMPI,' -np ',num2str(ncores),' ', 'Stab2DComp.edp'];
%        status = mysystem(solvercommand);
         
    case('2DComp')
         % 2D flow (cylinder, etc...)

            % 2D Baseflow / 2D modes
        mydisp(1,['      ### FUNCTION SF_Stability : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);
        mydisp(1,['      ### USING 2D compressible Solver']);
        if(p.Results.sym == 'A')
            symmetry = 0;
        elseif(p.Results.sym == 'S')
            symmetry = 1;
        elseif(p.Results.sym == 'N')
            symmetry = 2;
        end
        
        if(p.Results.type == 'D')
            typeEig = 0;
        elseif(p.Results.type == 'A')
            typeEig = 1;
        elseif(p.Results.type == 'S')
            typeEig = 2;
        else
            typeEig = 0;
        end
        argumentstring = [' " ' num2str(p.Results.Re) ' ' num2str(p.Results.Ma) ' ' num2str(real(shift)) ' ' num2str(imag(shift))... 
                             ' ' num2str(symmetry) ' ' num2str(typeEig) ' ' num2str(p.Results.nev) ' " '];
       % fff = [ ffMPI ' -np ',num2str(ncores) ]; does not work with FreeFem++-mpi
          fff = ffMPI ; 
        
        solver = [ffdir 'Stab2D_Comp.edp'];
%        solvercommand = ['echo ' argumentstring ' | ',ffMPI,' -np ',num2str(ncores),' ', 'Stab2DComp.edp'];
%        status = mysystem(solvercommand);
        
    case('2DMobile')
        % for spring-mounted cylinder
             
        mydisp(1,['      ### FUNCTION SF_Stability VIV : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);
        mydisp(1,['      ### USING 2D Solver FOR MOBILE OBJECT (e.g. spring-mounted)']);
        argumentstring = [ num2str(p.Results.Re) ' ' num2str(p.Results.MASS) ' ' num2str(p.Results.STIFFNESS) ' '... 
                            num2str(p.Results.DAMPING) ' ' num2str(real(shift)) ' ' num2str(imag(shift)) ' ' p.Results.sym...
                            ' ' p.Results.type ' ' num2str(p.Results.nev) ' R ']; 
        fff = ff;
        solver = [ffdir 'Stab2D_VIV.edp'];
%        solvercommand = ['echo ' argumenstring ' | ' ff ' ' ffdir 'Stab2D_VIV.edp'];
%        status = mysystem(solvercommand);
        
     case('3DFreeSurfaceStatic')
        % for oscillations of a free-surface problem (liquid bridge, hanging drops/attached bubbles, etc...)             
        if(p.Results.nu==0)
        mydisp(1,['      ### FUNCTION SF_Stability FREE SURFACE POTENTIAL : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);
        argumentstring = ['  ' num2str(p.Results.gamma) ' ' num2str(p.Results.rhog) ' ' num2str(p.Results.GammaBAR) ' '...
        num2str(p.Results.nu) ' ' num2str(p.Results.alpha) ' ' ...
        p.Results.typestart ' ' p.Results.typeend  ' ' num2str(p.Results.m) ' '... 
        num2str(p.Results.nev)  ' ' num2str(real(p.Results.shift)) ' ' num2str(imag(p.Results.shift)) ' '];
        fff = ffMPI;               
        solver = [ffdir 'StabAxi_FreeSurface_Potential.edp'];
%        solvercommand = ['echo ' argumentstring ' | ' ffMPI ' ' ffdir 'StabAxi_FreeSurface_Potential.edp'];
%        status = mysystem(solvercommand);     
        else
        mydisp(1,['      ### FUNCTION SF_Stability FREE SURFACE VISCOUS : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);
        argumentstring = [' " ' num2str(p.Results.gamma) ' ' num2str(p.Results.rhog) ' ' num2str(p.Results.nu) ...
            ' ' p.Results.typestart ' ' p.Results.typeend  ' '...
            ' ' num2str(p.Results.m) ' ' num2str(real(p.Results.shift)) ' ' num2str(imag(p.Results.shift)) ' ' num2str(p.Results.nev) ' " '];
       
        fff = ff;
        solver = [ffdir 'StabAxi_FreeSurface_Viscous.edp'];
%        solvercommand = ['echo ' argumentstring ' | ' ff ' ' ffdir 'StabAxi_FreeSurface_Viscous.edp'];
%        status = mysystem(solvercommand);  
        end
        
    %case(...)    
    % adapt to your case !
    
    case default
        error(['Error in SF_Stability : "problemtype =',ffmesh.problemtype,'  not possible or not yet implemented !'])
end


%% Chapter 3 : launch the ff solver

mydisp(1,['      ### FUNCTION SF_Stability : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);

if(strcmp(p.Results.solver,'default'))
    mydisp(1,['      ### USING STANDARD StabFem Solver ',solver]);        

else
    if(exist(p.Results.solver)==2)
        solver = p.Results.solver;
        
    elseif(exist([ffdir  p.Results.solver])==2)
           solver = [ffdir  p.Results.solver];
    else
        error(['Error : solver ',p.Results.solver, ' could not be found !']);
    end
    mydisp(1,['      ### USING CUSTOM FreeFem++ Solver ',solver]);
    if(strcmp(p.Results.solver,'StabAxi_COMPLEX_m0_nev1.edp')==1) 
        disp('NB USING ff instead of ff-mpi (VERY UGLY FIX TO OVERCOME A STRANGE BUG : otherwise shift-invert mode does not work with FreeFem++-mpi'); 
        fff = ff;
    end
end

solvercommand = ['echo ' argumentstring ' | ' fff ' ' solver ];
if(verbosity>=10)
    solvercommand
end

status = mysystem(solvercommand);

if(status~=0&&status~=141) % WARNING : error codes may differ with OCTAVE !
     %result 
     error('ERROR : FreeFem stability computation aborted');
 else
   % disp(['FreeFem : FreeFem stability computed for Re = ' num2str(p.Results.Re), ' ; m = '  num2str(p.Results.m) ' shift = ' num2str(shift) ])
  %
end



%% Chapter 4 : post-processing

if (p.Results.type=='D')
    rawData1 = importdata([ffdatadir 'Spectrum.txt']);
else
    rawData1 = importdata([ffdatadir 'Spectrum.txt']);
end

EVr = rawData1(:,1);
EVi = rawData1(:,2); 
eigenvalues = EVr+1i*EVi;

% sort eigenvalues 
%           (NB the term 1e-4 is a trick so that the sorting still
%           works when eigenvalues come in complex-conjugate pairs)
    switch(p.Results.sort)
        case('LR') % sort by decreasing real part of eigenvalue
            [t,o]=sort(-real(eigenvalues)+1e-4*abs(imag(eigenvalues)));
        case('SR') % sort by increasing real part of eigenvalue
            [t,o]=sort(real(eigenvalues)+1e-4*abs(imag(eigenvalues)));
        case('SM') % sort by increasing magnitude of eigenvalue
            [t,o]=sort(abs(eigenvalues)+1e-4*abs(imag(eigenvalues)));
        case('LM') % sort by decreasing magnitude of eigenvalue
            [t,o]=sort(-abs(eigenvalues)+1e-4*abs(imag(eigenvalues)));
        case('SI') % sort by increasing imaginary part of eigenvalue
            [t,o]=sort(imag(eigenvalues));  
        case('SIA') % sort by increasing imaginary part (abs) of eigenvalue
            [t,o]=sort(abs(imag(eigenvalues))+1e-4*imag(eigenvalues)+1e-4*real(eigenvalues));
        case('DIST') % sort by increasing distance to the shift
            [t,o]=sort(abs(eigenvalues-shift));  
        case('cont') % sort using continuation (to connect with previous branches)
            eigenvaluesSORT = eigenvalues;
            for i=1:length(eigenvalues)    
                [c index] = min(abs(eigenvaluesSORT-eigenvaluesPrev(i)));
                o(i) = index;
                eigenvaluesSORT(index)=NaN;
            end
        case('no')
            o = [1:length(eigenvalues)];
    end
    eigenvalues=eigenvalues(o);     
    eigenvaluesPrev = eigenvalues;

% updating two previous iterations
if(strcmp(p.Results.shift,'cont')==1)
sigmaPrevPrev = sigmaPrev;
sigmaPrev = eigenvalues(1);
else
sigmaPrevPrev = eigenvalues(1);
sigmaPrev = eigenvalues(1); 
end

    if(nargout>1) %% process output of eigenmodes
    if(p.Results.nev==1)
        if (p.Results.type=='D')
            eigenvectors=importFFdata(ffmesh,'Eigenmode.ff2m');
            eigenvectors.type=p.Results.type;
            iter = eigenvectors.iter;
            disp(['      # Stability calculation completed, eigenvalue = ',num2str(eigenvalues),' ; converged in ', num2str(eigenvectors.iter),' iterations']);
        elseif(p.Results.type=='A')
            eigenvectors=importFFdata(ffmesh,'EigenmodeA.ff2m');
            eigenvectors.type=p.Results.type;
            iter = eigenvectors.iter;
            disp(['      # Stability calculation completed (ADJOINT), eigenvalue = ',num2str(eigenvalues),' ; converged in ', num2str(eigenvectors.iter),' iterations']);
        elseif(p.Results.type=='S'||p.Results.type=='E')
            sensitivity=importFFdata(ffmesh,'Sensitivity.ff2m');
            iter = 1;% previous management of non convergence errors ; to be cleaned up
            if (nargout >2) 
                evD=importFFdata(ffmesh,'Eigenmode.ff2m');
                evD.type='D';
                iter = evD.iter;% previous management of non convergence errors ; to be cleaned up
            end
            if (nargout >3) 
                evA=importFFdata(ffmesh,'EigenmodeA.ff2m');
                evA.type='A';
            end
             if (p.Results.type=='E'||(nargout >4) )
            Endo=importFFdata(ffmesh,'Endogeneity.ff2m');
            Endo.type='S'; % useful ?
              mydisp(2,['  # Endogeneity successfully imported']);
             end
         end
        if(iter<0) 
            if(verbosity>1)
                error([' ERROR : simple shift-invert iteration failed ; use a better shift of use multiple mode iteration (nev>1). If you want to continue your loops despite this error (confident mode) use verbosity=1 ']);
            else
                disp([' WARNING : simple shift-invert iteration failed ; continuing despite of this. If you want to produce an error (secure mode) use verbosity>1.']);
            end
        end   
    elseif(p.Results.nev>1&&p.Results.type=='D')
    eigenvectors=[];
        for iev = 1:p.Results.nev
        egv=importFFdata(ffmesh,['Eigenmode' num2str(iev) '.ff2m']);
        egv.type=p.Results.type;
        %eigenvectors(iev) = egv;
        eigenvectors = [eigenvectors egv];
        end
        eigenvectors=eigenvectors(o);%sort the eigenvectors with the same filter as the eigenvalues
    elseif(p.Results.nev>1&&p.Results.type=='A')
    eigenvectors=[];
    for iev = 1:p.Results.nev
        egv=importFFdata(ffmesh,['EigenmodeA' num2str(iev) '.ff2m']);
        egv.type=p.Results.type;
        %eigenvectors(iev) = egv;
        eigenvectors = [eigenvectors egv];
    end
    eigenvectors=eigenvectors(o);%sort the eigenvectors with the same filter as the eigenvalues
    else
        error('ERROR');
    end
    
    end
    switch(nargout)
        case(1)
    varargout = eigenvalues;
        case(2)
             if(p.Results.type=='S')
                varargout = {eigenvalues,sensitivity};
             elseif(p.Results.type=='E')
                varargout = {eigenvalues,Endo};  
             else
                  varargout = {eigenvalues,eigenvectors}; 
             end
        case(3)
    error( 'number of output arguments not valid...' )
        case(4)
            if(p.Results.type=='S')
                varargout = {eigenvalues,sensitivity,evD,evA};  
            elseif(p.Results.type=='E')
                varargout = {eigenvalues,Endo,evD,evA};  
            end
        case(5)
            varargout = {eigenvalues,sensitivity,evD,evA,Endo}; 
    % FINALLY : plot the spectrum in figure 100
    
    if(strcmp(p.Results.PlotSpectrum,'yes')==1)
        figure(100);
        %%mycmp = [[0 0 0];[1 0 1] ;[0 1 1]; [1 1 0]; [1 0 0];[0 1 0];[0 0 1]]; %color codes for symbols
        h=plot(real(shift),imag(shift),'o');hold on;
        if(p.Results.type=='A') 
            type = 'A'; 
        else
            type = '';
        end
        for ind = 1:length(eigenvalues)
            h=plot(real(eigenvalues(ind)),imag(eigenvalues(ind)),'*');hold on;
            %%%%  plotting command for eigenmodes and callback function
            tt=['eigenmodeP= importFFdata(bf.mesh, ''' ffdatadir '/Eigenmode' type num2str(ind) '.ff2m''); ' ... 
      'plottitle =''Eigenmode for sigma = ', num2str(real(eigenvalues(ind))) ...
      ' + 1i * ' num2str(imag(eigenvalues(ind))) ' '' ; figure();'...
      'plotFF(eigenmodeP,''' p.Results.PlotSpectrumField ''',''title'',plottitle);'  ];
%   tt=['eigenmodeP= importFFdata(baseflow.mesh, ''' ffdatadir '/Eigenmode' num2str(ind) '.ff2m''); eigenmodeP.plottitle =''Eigenmode for sigma = ', num2str(real(eigenvalues(ind))) ' + 1i * ' num2str(imag(eigenvalues(ind))) ' '' ; plotFF(eigenmodeP,''' p.Results.PlotSpectrumField '''); '  ]; 
            set(h,'buttondownfcn',tt);
            ax = gca;
            ax.XAxisLocation = 'origin';
            ax.YAxisLocation = 'origin';

        end
    xlabel('\sigma_r');ylabel('\sigma_i');
    title('Spectrum (click on eigenvalue to display corresponding eigenmode)');
    end
    
   mydisp(1,'END Function SF_Stability :');  
    
end

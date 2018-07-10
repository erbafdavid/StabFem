function [eigenvalues,eigenvectors] = SF_Stability(baseflow,varargin)

% StabFem wrapper for Eigenvalue calculations 
%
% usage : [eigenvectors] = SF_Stability(field, [,param1,value1] [,param2,value2] [...])
%
% field is either a "baseflow" structure (with "mesh" structure as a subfield) 
% or directly a "mesh" structure (for instance in problems such as sloshing where baseflow is not relevant).
%
% Parameters include :
%
%   Re :        Reynolds number (specify only if it differs from the one of base flow, which is not usual)
%   m :         Azimuthal wavenumer (for axisymmetric problem)
%   k :         Transverse wavenumber (for 3D stability of 2D flow)
%   STIFFNESS : For spring-mounted object
%   MASS :      For spring-mounted object
%   DAMPING :   For spring-mounted object
%   gamma :     Surface tension (for free-surface problems)
%   rhog :      gravity parameter (for free-surface problems)
%   nu :        viscosity (for free-surface problelms)
%   sym :       Symmetry condition for a 2D problem 
%               (set to 'S' for symmetric, 'A' for antisymmetric, or 'N' if no symmetry plane is present)
%   shift :     shift for shift-invert algorithm.
%               value can be either a numerical value (complex), 'prev' to use previously computed eigenvalue, 
%               or 'cont' to use extrapolated value from two previous computations. 
%               (obviously 'prev' and 'cont' cannot be used at first call to this function).
%   nev :       requested number of eigenvalues
%               (the solver will use Arnoldi method if nev>1 and shift-invert if nev=1)
%   type :      'D' for direct problem (default) ; 'A' for ajoint problem ; 'DA' for discrete adjoint 
%   sort :      how to sort the eigenvalues if nev>1. Accepted values :
%               'LR' (largest real), 'SR' (smallest real), ,'SM' (smallest magnitude), 'SI', 'SIA' (smallest absolute value of imaginary part),
%               'cont' (sort according to proximity with previous computation; continuation mode) 
%   PlotSpectrum : set to 'yes' to launch the spectrum explorator.
%               This option will draw the spectrum in figure 100 and will allow to display the eigenmodes 
%               by clicking on the corresponding eigenvalue
%  PlotSpectrumField : which field to plot in the spectrum explorator. 
%
% STABFEM IMPLEMENTATION :
% According to parameters, this wrapper will launch one of the following
% FreeFem++ solvers :
%      'Stab2D.edp'
%      'StabAxi.edp'
%       (list to be completed)
%
% output :  eigenvalues (array of complex values) + eigenvectors (returned as a structure or an array of structures)
%
% This program is part of the StabFem project distributed under gnu licence. 
% Copyright D. Fabre, 2017-2018.
%

global ff ffMPI ffdir ffdatadir sfdir verbosity

persistent sigmaPrev sigmaPrevPrev % for continuation on one branch
persistent eigenvaluesPrev % for sort of type 'cont'

   if(isfield(baseflow,'np')==1)
       % first argument is a simple mesh
       ffmesh = baseflow; 
       mycp(ffmesh.filename,[ffdatadir 'mesh.msh']); % this should be done in this way in the future
   else
       % first argument is a base flow
       ffmesh = baseflow.mesh;
       mycp(baseflow.filename,[ffdatadir 'BaseFlow.txt']);
       mycp(ffmesh.filename,[ffdatadir 'mesh.msh']); % this should be done in this way in the future
   end
   

%%% management of optionnal parameters
    p = inputParser;
  
   % parameter for most cases
    if(isfield(baseflow,'Re')) ReDefault = baseflow.Re ; else ReDefault = 0; end;
    addParameter(p,'Re',ReDefault,@isnumeric); % Reynolds
   
    % parameter for compressible cases   
   if(isfield(baseflow,'Ma')) MaDefault = baseflow.Ma ; else MaDefault = 0.01; end;
   addParameter(p,'Ma',MaDefault,@isnumeric);
   
   %paramaters for axisymmetric case
   addParameter(p,'m',1,@isnumeric);
 
   %parameters for 2D case
   addParameter(p,'k',0,@isnumeric);
   addParameter(p,'sym','A',@ischar);   
   
   %parameters for spring-mounted object  
   addParameter(p,'STIFFNESS',0);
   addParameter(p,'MASS',0);
   addParameter(p,'DAMPING',0);
   
   % parameters for free-surface problems
    if(isfield(baseflow,'gamma')) gammaDefault = baseflow.gamma ;else gammaDefault = 0; end;
    addParameter(p,'gamma',gammaDefault,@isnumeric);
    if(isfield(baseflow,'rhog')) rhogDefault = baseflow.gamma ;else rhogDefault = 0; end;
    addParameter(p,'rhog',rhogDefault);
    if(isfield(baseflow,'nu')) nuDefault = baseflow.nu ;else nuDefault = 0; end;
    addParameter(p,'nu',nuDefault);
   
  %parameters for the eigenvalue solver
   addParameter(p,'shift',1+1i);
   addParameter(p,'nev',1,@isnumeric);
   addParameter(p,'type','D',@ischar); 
  
   %parameters for mpirun
   addParameter(p,'ncores',1,@isnumeric);
   
   % parameters for the post-processing options
   addParameter(p,'sort','no',@ischar); 
   addParameter(p,'PlotSpectrum','no',@ischar);
   addParameter(p,'PlotSpectrumField','ux1',@ischar); 
   
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
 
   
% select the relevant freefem script


switch ffmesh.problemtype

    case('AxiXR')
     
     mydisp(1,['      ### FUNCTION SF_Stability : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);
     mydisp(1,['      ### USING Axisymmetric Solver']);
     argumentstring = [ num2str(p.Results.Re) ' '  num2str(real(shift)) ' ' num2str(imag(shift)) ...
                          ' ' num2str(p.Results.m) ' ' p.Results.type ' ' num2str(p.Results.nev) ];
     solvercommand = ['echo ' argumentstring ' | ' ff ' ' ffdir 'Stab_Axi.edp'];
     status = mysystem(solvercommand);
        
        
    case('AxiXRPOROUS')
    
     mydisp(1,['      ### FUNCTION SF_Stability POROUS : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);
     mydisp(1,['      ### USING Axisymmetric Solver WITH POROSITY AND SWIRL']);
     argumentstring = [ num2str(p.Results.Re) ' ' num2str(baseflow.Porosity) ' '  num2str(real(shift)) ' ' num2str(imag(shift))... 
                             ' ' num2str(p.Results.m) ' ' p.Results.type ' ' num2str(p.Results.nev) ];
     solvercommand = ['echo ' argumentstring ' | ' ff ' ' ffdir 'Stab_Axi_Porous.edp'];
     status = mysystem(solvercommand);        
    
 
    case('2D')
         % 2D flow (cylinder, etc...)

         if(p.Results.k==0)
            % 2D Baseflow / 2D modes
        mydisp(1,['      ### FUNCTION SF_Stability : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);
        mydisp(1,['      ### USING 2D Solver']);
        argumentstring = [ num2str(p.Results.Re) ' '  num2str(real(shift)) ' ' num2str(imag(shift))... 
                             ' ' p.Results.sym ' ' p.Results.type ' ' num2str(p.Results.nev) ];
        solvercommand = ['echo ' argumentstring ' | ' ff ' ' ffdir 'Stab2D.edp'];
        status = mysystem(solvercommand);
        
         else 
             
             % 2D BaseFlow / 3D modes
                 mydisp(1,['      ### FUNCTION SF_Stability : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);
        mydisp(1,['      ### 3D Stability of 2D Base-Flow with k = ',num2str(p.Results.k)]);
        argumentstring = [num2str(p.Results.Re) ' ' num2str(p.Results.k) ' '  num2str(real(shift)) ....
            ' ' num2str(imag(shift)) ' ' p.Results.sym ' ' p.Results.type ' ' num2str(p.Results.nev) ];
                         
        solvercommand = ['echo ' argumentstring ' | ' ff ' ' ffdir 'Stab2D_Modes3D.edp'];
        status = mysystem(solvercommand);
         end
         
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
        ncores = p.Results.ncores;
        argumentstring = [' " ' num2str(p.Results.Re) ' ' num2str(p.Results.Ma) ' ' num2str(real(shift)) ' ' num2str(imag(shift))... 
                             ' ' num2str(symmetry) ' ' num2str(typeEig) ' ' num2str(p.Results.nev) ' " '];
        solvercommand = ['echo ' argumentstring ' | ',ffMPI,' -np ',num2str(ncores),' ', 'Stab2DComp.edp'];
        status = mysystem(solvercommand);
        
    case('2DMobile')
        % for spring-mounted cylinder
             
        mydisp(1,['      ### FUNCTION SF_Stability VIV : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);
        mydisp(1,['      ### USING 2D Solver FOR MOBILE OBJECT (e.g. spring-mounted)']);
        argumentstring = [ num2str(p.Results.Re) ' ' num2str(p.Results.MASS) ' ' num2str(p.Results.STIFFNESS) ' '... 
                            num2str(p.Results.DAMPING) ' ' num2str(real(shift)) ' ' num2str(imag(shift)) ' ' p.Results.sym...
                            ' ' p.Results.type ' ' num2str(p.Results.nev) ]; 
        solvercommand = ['echo ' argumenstring ' | ' ff ' ' ffdir 'Stab2D_VIV.edp'];
        status = mysystem(solvercommand);
        
     case('3DFreeSurfaceStatic')
        % for oscillations of a free-surface problem (liquid bridge, hanging drops/attached bubbles, etc...)             
        if(p.Results.nu==0)
        mydisp(1,['      ### FUNCTION SF_Stability FREE SURFACE POTENTIAL : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);
        argumentstring = [' " ' num2str(p.Results.gamma) ' ' num2str(p.Results.rhog) ' ' num2str(p.Results.m) ' ' num2str(p.Results.nev)  ' ' num2str(imag(p.Results.shift)) ' " '];
        solvercommand = ['echo ' argumentstring ' | ' ff ' ' ffdir 'StabAxi_FreeSurface_Potential.edp'];
        status = mysystem(solvercommand);     
        else
        mydisp(1,['      ### FUNCTION SF_Stability FREE SURFACE VISCOUS : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);
        argumentstring = [' " ' num2str(p.Results.gamma) ' ' num2str(p.Results.rhog) ' ' num2str(p.Results.nu) ...
            ' ' num2str(p.Results.m) ' ' num2str(real(p.Results.shift)) ' ' num2str(imag(p.Results.shift)) ' ' num2str(p.Results.nev) ' " '];
        solvercommand = ['echo ' argumentstring ' | ' ff ' ' ffdir 'StabAxi_FreeSurface_Viscous.edp'];
        status = mysystem(solvercommand);  
        end
        
    %case(...)    
    % adapt to your case !
    
    case default
        error(['Error in SF_Stability : "problemtype =',ffmesh.problemtype,'  not possible or not yet implemented !'])
end
    

if(status~=0&&status~=141) 
     %result 
     error('ERROR : FreeFem stability computation aborted');
 else
   % disp(['FreeFem : FreeFem stability computed for Re = ' num2str(p.Results.Re), ' ; m = '  num2str(p.Results.m) ' shift = ' num2str(shift) ])
  %
end



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
mycp([ffdatadir 'Eigenmode.txt'],[ffdatadir 'Eigenmode_guess.txt']);  
else
sigmaPrevPrev = eigenvalues(1);
sigmaPrev = eigenvalues(1); 
end

    if(nargout>1) %% process output of eigenmodes
    if(p.Results.nev==1)
        if (p.Results.type=='D')
        eigenvectors=importFFdata(ffmesh,'Eigenmode.ff2m');
        eigenvectors.type=p.Results.type;
         disp(['      # Stability calculation completed, eigenvalue = ',num2str(eigenvalues),' ; converged in ', num2str(eigenvectors.iter),' iterations']);
        elseif(p.Results.type=='A')
        eigenvectors=importFFdata(ffmesh,'EigenmodeA.ff2m');
        eigenvectors.type=p.Results.type;
         disp(['      # Stability calculation completed (ADJOINT), eigenvalue = ',num2str(eigenvalues),' ; converged in ', num2str(eigenvectors.iter),' iterations']);
        elseif(p.Results.type=='S')
        eigenvectors=importFFdata(ffmesh,'Eigenmode.ff2m','EigenmodeA.ff2m','Sensitivity.ff2m');
        eigenvectors.type=p.Results.type;
         disp(['      # Stability calculation completed (DIRECT+ADJOINT+SENSITIVITY), eigenvalue = ',num2str(eigenvalues),' ; converged in ', num2str(eigenvectors.iter),' iterations']);
        end
        if(eigenvectors.iter<0) 
            error(['ERROR : simple shift-invert iteration failed ; use a better shift of use multiple mode iteration (nev>1)']);
        end   
    elseif(p.Results.nev>1&&p.Results.type=='D')
    eigenvectors=[];
        for iev = 1:p.Results.nev
        egv=importFFdata(ffmesh,['Eigenmode' num2str(iev) '.ff2m']);
        egv.type=p.Results.type;
        eigenvectors = [eigenvectors egv];
        end
        eigenvectors=eigenvectors(o);%sort the eigenvectors with the same filter as the eigenvalues
    elseif(p.Results.nev>1&&p.Results.type=='A')
    eigenvectors=[];
    for iev = 1:p.Results.nev
        egv=importFFdata(ffmesh,['EigenmodeA' num2str(iev) '.ff2m']);
        egv.type=p.Results.type;
        eigenvectors = [eigenvectors egv];
    end
    eigenvectors=eigenvectors(o);%sort the eigenvectors with the same filter as the eigenvalues
    else
        error('ERROR : wrong value for mode type / mode number nev');
    end
    
    end
    
    % FINALLY : plot the spectrum in figure 100
    
    if(strcmp(p.Results.PlotSpectrum,'yes')==1)
        figure(100);
        %%mycmp = [[0 0 0];[1 0 1] ;[0 1 1]; [1 1 0]; [1 0 0];[0 1 0];[0 0 1]]; %color codes for symbols
        h=plot(real(shift),imag(shift),'o');hold on;
        for ind = 1:length(eigenvalues)
            h=plot(real(eigenvalues(ind)),imag(eigenvalues(ind)),'*');hold on;
            %%%%  plotting command for eigenmodes and callback function
            tt=['eigenmodeP= importFFdata(baseflow.mesh, ''' ffdatadir '/Eigenmode' num2str(ind) '.ff2m''); ' ... 
      'eigenmodeP.plottitle =''Eigenmode for sigma = ', num2str(real(eigenvalues(ind))) ...
      ' + 1i * ' num2str(imag(eigenvalues(ind))) ' '' ; figure();plotFF(eigenmodeP,''' p.Results.PlotSpectrumField '''); '  ]; 
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

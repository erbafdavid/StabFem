function [eigenvalues,eigenvectors] = SF_Stability(baseflow,varargin)

% Matlab/FreeFem driver for Base flow calculation (Newton iteration)
%
% usage : [eigenvectors] = SF_Stability(baseflow [,param1,value1] [,param2,value2] [...])
% Parameters include :
% Re : Reynolds number (specify only if it differs from the base flow, which is not usual)
% m : azimuthal wavenumer (for axisymmetric problem)
% k : transverse wavenumber (for 3D stability of 2D flow, to be implemented)
% sym : symmetry condition for a 2D problem (set to 'S' for symmetric, 'A' for antisymmetric, or 'N' if no symmetry plane is present)
% shift : for shift-invert (complex), 
% nev : number of eigenvalues
% type : 'D' for direct problem ; 'A' for ajoint problem ; 'DA' for discrete adjoint 
%
% the solver will use Arnoldi method if nev>1 and shift-invert if nev=1
% output :  eigenvector(s) (structures)
% with two outputs, the second Spectrum is the set of eigenvalues
%
% Version 2.0 by D. Fabre , june 2017
%

global ff ffdir ffdatadir sfdir verbosity

persistent sigmaPrev sigmaPrevPrev


%%% management of optionnal parameters
    p = inputParser;
  %paramaters for axisymmetric case
   addParameter(p,'m',1,@isnumeric);
  %parameters for 2D case (to be implemented...)
   addParameter(p,'k',1,@isnumeric);
   addParameter(p,'sym','A',@ischar);
   %parameters for the eigenvalue solver
   addParameter(p,'shift',1+1i);
   addParameter(p,'nev',1,@isnumeric);
   addParameter(p,'type','D',@ischar); 
   addParameter(p,'Re',baseflow.Re,@isnumeric);
   addParameter(p,'PlotSpectrum','no',@ischar); 
   
   addParameter(p,'STIFFNESS',0);
   addParameter(p,'MASS',0);
   addParameter(p,'DAMPING',0);
   
   parse(p,varargin{:});
   if(isempty(sigmaPrev))   sigmaPrev = p.Results.shift; sigmaPrevPrev = p.Results.shift; end;
   
   if(strcmp(p.Results.shift,'prev')==1)
       shift = sigmaPrev;       
       if(verbosity>1) disp(['   # SHIFT from previous computation = ' num2str(shift)]); end
   elseif(strcmp(p.Results.shift,'cont')==1)      
       shift = 2*sigmaPrev-sigmaPrevPrev;      
       if(verbosity>1) disp(['   # SHIFT extrapolated from two previous computations = ' num2str(shift)]); end
   elseif(isnumeric(p.Results.shift)==1);
       shift = p.Results.shift;
        if(verbosity>1) disp(['   # SHIFT specified by user = ' num2str(shift)]); end
   else disp('   # ERROR in SF_Stabilty while specifying the shift') 
   end
 
% run the relevant freefem script
if(strcmp(baseflow.mesh.problemtype,'AxiXR')==1)
    
     if(verbosity>0)disp(['      ### FUNCTION SF_Stability : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);end
     if(verbosity>0)disp(['      ### USING Axisymmetric Solver']);end
     solvercommand = ['echo '' ' num2str(p.Results.Re) ' '  num2str(real(shift)) ' ' num2str(imag(shift))... 
                             ' ' num2str(p.Results.m) ' ' p.Results.type ' ' num2str(p.Results.nev) ' '' | ' ff ' ' ffdir 'Stab_Axi.edp'];
        status = mysystem(solvercommand);
        
        
elseif(strcmp(baseflow.mesh.problemtype,'AxiXRPOROUS')==1)
    
     if(verbosity>0)disp(['      ### FUNCTION SF_Stability POROUS : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);end
     if(verbosity>0)disp(['      ### USING Axisymmetric Solver WITH POROSITY AND SWIRL']);end
     solvercommand = ['echo '' ' num2str(p.Results.Re) ' ' num2str(baseflow.Porosity) ' '  num2str(real(shift)) ' ' num2str(imag(shift))... 
                             ' ' num2str(p.Results.m) ' ' p.Results.type ' ' num2str(p.Results.nev) ' '' | ' ff ' ' ffdir 'Stab_Axi_Porous.edp'];
        status = mysystem(solvercommand);        
    
 
   

elseif(strcmp(baseflow.mesh.problemtype,'2D')==1)
         % 2D flow (cylinder, etc...)
    
         
        if(verbosity>0)disp(['      ### FUNCTION SF_Stability : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);end
        if(verbosity>0)disp(['      ### USING 2D Solver']);end
        solvercommand = ['echo '' ' num2str(p.Results.Re) ' '  num2str(real(shift)) ' ' num2str(imag(shift))... 
                             ' ' p.Results.sym ' ' p.Results.type ' ' num2str(p.Results.nev) ' '' | ' ff ' ' ffdir 'Stab2D.edp'];
        status = mysystem(solvercommand);
   
  
elseif(strcmp(baseflow.mesh.problemtype,'2DMobile')==1)  % for spring-mounted cylinder
             
        if(verbosity>0)disp(['      ### FUNCTION SF_Stability VIV : computation of ' num2str(p.Results.nev) ' eigenvalues/modes (DIRECT) with FF solver']);end
        if(verbosity>0)disp(['      ### USING 2D Solver FOR MOBILE OBJECT (e.g. spring-mounted)']);end
        solvercommand = ['echo '' ' num2str(p.Results.Re) ' ' ...
                             num2str(p.Results.MASS) ' ' num2str(p.Results.STIFFNESS) ' ' num2str(p.Results.DAMPING) ' ' num2str(real(shift)) ' ' num2str(imag(shift))... 
                             ' ' p.Results.sym ' ' p.Results.type ' ' num2str(p.Results.nev) ' '' | ' ff ' ' ffdir 'Stab2D_VIV.edp'];
        status = mysystem(solvercommand);
            
%elseif(strcmp(baseflow.mesh.problemtype,keyword)==1)
    % adapt to your case !
    
end
    

if(status~=0) 
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
[t,o]=sort(-real(eigenvalues)+1e-4*imag(eigenvalues)); eigenvalues=eigenvalues(o); 

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
        eigenvectors=importFFdata(baseflow.mesh,'Eigenmode.ff2m');
        eigenvectors.type=p.Results.type;
         disp(['      # Stability calculation completed, eigenvalue = ',num2str(eigenvalues),' ; converged in ', num2str(eigenvectors.iter),' iterations']);
        elseif(p.Results.type=='A')
        eigenvectors=importFFdata(baseflow.mesh,'EigenmodeA.ff2m');
        eigenvectors.type=p.Results.type;
         disp(['      # Stability calculation completed (ADJOINT), eigenvalue = ',num2str(eigenvalues),' ; converged in ', num2str(eigenvectors.iter),' iterations']);
        elseif(p.Results.type=='S')
        eigenvectors=importFFdata(baseflow.mesh,'Eigenmode.ff2m','EigenmodeA.ff2m','Sensitivity.ff2m');
        eigenvectors.type=p.Results.type;
         disp(['      # Stability calculation completed (DIRECT+ADJOINT+SENSITIVITY), eigenvalue = ',num2str(eigenvalues),' ; converged in ', num2str(eigenvectors.iter),' iterations']);
        end
        if(eigenvectors.iter<0) 
            error([' ERROR : simple shift-invert iteration failed ; use a better shift of use multiple mode iteration (nev>1)']);
        end   
    elseif(p.Results.nev>1&&p.Results.type=='D')
    eigenvectors=[];
        for iev = 1:p.Results.nev
        egv=importFFdata(baseflow.mesh,['Eigenmode' num2str(iev) '.ff2m']);
        egv.type=p.Results.type;
        eigenvectors = [eigenvectors egv];
        end
        eigenvectors=eigenvectors(o);%sort the eigenvectors with the same filter as the eigenvalues
    elseif(p.Results.nev>1&&p.Results.type=='A')
    eigenvectors=[];
    for iev = 1:p.Results.nev
        egv=importFFdata(baseflow.mesh,['EigenmodeA' num2str(iev) '.ff2m']);
        egv.type=p.Results.type;
        eigenvectors = [eigenvectors egv];
    end
    eigenvectors=eigenvectors(o);%sort the eigenvectors with the same filter as the eigenvalues
    else
        error('ERROR');
    end
    
    end
    
    if(strcmp(p.Results.PlotSpectrum,'yes')==1)
        eigenvalues
        plot(imag(eigenvalues),real(eigenvalues),'x');
        title('Spectrum');
    end
    
end


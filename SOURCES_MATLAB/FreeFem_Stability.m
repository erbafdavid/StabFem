function [eigenvalues,eigenvector] = FreeFem_Stability(baseflow,Re,m,shift,nev,OPT1)

% Matlab/FreeFem driver for Base flow calculation (Newton iteration)
%
% usage : [eigenvalues,eigenvectors] = FreeFem_Stability(baseflow,Re,m,shift,nev,type)
% Parameters : Reynolds, wavenumber m, shift (complex), nev number of
% eigenvalues
% type is 'D' for direct problem ; 'A' for ajoint problem ; 'DA' for discrete adjoint 
%   (optional parameter ; set to 'D' if not specified)
% the solver will use Arnoldi method if nev>1 and shift-invert if nev=1
% output : eigenvalues (vector of size nev) ; eigenvector (presently only working for nev=1) 
%
% Version 2.0 by D. Fabre , june 2017
%

global ff ffdir

% management of optional parameters
if (nargin>=6)
    type = OPT1;
else
    type = 'D';
end


% run the relevant freefem script
if(strcmp(baseflow.mesh.problemtype,'AxiXR')==1)
    % Axisymmetric base flow (for sphere, whistling jet, etc..)


if ((type=='D')&&(nev==1))
    disp('FreeFem_Stability : computation of 1 eigenvalue/mode (DIRECT) with shift/invert method');
    [status]=system(['echo ' num2str(Re) ' ' num2str(m) ' ' num2str(real(shift)) ' ' num2str(imag(shift)) ... 
       '  | ' ff ' ' ffdir 'StabAxi_ShiftInvert.edp'])
elseif((type=='D')&&(nev>1)) 
    disp(['FreeFem_Stability : computation of ' num2str(nev) ' eigenvalues/modes (DIRECT) with FF solver']);
    [status]=system(['echo ' num2str(Re) ' ' num2str(m) ' '  num2str(real(shift)) ' ' num2str(imag(shift)) ' ' num2str(nev)... 
       '  | ' ff ' ' ffdir 'StabAxi.edp']);
elseif ((type=='A')&&(nev==1))
    disp('FreeFem_Stability : computation of 1 eigenvalue/mode (ADJOINT) with shift/invert method');
    [status]=system(['echo ' num2str(Re) ' ' num2str(m) ' ' num2str(real(shift)) ' ' num2str(imag(shift)) ... 
       '  | ' ff ' ' ffdir 'StabAxi_ShiftInvert_ADJ.edp']);
     system('cp Eigenmode.txt Eigenmode_guess.txt');
elseif((type=='A')&&(nev>1))
    disp(['FreeFem_Stability : computation of ' num2str(nev) ' eigenvalues/modes (ADJOINT) with FF solver']);
    [status]=system(['echo ' num2str(Re) ' ' num2str(m) ' '  num2str(real(shift)) ' ' num2str(imag(shift)) ' ' num2str(nev)... 
       '  | ' ff ' ' ffdir 'StabAxi_ADJ.edp']);
end

elseif(strcmp(baseflow.mesh.problemtype,'AxiXR')==1)
    % 2D flow (cylinder, etc...)
    % who wants to implement this ???

%elseif(strcmp(baseflow.mesh.problemtype,keyword)==1)
    % adapt to your case !
    
end
    

if(status~=0) 
     %result 
     error('ERROR : FreeFem stability computation aborted');
 else
    disp(['FreeFem : FreeFem stability computed for Re = ' num2str(Re), ' ; m = '  num2str(m) ' shift = ' num2str(shift) ])
end



if (type=='D')
    rawData1 = importdata(['./Eigenvalues.txt']);
else
    rawData1 = importdata(['./EigenvaluesA.txt']);
end
EVr = rawData1(:,1);
EVi = rawData1(:,2); 
eigenvalues = EVr+1i*EVi;


if(nargout==2) % handling output for the eigenmode(s)
    if(nev==1&&type=='D')
        eigenvector=importFFdata(baseflow.mesh,'Eigenmode.ff2m');
    elseif(nev==1&&type=='A')
        eigenvector=importFFdata(baseflow.mesh,'EigenmodeA.ff2m');
    elseif(nev>1&&type=='D')
    for iev = 1:nev
        eigenvector(iev)=importFFdata(baseflow.mesh,['Eigenmode' num2str(iev) '.ff2m']);
    end
    elseif(nev>1&&type=='D')
    for iev = 1:nev
        eigenvector(iev)=importFFdata(baseflow.mesh,['EigenmodeA' num2str(iev) '.ff2m']);
    end
    else
        error('ERROR');
    end
end

end

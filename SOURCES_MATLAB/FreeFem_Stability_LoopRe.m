function sigma_branch=FreeFem_Stability_LoopRe(baseflow,Re_Range,m,shift,nev)

% Matlab driver to compute stability curve : sigma as function of Re in a
% given range.
%
% usage : sigma_branch = FreeFem_Stability_LoopRe(baseflow,Re_range,m,shift,nev)
% Parameters : Reynolds, wavenumber m, shift (complex), nev number of
% eigenvalues
% type is 'D' for direct problem ; 'A' for ajoint problem ; 'DA' for discrete adjoint 
%   (optional parameter ; set to 'D' if not specified)
%
%  If nev > 1 the loop will use Arnoldi iteration with fixed shift 
%  If nev = 1 the loop will use shift-invert iteration with continuation for shift and eigenmode structure
%    (much more efficient for tracking one branch)
%
% Version 2.0 by D. Fabre , 2 june 2017

global ff ffdir ffdatadir

sigma_branch = [];
system('rm Eigenmode_guess.txt');

for Re = Re_Range
   
   % if(exist([ ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.txt'])==2);
   %     disp(['Re = ',num2str(Re), ' : base flow already computed']);
   %     system(['cp ' ffdatadir '/CHBASE/chbase_Re' num2str(Re) '.txt chbase.txt']);
   % else
   %     disp(['Re = ',num2str(Re), ' : computing base flow ']);
        baseflow=FreeFem_BaseFlow(baseflow,Re)
   % end
    
    EV = FreeFem_Stability(baseflow,Re,m,shift,nev);
    sigma_branch = [sigma_branch,EV];
    
    system('cat ./Eigenvalues.txt >> Branches.txt'); %% file to put everything in case of crashpor
    if (nev==1)
        if(length(sigma_branch)>1) 
            shift = 2*sigma_branch(end)-sigma_branch(end-1); % guess is interpolated using two previous values  
        else
            shift = sigma_branch(1); % guess is previous value
        end
        system('cp Eigenmode.txt Eigenmode_guess.txt'); % provides a guess for next iteration
    end
end
